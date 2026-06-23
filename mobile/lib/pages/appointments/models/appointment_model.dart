/// Mirrors backend RendezVousDto. Backend statut values are UNACCENTED:
/// "Planifie", "Confirme", "Annule", "Complete", "EnConsultation",
/// "EnAttenteValidation". The web app sometimes shows accented variants, so all
/// status helpers below normalise (lowercase + strip accents) before comparing.
class Appointment {
  final int id;
  final int? patientId;
  final String? patientNom;
  final String? patientPrenom;
  final String? patientNomComplet;
  final int? dentisteId;
  final String? dentisteNom;
  final String dateHeure;

  /// "HH:mm:ss" TimeSpan string from backend (DureeEstimee). Defaults to 30 min.
  final String dureeEstimee;
  final String? motif;
  final String? note;
  final String? actualArrivalAt;
  String statut;

  Appointment({
    required this.id,
    this.patientId,
    this.patientNom,
    this.patientPrenom,
    this.patientNomComplet,
    this.dentisteId,
    this.dentisteNom,
    required this.dateHeure,
    this.dureeEstimee = '00:30:00',
    this.motif,
    this.note,
    this.actualArrivalAt,
    required this.statut,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: (j['id'] ?? 0) as int,
        patientId: j['patientId'] as int?,
        patientNom: j['patientNom'] as String?,
        patientPrenom: j['patientPrenom'] as String?,
        patientNomComplet: j['patientNomComplet'] as String?,
        dentisteId: j['dentisteId'] as int?,
        dentisteNom: (j['dentisteNomComplet'] ?? j['dentisteNom']) as String?,
        dateHeure: (j['dateHeure'] ?? j['dateDebut'] ?? '') as String,
        dureeEstimee: (j['dureeEstimee'] ?? '00:30:00').toString(),
        motif: j['motif'] as String?,
        note: j['note'] as String?,
        actualArrivalAt: j['actualArrivalAt']?.toString(),
        statut: (j['statut'] ?? j['status'] ?? '') as String,
      );

  /// Payload matching AddRendezVousCommand / UpdateRendezVousCommand.
  /// All command fields are `required` on the backend.
  Map<String, dynamic> toJson() => {
        if (id != 0) 'id': id,
        'dateHeure': dateHeure,
        'dureeEstimee': dureeEstimee,
        'statut': statut,
        if (motif != null) 'motif': motif,
        if (note != null) 'note': note,
        if (patientId != null) 'patientId': patientId,
        if (dentisteId != null) 'dentisteId': dentisteId,
      };

  String get patientFullName {
    if (patientNomComplet?.trim().isNotEmpty == true) {
      return patientNomComplet!.trim();
    }
    return [patientPrenom, patientNom]
        .where((s) => s?.isNotEmpty == true)
        .join(' ')
        .trim();
  }

  String get formattedTime {
    try {
      final d = DateTime.parse(dateHeure);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateHeure;
    }
  }

  DateTime? get dateTime {
    try {
      return DateTime.parse(dateHeure);
    } catch (_) {
      return null;
    }
  }

  /// Estimated duration in minutes parsed from the "HH:mm:ss" string.
  int get durationMinutes {
    final parts = dureeEstimee.split(':');
    if (parts.length < 2) return 30;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  String get formattedDuration {
    final minutes = durationMinutes;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return m > 0 ? '${h}h ${m}m' : '${h}h';
    return '$m min';
  }

  // ===== STATUS NORMALISATION (accent + case insensitive) =====

  static String _normalize(String s) {
    final lower = s.toLowerCase().trim();
    const accents = {
      'à': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'î': 'i', 'ï': 'i',
      'ô': 'o', 'ö': 'o',
      'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c',
    };
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      buf.write(accents[ch] ?? ch);
    }
    return buf.toString();
  }

  String get _statutKey => _normalize(statut);

  bool get isPlanifie => _statutKey == 'planifie';
  bool get isConfirme => _statutKey == 'confirme';
  bool get isAnnule => _statutKey == 'annule';
  bool get isComplete =>
      _statutKey == 'complete' || _statutKey == 'termine';
  bool get isEnConsultation => _statutKey == 'enconsultation';
  bool get isEnAttente =>
      _statutKey == 'enattentevalidation' || _statutKey == 'enattente';

  /// True when a planned RDV is within 15 min ahead or up to 60 min late.
  bool get isImminent {
    if (!isPlanifie) return false;
    final dt = dateTime;
    if (dt == null) return false;
    final diff = dt.difference(DateTime.now()).inMinutes;
    return diff <= 15 && diff >= -60;
  }

  /// Human-readable French label for display.
  String get statutLabel {
    switch (_statutKey) {
      case 'planifie':
        return 'Planifié';
      case 'confirme':
        return 'Confirmé';
      case 'annule':
        return 'Annulé';
      case 'complete':
      case 'termine':
        return 'Terminé';
      case 'enconsultation':
        return 'En consultation';
      case 'enattentevalidation':
      case 'enattente':
        return 'En attente';
      default:
        return statut.isEmpty ? '—' : statut;
    }
  }
}

class Dentist {
  final int id;
  final String nom;
  final String prenom;
  final String? spec;

  Dentist({required this.id, required this.nom, required this.prenom, this.spec});

  factory Dentist.fromJson(Map<String, dynamic> j) => Dentist(
        id: (j['id'] ?? 0) as int,
        nom: (j['nom'] ?? '') as String,
        prenom: (j['prenom'] ?? '') as String,
        spec: (j['roleName'] == 'Dentiste'
                ? 'Chirurgien-Dentiste'
                : j['roleName']) as String?,
      );

  String get fullName => 'Dr. ${prenom.trim()} ${nom.trim()}'.trim();
}
