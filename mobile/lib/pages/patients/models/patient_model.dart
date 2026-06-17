class Patient {
  final int id;
  String nom;
  String prenom;
  String? email;
  String? phone;
  String? dateNaissance;
  String? adresse;
  bool isActive;

  Patient({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.phone,
    this.dateNaissance,
    this.adresse,
    this.isActive = true,
  });

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
        id: (j['id'] ?? 0) as int,
        nom: (j['nom'] ?? '') as String,
        prenom: (j['prenom'] ?? '') as String,
        email: j['email'] as String?,
        phone: (j['telephone'] ?? j['phone'] ?? j['tel']) as String?,
        dateNaissance: (j['dateNaissance'] ?? j['dob']) as String?,
        adresse: j['adresse'] as String?,
        isActive: (j['isActive'] ?? j['actif'] ?? true) as bool,
      );

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        if (email != null) 'email': email,
        if (phone != null) 'telephone': phone,
        if (dateNaissance != null) 'dateNaissance': dateNaissance,
        if (adresse != null) 'adresse': adresse,
        'isActive': isActive,
      };

  String get fullName => '$prenom $nom';

  String get initials =>
      (prenom.isNotEmpty && nom.isNotEmpty)
          ? (prenom[0] + nom[0]).toUpperCase()
          : '?';
}
