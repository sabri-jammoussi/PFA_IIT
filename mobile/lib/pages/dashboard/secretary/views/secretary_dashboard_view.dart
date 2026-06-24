import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/screens/home_screen.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => HomeScreen.scaffoldKey.currentState?.openDrawer(),
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
              _Header(
                fullName: vm.fullName.value,
                cabinetName: vm.cabinetName.value,
              ),
              const SizedBox(height: AppSpacing.base),

              // KPI grid (2x2)
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: "Patients Attendus",
                      value: vm.todayAppointments.length.toString(),
                      icon: Icons.calendar_today_rounded,
                      color: DfColors.info(context),
                      faint: DfColors.infoFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Demandes en Attente',
                      value: vm.pendingCount.toString(),
                      icon: Icons.notifications_active_outlined,
                      color: DfColors.warning(context),
                      faint: DfColors.warningFaint(context),
                      valueColor: vm.pendingCount > 0
                          ? DfColors.warning(context)
                          : null,
                      pulse: vm.pendingCount > 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: "Salle d'attente",
                      value: vm.todayAppointments.length.toString(),
                      icon: Icons.chair_alt_outlined,
                      color: DfColors.brandPrimary(context),
                      faint: DfColors.brandFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Factures Impayées',
                      value: vm.unpaidCount.value.toString(),
                      icon: Icons.account_balance_wallet_outlined,
                      color: vm.unpaidCount.value > 0
                          ? DfColors.danger(context)
                          : DfColors.success(context),
                      faint: vm.unpaidCount.value > 0
                          ? DfColors.dangerFaint(context)
                          : DfColors.successFaint(context),
                      valueColor: vm.unpaidCount.value > 0
                          ? DfColors.danger(context)
                          : DfColors.success(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Billing summary
              _BillingSummary(
                unpaidCount: vm.unpaidCount.value,
                unpaidTotal: vm.unpaidTotal.value,
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
                      onTap: () =>
                          Get.offAllNamed('/home', arguments: {'index': 1}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickAction(
                      label: 'Facturation',
                      icon: Icons.receipt_long_outlined,
                      color: DfColors.success(context),
                      onTap: () =>
                          Get.offAllNamed('/home', arguments: {'index': 3}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Pending appointment requests
              Row(
                children: [
                  Expanded(
                    child: DfSectionLabel(
                      title:
                          'Demandes de RDV Patients (${vm.pendingCount})',
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    ),
                  ),
                ],
              ),
              if (vm.pendingRequests.isEmpty)
                const DfEmptyState(
                  icon: Icons.task_alt_rounded,
                  title: 'Aucune demande en attente',
                  subtitle: 'Toutes les demandes ont été traitées.',
                )
              else
                ...vm.pendingRequests.map((r) => _PendingRequestTile(rdv: r)),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.fullName, required this.cabinetName});

  final String fullName;
  final String cabinetName;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DfPill(label: 'ACCUEIL & SECRÉTARIAT'),
          const SizedBox(height: AppSpacing.md),
          Text(
            fullName.isEmpty ? 'Bonjour' : 'Bonjour, $fullName',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            cabinetName.isEmpty
                ? 'Admissions, agenda et encaissements.'
                : 'Cabinet: $cabinetName • Admissions, agenda et encaissements.',
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

class _BillingSummary extends StatelessWidget {
  const _BillingSummary({required this.unpaidCount, required this.unpaidTotal});

  final int unpaidCount;
  final double unpaidTotal;

  @override
  Widget build(BuildContext context) {
    final bool clear = unpaidCount == 0;
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 16, color: DfColors.mutedTextColor(context)),
              const SizedBox(width: 8),
              Text(
                'IMPAYÉS & RÈGLEMENTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: DfColors.dimTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (clear)
            Text(
              'Toutes les factures sont réglées. Aucun dossier bloquant en attente d\'encaissement.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: DfColors.mutedTextColor(context),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${unpaidTotal.toStringAsFixed(2)} DT',
                  style: DfTextStyles.monoMd(DfColors.danger(context)),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'à encaisser sur $unpaidCount facture${unpaidCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: DfColors.mutedTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PendingRequestTile extends StatelessWidget {
  const _PendingRequestTile({required this.rdv});

  final Map<String, dynamic> rdv;

  @override
  Widget build(BuildContext context) {
    final String name =
        (rdv['patientNomComplet'] ?? 'Patient').toString();
    final String motif = (rdv['motif'] ?? 'Non spécifié').toString();
    final String dateLabel = _fmtDate((rdv['dateHeure'] ?? '').toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: DfColors.warningFaint(context),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DfColors.warning(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(dateLabel,
                          style: TextStyle(
                              fontSize: 12,
                              color: DfColors.mutedTextColor(context))),
                    ],
                  ),
                ),
                DfStatusBadge.warning(context, 'EN ATTENTE'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.medical_services_outlined,
                    size: 14, color: DfColors.mutedTextColor(context)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    motif,
                    style: TextStyle(
                      fontSize: 12,
                      color: DfColors.subTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      final String hh = d.hour.toString().padLeft(2, '0');
      final String mm = d.minute.toString().padLeft(2, '0');
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} • $hh:$mm';
    } catch (_) {
      return '--';
    }
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
  final String label, value;
  final IconData icon;
  final Color color, faint;
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
                    borderRadius: BorderRadius.circular(AppRadius.sm)),
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
                  valueColor ?? DfColors.textColor(context)),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: DfColors.mutedTextColor(context),
                  fontWeight: FontWeight.w600)),
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
