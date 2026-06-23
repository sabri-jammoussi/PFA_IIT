import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/dentist_stats_model.dart';
import '../viewmodels/dentist_dashboard_viewmodel.dart';

class DentistDashboardView extends StatelessWidget {
  const DentistDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DentistDashboardViewModel vm = Get.put(DentistDashboardViewModel());

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
              _Header(
                doctorName: vm.doctorName.value,
                cabinetName: vm.cabinetName.value,
              ),
              const SizedBox(height: AppSpacing.base),

              // KPI grid (4 cards, 2x2)
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Patients Attendus',
                      value: stats.todayCount.toString(),
                      icon: Icons.calendar_today_rounded,
                      color: DfColors.info(context),
                      faint: DfColors.infoFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Urgences Signalées',
                      value: stats.urgencesCount.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: stats.urgencesCount > 0
                          ? DfColors.danger(context)
                          : DfColors.mutedTextColor(context),
                      faint: stats.urgencesCount > 0
                          ? DfColors.dangerFaint(context)
                          : DfColors.surface2(context),
                      valueColor: stats.urgencesCount > 0
                          ? DfColors.danger(context)
                          : null,
                      pulse: stats.urgencesCount > 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Actes Clôturés',
                      value: stats.completedCount.toString(),
                      icon: Icons.check_circle_rounded,
                      color: DfColors.success(context),
                      faint: DfColors.successFaint(context),
                      valueColor: DfColors.success(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Honoraires du Jour',
                      value: '${stats.revenue.toStringAsFixed(2)} DT',
                      icon: Icons.account_balance_wallet_outlined,
                      color: DfColors.brandPrimary(context),
                      faint: DfColors.brandFaint(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Next patient
              const DfSectionLabel(
                title: 'Prochain Patient en Consultation',
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
              ),
              _NextPatientCard(next: vm.nextPatient.value),

              const SizedBox(height: AppSpacing.xl),
              const DfSectionLabel(
                title: 'Rendez-vous du jour',
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
              ),
              if (vm.todayAppointments.isEmpty)
                const DfEmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'Aucun rendez-vous aujourd\'hui',
                  subtitle: 'Profitez de cette journée calme.',
                )
              else
                ...vm.todayAppointments
                    .map((appt) => _AppointmentTile(appt: appt)),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.doctorName, required this.cabinetName});

  final String doctorName;
  final String cabinetName;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DfPill(label: 'ESPACE PRATICIEN'),
          const SizedBox(height: AppSpacing.md),
          Text(
            doctorName.isEmpty ? 'Bienvenue' : 'Bienvenue, Dr. $doctorName',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            cabinetName.isEmpty
                ? 'Tableau de bord clinique quotidien.'
                : 'Cabinet: $cabinetName • Tableau de bord clinique quotidien.',
            style: TextStyle(
              fontSize: 12,
              color: DfColors.mutedTextColor(context),
            ),
          ),
        ],
      ),
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
    this.valueColor,
    this.pulse = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color faint;
  final Color? valueColor;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Spacer(),
              if (pulse) DfDot(color: color, pulse: true, size: 8),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: DfTextStyles.kpiNumber(
                valueColor ?? DfColors.textColor(context),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: DfColors.mutedTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPatientCard extends StatelessWidget {
  const _NextPatientCard({required this.next});

  final NextPatient? next;

  @override
  Widget build(BuildContext context) {
    final NextPatient n = next ?? NextPatient.none();
    return DfCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DfColors.brandFaint(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              n.isEmpty ? Icons.event_busy_rounded : Icons.person_rounded,
              size: 22,
              color: DfColors.brandPrimary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DfColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Motif : ${n.motif}',
                  style: TextStyle(
                    fontSize: 12,
                    color: DfColors.mutedTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: DfColors.surface2(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: DfColors.borderColor(context)),
            ),
            child: Text(
              n.time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DfColors.textColor(context),
              ),
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
    final String patientName = (appt['patientNomComplet'] ??
            appt['patientNom'] ??
            appt['patient'] ??
            'Patient')
        .toString();
    final String time = _fmtTime((appt['dateHeure'] ?? '').toString());
    final String statut =
        (appt['statut'] ?? appt['status'] ?? '').toString();
    final String s = statut.toLowerCase();
    final bool done =
        s == 'termine' || s == 'terminé' || s == 'confirme' || s == 'confirmé';

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
              done
                  ? DfStatusBadge.success(context, statut)
                  : DfStatusBadge.warning(context, statut),
          ],
        ),
      ),
    );
  }

  static String _fmtTime(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}
