/**
 * mockData.js
 * -----------
 * Reference dataset extracted from Vue component fallback functions.
 * These objects are NOT loaded at runtime. They are preserved here for:
 *   - Database seeding
 *   - Unit/integration testing
 *   - API contract documentation
 *
 * Endpoints used by the app:
 *   GET  /patients
 *   POST /patients
 *   PUT  /patients/:id
 *   DELETE /patients/:id
 *
 *   GET  /rendezvous?startDate=&endDate=&dentisteId=
 *   POST /rendezvous
 *   PUT  /rendezvous/:id
 *   DELETE /rendezvous/:id
 *
 *   GET  /actes-medicaux
 *   POST /actes-medicaux
 *   PUT  /actes-medicaux/:id
 *   DELETE /actes-medicaux/:id
 *
 *   GET  /soins-effectues?patientId=
 *   POST /soins-effectues
 *
 *   GET  /consultations?patientId=
 *   POST /consultations
 *
 *   GET  /ordonnances?patientId=
 *
 *   GET  /factures
 *   POST /paiements
 *
 *   GET  /users/dentists
 */

// ─── Patients ────────────────────────────────────────────────────────────────

export const mockPatients = [
  {
    id: 1,
    nom: 'Martin',
    prenom: 'Sophie',
    dateNaissance: '1988-04-12',
    telephone: '06 12 34 56 78',
    email: 'sophie.m@mail.com',
    adresse: '15 Rue de Tunis, Sfax',
    antecedentsMedicaux: 'Asthme léger, Allergie au latex',
    groupSanguin: 'A+'
  },
  {
    id: 2,
    nom: 'Lefevre',
    prenom: 'Marc',
    dateNaissance: '1975-09-24',
    telephone: '06 98 76 54 32',
    email: 'm.lefevre@mail.com',
    adresse: '42 Av Habib Bourguiba, Tunis',
    antecedentsMedicaux: 'Hypertension sous traitement',
    groupSanguin: 'O-'
  },
  {
    id: 3,
    nom: 'Ben Ali',
    prenom: 'Amine',
    dateNaissance: '1995-11-03',
    telephone: '07 55 44 33 22',
    email: 'a.benali@mail.com',
    adresse: 'Villa 54, Sousse',
    antecedentsMedicaux: 'Allergie Pénicilline',
    groupSanguin: 'B+'
  },
  {
    id: 4,
    nom: 'Durand',
    prenom: 'Luc',
    dateNaissance: '1962-07-15',
    telephone: '06 11 22 33 44',
    email: 'luc.durand@mail.com',
    adresse: '8 Rue de Tarek Ibn Ziad, Bizerte',
    antecedentsMedicaux: 'Diabète Type 2',
    groupSanguin: 'AB+'
  },
  {
    id: 5,
    nom: 'Khalifa',
    prenom: 'Sarah',
    dateNaissance: '2001-02-18',
    telephone: '07 88 99 00 11',
    email: 's.khalifa@mail.com',
    adresse: 'Cité El Ghazala, Ariana',
    antecedentsMedicaux: 'Aucun',
    groupSanguin: 'O+'
  }
]

// ─── Rendez-vous (Appointments) ───────────────────────────────────────────────
// Date fields use dynamic today-based offsets — stored as time-of-day only

export const mockAppointments = [
  {
    id: 101,
    dateHeure: 'TODAY T09:00:00',
    dureeEstimee: '00:45:00',
    statut: 'Terminé',
    motif: 'Détartrage & Polissage',
    note: 'Patient sensible aux gencives',
    patientId: 1,
    patientNomComplet: 'Mme. Sophie Martin',
    dentisteId: 1
  },
  {
    id: 102,
    dateHeure: 'TODAY T10:00:00',
    dureeEstimee: '01:00:00',
    statut: 'Terminé',
    motif: 'Pose couronne céramique',
    note: 'Ajustement dent 26',
    patientId: 2,
    patientNomComplet: 'M. Marc Lefevre',
    dentisteId: 1
  },
  {
    id: 103,
    dateHeure: 'TODAY T11:15:00',
    dureeEstimee: '00:30:00',
    statut: 'Planifié',
    motif: 'Consultation générale',
    note: 'Visite annuelle de contrôle',
    patientId: 3,
    patientNomComplet: 'Mme. Amine Ben Ali',
    dentisteId: 1
  },
  {
    id: 104,
    dateHeure: 'TODAY T14:30:00',
    dureeEstimee: '00:45:00',
    statut: 'Planifié',
    motif: 'Traitement de canal (dent 14)',
    note: 'Deuxième séance',
    patientId: 4,
    patientNomComplet: 'M. Luc Durand',
    dentisteId: 1
  },
  {
    id: 105,
    dateHeure: 'TODAY T16:00:00',
    dureeEstimee: '00:30:00',
    statut: 'Planifié',
    motif: 'Extraction dent de sagesse',
    note: 'Radio panoramique consultée',
    patientId: 5,
    patientNomComplet: 'Mme. Sarah Khalifa',
    dentisteId: 1
  }
]

