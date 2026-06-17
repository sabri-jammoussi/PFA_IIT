class Appointment {
  final int id;
  final int? patientId;
  final String? patientNom;
  final String? patientPrenom;
  final int? dentisteId;
  final String? dentisteNom;
  final String dateHeure;
  final String? motif;
  String statut;

  Appointment({
    required this.id,
    this.patientId,
    this.patientNom,
    this.patientPrenom,
    this.dentisteId,
    this.dentisteNom,
    required this.dateHeure,
    this.motif,
    required this.statut,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: (j['id'] ?? 0) as int,
        patientId: j['patientId'] as int?,
        patientNom: j['patientNom'] as String?,
        patientPrenom: j['patientPrenom'] as String?,
        dentisteId: j['dentisteId'] as int?,
        dentisteNom: j['dentisteNom'] as String?,
        dateHeure: (j['dateHeure'] ?? j['dateDebut'] ?? '') as String,
        motif: j['motif'] as String?,
        statut: (j['statut'] ?? j['status'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => {
        if (patientId != null) 'patientId': patientId,
        if (dentisteId != null) 'dentisteId': dentisteId,
        'dateHeure': dateHeure,
        if (motif != null) 'motif': motif,
        'statut': statut,
      };

  String get patientFullName =>
      [patientPrenom, patientNom].where((s) => s?.isNotEmpty == true).join(' ');

  String get formattedTime {
    try {
      final d = DateTime.parse(dateHeure);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateHeure;
    }
  }
}

class Dentist {
  final int id;
  final String nom;
  final String prenom;

  Dentist({required this.id, required this.nom, required this.prenom});

  factory Dentist.fromJson(Map<String, dynamic> j) => Dentist(
        id: (j['id'] ?? 0) as int,
        nom: (j['nom'] ?? '') as String,
        prenom: (j['prenom'] ?? '') as String,
      );

  String get fullName => '$prenom $nom';
}
