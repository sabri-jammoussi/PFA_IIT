import 'dart:convert';

import '../storage/secure_token_storage.dart';
import '../constants/user_role.dart';

class UserClaims {
  const UserClaims({
    required this.id,
    required this.username,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.displayName,
    required this.initials,
    required this.role,
    required this.cabinetId,
    required this.cabinetName,
  });

  final String id;
  final String username;
  final String email;
  final String nom;
  final String prenom;
  final String displayName;
  final String initials;
  final UserRole role;
  final String cabinetId;
  final String cabinetName;

  factory UserClaims.anonymous() => const UserClaims(
    id: '',
    username: '',
    email: '',
    nom: '',
    prenom: '',
    displayName: 'Utilisateur',
    initials: 'U',
    role: UserRole.unknown,
    cabinetId: '',
    cabinetName: '',
  );
}

class UserClaimsService {
  static Future<UserClaims> currentUser() async {
    final String? token = await SecureStorage.readToken();
    return fromToken(token);
  }

  static UserClaims fromToken(String? token) {
    if (token == null || token.trim().isEmpty) return UserClaims.anonymous();
    final Map<String, dynamic> payload = _decodePayload(token.trim());
    if (payload.isEmpty) return UserClaims.anonymous();

    final String id = _str(payload, ['nameid', 'sub', 'id', 'unique_name']);
    final String username = _str(payload, ['unique_name', 'username', 'sub']);
    final String email = _str(payload, ['email', 'upn']);
    final String nom = _str(payload, ['family_name', 'familyName', 'nom', 'lastName']);
    final String prenom = _str(payload, ['given_name', 'givenName', 'prenom', 'firstName']);
    final String cabinetId = _str(payload, ['cabinetId', 'cabinet_id', 'societeId']);
    final String cabinetName = _str(payload, ['cabinetName', 'cabinet_name', 'cabinetname']);
    final dynamic rawRole = payload['role'] ?? payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
    final UserRole role = UserRoleX.fromTokenValue(rawRole);

    final String displayName = [prenom, nom]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim()
        .let((n) => n.isEmpty ? (username.isNotEmpty ? username : 'Utilisateur') : n);

    return UserClaims(
      id: id,
      username: username,
      email: email,
      nom: nom,
      prenom: prenom,
      displayName: displayName,
      initials: _initials(displayName, email),
      role: role,
      cabinetId: cabinetId,
      cabinetName: cabinetName,
    );
  }

  static Map<String, dynamic> _decodePayload(String token) {
    final List<String> parts = token.split('.');
    if (parts.length < 2) return {};
    try {
      final String normalized = base64Url.normalize(parts[1]);
      final dynamic payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is Map<String, dynamic>) return payload;
    } catch (_) {}
    return {};
  }

  static String _str(Map<String, dynamic> payload, List<String> keys) {
    for (final String k in keys) {
      final dynamic v = payload[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static String _initials(String name, String email) {
    final List<String> parts = name.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) return (parts.first[0] + parts[1][0]).toUpperCase();
    if (parts.length == 1 && parts.first.length >= 2) return parts.first.substring(0, 2).toUpperCase();
    final String local = email.split('@').first;
    if (local.length >= 2) return local.substring(0, 2).toUpperCase();
    return 'U';
  }
}

extension _StringX on String {
  T let<T>(T Function(String) f) => f(this);
}
