class UserProfile {
  final int id;
  String username;
  String email;
  String nom;
  String prenom;
  bool isActive;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: (j['id'] ?? 0) as int,
        username: (j['username'] ?? j['userName'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        nom: (j['nom'] ?? '') as String,
        prenom: (j['prenom'] ?? '') as String,
        isActive: (j['isActive'] ?? j['actif'] ?? true) as bool,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'nom': nom,
        'prenom': prenom,
      };

  String get displayName => '$prenom $nom'.trim();
  String get initials =>
      (prenom.isNotEmpty && nom.isNotEmpty)
          ? (prenom[0] + nom[0]).toUpperCase()
          : username.isNotEmpty
              ? username[0].toUpperCase()
              : '?';
}
