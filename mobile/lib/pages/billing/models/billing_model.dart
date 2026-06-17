class Invoice {
  final int id;
  final String? patientNom;
  final String? patientPrenom;
  final double montantTotal;
  double montantPaye;
  String statut;
  final String dateFacture;

  Invoice({
    required this.id,
    this.patientNom,
    this.patientPrenom,
    required this.montantTotal,
    required this.montantPaye,
    required this.statut,
    required this.dateFacture,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: (j['id'] ?? 0) as int,
        patientNom: j['patientNom'] as String?,
        patientPrenom: j['patientPrenom'] as String?,
        montantTotal:
            ((j['montantTotal'] ?? j['total'] ?? 0) as num).toDouble(),
        montantPaye: ((j['montantPaye'] ?? j['paye'] ?? 0) as num).toDouble(),
        statut: (j['statut'] ?? j['status'] ?? '') as String,
        dateFacture: (j['dateFacture'] ?? j['date'] ?? '') as String,
      );

  String get patientFullName =>
      [patientPrenom, patientNom].where((s) => s?.isNotEmpty == true).join(' ');

  double get balance => montantTotal - montantPaye;
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
        'factureId': factureId,
        'montant': montant,
        'datePaiement': datePaiement,
        'modePaiement': modePaiement,
      };
}
