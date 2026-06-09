# DentiFlow — Role Layouts: Confirmation & Task Breakdown

> Local planning notes (this folder is git-ignored, not committed).
> Source: Gemini's review of the Doctor / Secretary / Admin layout split.

## Verdict on Gemini's plan

The **layout breakdown is sound** — role-isolated workspaces (Dentiste = clinical hub,
Secretaire = operational engine, Admin = system backstage) is the correct model.

**BUT** most of what Gemini called "the next step" already exists in this repo:

| Gemini's "build this" item            | Reality in repo                                                            |
| ------------------------------------- | -------------------------------------------------------------------------- |
| Shared master shell (`MainLayout.vue`)| ✅ Exists — `vue/src/components/MainLayout.vue`                             |
| Sidebar reads role, shows allowed tabs| ✅ Exists — `menuItems` filtered by `authStore.role` (lines 33-76)         |
| Role-based routing / redirects        | ✅ Exists — `router/index.js` `meta.roles` guard + `redirectBasedOnRole`   |
| Per-role dashboards                    | ✅ Exist — `views/{admin,dentiste,secretaire}/*Dashboard.vue`              |
| Feature views (patients, billing…)     | ✅ Exist as files                                                          |

So we do **not** rebuild the shell. The real, valuable work is Gemini's three
**"Pro-Tips"**, which are the actual gaps:

## The three real gaps (= tasks)

| # | Pro-Tip (role)        | Gap found in code                                                          | Backend ready? |
| - | --------------------- | -------------------------------------------------------------------------- | -------------- |
| 1 | Doctor: edit pricing  | `MedicalActsView.vue` is **read-only** (mock fallback, no add/edit/delete) | ✅ full CRUD   |
| 2 | Secretary: receipts   | `BillingView.vue` "Encaisser" is **local-only**; no real payment/receipt # | ⚠️ partial     |
| 3 | Admin: system config  | No SMTP/Cloudinary config page; **no Settings DB entity** at all           | ❌ none        |

## Status

- [x] **Task 1** — Editable Medical Acts catalog → `01-doctor-editable-acts-catalog.md` ✅ DONE
- [ ] **Task 2** — Real payments + sequential receipt numbers → `02-secretary-billing-and-receipts.md`
- [ ] **Task 3** — Admin system config (new entity + migration) → `03-admin-system-config.md`
- [x] **Task 4** — Unify dropdowns to PrimeVue filter Selects + style fix → `04-primevue-filter-dropdowns.md` ✅ DONE

Tasks 2 & 3 require **backend changes + EF migrations**, so they are done deliberately
(not blind), after Task 1 (pure frontend, lowest risk) lands.
