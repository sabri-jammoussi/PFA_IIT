import 'package:flutter/material.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/api_service.dart';
import 'package:dentiflow/core/widgets/df_button.dart';

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
        'Demande envoyée',
        'Votre demande de réactivation a été transmise.',
        type: SnackbarType.success,
      );
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DfEmptyState(
                icon: Icons.lock_clock_outlined,
                title: 'Abonnement expiré',
                subtitle:
                    'Votre abonnement DentiFlow a expiré. Contactez votre administrateur ou demandez une réactivation.',
              ),
              const SizedBox(height: AppSpacing.xxl),
              DfPrimaryButton(
                label: 'Demander la réactivation',
                loading: _loading,
                icon: Icons.refresh_rounded,
                onPressed: _reactivate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
