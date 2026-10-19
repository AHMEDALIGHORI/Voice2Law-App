# Requirements Document

## Introduction

Voice2Law is a Flutter-based legal information app for Pakistan. It uses speech recognition, text-to-speech (TTS), and an AI assistant (Gemini) to answer legal questions. The app currently has partial Urdu support: the Noto Nastaliq Urdu font is bundled, the AI backend returns dual-language JSON (English + Urdu fields), and the TTS service probes for an `ur-PK` voice at startup.

This feature completes that foundation by ensuring that Urdu-language input and output work end-to-end across the voice assistant, text assistant, and settings screens — including speech recognition in Urdu, TTS playback of Urdu answers, correct right-to-left (RTL) text rendering, user-visible language switching, and graceful degradation when the device lacks an Urdu voice or recogniser. It also strengthens offline resilience so the app continues to deliver full legal guidance when the Gemini API is unavailable.

## Glossary

- **App**: The Voice2Law Flutter application.
- **Language_Switcher**: The in-app control that lets the user choose between English and Urdu as the active interface language.
- **STT_Engine**: The device speech-to-text engine, accessed through the `speech_to_text` Flutter plugin.
- **TTS_Engine**: The device text-to-speech engine, accessed through the `flutter_tts` Flutter plugin.
- **Urdu_Locale**: The BCP-47 locale tag `ur-PK`, or the fallback tags `ur` and `ur-IN`, used to configure the STT_Engine and TTS_Engine.
- **AI_Response**: The JSON object returned by Gemini or the LocalLegalBrain, which contains parallel English and Urdu text fields (e.g., `answer` / `answerUrdu`, `empatheticOpening` / `empatheticOpeningUrdu`).
- **Urdu_Field**: Any text field in an AI_Response whose key ends with `Urdu` (e.g., `answerUrdu`, `courtModeAnswerUrdu`, `titleUrdu`).
- **RTL_Layout**: A widget layout configured for right-to-left text direction, required for Urdu script.
- **NotoNastaliqUrdu**: The Noto Nastaliq Urdu font family bundled in `assets/fonts/`, used for rendering Urdu script.
- **SpeechService**: The `lib/services/speech_service.dart` singleton that wraps the STT_Engine and TTS_Engine.
- **AppConfig**: The `lib/core/app_config.dart` singleton that persists user preferences, including `sttLocale` and `ttsEnabled`.
- **LanguagePreference**: The user-facing language setting stored in AppConfig (values: `'en'` for English, `'ur'` for Urdu, `'auto'` for device default).
- **LocalLegalBrain**: The `lib/services/local_legal_brain.dart` offline answering engine, backed by 1,507 bundled statute sections and curated knowledge items for Pakistani law domains.
- **DirectGeminiService**: The `lib/services/direct_gemini_service.dart` service that calls the Gemini REST API directly from the device and falls back to LocalLegalBrain on failure.
- **OfflineMode**: The App state in which all answers are served by LocalLegalBrain because the Gemini API is unreachable, has returned an error, or has no API key configured.
- **OfflineBanner**: A persistent non-dismissible UI element displayed during OfflineMode that informs the user the live AI is unavailable and answers are from the bundled legal library.
- **RetryPolicy**: The sequence of attempts the App makes before entering OfflineMode: primary Gemini model → fallback Gemini model → LocalLegalBrain.

---

## Requirements

### Requirement 1: Language Selection

**User Story:** As a user, I want to choose Urdu or English as my preferred language, so that the app communicates with me in my language throughout every screen.

#### Acceptance Criteria

1. THE App SHALL persist a LanguagePreference value of `'en'`, `'ur'`, or `'auto'` across app restarts using AppConfig.
2. IF AppConfig cannot be read at startup, THEN THE App SHALL default LanguagePreference to `'en'`.
3. THE Language_Switcher SHALL be rendered as an interactable control on the Settings screen and on the Voice and Text assistant screens.
4. WHEN the user sets LanguagePreference to `'ur'`, THE App SHALL display all UI labels, prompts, placeholder text, and status messages in Urdu and apply a right-to-left layout direction.
5. WHEN the user sets LanguagePreference to `'en'`, THE App SHALL display all UI labels, prompts, placeholder text, and status messages in English and apply a left-to-right layout direction.
6. WHEN the user sets LanguagePreference to `'auto'`, THE App SHALL select `'ur'` if the device locale uses the BCP-47 language tag `ur`, and `'en'` for all other device locales.
7. WHEN the user changes LanguagePreference, THE App SHALL apply the new language and layout direction without requiring an app restart.

---

### Requirement 2: Urdu Speech Recognition

**User Story:** As a user, I want to speak my legal question in Urdu, so that the app can understand me without requiring me to type.

#### Acceptance Criteria

