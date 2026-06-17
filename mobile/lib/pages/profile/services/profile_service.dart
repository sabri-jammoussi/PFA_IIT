import 'package:dentiflow/core/services/api_service.dart';
import '../models/profile_model.dart';

class ProfileService {
  static Future<UserProfile> getProfile(String id) async {
    final dynamic data = await ApiService.get('/users/$id');
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  static Future<UserProfile> updateProfile(
      String id, UserProfile p) async {
    final dynamic data =
        await ApiService.put('/users/$id', body: p.toJson());
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> changePassword(
      String id, String current, String newPassword) async {
    await ApiService.put('/users/$id/password', body: {
      'currentPassword': current,
      'newPassword': newPassword,
    });
  }
}
