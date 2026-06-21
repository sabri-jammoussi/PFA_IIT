class MyAppointment {
  final int id;
  final String? dentisteNom;
  final String dateHeure;
  final String statut;
  final String? motif;

  MyAppointment({
    required this.id,
    this.dentisteNom,
    required this.dateHeure,
    required this.statut,
    this.motif,
  });

  factory MyAppointment.fromJson(Map<String, dynamic> j) => MyAppointment(
        id: (j['id'] ?? 0) as int,
        dentisteNom: j['dentisteNom'] as String? ??
            j['dentisteNomComplet'] as String?,
        dateHeure: (j['dateHeure'] ?? j['dateDebut'] ?? '') as String,
        statut: (j['statut'] ?? j['status'] ?? '') as String,
        motif: j['motif'] as String?,
      );

  String get formattedDate {
    try {
      final d = DateTime.parse(dateHeure);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateHeure;
    }
  }
}

class MedicalRecordSummary {
  final int totalConsultations;
  final int totalTreatments;
  final String? lastVisit;

  MedicalRecordSummary({
    required this.totalConsultations,
    required this.totalTreatments,
    this.lastVisit,
  });

  factory MedicalRecordSummary.fromJson(Map<String, dynamic> j) =>
      MedicalRecordSummary(
        totalConsultations:
            (j['totalConsultations'] ?? j['consultations'] ?? 0) as int,
        totalTreatments:
            (j['totalTreatments'] ?? j['traitements'] ?? 0) as int,
        lastVisit: j['lastVisit'] as String?,
      );
}

class Availability {
  final String date;
  final List<String> slots;

  Availability({required this.date, required this.slots});

  factory Availability.fromJson(Map<String, dynamic> j) => Availability(
        date: (j['date'] ?? '') as String,
        slots: (j['slots'] as List?)?.cast<String>() ?? [],
      );
}

// ─── Extended medical record with full lists ───────────────────────────────

class PatientConsultation {
  final int id;
  final String dateConsultation;
  final String? dentisteNom;
  final String? notesObservations;
  final List<Map<String, dynamic>> soins;

  PatientConsultation({
    required this.id,
    required this.dateConsultation,
    this.dentisteNom,
    this.notesObservations,
    required this.soins,
  });

  factory PatientConsultation.fromJson(Map<String, dynamic> j) =>
      PatientConsultation(
        id: (j['id'] ?? 0) as int,
        dateConsultation:
            (j['dateConsultation'] ?? j['date'] ?? '') as String,
        dentisteNom: j['dentisteNomComplet'] as String? ??
            j['dentisteNom'] as String?,
        notesObservations: j['notesObservations'] as String?,
        soins: (j['soins'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            [],
      );

  String get formattedDate {
    try {
      final d = DateTime.parse(dateConsultation);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateConsultation;
    }
  }
}

class PatientPrescription {
  final int id;
  final String dateEmission;
  final String? dentisteNom;
  final String? traitement;

  PatientPrescription({
    required this.id,
    required this.dateEmission,
    this.dentisteNom,
    this.traitement,
  });

  factory PatientPrescription.fromJson(Map<String, dynamic> j) =>
      PatientPrescription(
        id: (j['id'] ?? 0) as int,
        dateEmission: (j['dateEmission'] ?? '') as String,
        dentisteNom: j['dentisteNomComplet'] as String? ??
            j['dentisteNom'] as String?,
        traitement: j['traitement'] as String?,
      );

  String get formattedDate {
    try {
      final d = DateTime.parse(dateEmission);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateEmission;
    }
  }
}

class PatientInvoice {
  final int id;
  final String? numeroFacture;
  final String dateEmission;
  final double montantTotal;
  final double montantPaye;
  final String? statutPaiement;

  PatientInvoice({
    required this.id,
    this.numeroFacture,
    required this.dateEmission,
    required this.montantTotal,
    required this.montantPaye,
    this.statutPaiement,
  });

  double get reste => montantTotal - montantPaye;

  factory PatientInvoice.fromJson(Map<String, dynamic> j) => PatientInvoice(
        id: (j['id'] ?? 0) as int,
        numeroFacture: j['numeroFacture'] as String?,
        dateEmission: (j['dateEmission'] ?? '') as String,
        montantTotal:
            ((j['montantTotal'] ?? 0) as num).toDouble(),
        montantPaye:
            ((j['montantPaye'] ?? 0) as num).toDouble(),
        statutPaiement: j['statutPaiement'] as String?,
      );

  String get formattedDate {
    try {
      final d = DateTime.parse(dateEmission);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dateEmission;
    }
  }
}

class FullMedicalRecord {
  final List<PatientConsultation> consultations;
  final List<PatientPrescription> prescriptions;
  final List<PatientInvoice> invoices;

  FullMedicalRecord({
    required this.consultations,
    required this.prescriptions,
    required this.invoices,
  });

  factory FullMedicalRecord.fromJson(Map<String, dynamic> j) =>
      FullMedicalRecord(
        consultations: (j['consultations'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(PatientConsultation.fromJson)
                .toList() ??
            [],
        prescriptions: (j['prescriptions'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(PatientPrescription.fromJson)
                .toList() ??
            [],
        invoices: (j['invoices'] as List?)
                ?.cast<Map<String, dynamic>>()
                .map(PatientInvoice.fromJson)
                .toList() ??
            [],
      );
}

