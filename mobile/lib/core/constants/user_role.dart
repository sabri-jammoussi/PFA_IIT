enum UserRole { admin, dentist, secretary, patient, unknown }

extension UserRoleX on UserRole {
  static UserRole fromId(dynamic value) {
    final int id = value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
    switch (id) {
      case 1: return UserRole.admin;
      case 2: return UserRole.dentist;
      case 3: return UserRole.secretary;
      case 4: return UserRole.patient;
      default: return UserRole.unknown;
    }
  }

  static UserRole fromTokenValue(dynamic value) {
    if (value == null) return UserRole.unknown;
    if (value is List) {
      if (value.isEmpty) return UserRole.unknown;
      value = value.first;
    }
    if (value is int) return fromId(value);
    final String s = value.toString().trim();
    // Numeric string
    if (int.tryParse(s) != null) return fromId(int.parse(s));
    // Named roles from JWT
    switch (s.toLowerCase()) {
      case 'admin':
      case 'administrateur': return UserRole.admin;
      case 'dentiste':
      case 'dentist': return UserRole.dentist;
      case 'secretaire':
      case 'assistant':
      case 'secretary': return UserRole.secretary;
      case 'patient': return UserRole.patient;
      default: return UserRole.unknown;
    }
  }

  int get id {
    switch (this) {
      case UserRole.admin: return 1;
      case UserRole.dentist: return 2;
      case UserRole.secretary: return 3;
      case UserRole.patient: return 4;
      case UserRole.unknown: return 0;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin: return 'Administrateur';
      case UserRole.dentist: return 'Dentiste';
      case UserRole.secretary: return 'Secrétaire';
      case UserRole.patient: return 'Patient';
      case UserRole.unknown: return 'Inconnu';
    }
  }

  String get landingRoute {
    switch (this) {
      case UserRole.dentist: return '/home';
      case UserRole.secretary: return '/home';
      case UserRole.patient: return '/home';
      default: return '/home';
    }
  }
}
