# Task 4 — Unify all dropdowns to PrimeVue filter Selects + fix styling

**Ask:** turn all dropdowns into PrimeVue filterable dropdowns and correct their styling
to match the reference screenshots (clean light panel, search box, green-highlighted
selected option).

## Findings
- PrimeVue v4 + **Aura** preset; `Select` is globally registered as both `Select` and `Dropdown` (`main.js`).
- **Most dropdowns are already** `<Dropdown filter>`: PatientAddDialog, PatientUpdateDialog,
  AppointmentAddDialog (×3), AppointmentsView, PatientProfileView (×2).
- **Only native `<select>` left:** `SettingsView.vue` (theme + language).
- **Root cause of the dark panel in screenshot #2:** theme had no `darkModeSelector`, so Aura
  followed the OS color scheme → overlays render dark on a dark-mode OS while the app stays light.

## Implementation
1. **`vue/src/main.js`** — set `theme.options.darkModeSelector: '.app-dark'` (a class never applied)
   so PrimeVue always renders in light mode → consistent with the app.
2. **`vue/src/views/SettingsView.vue`** — replace the 2 native `<select>` with `<Dropdown filter>`
   bound to the existing `themeOptions` / `languageOptions`.
3. **`vue/src/assets/main.css`** — global (unlayered, so it wins over the `primevue` cssLayer)
   styling for `.p-select*`:
   - trigger matches app inputs (slate-50 bg, slate-200 border, rounded-lg, text-xs, sky focus ring);
   - clean overlay (rounded-xl, shadow), styled filter box;
   - selected option = emerald highlight (matches the screenshot), hover = slate-100.

## Acceptance criteria
- [x] No native `<select>` left in `src/`.
- [x] Every dropdown is a PrimeVue Select with `filter` enabled.
- [x] Overlays always render light (no OS-dark bleed-through).
- [x] Consistent slate trigger + green selected-option highlight across all dropdowns.
- [x] `npm run build` passes.
