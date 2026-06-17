# DentiFlow Mobile — Implementation Plan

> Flutter (iOS / Android) client for the DentiFlow dental-clinic SaaS.
> Architecture, state management, design system and reusable widgets are **copied from the xHR Mobile app**
> (`C:\Users\ayadi.afif\source\repos\xHR\Mobile`). Roles, pages and API contracts come from the **Vue frontend**
> (`C:\Users\ayadi.afif\source\repos\pfa\PFA_IIT\vue`).

---

## 0. Reference sources

| What | Where to copy from |
|---|---|
| MVVM + GetX structure, services, theming | `xHR/Mobile/lib/` |
| Design system (`HrColors`, `AppSpacing`, `HrCard`, badges…) | `xHR/Mobile/lib/core/hr_ui.dart` |
| Bottom-sheet dropdown picker | `xHR/Mobile/lib/core/dropDownSalarie/` |
| Glass bottom tab bar | `xHR/Mobile/lib/screens/widgets/liquid_glass_tab_bar.dart` |
| Sidebar / drawer (role-based) | `xHR/Mobile/lib/sideBar/drawer_widget.dart` |
| Bottom-sheet dialog form + field components | `xHR/Mobile/lib/pages/delegation/view/add_delegation_sheet.dart` |
| Cupertino time picker | `xHR/Mobile/lib/core/customTimePicker/custom_time_picker.dart` |
| HTTP client + 401 refresh, secure storage, SignalR | `xHR/Mobile/lib/core/services/`, `lib/core/storage/` |
| Roles → pages, API endpoints | `vue/src/router/index.js`, `vue/src/stores/`, `vue/src/services/api.js` |

> **Rename rule when copying:** `Hr*` → `Df*` (DentiFlow), `xHR` brand green `#00DC00` → DentiFlow brand color (see Task M2). Keep widget APIs identical so the rest of the plan stays valid.

---

## 1. Target architecture (MVVM + GetX)

Mirror the xHR `lib/` layout. Each feature is a self-contained folder with `models/ + view/ + viewmodels/ + service/`.

```
lib/
├── main.dart                       # GetMaterialApp, routes, theme, startup init
├── config/
│   └── app_config.dart             # base URL (debug/release) → http://<host>:5094/api
├── controllers/
│   └── app_controller.dart         # global: ThemeMode, Locale (GetxController)
├── core/
│   ├── constants/
│   │   ├── preferences_keys.dart
│   │   └── user_role.dart          # Role enum: admin=1, dentist=2, secretary=3, patient=4
│   ├── df_ui.dart                  # design system (copy of hr_ui.dart, rebranded)
│   ├── services/
│   │   ├── api_service.dart        # http + Authorization header + 401 handling
│   │   ├── signalr_service.dart    # /notif hub
│   │   ├── notification_service.dart
│   │   └── user_claims_service.dart# decode JWT → id, role, cabinetId, names
│   ├── storage/
│   │   └── secure_token_storage.dart  # flutter_secure_storage → denti_token
│   ├── widgets/                    # shared widgets (dropdown, button, dialogs…)
│   │   ├── df_dropdown_field.dart
│   │   ├── df_button.dart
│   │   ├── df_bottom_sheet.dart
│   │   └── df_text_field.dart
│   └── viewmodels/                 # shared VMs (e.g. patient picker)
├── pages/                          # one folder per feature (see §4)
│   ├── auth/
│   ├── dashboard/
│   ├── patients/
│   ├── appointments/
│   ├── consultation/
│   ├── billing/
│   ├── stock/
│   ├── patient_portal/
│   ├── notifications/
│   ├── profile/
│   └── settings/
├── screens/
│   ├── home_screen.dart            # PageView + glass tab bar (tabs depend on role)
│   └── widgets/
│       └── glass_tab_bar.dart      # copy of liquid_glass_tab_bar.dart
├── sidebar/
│   └── drawer_widget.dart          # role-based menu
└── translations/
    └── languages.dart              # GetX i18n (fr / en)
```

**Per-feature MVVM contract**
- **Model** — plain Dart class with `fromJson` / `toJson`.
- **Service** — static methods calling `ApiService.get/post/put/delete(endpoint)`.
- **ViewModel** — `extends GetxController`, exposes `.obs` observables (`isLoading`, `items`, `errorMessage`) and async actions.
- **View** — `StatelessWidget`/`StatefulWidget` binding via `Obx(() => …)`.

