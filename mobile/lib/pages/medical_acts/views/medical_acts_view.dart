import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
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
      floatingActionButton: Obx(() => vm.canManage.value
          ? FloatingActionButton.extended(
              onPressed: () => _openSheet(context, vm, null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nouvel acte'),
            )
          : const SizedBox.shrink()),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
              child: DfTextField(
                label: 'Rechercher',
                hint: 'Libellé ou code nomenclature...',
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: DfColors.mutedTextColor(context)),
                onChanged: (v) => vm.search.value = v,
              ),
            ),
            Expanded(child: _buildList(context, vm)),
          ],
        );
      }),
    );
  }

  Widget _buildList(BuildContext context, MedicalActsViewModel vm) {
    final List<MedicalAct> list = vm.filteredActs;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: vm.loadActs,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            DfEmptyState(
              icon: Icons.medical_services_outlined,
              title: vm.search.value.trim().isEmpty
                  ? 'Aucun acte médical'
                  : 'Aucun résultat',
              subtitle: vm.search.value.trim().isEmpty
                  ? 'Le catalogue des actes est vide.'
                  : 'Aucun acte ne correspond à votre recherche.',
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: vm.loadActs,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, 0, AppSpacing.base, 100),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final MedicalAct act = list[index];
          return _ActCard(
            act: act,
            canManage: vm.canManage.value,
            onEdit: () => _openSheet(context, vm, act),
            onDelete: () => _confirmDelete(context, vm, act),
          );
        },
      ),
    );
  }

  void _openSheet(
      BuildContext context, MedicalActsViewModel vm, MedicalAct? act) {
    if (!vm.canManage.value) return;
    DfBottomSheet.show(
      context,
      child: MedicalActSheet(
        act: act,
        onSave: (a) => a.id == 0 ? vm.addAct(a) : vm.updateAct(a),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, MedicalActsViewModel vm, MedicalAct act) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer l'acte"),
        content: Text(
            'Voulez-vous vraiment retirer « ${act.libelle} » du catalogue ? Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteAct(act);
            },
            style: TextButton.styleFrom(foregroundColor: DfColors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _ActCard extends StatelessWidget {
  const _ActCard({
    required this.act,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  final MedicalAct act;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);
    return DfCard(
      onTap: canManage ? onEdit : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Code nomenclature — monospace chip
              if (act.codeNomenclature?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: DfColors.surface3(context),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: DfColors.borderColor(context)),
                  ),
                  child: Text(
                    act.codeNomenclature!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: DfColors.textColor(context),
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '${act.tarifDeBase.toStringAsFixed(2)} DT',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  act.libelle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: DfColors.textColor(context),
                  ),
                ),
              ),
              if (canManage) ...[
                _IconAction(
                  icon: Icons.edit_outlined,
                  color: DfColors.mutedTextColor(context),
                  onTap: onEdit,
                ),
                const SizedBox(width: AppSpacing.xs),
                _IconAction(
                  icon: Icons.delete_outline_rounded,
                  color: DfColors.red,
                  onTap: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: DfColors.surface3(context),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: DfColors.borderColor(context)),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
