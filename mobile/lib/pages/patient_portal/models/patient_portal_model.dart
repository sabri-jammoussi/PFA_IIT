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
        dentisteNom: j['dentisteNom'] as String?,
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
