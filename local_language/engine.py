"""Local inference only. Model downloads happen in setup_models.py, never per query."""
import io
import os
import threading
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MODELS = ROOT / "models"
TEXT_LANGUAGES = {"en", "ur", "pa", "sd", "ps"}
# Pashto needs a separately evaluated fine-tuned checkpoint. Do not advertise
# standard Whisper's language token as working recognition support.
VOICE_LANGUAGES = {"en", "ur", "pa", "sd"}


class LanguageError(ValueError):
    pass


class LocalEngine:
    def __init__(self):
        self._translator = None
        self._tokenizer = None
        self._whisper = None
        self._lock = threading.Lock()

    def capabilities(self):
        return {
            "translation_ready": (MODELS / "translation" / "model.bin").is_file(),
            "speech_ready": (MODELS / "speech" / "model.bin").is_file(),
            "text_languages": sorted(TEXT_LANGUAGES),
            "voice_languages": sorted(VOICE_LANGUAGES),
            "punjabi_output_script": "Gurmukhi",
            "quality": "experimental; review transcripts and translations",
        }

    def _load_translation(self):
        if not self.capabilities()["translation_ready"]:
            raise LanguageError("Translation model missing. Run setup_models.py on the PC.")
        if self._translator is None:
            import ctranslate2
            import sentencepiece
            folder = MODELS / "translation"
            self._tokenizer = sentencepiece.SentencePieceProcessor(model_file=str(folder / "spiece.model"))
            self._translator = ctranslate2.Translator(
                str(folder), device="cpu", compute_type="int8",
                inter_threads=1, intra_threads=min(4, os.cpu_count() or 2),
            )

    def translate(self, text, source, target):
        if source not in TEXT_LANGUAGES or target not in TEXT_LANGUAGES:
            raise LanguageError("This language is not available in this local service.")
        if not text.strip() or len(text) > 6000:
            raise LanguageError("Enter between 1 and 6,000 characters.")
        if source == target:
            return text
        with self._lock:
            self._load_translation()
            # Chunk by sentencepiece IDs without silently truncating input.
            ids = self._tokenizer.encode(text)
            chunks = [ids[i:i + 160] for i in range(0, len(ids), 160)]
            if len(chunks) > 20:
                raise LanguageError("This text is too long. Translate a shorter passage.")
            output = []
            for chunk in chunks:
                part = self._tokenizer.decode(chunk)
                tokens = self._tokenizer.encode(f"<2{target}> {part}", out_type=str) + ["</s>"]
                result = self._translator.translate_batch(
                    [tokens], beam_size=2, max_decoding_length=384,
                )[0].hypotheses[0]
                if len(result) >= 384:
                    raise LanguageError("Translation reached its length limit. Try a shorter passage.")
                decoded = self._tokenizer.decode([t for t in result if t not in {"</s>", "<pad>"}])
                if not decoded.strip():
                    raise LanguageError("No translation produced. Please edit and retry.")
                output.append(decoded.strip())
            return " ".join(output)

    def transcribe(self, audio, language):
        if language not in VOICE_LANGUAGES:
            raise LanguageError("Voice recognition for this language is not enabled. Type your text instead.")
        try:
            with wave.open(io.BytesIO(audio)) as wav:
                valid = wav.getnchannels() == 1 and wav.getsampwidth() == 2 and wav.getframerate() == 16000
                duration = wav.getnframes() / wav.getframerate()
                if not valid or not 0.25 <= duration <= 60:
                    raise LanguageError("Record 0.25–60 seconds of mono 16 kHz PCM audio.")
        except (wave.Error, EOFError) as exc:
            raise LanguageError("Invalid WAV recording.") from exc
        with self._lock:
            if not self.capabilities()["speech_ready"]:
                raise LanguageError("Speech model missing. Run setup_models.py on the PC.")
            if self._whisper is None:
                from faster_whisper import WhisperModel
                self._whisper = WhisperModel(str(MODELS / "speech"), device="cpu", compute_type="int8", cpu_threads=4)
            segments, _ = self._whisper.transcribe(
                io.BytesIO(audio), language=language, beam_size=3,
                vad_filter=True, condition_on_previous_text=False,
            )
            text = " ".join(s.text.strip() for s in segments if s.no_speech_prob < 0.6).strip()
            if not text:
                raise LanguageError("No clear speech found. Please record again or type your question.")
            return text
