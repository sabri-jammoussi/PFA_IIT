/// Lightweight clinical snapshot of a patient used by the consultation screen.
/// We read the raw `/patients/{id}` payload here (instead of the shared Patient
/// model) because the consultation page needs the critical medical fields
/// (blood group + medical history) that the patients module model does not expose.
class PatientClinical {
  final int id;
  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? groupSanguin;
  final String? antecedentsMedicaux;

  PatientClinical({
    required this.id,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.groupSanguin,
    this.antecedentsMedicaux,
  });

  factory PatientClinical.fromJson(Map<String, dynamic> j) => PatientClinical(
        id: (j['id'] ?? 0) as int,
        nom: (j['nom'] ?? '') as String,
        prenom: (j['prenom'] ?? '') as String,
        dateNaissance: (j['dateNaissance'] ?? j['dob']) as String?,
        groupSanguin: (j['groupSanguin'] ?? j['groupeSanguin']) as String?,
        antecedentsMedicaux:
            (j['antecedentsMedicaux'] ?? j['antecedents']) as String?,
      );

  String get fullName => '$prenom $nom';
}

class Consultation {
  final int id;
  final int patientId;
  final int dentisteId;
  final String dateConsultation;
  final String? notesObservations;

  Consultation({
    required this.id,
    required this.patientId,
    required this.dentisteId,
    required this.dateConsultation,
    this.notesObservations,
  });

  factory Consultation.fromJson(Map<String, dynamic> j) => Consultation(
        id: (j['id'] ?? 0) as int,
        patientId: (j['patientId'] ?? 0) as int,
        dentisteId: (j['dentisteId'] ?? 0) as int,
        dateConsultation: (j['dateConsultation'] ?? j['date'] ?? '') as String,
        notesObservations:
            (j['notesObservations'] ?? j['notes']) as String?,
      );

  Map<String, dynamic> toJson() => {
        'dateConsultation': dateConsultation,
        'notesObservations': notesObservations,
        'patientId': patientId,
        'dentisteId': dentisteId,
      };
}

class Treatment {
  final int id;
  final int? numeroDent;
  final String? faceDentaire;
  final double prixApplique;
  final String? notes;
  final int consultationId;
  final String? consultationDate;
  final int acteMedicalId;
  final String? acteMedicalLibelle;

  Treatment({
    required this.id,
    required this.numeroDent,
    required this.faceDentaire,
    required this.prixApplique,
    required this.consultationId,
    required this.acteMedicalId,
    this.consultationDate,
    this.acteMedicalLibelle,
    this.notes,
  });

  factory Treatment.fromJson(Map<String, dynamic> j) => Treatment(
        id: (j['id'] ?? 0) as int,
        numeroDent: j['numeroDent'] as int?,
        faceDentaire: j['faceDentaire'] as String?,
        prixApplique: ((j['prixApplique'] ?? j['prix'] ?? 0) as num).toDouble(),
        notes: j['notes'] as String?,
        consultationId: (j['consultationId'] ?? 0) as int,
        consultationDate:
            (j['consultationDate'] ?? j['dateConsultation']) as String?,
        acteMedicalId: (j['acteMedicalId'] ?? 0) as int,
        acteMedicalLibelle:
            (j['acteMedicalLibelle'] ?? j['acteMedical']) as String?,
      );

  /// Payload for POST /soins-effectues (AddSoinEffectueCommand).
  Map<String, dynamic> toJson() => {
        'numeroDent': numeroDent,
        'faceDentaire': faceDentaire,
        'prixApplique': prixApplique,
        'notes': notes,
        'consultationId': consultationId,
        'acteMedicalId': acteMedicalId,
      };
}

/// A patient checked in by the secretary and waiting for the doctor.
class WaitingEntry {
  final int appointmentId;
  final int patientId;
  final String patientNomComplet;
  final String? motif;
  final String? arrivalTime;
  final String? lastVisitDate;

  WaitingEntry({
    required this.appointmentId,
    required this.patientId,
    required this.patientNomComplet,
    this.motif,
    this.arrivalTime,
    this.lastVisitDate,
  });

  factory WaitingEntry.fromJson(Map<String, dynamic> j) => WaitingEntry(
        appointmentId: (j['appointmentId'] ?? 0) as int,
        patientId: (j['patientId'] ?? 0) as int,
        patientNomComplet: (j['patientNomComplet'] ?? '') as String,
        motif: j['motif'] as String?,
        arrivalTime: j['arrivalTime'] as String?,
        lastVisitDate: j['lastVisitDate'] as String?,
      );
}

/// A stock article consumed during the consultation (decrements inventory only).
class ConsommationArticle {
  final int id;
  final int quantite;
  final int consultationId;
  final int articleId;
  final String? articleNom;
  final String? articleUnite;

  ConsommationArticle({
    required this.id,
    required this.quantite,
    required this.consultationId,
    required this.articleId,
    this.articleNom,
    this.articleUnite,
  });

  factory ConsommationArticle.fromJson(Map<String, dynamic> j) =>
      ConsommationArticle(
        id: (j['id'] ?? 0) as int,
        quantite: (j['quantite'] ?? 0) as int,
        consultationId: (j['consultationId'] ?? 0) as int,
        articleId: (j['articleId'] ?? 0) as int,
        articleNom: j['articleNom'] as String?,
        articleUnite: j['articleUnite'] as String?,
      );
}

/// Suggested consumable from a medical act's "recipe" (editable pre-fill).
class RecetteSuggestion {
  final int id;
  final int articleId;
  final String? articleNom;
  final int quantiteRequise;

  RecetteSuggestion({
    required this.id,
    required this.articleId,
    required this.quantiteRequise,
    this.articleNom,
  });

  factory RecetteSuggestion.fromJson(Map<String, dynamic> j) =>
      RecetteSuggestion(
        id: (j['id'] ?? 0) as int,
        articleId: (j['articleId'] ?? 0) as int,
        quantiteRequise: (j['quantiteRequise'] ?? 1) as int,
        articleNom: (j['articleNom'] ?? j['articleLibelle']) as String?,
      );
}

class Prescription {
  final int id;
  final int consultationId;
  final String dateEmission;
  final String traitement;

  Prescription({
    required this.id,
    required this.consultationId,
    required this.dateEmission,
    required this.traitement,
  });

  factory Prescription.fromJson(Map<String, dynamic> j) => Prescription(
        id: (j['id'] ?? 0) as int,
        consultationId: (j['consultationId'] ?? 0) as int,
        dateEmission: (j['dateEmission'] ?? j['date'] ?? '') as String,
        traitement: (j['traitement'] ?? j['contenu'] ?? '') as String,
      );

  /// Payload for POST /ordonnances (AddOrdonnanceCommand).
  Map<String, dynamic> toJson() => {
        'dateEmission': dateEmission,
        'traitement': traitement,
        'consultationId': consultationId,
      };
}
