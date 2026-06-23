class DentistStats {
  final int todayCount;
  final int completedCount;
  final int pendingCount;
  final int urgencesCount;
  final double revenue;

  const DentistStats({
    required this.todayCount,
    required this.completedCount,
    required this.pendingCount,
    required this.urgencesCount,
    required this.revenue,
  });
}

/// Lightweight "next patient" projection for the dentist dashboard.
class NextPatient {
  final String name;
  final String motif;
  final String time;
  final bool isEmpty;

  const NextPatient({
    required this.name,
    required this.motif,
    required this.time,
    this.isEmpty = false,
  });

  factory NextPatient.none() => const NextPatient(
        name: 'Aucun patient attendu',
        motif: 'Pas de motif',
        time: '--:--',
        isEmpty: true,
      );
}
