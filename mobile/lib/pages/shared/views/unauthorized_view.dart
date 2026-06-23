import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';

/// Shown when the user reaches a screen they are not allowed to access.
/// Mirrors the Vue shared/UnauthorizedView: centered lock icon,
/// "Accès Refusé" title, rose "Permissions Insuffisantes" subtitle,
/// an explanation and a "Retour" button.
class UnauthorizedView extends StatelessWidget {
  const UnauthorizedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lock icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: DfColors.dangerFaint(context),
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 38,
                    color: DfColors.danger(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  'Accès Refusé',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Rose subtitle
                Text(
                  'PERMISSIONS INSUFFISANTES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.danger(context),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                // Divider accent
                Container(
                  width: 48,
                  height: 2,
                  decoration: BoxDecoration(
                    color: DfColors.borderStrongColor(context),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                // Explanation
                Text(
                  "Votre compte ne possède pas les habilitations nécessaires "
                  "pour accéder à cette fonctionnalité.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DfColors.mutedTextColor(context),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Return action
                SizedBox(
                  width: double.infinity,
                  child: DfPrimaryButton(
                    label: 'Retour',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.offAllNamed('/home');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
