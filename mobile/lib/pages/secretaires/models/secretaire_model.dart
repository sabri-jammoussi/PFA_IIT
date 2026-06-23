class Secretaire {
  final int id;
  final String username;
  final String nom;
  final String prenom;
  final String? email;
  final bool isActive;
  final DateTime? createdAt;

  Secretaire({
    required this.id,
    required this.username,
    required this.nom,
    required this.prenom,
    this.email,
    required this.isActive,
    this.createdAt,
  });

  String get displayName => '$prenom $nom'.trim();

  String get initials {
    final parts =
        displayName.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) return (parts.first[0] + parts[1][0]).toUpperCase();
    if (parts.length == 1 && parts.first.length >= 2) {
      return parts.first.substring(0, 2).toUpperCase();
    }
    return '??';
  }

  factory Secretaire.fromJson(Map<String, dynamic> j) => Secretaire(
        id: (j['id'] ?? 0) as int,
        username: (j['username'] ?? j['userName'] ?? '') as String,
        nom: (j['nom'] ?? j['lastName'] ?? '') as String,
        prenom: (j['prenom'] ?? j['firstName'] ?? '') as String,
        email: j['email'] as String?,
        isActive: (j['isActive'] ?? j['actif'] ?? true) as bool,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'].toString())
            : null,
      );
}
