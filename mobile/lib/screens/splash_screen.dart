import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/storage/secure_token_storage.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import 'package:dentiflow/core/constants/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final bool hasToken = await SecureStorage.hasToken();
    if (!hasToken) {
      Get.offAllNamed('/login');
      return;
    }

    final claims = await UserClaimsService.currentUser();
    if (claims.role == UserRole.unknown) {
      Get.offAllNamed('/login');
      return;
    }

    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.medical_services_rounded, color: primary, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'DentiFlow',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestion de cabinet dentaire',
              style: TextStyle(
                color: DfColors.mutedTextColor(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: primary,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
