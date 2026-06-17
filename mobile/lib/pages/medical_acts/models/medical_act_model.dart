class MedicalAct {
  final int id;
  String libelle;
  double tarifDeBase;
  String? description;

  MedicalAct({
    required this.id,
    required this.libelle,
    required this.tarifDeBase,
    this.description,
  });

  factory MedicalAct.fromJson(Map<String, dynamic> j) => MedicalAct(
        id: (j['id'] ?? 0) as int,
        libelle: (j['libelle'] ?? j['nom'] ?? '') as String,
        tarifDeBase:
            ((j['tarifDeBase'] ?? j['tarif'] ?? j['prix'] ?? 0) as num).toDouble(),
        description: j['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'libelle': libelle,
        'tarifDeBase': tarifDeBase,
        if (description != null) 'description': description,
      };
}
