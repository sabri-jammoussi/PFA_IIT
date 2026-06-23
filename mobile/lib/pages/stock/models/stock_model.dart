class StockItem {
  final int id;
  String nom;
  String? description;
  int quantiteEnStock;
  int seuilAlerte;
  String unite;

  StockItem({
    required this.id,
    required this.nom,
    this.description,
    required this.quantiteEnStock,
    required this.seuilAlerte,
    this.unite = 'Unité',
  });

  factory StockItem.fromJson(Map<String, dynamic> j) => StockItem(
        id: (j['id'] ?? 0) as int,
        nom: (j['nom'] ?? '') as String,
        description: j['description'] as String?,
        quantiteEnStock: ((j['quantiteEnStock'] ?? 0) as num).toInt(),
        seuilAlerte: ((j['seuilAlerte'] ?? 0) as num).toInt(),
        unite: (j['unite'] ?? 'Unité') as String,
      );

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'description': description,
        'quantiteEnStock': quantiteEnStock,
        'seuilAlerte': seuilAlerte,
        'unite': unite,
      };

  /// Critical / under-threshold (matches API IsLowStock and Vue logic).
  bool get isLowStock => quantiteEnStock <= seuilAlerte;

  /// Out of stock.
  bool get isOutOfStock => quantiteEnStock <= 0;
}
