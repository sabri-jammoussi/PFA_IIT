# Task 2 — Secretary: real payments + sequential receipt numbers

**Pro-Tip:** "When the secretary marks an invoice as 'Paid', auto-generate a unique
sequential receipt number (e.g., FAC-2026-0001) for compliance."

## Current state
- `vue/src/views/BillingView.vue` `payInvoice()` only mutates local state — **no API call**.
- Backend `Factures` + `Paiements` features exist (Add/Update/Delete/GetAll/GetById).
- `FactureDto = { id, numeroFacture, dateEmission, montantTotal, montantPaye, statutPaiement, patientId, patientNomComplet }`.
- `AddFactureCommandHandler` requires caller to **supply** `NumeroFacture` and rejects duplicates —
  it does NOT auto-generate the sequential number.

## Proposed implementation
### Backend
1. Auto-generate `NumeroFacture` server-side in `AddFactureCommandHandler` when not provided:
   format `FAC-{year}-{seq:0000}`, seq = count of factures in that year + 1 (transaction-safe).
2. Add a payment endpoint flow: marking paid should create a `PaiementDao` row and update
   `Facture.MontantPaye` / `StatutPaiement` (`Payé` / `Partiel` / `Impayé`).
   - Check whether a "receipt number" should live on `PaiementDao` (e.g. `NumeroRecu = REC-{year}-{seq}`).
     If a new column is needed → **EF migration required** (`back/Dentiste.api/Dentiste.Data`).
3. Confirm `PaiementDto` / `AddPaiementCommand` shape before wiring (not yet read).

### Frontend
- `BillingView.vue`: replace local `payInvoice` with real call (record payment, refetch),
  toast shows the generated receipt/invoice number. Keep mock fallback for demo.

## Open questions
- Receipt number on the **invoice** (NumeroFacture, exists) vs a **payment receipt** (new field)?
- Partial payments: should "Encaisser" prompt for an amount, or always settle in full?

## Risk
- Touches DB schema (migration) + concurrency on sequence generation. Do carefully.