1. WHEN LanguagePreference is `'ur'`, THE SpeechService SHALL configure the STT_Engine with the Urdu_Locale before starting a recording session.
2. WHEN a recording session starts and LanguagePreference is `'auto'`, IF the STT_Engine reports Urdu_Locale as available, THEN THE SpeechService SHALL set the active recognition locale to Urdu_Locale for that session.
3. IF the STT_Engine does not support the Urdu_Locale, THEN THE App SHALL display a message in the active language informing the user that Urdu speech recognition is unavailable.
4. IF the STT_Engine does not support the Urdu_Locale, THEN THE App SHALL make the manual text input field available as an alternative to voice input.
5. WHEN the STT_Engine emits a partial transcript result for Urdu speech, THE App SHALL display the partial transcript in the NotoNastaliqUrdu font with RTL_Layout within 500 milliseconds of receiving the partial result.
6. WHEN the STT_Engine emits a final transcript result for Urdu speech, THE App SHALL replace the partial transcript display with the final transcript in the NotoNastaliqUrdu font with RTL_Layout.
7. IF LanguagePreference is `'en'`, THEN THE SpeechService SHALL use the `en-US` locale for speech recognition.

---

### Requirement 3: Urdu Text-to-Speech Playback

**User Story:** As a user, I want the app to read Urdu answers aloud in Urdu, so that I can listen to the response without reading.

#### Acceptance Criteria

1. WHEN TTS playback is triggered for an AI_Response and LanguagePreference is `'ur'`, THE TTS_Engine SHALL be configured with the `ur-PK` locale before speaking.
2. WHEN TTS playback is triggered for an AI_Response and LanguagePreference is `'en'`, THE TTS_Engine SHALL use the `en-US` locale.
3. IF the TTS_Engine does not have the required locale voice installed, THEN THE App SHALL display a message prompting the user to install the required TTS voice and SHALL NOT attempt silent playback.
4. WHEN the text to be spoken contains Urdu script characters (Unicode range U+0600–U+06FF), THE TTS_Engine SHALL automatically select the `ur-PK` locale regardless of the current LanguagePreference.
5. WHILE TTS playback is active, THE App SHALL display a visual indicator showing that audio is playing.
6. WHEN TTS playback completes or is stopped by the user, THE App SHALL remove the visual playing indicator.
7. WHEN TTS playback is active, THE App SHALL display a control that allows the user to stop playback.

---

### Requirement 4: Urdu Answer Rendering

**User Story:** As a user, I want to read AI-generated legal answers in Urdu script, so that I can understand the response in my preferred language.

#### Acceptance Criteria

1. WHEN LanguagePreference is `'ur'`, THE App SHALL render Urdu_Fields from the AI_Response as the sole answer text displayed to the user.
2. WHEN LanguagePreference is `'en'`, THE App SHALL render the English fields from the AI_Response as the sole answer text displayed to the user.
3. WHEN an Urdu_Field is rendered, THE App SHALL apply the NotoNastaliqUrdu font family and set the text direction to `TextDirection.rtl` so that alignment, punctuation, and line breaks conform to Urdu script conventions.
4. IF an AI_Response is received and an Urdu_Field is null, an empty string, or contains only whitespace, THEN THE App SHALL render the corresponding English field as the answer text and SHALL display a non-dismissible inline label immediately above the answer text indicating that an Urdu translation is unavailable for that field.
5. IF an AI_Response is received and both the Urdu_Field and the corresponding English field are null, empty strings, or contain only whitespace, THEN THE App SHALL display a non-dismissible inline error message in place of the answer text indicating that no answer content is available.
6. WHILE the App is in Court Mode, IF LanguagePreference is `'ur'`, THEN THE App SHALL render `courtModeAnswerUrdu` as the sole Court Mode answer text displayed to the user.
7. IF LanguagePreference is neither `'ur'` nor `'en'`, THEN THE App SHALL default to rendering English fields from the AI_Response as the answer text.

---

### Requirement 5: Procedural Roadmap and Document Checklist in Urdu

**User Story:** As a user, I want the step-by-step legal roadmap and document checklist to be shown in Urdu, so that I can follow the procedure in my own language.

#### Acceptance Criteria

1. WHEN LanguagePreference is `'ur'` and an AI_Response contains `roadmap` steps, THE App SHALL display `titleUrdu` and `descriptionUrdu` for each step in place of the English equivalents.
2. WHEN LanguagePreference is `'ur'` and an AI_Response contains a `documents` list, THE App SHALL display `nameUrdu` and `notesUrdu` for each document.
3. WHEN LanguagePreference is `'ur'` and an AI_Response contains `statutes`, THE App SHALL display `actNameUrdu` and `citationUrdu` for each statute.
4. WHEN any Urdu text field from `roadmap` steps, `documents`, or `statutes` is rendered, THE App SHALL apply the NotoNastaliqUrdu font and right-to-left text direction with right-aligned text to that text widget.
5. IF a Urdu field in a `roadmap` step, `documents` item, or `statutes` item is null or has a length of zero characters, THEN THE App SHALL display the corresponding English field for that individual field in its place.

