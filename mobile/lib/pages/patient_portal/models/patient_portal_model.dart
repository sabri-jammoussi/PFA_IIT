import 'package:flutter/material.dart';
import 'package:dentiflow/core/df_ui.dart';

/// Normalizes an appointment / invoice status for comparison: lowercases and
/// strips French accents so "Annulé" and "Annule" match the same branch.
String normalizeStatus(String? raw) {
  if (raw == null) return '';
  final String s = raw.trim().toLowerCase();
  const Map<String, String> accents = {
    'à': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'î': 'i', 'ï': 'i',
    'ô': 'o', 'ö': 'o',
    'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c',
  };
  final StringBuffer out = StringBuffer();
  for (final int code in s.runes) {
    final String ch = String.fromCharCode(code);
    out.write(accents[ch] ?? ch);
  }
  return out.toString();
}

/// Visual mapping of an appointment status to (color, faint color).
/// EnAttenteValidation -> warning, Planifie/Confirme -> info/success,
/// Annule -> danger, Termine -> success.
class StatusVisual {
  final Color color;
  final Color faint;
  const StatusVisual(this.color, this.faint);

  static StatusVisual appointment(BuildContext context, String? statut) {
    final String s = normalizeStatus(statut);
    if (s.contains('attente') || s.contains('demande')) {
      return StatusVisual(
          DfColors.warning(context), DfColors.warningFaint(context));
    }
    if (s.contains('annul') || s.contains('refus')) {
      return StatusVisual(
          DfColors.danger(context), DfColors.dangerFaint(context));
    }
    if (s.contains('termin') || s.contains('confirm')) {
      return StatusVisual(
          DfColors.success(context), DfColors.successFaint(context));
    }
    // Planifie and anything else -> info
    return StatusVisual(DfColors.info(context), DfColors.infoFaint(context));
  }

  static StatusVisual invoice(BuildContext context, String? statut) {
    final String s = normalizeStatus(statut);
    if (s.contains('paye') && !s.contains('partiel') && !s.contains('impaye')) {
      return StatusVisual(
          DfColors.success(context), DfColors.successFaint(context));
    }
    if (s.contains('partiel')) {
      return StatusVisual(
          DfColors.warning(context), DfColors.warningFaint(context));
    }
    return StatusVisual(DfColors.danger(context), DfColors.dangerFaint(context));
  }
}

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
        dentisteNom: j['dentisteNomComplet'] as String? ??
            j['dentisteNom'] as String?,
        dateHeure: (j['dateHeure'] ?? j['dateDebut'] ?? '') as String,
        statut: (j['statut'] ?? j['status'] ?? '') as String,
        motif: j['motif'] as String?,
      );

  DateTime? get dateTime {
    try {
      return DateTime.parse(dateHeure);
    } catch (_) {
      return null;
    }
  }

  bool get isPast {
    final DateTime? d = dateTime;
    if (d == null) return false;
    return d.isBefore(DateTime.now());
  }

  /// True for statuses that count as an active, upcoming visit.
  bool get isUpcomingStatus {
    final String s = normalizeStatus(statut);
    return !(s.contains('annul') || s.contains('refus') || s.contains('termin'));
  }

  String get formattedDate {
    final DateTime? d = dateTime;
    if (d == null) return dateHeure;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateLong {
    final DateTime? d = dateTime;
    if (d == null) return dateHeure;
    return '${_weekday(d.weekday)} ${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';
  }

  String get formattedTime {
    final DateTime? d = dateTime;
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  /// Compact label used by the "Prochain RDV" KPI: "12 juin 09:00".
  String get formattedShort {
    final DateTime? d = dateTime;
    if (d == null) return dateHeure;
    return '${d.day.toString().padLeft(2, '0')} ${_month(d.month).substring(0, 3)} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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

/// A single bookable 30-minute slot as returned by /my/appointments/availability:
/// { "time": "09:00", "dateTime": "2026-06-23T09:00:00", "isAvailable": true }
class AppointmentSlot {
  final String time;
  final String dateTime;
  final bool isAvailable;

  AppointmentSlot({
    required this.time,
    required this.dateTime,
    required this.isAvailable,
  });

  factory AppointmentSlot.fromJson(Map<String, dynamic> j) => AppointmentSlot(
        time: (j['time'] ?? '') as String,
        dateTime: (j['dateTime'] ?? '') as String,
        isAvailable: (j['isAvailable'] ?? false) as bool,
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
      return '${_weekday(d.weekday)} ${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year}';
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

// ─── French date helpers (no intl dependency assumed) ───────────────────────

String _weekday(int w) {
  const days = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
  ];
  return (w >= 1 && w <= 7) ? days[w - 1] : '';
}

String _month(int m) {
  const months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];
  return (m >= 1 && m <= 12) ? months[m - 1] : '';
}
