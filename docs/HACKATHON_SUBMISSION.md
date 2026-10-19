# Hackathon submission checklist

Deadline: **19 October 2026, 11:59 PM PKT**. No commits or changes after the deadline are accepted.
Submission form: https://tally.so/r/D4rpdZ
Organizer contact: chairman@nylp.com.pk

## 1. Build artifacts

- [x] `flutter pub get`
- [x] `flutter analyze` → no issues (`flutter analyze --no-pub`)
- [x] `flutter test` → all tests pass (**194/194**)
- [x] `flutter build web --release` (demo keys compiled in via `--dart-define`)
- [x] `flutter build apk --release` → signed release APK at `releases/Voice2Law-1.2.0-release.apk` (61 MB)

Web output: `build/web/` · Android artifact: `releases/Voice2Law-1.2.0-release.apk`

Both artifacts ship with shared demo keys (Gemini + Groq) compiled in, so cloud AI is enabled by default with automatic Gemini↔Groq fallback. These demo keys are public, rate-limited and were shared in chat — rotate them and rebuild with `tool/build_demo.ps1` before any real distribution. The source tree contains no keys.

Validated locally on 19 October 2026. Running `flutter analyze --no-pub` and `flutter test --no-pub` again after any further code change is recommended; documentation-only edits do not require a rebuild.

## 2. Deploy the live demo

Pick one and keep the URL stable until judging ends.

### Option A — Netlify Drop (fastest, no CLI)
1. Open https://app.netlify.com/drop
2. Drag the entire `build/web` folder.
3. Copy the generated `https://…netlify.app` URL.
4. Test in incognito: `/#/rights-scenarios` and `/#/document-explainer` should open directly.

### Option B — Vercel
```powershell
npx vercel build/web --prod
```
(Sign in when prompted. No `vercel.json` is required; Flutter web uses hash routes.)

### Option C — GitHub Pages
```powershell
git init
git add .
git commit -m "Voice2Law — NYLP AI Hackathon 2026"
git branch -M main
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
npx gh-pages -d build/web
```
Enable Pages on the `gh-pages` branch.

> Do **not** commit `android/key.properties`, keystores, `.env`, or any API key. The demo artifacts build keys in via `--dart-define`; the demo keys are public and rate-limited, so rotate them before sharing any build beyond the hackathon.

## 3. Record the demo video

- [ ] Follow `docs/DEMO_SCRIPT.md` (2:30–3:00).
- [ ] Show the product working, not slides.
- [ ] Upload to YouTube (unlisted) or Google Drive with link sharing on.
- [ ] Confirm the link opens in an incognito window.

## 4. Finish the README

- [ ] Replace the two `TODO` links at the top with the live demo and video URLs.
- [ ] Fill in the **Team contributions** table with real names and roles.
- [x] Confirm screenshots in `shots/` match the current build. All six README images exist and were reviewed on 19 October 2026; `ai-tools.png`, `my-rights.png` and `snap-explain.png` were regenerated from the current build.
- [ ] Add the live link to the repository "About" section if using GitHub.

## 5. Written description (for the form)

Short version:

> Voice2Law is a voice-first, multilingual legal explainer for Pakistan. Citizens can ask a question by voice or text, or photograph an FIR, rent notice or court order and get a plain-language explanation of what it means and what to do next. Answers are grounded in a bundled Pakistani statute corpus with hybrid retrieval, and core rights guidance works offline. The app ships 15 practical AI tools, supports Urdu and English offline, requests Punjabi, Sindhi and Pashto answers when cloud AI is enabled (falling back to English if unavailable), and keeps conversations in memory with a one-tap calculator quick-exit for privacy. Built with Flutter; Gemini, Groq and Seena are supported through a provider abstraction with an offline fallback.

## 6. Final smoke test

Do this on the deployed URL, in incognito, on a phone-sized window:

- [x] Home loads (offline library available without a key; demo keys are compiled into the attached artifacts).
- [ ] **Ask by Text** returns an answer (cloud via demo-key fallback, or clearly labelled offline).
- [ ] **My Rights** cards expand and read correctly.
- [ ] **Snap & Explain** accepts a photo and returns an explanation (Gemini; free-tier quota may return 429 — in that case show the honest fallback, or run this check when quota resets).
- [ ] Language switch to Urdu renders Nastaliq correctly.
- [ ] Quick exit replaces the screen with the calculator.
- [ ] No "disclaimer missing" — every AI feature shows the legal-information boundary.
- [ ] Network tab shows only provider API calls (api.groq.com / generativelanguage.googleapis.com); demo keys are compiled into the artifact by design and are not secret — say so honestly in the demo if asked.

## 7. Live verification performed (19 October 2026)

- All 13 cloud-backed AI tool forms returned real answers through the compiled-in demo keys (Gemini free tier was 429 at test time; the app's automatic Groq fallback carried every request).
- Ask by Text returned a full Urdu answer through the same fallback.
- Snap & Explain vision request path is covered by mocked HTTP tests; the live Gemini vision call was blocked by the free-tier quota at test time.
- `flutter analyze --no-pub` clean; `flutter test --no-pub` 190/190.

## 8. Submit

- [ ] Product link
- [ ] Demo video link
- [ ] Written description (above)
- [ ] README link / repository link
- [ ] Team details
- [ ] Submit before **11:59 PM PKT** and keep the confirmation email.
