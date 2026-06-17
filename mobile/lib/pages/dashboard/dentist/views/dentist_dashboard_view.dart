import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../viewmodels/dentist_dashboard_viewmodel.dart';

class DentistDashboardView extends StatelessWidget {
  const DentistDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DentistDashboardViewModel vm = Get.put(DentistDashboardViewModel());
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
        final stats = vm.stats;
        return RefreshIndicator(
          onRefresh: vm.loadData,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: "Aujourd'hui",
                      value: stats.todayCount.toString(),
                      icon: Icons.calendar_today_rounded,
                      color: primary,
                      faint: DfColors.brandFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Terminés',
                      value: stats.completedCount.toString(),
                      icon: Icons.check_circle_rounded,
                      color: DfColors.green,
                      faint: DfColors.successFaint(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'En attente',
                      value: stats.pendingCount.toString(),
                      icon: Icons.hourglass_empty_rounded,
                      color: DfColors.orange,
                      faint: DfColors.warningFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Revenus',
                      value: '${stats.revenue.toStringAsFixed(0)} DT',
                      icon: Icons.payments_outlined,
                      color: DfColors.blue,
                      faint: DfColors.infoFaint(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const DfSectionLabel(title: 'Rendez-vous du jour'),
              const SizedBox(height: AppSpacing.sm),
              if (vm.todayAppointments.isEmpty)
                DfEmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'Aucun rendez-vous aujourd\'hui',
                  subtitle: 'Profitez de cette journée calme.',
                )
              else
                ...vm.todayAppointments.map((appt) => _AppointmentTile(appt: appt)),
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

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color faint;

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
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: DfColors.textColor(context),
              letterSpacing: -0.8,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: DfColors.mutedTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appt});

  final Map<String, dynamic> appt;

  @override
  Widget build(BuildContext context) {
    final String patientName = appt['patientNom'] ?? appt['patient'] ?? 'Patient';
    final String time = appt['heure'] ?? appt['heureDebut'] ?? '--:--';
    final String statut = appt['statut'] ?? appt['status'] ?? '';
    final bool done = statut.toLowerCase() == 'terminé';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DfCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DfColors.brandFaint(context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.person_rounded,
                  size: 20, color: DfColors.brandPrimary(context)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(time,
                      style: TextStyle(
                          fontSize: 12,
                          color: DfColors.mutedTextColor(context))),
                ],
              ),
            ),
            if (statut.isNotEmpty)
              DfStatusBadge(
                label: statut,
                color: done ? DfColors.green : DfColors.orange,
                faintColor:
                    done ? DfColors.greenFaintLight : DfColors.orangeFaintLight,
              ),
          ],
        ),
      ),
    );
  }
}
