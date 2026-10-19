# Voice2Law — 3-minute demo script

**Goal:** show a real person getting a useful legal answer in under a minute, then show the two features that make this different from a chat wrapper.

**Before recording**
- Use a phone-sized browser window (390×844) or an Android device.
- The attached release artifacts already have demo keys compiled in (cloud AI on by default, Gemini with automatic Groq fallback). If you built from source instead, enable cloud AI in **Settings** with your own Gemini key (needed for Snap & Explain and AI expansion). Test once before recording.
- Have one clear photo of a legal document ready (a sample rent notice or FIR works best — no real personal data).
- Turn on Do Not Disturb; hide bookmarks; set the app language to English for the demo, then switch to Urdu once.
- Record at 1080p, 30 fps, with system audio muted and a voice-over.

---

## 0:00–0:20 — Hook

**Say:** *"In Pakistan, a rent notice or an FIR can decide whether a family keeps its home — but it is written in English legalese, and most people cannot afford a lawyer to read it. Voice2Law turns that document into a clear answer, in the language they actually speak."*

Show the home screen.

## 0:20–0:55 — Ask by voice

1. Tap **Ask by Voice**.
2. Ask: *"Police stopped my brother and will not let him call a lawyer. What are his rights?"*
3. Let the transcript appear and the answer load.
4. Point out: direct answer, **Article 10 / Article 13**, a 24-hour production limit, and the numbered next steps.
5. Tap the Urdu option and show the same answer in Urdu.

**Say:** *"This is grounded in the bundled Pakistani statute corpus — not free-form model memory. If the cloud is unavailable, the app falls back to the offline legal library and says so."*

## 0:55–1:20 — My Rights (offline)

1. Go back and open **My Rights**.
2. Show the five cards. Expand **Landlord Eviction Notice**.
3. Point out the rights, the next steps, the Rent Controller and the helpline.
4. Turn on airplane mode (or just say cloud is off) and repeat that the card still works.

**Say:** *"The five most common situations work with zero AI calls, zero network and zero cost. This is the part that reaches people who cannot wait for a connection."*

## 1:20–2:05 — Snap & Explain

1. Open **Snap & Explain**.
2. Tap **Choose photo** and pick the prepared document photo.
3. Tap **Explain this photo**.
4. While it loads, point out the privacy note: *"The photo is sent only when I tap Explain, and Voice2Law does not store it."*
5. Show the result: document type, plain-language meaning, key dates, what to do next, red flags.

**Say:** *"No typing. The vision model reads the document, admits what it cannot read, and turns it into an action list. This is the feature that makes the app usable for someone who cannot type English."*

## 2:05–2:30 — Multi-turn follow-up + privacy

1. Go to **Ask by Text** and ask a follow-up such as *"What if I don't have a lawyer?"*
2. Show that the answer accounts for the previous question.
3. Tap the **shield** icon (quick exit). Show the calculator replacing the screen.

**Say:** *"Context carries across turns, but every conversation lives in memory only. One tap replaces the app with a calculator and stops the microphone — important for someone in an unsafe home."*

## 2:30–3:00 — Close

Return to the **AI Legal Tools** hub and scroll once.

**Say:** *"Voice2Law ships 15 practical tools — document drafting, deadlines, case intake, scam detection, mediation and more. Urdu and English work offline; Punjabi, Sindhi and Pashto answers are available when cloud AI is enabled. Citations come from the bundled statute corpus, with a clear boundary that this is legal information, not legal advice. It is built with Flutter, runs on Android, iOS and the web, and needs no backend for the core experience."*

End on the logo and the tagline: **"Understand your rights. Choose your next step."**

---

## Fallback if the network fails during recording

- If Gemini is slow, wait up to 30 seconds; the app retries the fallback model.
- If the photo explanation fails, paste two lines of text and use the text path — the rest of the flow is unchanged.
- Never edit the recording to hide an offline/error state; showing the honest fallback is a strength.

## What to emphasize for each judging criterion

| Criterion | Moment in the demo |
|---|---|
| **Innovation (25%)** | Vision-first document reading + hybrid RAG + offline-first rights cards |
| **Impact (25%)** | Urdu/regional languages, low-end phones, no-cost offline access, privacy quick exit |
| **Feasibility (25%)** | Working build, 194 passing tests, provider fallback, no backend dependency, clear limitations |
| **Presentation (25%)** | One user story, live product, under 3 minutes, honest about what is not production-certified |
