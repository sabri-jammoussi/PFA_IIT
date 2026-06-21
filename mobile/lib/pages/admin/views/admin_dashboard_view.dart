import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../viewmodels/admin_viewmodel.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminViewModel vm = Get.put(AdminViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performances Plateforme'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.business_rounded),
            tooltip: 'Gestion des cabinets',
            onPressed: () => Get.toNamed('/admin/cabinets'),
          ),
        ],
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: vm.loadData,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // SaaS header banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SaaS CONTROLLER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Performances Plateforme',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supervision globale de l\'infrastructure Cloud DentiFlow.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // KPI row
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Cabinets Clients',
                      value: vm.cabinetsCount.toString(),
                      icon: Icons.business_rounded,
                      color: primary,
                      faint: DfColors.brandFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Taux Actif',
                      value: '99.99%',
                      icon: Icons.check_circle_rounded,
                      color: DfColors.green,
                      faint: DfColors.successFaint(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _KpiCard(
                      label: 'Données',
                      value: '12.4 GB',
                      icon: Icons.storage_rounded,
                      color: DfColors.blue,
                      faint: DfColors.infoFaint(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Infrastructure status
              const DfSectionLabel(title: 'État de l\'infrastructure'),
              const SizedBox(height: AppSpacing.sm),
              DfCard(
                child: Column(
                  children: [
                    _StatusRow(
                        label: 'Hébergement Cloud (Cloudinary)',
                        status: 'FONCTIONNEL',
                        ok: true),
                    Divider(
                        height: 1, color: DfColors.borderColor(context)),
                    _StatusRow(
                        label: 'Serveurs d\'envoi Mail',
                        status: 'FONCTIONNEL',
                        ok: true),
                    Divider(
                        height: 1, color: DfColors.borderColor(context)),
                    _StatusRow(
                        label: 'Base de données SQL Server',
                        status: 'ACTIF (0.2ms)',
                        ok: true),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Recent cabinets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DfSectionLabel(title: 'Dernières inscriptions'),
                  TextButton.icon(
                    icon: Icon(Icons.arrow_forward_rounded,
                        size: 16, color: primary),
                    label: Text('Tous',
                        style: TextStyle(fontSize: 12, color: primary)),
                    onPressed: () => Get.toNamed('/admin/cabinets'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (vm.recentCabinets.isEmpty)
                DfEmptyState(
                  icon: Icons.business_outlined,
                  title: 'Aucun cabinet enregistré',
                  subtitle: 'Aucune clinique cliente sur la plateforme.',
                )
              else
                ...vm.recentCabinets.map((cab) => Padding(
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
                              child: Icon(Icons.local_hospital_rounded,
                                  size: 20, color: primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cab['nomCabinet']?.toString() ??
                                        'Cabinet',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    'ID: #${cab['id']} • ${cab['adresse'] ?? 'Pas d\'adresse'}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            DfColors.mutedTextColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            DfStatusBadge(
                              label: (cab['isSubscriptionActive'] ?? true)
                                  ? 'Actif'
                                  : 'Suspendu',
                              color: (cab['isSubscriptionActive'] ?? true)
                                  ? DfColors.green
                                  : DfColors.red,
                              faintColor:
                                  (cab['isSubscriptionActive'] ?? true)
                                      ? DfColors.greenFaintLight
                                      : DfColors.redFaintLight,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: faint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DfColors.textColor(context),
                  letterSpacing: -0.5)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: DfColors.mutedTextColor(context),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.status,
    required this.ok,
  });
  final String label, status;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base, vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: DfColors.textColor(context),
                    fontWeight: FontWeight.w500)),
          ),
          Text(status,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ok ? DfColors.green : DfColors.red)),
        ],
      ),
    );
  }
}
