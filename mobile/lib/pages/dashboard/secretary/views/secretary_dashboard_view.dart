import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../viewmodels/secretary_dashboard_viewmodel.dart';

class SecretaryDashboardView extends StatelessWidget {
  const SecretaryDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final SecretaryDashboardViewModel vm =
        Get.put(SecretaryDashboardViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: Obx(() {
        if (vm.isLoading.value && vm.todayAppointments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: vm.loadData,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // KPI cards
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: "Aujourd'hui",
                      value: vm.todayAppointments.length.toString(),
                      icon: Icons.calendar_today_rounded,
                      color: primary,
                      faint: DfColors.brandFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'En attente',
                      value: vm.pendingCount.value.toString(),
                      icon: Icons.inbox_rounded,
                      color: DfColors.orange,
                      faint: DfColors.warningFaint(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      label: 'Nouveau rendez-vous',
                      icon: Icons.add_circle_outline_rounded,
                      color: primary,
                      onTap: () => Get.offAllNamed('/home',
                          arguments: {'index': 1}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      label: 'Facturation',
                      icon: Icons.receipt_long_outlined,
                      color: DfColors.green,
                      onTap: () => Get.offAllNamed('/home',
                          arguments: {'index': 3}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Today's list
              const DfSectionLabel(title: "Salle d'attente"),
              const SizedBox(height: AppSpacing.sm),
              if (vm.todayAppointments.isEmpty)
                DfEmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'Aucun rendez-vous aujourd\'hui',
                  subtitle: 'Journée tranquille.',
                )
              else
                ...vm.todayAppointments.map((appt) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: DfCard(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: DfColors.brandFaint(context),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Icon(Icons.person_rounded,
                                  size: 20, color: primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appt['patientNom'] ??
                                        appt['patient'] ??
                                        'Patient',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    appt['heure'] ??
                                        appt['heureDebut'] ??
                                        '--:--',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            DfColors.mutedTextColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            if ((appt['dentisteNom'] ?? '') != '')
                              Text(
                                'Dr. ${appt['dentisteNom']}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        DfColors.mutedTextColor(context)),
                              ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      }),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.faint,
  });
  final String label, value;
  final IconData icon;
  final Color color, faint;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: faint,
                borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: DfColors.textColor(context),
                  letterSpacing: -0.8)),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: DfColors.mutedTextColor(context),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DfColors.textColor(context))),
        ],
      ),
    );
  }
}
