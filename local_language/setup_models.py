"""One-time public downloads. No accounts, API keys or payment required."""
import os
os.environ["HF_HUB_DISABLE_TELEMETRY"] = "1"
os.environ["HF_HUB_DISABLE_XET"] = "1"
from huggingface_hub import snapshot_download
from engine import MODELS

if __name__ == "__main__":
    snapshot_download(
        "Nextcloud-AI/madlad400-3b-mt-ct2-int8",
        revision="aa32bbdeba7880eff2096ec044cb155a340a9400",
        local_dir=MODELS / "translation",
        allow_patterns=["model.bin", "config.json", "shared_vocabulary.json", "spiece.model", "README.md"],
        max_workers=2,
    )
    snapshot_download(
        "Systran/faster-whisper-small",
        local_dir=MODELS / "speech",
        allow_patterns=["model.bin", "config.json", "tokenizer.json", "vocabulary.json", "preprocessor_config.json", "README.md"],
        max_workers=2,
    )
    print("Models installed. Run start.ps1; inference can now run without internet.")