// ─── Actes Médicaux ───────────────────────────────────────────────────────────

export const mockMedicalActs = [
  { id: 1, codeNomenclature: 'C',     libelle: 'Consultation générale & Diagnostic buccal',              tarifDeBase: 50.00 },
  { id: 2, codeNomenclature: 'SC12',  libelle: 'Détartrage, nettoyage prophylactique et polissage',       tarifDeBase: 80.00 },
  { id: 3, codeNomenclature: 'SC20',  libelle: 'Restauration carie composite direct (1 face)',             tarifDeBase: 90.00 },
  { id: 4, codeNomenclature: 'HB04',  libelle: 'Traitement endodontique canalaire (dent antérieure)',     tarifDeBase: 150.00 },
  { id: 5, codeNomenclature: 'HB08',  libelle: 'Traitement endodontique canalaire (dent postérieure)',    tarifDeBase: 220.00 },
  { id: 6, codeNomenclature: 'HB12',  libelle: 'Extraction dentaire simple non chirurgicale',             tarifDeBase: 100.00 },
  { id: 7, codeNomenclature: 'SPR50', libelle: 'Pose de couronne unitaire céramo-métallique',             tarifDeBase: 650.00 },
  { id: 8, codeNomenclature: 'SPR75', libelle: 'Implant dentaire titane de base (hors couronne)',         tarifDeBase: 1200.00 }
]

// ─── Soins Effectués ──────────────────────────────────────────────────────────
// (linked to patient id=1 — Sophie Martin)

export const mockSoinsEffectues = [
  {
    id: 201,
    numeroDent: 14,
    faceDentaire: 'O',
    prixApplique: 90.00,
    notes: 'Carie profonde nettoyée, obturation composite effectuée.',
    consultationDate: '2026-02-14T10:30:00',
    acteMedicalLibelle: 'Restauration Composite (1 face)'
  },
  {
    id: 202,
    numeroDent: 46,
    faceDentaire: 'V',
    prixApplique: 150.00,
    notes: 'Traitement endodontique. Obturation canalaire étanche.',
    consultationDate: '2026-03-22T09:15:00',
    acteMedicalLibelle: 'Traitement de canal (Dents antérieures)'
  },
  {
    id: 203,
    numeroDent: 11,
    faceDentaire: 'M',
    prixApplique: 50.00,
    notes: 'Polissage esthétique suite à léger éclat.',
    consultationDate: '2026-05-18T14:00:00',
    acteMedicalLibelle: 'Consultation de contrôle'
  }
]

// ─── Ordonnances ──────────────────────────────────────────────────────────────

export const mockOrdonnances = [
  {
    id: 1,
    dateEmission: '2026-03-22T09:15:00',
    traitement: 'Amoxicilline 500mg (1g x2/jour pendant 5 jours) + Paracétamol 1g (si douleur, max 3g/jour)',
    patientNomComplet: 'Sophie Martin'
  }
]

// ─── Factures ─────────────────────────────────────────────────────────────────

export const mockFactures = [
  { id: 401, numeroFacture: 'FAC-2026-001', dateEmission: '2026-02-14', montantTotal: 90.00,  montantPaye: 90.00,  statutPaiement: 'Payé',    patientNomComplet: 'Sophie Martin' },
  { id: 402, numeroFacture: 'FAC-2026-002', dateEmission: '2026-03-22', montantTotal: 150.00, montantPaye: 50.00,  statutPaiement: 'Partiel', patientNomComplet: 'Luc Durand' },
  { id: 403, numeroFacture: 'FAC-2026-003', dateEmission: '2026-05-18', montantTotal: 80.00,  montantPaye: 0.00,   statutPaiement: 'Impayé',  patientNomComplet: 'Marc Lefevre' },
  { id: 404, numeroFacture: 'FAC-2026-004', dateEmission: '2026-06-05', montantTotal: 650.00, montantPaye: 650.00, statutPaiement: 'Payé',    patientNomComplet: 'Amine Ben Ali' }
]
