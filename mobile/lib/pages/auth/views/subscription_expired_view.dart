import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/api_service.dart';
import 'package:dentiflow/core/storage/secure_token_storage.dart';
import 'package:dentiflow/core/widgets/df_button.dart';

/// Shown when the cabinet subscription has expired (HTTP 402).
/// Mirrors the Vue shared/SubscriptionExpiredView: suspended-licence message,
/// a renewal CTA (with the annual price) and a "change account" action.
class SubscriptionExpiredView extends StatefulWidget {
  const SubscriptionExpiredView({super.key});

  @override
  State<SubscriptionExpiredView> createState() =>
      _SubscriptionExpiredViewState();
}

class _SubscriptionExpiredViewState extends State<SubscriptionExpiredView> {
  bool _loading = false;

  Future<void> _reactivate() async {
    setState(() => _loading = true);
    try {
      await ApiService.post('/cabinet/subscription/reactivate');
      showThemedSnackbar(
        'Abonnement activé',
        'Le règlement a été validé. Redirection vers votre portail...',
        type: SnackbarType.success,
      );
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.offAllNamed('/home');
    } catch (_) {
      // ApiService already surfaces the error via snackbar.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeAccount() async {
    await SecureStorage.deleteToken();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Critical indicator
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: DfColors.dangerFaint(context),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Icon(
                      Icons.credit_card_off_outlined,
                      size: 38,
                      color: DfColors.danger(context),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Licence Suspendue',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DfColors.danger(context),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'VEUILLEZ RÉGULARISER VOTRE ABONNEMENT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.mutedTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                Text(
                  "L'abonnement annuel de votre cabinet est arrivé à expiration. "
                  "L'accès à la fiche clinique, à l'agenda et aux stocks est "
                  "temporairement restreint.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DfColors.mutedTextColor(context),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Renewal box
                DfCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RENOUVELLEMENT INSTANTANÉ',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: DfColors.brandPrimary(context),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Régularisation du solde de licence',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Divider(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Licence annuelle SaaS',
                            style: TextStyle(
                              fontSize: 13,
                              color: DfColors.mutedTextColor(context),
                            ),
                          ),
                          Text(
                            '1 200,00 DT / an',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: DfColors.textColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      DfPrimaryButton(
                        label: "Régler l'abonnement (Simulation)",
                        loading: _loading,
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _reactivate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),

                DfSecondaryButton(
                  label: 'Changer de compte',
                  icon: Icons.logout_rounded,
                  onPressed: _changeAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
