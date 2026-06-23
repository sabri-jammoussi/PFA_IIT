class Invoice {
  final int id;
  final String numeroFacture;
  final String dateEmission;
  final double montantTotal;
  double montantPaye;
  String statutPaiement; // 'Payé' | 'Partiel' | 'Impayé'
  final int patientId;
  final String? patientNomComplet;

  Invoice({
    required this.id,
    required this.numeroFacture,
    required this.dateEmission,
    required this.montantTotal,
    required this.montantPaye,
    required this.statutPaiement,
    required this.patientId,
    this.patientNomComplet,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: (j['id'] ?? 0) as int,
        numeroFacture: (j['numeroFacture'] ?? '') as String,
        dateEmission: (j['dateEmission'] ?? '') as String,
        montantTotal: ((j['montantTotal'] ?? 0) as num).toDouble(),
        montantPaye: ((j['montantPaye'] ?? 0) as num).toDouble(),
        statutPaiement: (j['statutPaiement'] ?? '') as String,
        patientId: (j['patientId'] ?? 0) as int,
        patientNomComplet: j['patientNomComplet'] as String?,
      );

  String get patientLabel => (patientNomComplet?.isNotEmpty == true)
      ? patientNomComplet!
      : 'Patient #$patientId';

  String get patientFullName => patientNomComplet ?? '';

  double get balance => montantTotal - montantPaye;

  bool get isPaid => statutPaiement == 'Payé' || balance <= 0;
  bool get isPartial => statutPaiement == 'Partiel';
}

class Payment {
  final int factureId;
  final double montant;
  final String datePaiement;
  final String modePaiement;

  Payment({
    required this.factureId,
    required this.montant,
    required this.datePaiement,
    required this.modePaiement,
  });

  Map<String, dynamic> toJson() => {
        'datePaiement': datePaiement,
        'montant': montant,
        'modePaiement': modePaiement,
        'factureId': factureId,
      };
}
