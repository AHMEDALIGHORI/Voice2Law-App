# Voice2Law gap audit — 15 October 2026

Scope: Flutter source, configuration, platform release settings, and existing automated tests in `D:\Voice2LawApp`. This was an inspection; application code was not changed. No device microphone test, live backend audit, live Gemini request, or verification of the legal accuracy/currentness of the dataset was performed.

## Fix first

### 1. Embedded AI credential and insecure token storage — high

- `lib/core/app_config.dart:38` contains a bundled Gemini credential, which is used by default and restored by reset. Its validity was not tested.
- `lib/core/app_config.dart:83` and `:107` store the admin token and custom AI key in SharedPreferences.
- `android/app/src/main/AndroidManifest.xml:13` permits cleartext traffic, and the default backend URL uses HTTP. `ApiService` attaches the bearer token to requests when configured.
- Impact: distributed builds expose the bundled credential; HTTP backend connections can expose questions and tokens in transit.
- Next step: remove the distributed credential and rotate it if active; put shared AI credentials behind a controlled backend, use platform secure storage for device tokens, and restrict production API connections to HTTPS.

### 2. Admin authorization and session lifecycle are incomplete — high

- `lib/core/auth_controller.dart:53` restores any saved session as `role: 'admin'` without server validation.
- `lib/screens/admin/admin_panel_screen.dart:118` checks authentication but does not check `isAdmin`.
- Live login accepts the profile from `/auth/me`; failed token validation can fall through to hardcoded demo credentials.
- The 30-minute expiry is checked only during restoration, so an open session does not expire automatically. The advertised 15-minute lockout has no expiry timestamp; its counter remains locked until the controller is recreated.
- Impact: the client admin gate is unreliable. Actual access to protected server data depends on backend authorization, which was outside this audit.
- Next step: isolate demo access from production, validate the role and token on restoration, and implement timed expiry and lockout behavior.

### 3. Safety exit does not match its privacy promises — high

- `lib/widgets/legal_ux_components.dart:523` opens a dialog before taking action.
- Calculator mode pushes a new route over the assistant without stopping recording, speech playback, or an outstanding answer request. Back navigation can expose the previous conversation.
- Wipe & Exit removes routes and shows a message claiming memory and session cache were sanitized, but has no explicit wipe or request-cancellation operation. It cannot retract questions already sent to a service.
- Next step: stop microphone and TTS immediately, cancel or ignore pending work, define exactly what is cleared, and make the UI wording match that behavior.

### 4. Answer confidence and citation verification are missing — high

- `lib/services/direct_gemini_service.dart:298` assigns every parsed cloud response `confidence: 95.0`.
- Local responses also use fixed confidence values (`lib/services/local_legal_brain.dart:681`, `:745`, `:779`). Both assistant screens display percentages as confidence.
- The cloud parser accepts model-generated statutes and citations without checking them against retrieved evidence. The source models do not carry authoritative source URLs or amendment/version dates.
- Impact: users see a precise-looking score that does not measure correctness, and cannot verify the answer's source/version directly.
- Next step: remove unsupported percentages, expose retrieved evidence and source versions, and validate citations before presenting them as supported. Legal accuracy needs a separate review with qualified reviewers.

## Functional gaps

### 5. Backend voice responses discard rich answer fields — high

`lib/services/api_service.dart:154` reconstructs `AiAnswer` to fill in the transcript but only copies the basic fields. Roadmap, documents, statutes, court-mode answers, urgency, empathetic openings, and suggested helpline are dropped. With direct AI disabled, voice questions therefore lose features that the backend may have returned. Preserve all fields when supplying the transcript fallback.

### 6. Default voice AI fallback can hide its offline state — medium

`DirectGeminiService.askLegalQuestion` catches cloud failures internally and returns an offline answer. `lib/screens/voice_assistant_screen.dart:171` sets `_usedOfflineFallback` only when an exception reaches the screen, and `:351` uses that flag for the offline notice. The screen never derives that notice from `answer.offline`, so the default direct-AI path can show local guidance without the warning. Derive the indicator from the returned answer.

### 7. Urdu font configuration is misplaced — medium

`pubspec.yaml:79` nests `fonts` under `flutter_launcher_icons`, instead of under `flutter`. The UI requests `NotoNastaliqUrdu`, but Flutter does not register that bundled font from the current declaration. Move it into the Flutter section and check Urdu rendering on a device.

### 8. Follow-up questions have no conversation context — medium

`lib/screens/text_assistant_screen.dart:68` sends only the current question. `lib/services/direct_gemini_service.dart:172` constructs a single contents entry without earlier turns. A follow-up such as “What documents do I need for that?” loses the preceding case facts. Keep a bounded conversation context and provide an explicit clear-conversation action. Chat messages currently live only in widget state, so reopening the screen also starts over.

### 9. Empty lawyer results are replaced by unlabelled demo records — medium

`lib/screens/find_lawyers_screen.dart:51` replaces an empty successful API result with `ContentData.defaultLawyers`, but leaves `fromApi` true. The bundled-directory banner only appears when `_fromApi` is false. Show a real empty state, or label bundled data consistently and prevent sample profiles being mistaken for live verified contacts.

### 10. Several admin sections are still demonstrations — medium

`lib/screens/admin/sections/admin_sections.dart:496`, `:592`, and `:763` build AI review, voice monitoring, and analytics from bundled sample queries/metrics. They do not represent current service activity. Connect them to real endpoints and ensure demo data remains clearly marked. Existing public-directory/contact/admin REST features also require a backend; direct Gemini mode makes the assistant standalone, not the entire product.

## Release and validation gaps

- `android/app/build.gradle.kts` signs release builds with the debug signing configuration. Production signing is not configured.
- `test/direct_gemini_service_test.dart` makes real network calls but permits offline fallback to satisfy the nominal cloud success test. It was intentionally excluded from this run.
- The selected settings/voice test uses Flutter's mocked HTTP client and passes after two HTTP 400 responses and local fallback. It therefore does not prove cloud integration works.
- No existing dedicated tests cover admin role restoration/expiry, safety exit, rich backend voice payload preservation, or the fallback label issue above.
- Real-device Urdu recognition/TTS, permission denial/recovery, large text, accessibility, and screen-size checks still need validation.
- README and the earlier UI/UX audit describe older behavior; for example, current code includes direct Gemini and a system dark theme that the older documentation does not consistently reflect.

## Checks performed

- `flutter analyze`: passed, no issues found.
- `flutter test --no-pub test/widget_test.dart test/pakistani_law_data_test.dart test/statute_corpus_concept_map_test.dart test/standalone_ai_settings_test.dart --reporter compact`: all 25 tests passed.
- These results establish static cleanliness and the existing tested behaviors; they do not resolve the gaps above.

Recommended order: credentials and admin authorization; safety-exit behavior; answer evidence and confidence; voice payload/fallback fixes; font and conversation context; real directory/admin data; release signing and device validation.

## Implementation follow-up — 16 October 2026

The software fixes and redesign are documented in `IMPLEMENTATION_REPORT.md`. This audit is retained as the original findings record. Current setup and behavior are in `README.md`; remaining provider-account, backend, legal-review and publisher-signing dependencies are explicitly listed in the implementation report.