---

## 2. Roles → pages matrix (from Vue)

JWT `role` claim maps to numeric IDs. Token key in storage: **`denti_token`**. Logout = `POST /auth/logout`.

| Feature / page | Admin (1) | Dentist (2) | Secretary (3) | Patient (4) |
|---|:--:|:--:|:--:|:--:|
| Platform analytics dashboard | ~~✓~~ | | | |
| Cabinets management | ~~✓~~ | | | |
| Admin settings (SMTP / Cloudinary / Storage) | ~~✓~~ | | | |
| Dentist dashboard (today's KPIs) | | ✓ | | |
| Patient records list | | ✓ | ✓ | |
| Patient dossier (detail) | | ✓ | ✓ | |
| Consultation — FDI 32-tooth schema | | ✓ | | |
| Medical acts catalog | | ✓ | | |
| Secretaries management | | ✓ | | |
| Cabinet SMTP settings | | ✓ | | |
| Secretary dashboard (waiting room) | | | ✓ | |
| Agenda / appointment scheduling | | | ✓ | |
| Pending requests queue | | | ✓ | |
| Patient admissions (intake) | | | ✓ | |
| Billing & payments | | | ✓ | |
| Stock / inventory | | | ✓ | |
| Patient portal (my appts, record, booking) | | | | ✓ |
| Profile / Settings / Notifications / Logout | ✓ | ✓ | ✓ | ✓ |

> **Decision:** Admin is **out of scope for mobile** (SaaS back-office stays on web). Admin rows above are struck through and **Phase Adm is dropped**.

**Role landing routes** (post-login redirect): Dentist → dentist dashboard, Secretary → secretary dashboard, Patient → patient portal. *(If an admin logs in on mobile, show an "use the web console" notice.)*

**Tab bars by role** (bottom glass bar; sidebar holds the rest):
- **Dentist:** Dashboard · Patients · Consultation · Acts · Profile
- **Secretary:** Dashboard · Agenda · Requests · Billing · Profile
- **Patient:** Home · My Appointments · Book · Profile

---

## 3. API endpoints (base `http://<host>:5094/api`)

> Auth header: `Authorization: Bearer <denti_token>`. Handle `401` → clear token + go to login; `402` → subscription-expired screen.

| Group | Endpoints |
|---|---|
| Auth | `POST /auth/login`, `POST /auth/logout` |
| Users | `GET /users`, `GET /users/:id`, `POST /users`, `PUT /users/:id`, `GET /users/dentists` |
| Patients | `GET /patients`, `POST /patients`, `POST /patients/invite`, `PUT /patients/:id`, `POST /patients/:id/archive` |
| Appointments | `GET /rendezvous`, `GET /rendezvous/pending`, `POST /rendezvous`, `PUT /rendezvous/:id`, `DELETE /rendezvous/:id` |
| Patient portal | `GET /my/appointments`, `GET /my/appointments/medical-record`, `GET /my/appointments/availability`, `POST /my/appointments/request` |
| Medical acts | `GET /actes-medicaux`, `POST /actes-medicaux`, `PUT /actes-medicaux/:id` |
| Consultations | `GET /consultations`, `POST /consultations`, `PUT /consultations/:id` |
| Treatments (per tooth) | `GET /soins-effectues`, `POST /soins-effectues`, `PUT /soins-effectues/:id` |
| Prescriptions | `GET /ordonnances`, `POST /ordonnances` |
| Billing | `GET /factures`, `POST /paiements` |
| Stock | `GET /articles`, `POST /articles`, `PUT /articles/:id` |
| Cabinet settings | `GET /cabinet`, `GET /cabinet/settings/smtp`, `POST /cabinet/settings/smtp`, `POST /cabinet/subscription/reactivate` |
| Admin options | `GET/POST /options/smtp`, `GET/POST /options/cloudinary`, `GET/POST /options/storage` |
| Notifications | `GET /nf/notifications`, `GET /nf/notifications/count`, `POST /nf/notifications/seen/:id`, `POST /nf/notifications/seen` + SignalR hub `/notif` |

---

## 4. Task breakdown

Tasks are ordered by dependency. IDs are stable for tracking. Effort: **S** ≤ ½ day · **M** ≈ 1 day · **L** ≈ 2–3 days.

### Phase M — Foundation (architecture & design system)

- **M0 — Project bootstrap** *(S)*
  - Update `pubspec.yaml` deps (copy from xHR): `get`, `http`, `flutter_secure_storage`, `shared_preferences`, `signalr_netcore`, `flutter_local_notifications`, `intl`, `flutter_dotenv`, `package_info_plus`, `shimmer`, `cupertino_icons`, `flutter_localizations`.
  - Add `.env.dev` / `.env.prod` with `API_BASE_URL`.
  - Create the folder skeleton from §1.

- **M1 — Config & startup** *(S)*
  - `config/app_config.dart` — base URL from dotenv (debug vs release).
  - Rewrite `main.dart` → `GetMaterialApp` with routes, `theme/darkTheme`, translations, `initialRoute: '/splash'`; init `AppController`, `NotificationService`, `SignalRService`.

- **M2 — Design system (`df_ui.dart`)** *(M)*
  - Copy `hr_ui.dart`; rebrand `HrColors` → `DfColors`. Pick DentiFlow palette (dental blue/teal primary instead of green `#00DC00`).
  - Keep: `AppSpacing`, `AppRadius`, `DfCard`, `DfStatusBadge`, `DfPill`, `DfSectionLabel`, `DfInfoRow`, `DfSettingRow`, `showThemedSnackbar`, light()/dark() ThemeData, text theme.
  - **No dashed borders anywhere** (project UI rule).
  - Add fonts to `pubspec.yaml` (reuse SpaceGrotesk or pick one).

- **M3 — Core services** *(L)*
  - `secure_token_storage.dart` — copy; single key `denti_token`. **Decision: single-JWT model** (matches Vue) — no refresh token, **drop xHR's refresh + dedup logic**.
  - `api_service.dart` — copy; `Authorization` header, `401 → clear token + redirect login` (no refresh attempt), `402 → subscription-expired`. Strip xHR's `X-hr-Platform`/clock-sync/refresh unless needed.
  - `user_claims_service.dart` — decode JWT → `{ id, username, email, nom, prenom, role(1-4), cabinetId, cabinetName }`.
  - `notification_service.dart` + `signalr_service.dart` — copy; hub URL `/notif`.

- **M4 — Shared widgets** *(L)* — copy & rebrand from xHR:
  - `df_dropdown_field.dart` ← `employee_drop_down.dart` (generic `DfDropdownField<T>` with `DraggableScrollableSheet`, search, infinite pagination, avatar/initials).
  - `glass_tab_bar.dart` ← `liquid_glass_tab_bar.dart` (frosted bottom bar, sliding lozenge follows page scroll).
  - `drawer_widget.dart` ← xHR drawer (header w/ avatar + role-based `ListView`/`ExpansionTile`, version footer, logout w/ confirm).
  - `df_bottom_sheet.dart` ← `add_delegation_sheet.dart` pattern (drag handle, header, scrollable form, save button w/ spinner) + field components `_DateField`, `_PickerField`, `_TextField`.
  - `df_button.dart` — primary/secondary/danger buttons (56px height, radius 14) per xHR `ElevatedButtonThemeData`.
  - `df_time_picker.dart` ← `custom_time_picker.dart`; add a matching **date picker** bottom sheet for appointments.

- **M5 — App shell & routing** *(M)*
  - `home_screen.dart` — `PageView` + `glass_tab_bar`, tab set chosen by role (§2).
  - `sidebar/drawer_widget.dart` — role-based menu wired to named routes.
  - Splash screen → check token → role landing route. Route guard helper rejecting pages outside the user's role.

### Phase A — Auth (all roles)

- **A1 — Login** *(M)* — `pages/auth/`: login view (username/password), `AuthViewModel.login()` → `POST /auth/login`, store token, decode claims, redirect by role. Error snackbars. Optional biometric unlock (xHR uses `local_auth`).
- **A2 — Session & logout** *(S)* — `logout()` → `POST /auth/logout` + clear storage → login. Hydrate session on startup from secure storage. Subscription-expired screen (`402`) with reactivate action.

### Phase D — Dentist (role 2)

- **D1 — Dentist dashboard** *(M)* — today's appointments, completed count, emergencies, revenue, next patient. Source: `GET /rendezvous`, `GET /factures`.
- **D2 — Patients list + dossier** *(L)* — paginated/searchable list (`GET /patients`), add/edit via bottom-sheet form (`POST/PUT /patients`, `POST /patients/invite`), archive. Dossier view (`PatientProfileView` equivalent) aggregating consultations, treatments, prescriptions, invoices.
- **D3 — Consultation / FDI tooth schema** *(L)* — 32-tooth diagram (teeth 11-18, 21-28, 31-38, 41-48), 5 faces (O/V/L/M/D). **Decision: port the tooth numbering + face mapping from web `ConsultationView.vue`** for parity with the web app. Record treatment per tooth (`POST /soins-effectues`), create consultation (`POST /consultations`), prescriptions (`POST /ordonnances`). *Most complex screen — budget extra.*
- **D4 — Medical acts catalog** *(M)* — list + add/edit acts with tariff (`GET/POST/PUT /actes-medicaux`).
- **D5 — Secretaries management** *(M)* — list/add/edit staff for the clinic (`GET /users?role=3`, `POST /users`, `PUT /users/:id`).
- **D6 — Cabinet SMTP settings** *(S)* — form (`GET/POST /cabinet/settings/smtp`).

### Phase S — Secretary (role 3)

- **S1 — Secretary dashboard** *(M)* — waiting room + pending requests overview + quick actions.
- **S2 — Agenda / scheduling** *(L)* — calendar by date range (`GET /rendezvous`), create/cancel slots via bottom-sheet form using `df_dropdown_field` (patient, dentist) + date/time pickers (`POST /rendezvous`, `DELETE /rendezvous/:id`).
- **S3 — Pending requests queue** *(M)* — `GET /rendezvous/pending`, approve & assign to dentist (`PUT /rendezvous/:id`).
- **S4 — Admissions (patient intake)** *(M)* — reuse D2 patients form for intake.
- **S5 — Billing & payments** *(M)* — invoice list (`GET /factures`), payment bottom-sheet (amount, method cash/check/card, date → `POST /paiements`).
- **S6 — Stock / inventory** *(M)* — list + add/edit/restock items (`GET/POST/PUT /articles`).

### Phase P — Patient portal (role 4)

- **P1 — Patient home** *(M)* — my appointments (`GET /my/appointments`) + medical-record summary (`GET /my/appointments/medical-record`).
- **P2 — Appointment booking** *(M)* — availability picker (`GET /my/appointments/availability`) → request (`POST /my/appointments/request`).

### ~~Phase Adm — Admin (role 1)~~ — **dropped (web-only)**

> Admin SaaS back-office (analytics, cabinets management, platform settings) stays on the web console. Not built on mobile.

### Phase X — Cross-cutting

- **X1 — Notifications** *(M)* — sidebar/list (`GET /nf/notifications`), unread badge (`/count`), mark seen, **real-time via SignalR `/notif`**, local push. ⚠️ render notification text as **plain text** (no HTML) — mirrors the web XSS fix.
- **X2 — Profile** *(S)* — view/edit name, email, username, password change (`PUT /users/:id`).
- **X3 — Settings** *(S)* — theme toggle (light/dark via `AppController`), language (fr/en), notification preferences.
- **X4 — i18n** *(M)* — `translations/languages.dart`, externalize all strings (fr default, en).
- **X5 — Empty/error/loading states** *(M)* — shimmer loaders, empty illustrations, retry on error across all lists.

---

## 5. Suggested delivery milestones

1. **Walking skeleton** — M0–M5 + A1–A2 → login works, role lands on an empty themed shell with tab bar + drawer.
2. **Dentist vertical** — D1–D3 (proves the hardest UI: dossier + FDI schema).
3. **Secretary vertical** — S1–S6 (agenda + billing).
4. **Patient portal** — P1–P2.
5. **Polish** — X1–X5.

---

## 6. Decisions locked & remaining questions

**Locked (2026-06-17):**
- ✅ **Admin out of scope** — SaaS back-office stays web-only; Phase Adm dropped.
- ✅ **Single-JWT auth** — no refresh token; `401 → logout`. Matches the Vue frontend.
- ✅ **FDI schema** — port tooth numbering + face mapping from web `ConsultationView.vue` for parity.

**Still to confirm before build:**
- **Brand palette & app name** — DentiFlow primary color (replacing xHR green `#00DC00`)? App display name / icon?
- **Offline support** — needed for clinical use, or online-only (matches web)?
