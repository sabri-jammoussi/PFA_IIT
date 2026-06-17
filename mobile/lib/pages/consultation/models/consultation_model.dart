class Consultation {
  final int id;
  final int patientId;
  final int dentisteId;
  final String dateConsultation;
  final String? notes;
  final String? diagnose;

  Consultation({
    required this.id,
    required this.patientId,
    required this.dentisteId,
    required this.dateConsultation,
    this.notes,
    this.diagnose,
  });

  factory Consultation.fromJson(Map<String, dynamic> j) => Consultation(
        id: (j['id'] ?? 0) as int,
        patientId: (j['patientId'] ?? 0) as int,
        dentisteId: (j['dentisteId'] ?? 0) as int,
        dateConsultation: (j['dateConsultation'] ?? j['date'] ?? '') as String,
        notes: j['notes'] as String?,
        diagnose: (j['diagnose'] ?? j['diagnostic']) as String?,
      );

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'dentisteId': dentisteId,
        'dateConsultation': dateConsultation,
        if (notes != null) 'notes': notes,
        if (diagnose != null) 'diagnose': diagnose,
      };
}

class Treatment {
  final int id;
  final int patientId;
  final int acteMedicalId;
  final int numeroDent;
  final String faceDentaire;
  final double prixApplique;
  final String dateIntervention;
  final String? notes;

  Treatment({
    required this.id,
    required this.patientId,
    required this.acteMedicalId,
    required this.numeroDent,
    required this.faceDentaire,
    required this.prixApplique,
    required this.dateIntervention,
    this.notes,
  });

  factory Treatment.fromJson(Map<String, dynamic> j) => Treatment(
        id: (j['id'] ?? 0) as int,
        patientId: (j['patientId'] ?? 0) as int,
        acteMedicalId: (j['acteMedicalId'] ?? 0) as int,
        numeroDent: (j['numeroDent'] ?? 0) as int,
        faceDentaire: (j['faceDentaire'] ?? '') as String,
        prixApplique: ((j['prixApplique'] ?? j['prix'] ?? 0) as num).toDouble(),
        dateIntervention: (j['dateIntervention'] ?? j['date'] ?? '') as String,
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'acteMedicalId': acteMedicalId,
        'numeroDent': numeroDent,
        'faceDentaire': faceDentaire,
        'prixApplique': prixApplique,
        'dateIntervention': dateIntervention,
        if (notes != null) 'notes': notes,
      };
}

class Prescription {
  final int id;
  final int patientId;
  final int dentisteId;
  final String dateOrdonnance;
  final String contenu;

  Prescription({
    required this.id,
    required this.patientId,
    required this.dentisteId,
    required this.dateOrdonnance,
    required this.contenu,
  });

  factory Prescription.fromJson(Map<String, dynamic> j) => Prescription(
        id: (j['id'] ?? 0) as int,
        patientId: (j['patientId'] ?? 0) as int,
        dentisteId: (j['dentisteId'] ?? 0) as int,
        dateOrdonnance: (j['dateOrdonnance'] ?? j['date'] ?? '') as String,
        contenu: (j['contenu'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'dentisteId': dentisteId,
        'dateOrdonnance': dateOrdonnance,
        'contenu': contenu,
      };
}
