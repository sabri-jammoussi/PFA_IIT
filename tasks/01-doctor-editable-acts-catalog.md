# Task 1 — Doctor: editable Medical Acts pricing catalog ✅ DONE

**Pro-Tip:** "When the doctor modifies the Medical Acts base pricing catalog, save those
changes directly to the ActeMedical table."

## Current state (before)
- `vue/src/views/MedicalActsView.vue` only **lists** acts (GET `/actes-medicaux`) with a
  mock fallback. No create / edit / delete.

## Backend contract (already exists — no backend work)
- Route base: `api/actes-medicaux`, controller-level `[Authorize(Roles = Dentiste)]`.
- GET (list/by-id): allowed to `Dentiste` + `Secretaire`.
- POST `/actes-medicaux` body `AddActeMedicalCommand { libelle*, tarifDeBase*, codeNomenclature? }` → Dentiste only.
- PUT `/actes-medicaux/{id}` body `UpdateActeMedicalCommand { id*, libelle*, tarifDeBase*, codeNomenclature? }` (URL id must equal body id) → Dentiste only.
- DELETE `/actes-medicaux/{id}` → Dentiste only.
- DTO: `{ id, libelle, tarifDeBase, codeNomenclature }`.

## Implementation
- New `vue/src/views/MedicalActDialog.vue` — add/edit dialog (matches `PatientAddDialog`
  pattern: props `visible`,`act`,`saving`; emits `save`,`close`).
- Rewrite `vue/src/views/MedicalActsView.vue`:
  - `canManage = authStore.isDentist` → gates "Nouvel acte", edit & delete (matches backend role).
  - POST/PUT/DELETE wired to `api`, with toast + mock fallback (consistent w/ `PatientsView`).
  - `ConfirmationDialog` for delete.

## Acceptance criteria
- [x] Dentiste sees "Nouvel acte" + row edit/delete; can create/update/delete persisting via API.
- [x] Non-Dentiste (Admin/Secretaire) see the catalog **read-only** (no manage controls).
- [x] PUT sends `id` in both URL and body (controller requires they match).
- [x] Falls back gracefully to local mock when API unavailable (demo-safe).
