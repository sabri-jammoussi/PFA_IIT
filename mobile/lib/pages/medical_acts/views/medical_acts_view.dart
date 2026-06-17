import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/medical_act_model.dart';
import '../viewmodels/medical_acts_viewmodel.dart';
import 'medical_act_sheet.dart';

class MedicalActsView extends StatelessWidget {
  const MedicalActsView({super.key});

  @override
  Widget build(BuildContext context) {
    final MedicalActsViewModel vm = Get.put(MedicalActsViewModel());

    return Scaffold(
      appBar: AppBar(title: const Text('Actes médicaux')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context, vm, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvel acte'),
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.acts.isEmpty) {
          return const DfEmptyState(
            icon: Icons.medical_services_outlined,
            title: 'Aucun acte médical',
            subtitle: 'Ajoutez vos premiers actes médicaux.',
          );
        }
        return RefreshIndicator(
          onRefresh: vm.loadActs,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
            itemCount: vm.acts.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final MedicalAct act = vm.acts[index];
              return DfCard(
                onTap: () => _openSheet(context, vm, act),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: DfColors.brandFaint(context),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.healing_rounded,
                          size: 20, color: DfColors.brandPrimary(context)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(act.libelle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          if (act.description?.isNotEmpty == true)
                            Text(act.description!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DfColors.mutedTextColor(context)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(
                      '${act.tarifDeBase.toStringAsFixed(2)} DT',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: DfColors.brandPrimary(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: DfColors.mutedTextColor(context)),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _openSheet(
      BuildContext context, MedicalActsViewModel vm, MedicalAct? act) {
    DfBottomSheet.show(
      context,
      child: MedicalActSheet(
        act: act,
        onSave: (a) => a.id == 0 ? vm.addAct(a) : vm.updateAct(a),
      ),
    );
  }
}
