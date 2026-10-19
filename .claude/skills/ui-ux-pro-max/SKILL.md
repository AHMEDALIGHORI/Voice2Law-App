---
name: ui-ux-pro-max
description: Searchable UI/UX design intelligence (styles, palettes, font pairings, UX guidelines, icons, charts, stack-specific rules incl. Flutter) for designing, reviewing, or fixing Voice2Law interfaces. Use when making visual/interaction/accessibility decisions for the Flutter app or React website.
---

# UI/UX Pro Max (project wrapper)

This workspace ships the full **ui-ux-pro-max-skill** data set locally at:

```
d:\final-fyp-main\tools\ui-ux-pro-max\.claude\skills\ui-ux-pro-max\
├── SKILL.md              # the authoritative skill workflow
├── data\                 # styles, products/palettes, typography, ux-guidelines, icons, charts, stacks/flutter.csv ...
├── references\pro-rules.md       # canonical mobile-app pre-delivery checklist (iOS/Android/RN/Flutter)
├── references\quick-reference.md # §1-§3 CRITICAL/HIGH rules
└── scripts\search.py     # the search engine (requires Python: use `py`)
```

## When this skill is invoked

1. Read `tools\ui-ux-pro-max\.claude\skills\ui-ux-pro-max\SKILL.md` first and follow its 4-step workflow, substituting `python` with `py` on this machine.
2. Search from the skill folder, e.g.:

```powershell
cd d:\final-fyp-main\tools\ui-ux-pro-max\.claude\skills\ui-ux-pro-max
py scripts\search.py "legal justice law citizen rights trust" --design-system -p "Voice2Law" -f markdown
py scripts\search.py "inline validation error clarity focus" --domain ux -n 5
py scripts\search.py "touch targets safe area navigation" --stack flutter -n 5
```

3. Stack flags available: `flutter` (Voice2LawApp), `react` / `nextjs` / `html-tailwind` / `shadcn` (website).
4. **Before delivering any Flutter UI**, run through `references\pro-rules.md` "Pre-Delivery Checklist (canonical)" — icons, touch targets ≥44pt/48dp, contrast ≥4.5:1 text / ≥3:1 non-text, safe areas, semantics, reduced motion.

## Project conventions (Voice2Law)

- Design tokens live in `D:\Voice2LawApp\lib\theme\app_theme.dart` (`AppColors`, `AppText`, `AppTheme`).
- Use the **semantic accessibility tokens** added by the 2026-09 UI/UX audit — never reintroduce translucent text:
  - `AppColors.textSecondary` (#4A6F64, 5.60:1 on white) instead of `darkGreen.withValues(alpha: <0.7)`
  - `AppColors.goldText` (#8A6A22, 5.04:1) for gold **text on light surfaces**; `AppColors.gold` only on dark backgrounds (darkGreen app bar / panels)
  - `AppColors.emeraldText` / `AppColors.emeraldDeep` (#15803D, 5.02:1) for emerald text and selected-chip backgrounds (white label)
  - `AppColors.navUnselected` (#64756E, 4.87:1) for inactive nav labels
- Contrast audit scripts: `d:\final-fyp-main\tools\uiux_contrast_*.py` (run with `py`).
- Full audit record: `D:\Voice2LawApp\docs\UIUX_AUDIT.md`.
