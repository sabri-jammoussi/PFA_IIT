import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../viewmodels/cabinets_viewmodel.dart';

class CabinetsManagementView extends StatelessWidget {
  const CabinetsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final CabinetsViewModel vm = Get.put(CabinetsViewModel());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Cabinets'),
        actions: [
          Obx(() => IconButton(
                icon: vm.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded),
                onPressed: vm.loadCabinets,
              )),
        ],
      ),
      body: Obx(() {
        if (vm.isLoading.value && vm.cabinets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.cabinets.isEmpty) {
          return const DfEmptyState(
            icon: Icons.business_outlined,
            title: 'Aucun cabinet',
            subtitle: 'Aucune clinique cliente enregistrée sur la plateforme.',
          );
        }
        return RefreshIndicator(
          onRefresh: vm.loadCabinets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.base,
                    AppSpacing.base, AppSpacing.base, AppSpacing.sm),
                child: DfSectionLabel(
                  padding: EdgeInsets.zero,
                  title:
                      'Cabinets cliniques clientèle (${vm.cabinets.length})',
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, 0, AppSpacing.base, 100),
                  itemCount: vm.cabinets.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final cab = vm.cabinets[index];
              final int id = (cab['id'] ?? 0) as int;
              final bool isActive =
                  (cab['isSubscriptionActive'] ?? true) as bool;
              final bool isProcessing = vm.processing.contains(id);

              return DfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive
                                ? DfColors.brandFaint(context)
                                : DfColors.dangerFaint(context),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.local_hospital_rounded,
                            size: 22,
                            color: isActive
                                ? DfColors.brandPrimary(context)
                                : DfColors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cab['nomCabinet']?.toString() ??
                                    'Cabinet Inconnu',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                              Text(
                                'ID: #$id',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: DfColors.dimTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                        isActive
                            ? DfStatusBadge.success(context, 'Actif')
                            : DfStatusBadge.danger(context, 'Suspendu'),
                      ],
                    ),
                    // Details
                    if (cab['adresse'] != null ||
                        cab['telephoneCorporate'] != null) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      if (cab['adresse'] != null)
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14,
                                color: DfColors.mutedTextColor(context)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cab['adresse'].toString(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DfColors.mutedTextColor(context)),
                              ),
                            ),
                          ],
                        ),
                      if (cab['telephoneCorporate'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined,
                                size: 14,
                                color: DfColors.mutedTextColor(context)),
                            const SizedBox(width: 6),
                            Text(
                              cab['telephoneCorporate'].toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: DfColors.mutedTextColor(context)),
                            ),
                          ],
                        ),
                      ],
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    // Action button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isProcessing
                            ? null
                            : () => vm.toggleSubscription(cab),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              isActive ? DfColors.red : DfColors.green,
                          side: BorderSide(
                            color: isActive
                                ? DfColors.red.withOpacity(0.3)
                                : DfColors.green.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: isProcessing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : Icon(
                                isActive
                                    ? Icons.block_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 16),
                        label: Text(
                          isProcessing
                              ? 'En cours...'
                              : isActive
                                  ? 'Suspendre la licence'
                                  : 'Activer la licence',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
