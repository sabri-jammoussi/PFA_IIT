# Task 3 — Admin: system configuration (SMTP / Cloudinary)

**Pro-Tip:** "Keep sensitive system parameters (SMTP credentials, Cloudinary keys) away from
daily users… simple clean forms will do."

## Current state
- Sidebar already has a "Configuration Système" entry for Admin → routes to `AdminDashboard`.
- `views/SettingsView.vue` is **user-level** (password change + local UI prefs) — NOT system config.
- **No Settings/Config DB entity exists** (only `JwtSettings.cs`, an appsettings POCO).

## Proposed implementation (largest task)
### Backend (new feature, CQRS) — **EF migration required**
1. New entity `ParametreSystemeDao` (or key/value `SettingDao { Cle, Valeur, … }`) in
   `back/Dentiste.api/Dentiste.Data/Models`, registered in `DentisteContext` + migration.
2. New feature folder `Dentiste.Core/Features/Parametres/` with:
   - `GetSystemSettingsQuery` (Admin only)
   - `UpdateSystemSettingsCommand` (Admin only)
3. New `ParametresController` `[Authorize(Roles = Admin)]`, route `api/parametres`.
4. **Never** return raw secrets to the client — mask SMTP password / Cloudinary secret
   (return `****` + a "set" boolean), only write when a new value is submitted.

### Frontend
- New `views/admin/SystemConfigView.vue` (Admin-only route + sidebar link), clean forms:
  SMTP (host, port, user, password, from) + Cloudinary (cloud name, api key, api secret).

## Decisions needed
- Store secrets in DB (encrypted?) vs keep in `appsettings`/secrets manager and only expose a
  read-only status page. **Recommendation:** for a PFA, DB-backed with masked secrets is the
  demonstrable choice, but flag that production should use a secrets vault.

## Risk
- New entity + migration + full CQRS feature + controller + new view. Largest surface.
- Security-sensitive (secret handling) — review before shipping.
