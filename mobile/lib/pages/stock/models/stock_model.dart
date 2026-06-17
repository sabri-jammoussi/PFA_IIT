class StockItem {
  final int id;
  String libelle;
  int quantite;
  double prixUnitaire;
  String? fournisseur;

  StockItem({
    required this.id,
    required this.libelle,
    required this.quantite,
    required this.prixUnitaire,
    this.fournisseur,
  });

  factory StockItem.fromJson(Map<String, dynamic> j) => StockItem(
        id: (j['id'] ?? 0) as int,
        libelle: (j['libelle'] ?? j['nom'] ?? '') as String,
        quantite: (j['quantite'] ?? j['stock'] ?? 0) as int,
        prixUnitaire:
            ((j['prixUnitaire'] ?? j['prix'] ?? 0) as num).toDouble(),
        fournisseur: j['fournisseur'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'libelle': libelle,
        'quantite': quantite,
        'prixUnitaire': prixUnitaire,
        if (fournisseur != null) 'fournisseur': fournisseur,
      };
}
