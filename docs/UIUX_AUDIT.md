# Voice2Law UI/UX Audit (2026-09-26)

Driven by two skills installed in this project:

1. **ui-ux-pro-max** — searchable design database (119 UX guidelines, 192 palettes,
   74 font pairings, 22 stacks incl. `flutter`). Cloned at
   `d:\final-fyp-main\tools\ui-ux-pro-max\`; project wrapper skill at
   `.claude\skills\ui-ux-pro-max\SKILL.md`.
2. **frontend-design** (official Anthropic skill) — `.claude\skills\frontend-design\SKILL.md`.

## What the audit checked

Canonical mobile pre-delivery checklist (`references/pro-rules.md`): text contrast
≥4.5:1 (normal text), ≥3:1 non-text UI/icons, touch targets ≥44pt/48dp, emoji-as-icon
discipline, pressed/disabled feedback, semantics for icon-only controls, consistent
semantic tokens (no ad-hoc colors).

Measured with `d:\final-fyp-main\tools\uiux_contrast_*.py` (WCAG 2.1 relative
luminance formula).

## Findings → fixes applied

| # | Finding | Was | Now | Where |
|---|---------|-----|-----|-------|
| 1 | Secondary/caption text below 4.5:1 (34 sites) | `darkGreen.withValues(alpha: 0.4–0.65)` → 3.27–4.28:1 | `AppColors.textSecondary` #4A6F64 → **5.60:1 white / 4.99:1 lightGreen** | 14 files (screens, widgets, admin) |
| 2 | Gold Urdu labels/headings on white cards | `AppColors.gold` 2.42:1 | `AppColors.goldText` #8A6A22 → **5.04:1** | about, ask_question, contact, legal_topics, more |
| 3 | Gold rating star on white | 2.42:1 | `goldText` 5.04:1 | find_lawyers |
| 4 | Emerald micro-labels 11–12.5px on white | 3.02:1 | `emeraldDeep` #15803D → **5.02:1** | contact, find_lawyers, search, text_assistant, admin_sections, legal_ux_components |
| 5 | Bottom-nav unselected labels (12px) | #7A8B84 → 3.59:1 | `navUnselected` #64756E → **4.87:1** | app_theme |
| 6 | Selected-chip label (white/darkGreen on emerald) | 3.02–4.04:1 | chip bg `emeraldDeep` + per-widget white label → **5.02:1** | theme + find_lawyers, settings, admin_sections |
| 7 | StatusChip badge text (11.5px bold on tint) | 2.67–4.01:1 | darker badge colors → **4.85–5.51:1** | brand.dart |
| 8 | Discreet-mode shield icons over the light end of gradientGreen header | gold → up to 1.25:1 | `AppColors.white` → **3.02–12.2:1** | text_assistant, voice_assistant |
| 9 | Speak button hit target <48dp (`visualDensity: compact` → 40dp) | 40dp | default **48dp** | text_assistant |
| 10 | Mic button: no pressed feedback, no disabled state, no screen-reader label | GestureDetector only | `Semantics(button, label)` + `AnimatedScale` press + `AnimatedOpacity` disabled (0.45) | voice_assistant |

Pre-existing passes (verified, unchanged): no emoji-as-icons; IconButtons have
`tooltip` (semantic name) and default 48dp targets; mic FAB is 96×96; white-on-darkGreen
12.2:1; gold-on-darkGreen 5.04:1 (app bar, dark answer panels); 19px/w800 emerald
stat numbers meet the 3:1 large-text bar.

## Known limitations / next steps

- **Dark mode**: app is light-only; checklist items for dark-mode contrast are N/A
  until a dark theme exists.
- **Fonts**: design-system search recommends **EB Garamond (headings) + Lato (body)**
  for the legal/professional mood. Not applied yet — requires bundling TTFs in
  `pubspec.yaml` and visual QA of the Urdu (Noto Nastaliq) pairing + layout overflow.
- **Manual QA still required**: 375px width, landscape, largest system text,
  reduced-motion, TalkBack pass (per `pro-rules.md` Process checklist).
- Rerun the contrast audit after any palette change: `py d:\final-fyp-main\tools\uiux_contrast_verify.py`.

## Validated

- `flutter analyze` → No issues found
- `flutter test` → all tests passed (incl. live Gemini integration test)
- `flutter build apk --release` → rebuilt after these changes