---

### Requirement 6: Settings Screen — Language and Voice Preferences

**User Story:** As a user, I want clear language and voice controls in Settings, so that I can configure Urdu input and output to match my device capabilities.

#### Acceptance Criteria

1. THE Settings screen SHALL display a LanguagePreference control with options for English, Urdu, and Device Default.
2. WHEN the user selects the Urdu option in the LanguagePreference control, THE App SHALL set the STT recognition locale to Urdu_Locale and the TTS locale to Urdu_Locale before the user navigates away from the Settings screen.
3. IF the TTS_Engine does not have an Urdu voice installed, THEN THE Settings screen SHALL display a warning indicating that Urdu read-aloud is unavailable on this device, and this warning SHALL be visible only while the Urdu option is selected in the LanguagePreference control.
4. IF the STT_Engine does not list Urdu_Locale in its available locales, THEN THE Settings screen SHALL display a warning indicating that Urdu speech input is unavailable on this device, and this warning SHALL be visible only while the Urdu option is selected in the LanguagePreference control.
5. WHEN the Settings screen opens, THE Settings screen SHALL display the TTS voice locale most recently detected from the TTS_Engine.
6. WHEN the user selects the Device Default option in the LanguagePreference control, THE App SHALL set the STT recognition locale and the TTS locale to the locale reported by the device system settings before the user navigates away from the Settings screen.

---

### Requirement 7: Graceful Degradation on Web Platform

**User Story:** As a user accessing Voice2Law from a browser, I want the app to handle limited Urdu voice support gracefully, so that the core experience still works even without native Urdu TTS.

#### Acceptance Criteria

1. WHILE running on the web platform, THE TTS_Engine SHALL use the `en-US` locale for spoken audio output regardless of LanguagePreference.
2. WHILE running on the web platform and LanguagePreference is `'ur'`, THE App SHALL display Urdu text answers using the NotoNastaliqUrdu font with right-to-left text direction.
3. WHEN the App detects it is running on the web platform and LanguagePreference is `'ur'`, THE App SHALL display an informational message that spoken Urdu playback may not be available in the browser.
4. WHEN the App detects it is running on the web platform and LanguagePreference is `'ur'`, THE App SHALL display the Urdu text answer as the primary content.
5. IF the browser speech API does not support the Urdu_Locale, THEN THE App SHALL remain responsive to user input and continue to function without crashing.
6. IF the browser speech API does not support the Urdu_Locale, THEN THE App SHALL display the manual text input field in a visible and enabled state as an alternative to voice input.

---

### Requirement 8: Gemini API Failure — Offline Resilience

**User Story:** As a user, I want the app to keep answering my legal questions even when the Gemini AI is down or unreachable, so that I always get useful guidance regardless of my internet connection or API availability.

#### Acceptance Criteria

1. WHEN the primary Gemini model returns an HTTP error or times out, THE DirectGeminiService SHALL automatically retry the same question against the fallback Gemini model before entering OfflineMode.
2. WHEN both the primary and fallback Gemini models fail, THE App SHALL serve the answer using LocalLegalBrain without requiring any action from the user.
3. WHEN the App enters OfflineMode, THE App SHALL display the OfflineBanner on the Voice assistant screen and the Text assistant screen for the duration of that session.
4. THE OfflineBanner SHALL state clearly in both English and Urdu that answers are coming from the bundled legal library and have not been verified against the latest law.
5. WHEN the App is in OfflineMode and LanguagePreference is `'ur'`, THE OfflineBanner SHALL be displayed using the NotoNastaliqUrdu font with right-to-left text direction.
6. IF the App has no Gemini API key configured, THEN THE App SHALL enter OfflineMode immediately at startup without attempting any network request to the Gemini API.
7. IF the App is in OfflineMode and the user submits a question that LocalLegalBrain cannot match with confidence ≥ 70, THEN THE App SHALL display the generic bundled guidance answer and SHALL NOT display a blank or empty response.
8. WHEN the App returns a LocalLegalBrain answer, THE AiAnswer SHALL have `offline = true` and THE App SHALL NOT display that answer as if it were a live Gemini response.
9. WHEN the App is in OfflineMode and the user navigates to Settings, THE Settings screen SHALL display the current AI source as "Bundled Legal Library" and SHALL display the last known Gemini API status (success, HTTP error code, or timeout) if one was recorded in the current session.
10. WHEN network connectivity is restored and the user submits a new question, THE DirectGeminiService SHALL attempt the Gemini API again rather than staying in OfflineMode permanently.
