import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/patient_model.dart';
import '../viewmodels/patients_viewmodel.dart';
import 'patient_add_sheet.dart';

class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  State<PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<PatientsListView> {
  final PatientsViewModel _vm = Get.put(PatientsViewModel());
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _vm.loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    DfBottomSheet.show(
      context,
      child: PatientAddSheet(
        onSaved: (Patient p, {bool invite = false}) =>
            _vm.addPatient(p, invite: invite),
      ),
    );
  }

  void _openEditSheet(Patient patient) {
    DfBottomSheet.show(
      context,
      child: PatientAddSheet(
        patient: patient,
        onSaved: (Patient p, {bool invite = false}) {},
        onUpdated: _vm.updatePatient,
      ),
    );
  }

  Future<void> _confirmArchive(Patient patient) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archiver le patient'),
        content: Text(
            'Voulez-vous vraiment archiver le dossier de ${patient.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: DfColors.red),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
    if (ok == true) _vm.archivePatient(patient.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, prénom ou téléphone...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintStyle:
                      TextStyle(color: DfColors.mutedTextColor(context)),
                ),
                onChanged: _vm.search,
              )
            : const Text('Patients'),
        actions: [
          IconButton(
            icon:
                Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                _vm.search('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nouveau patient'),
      ),
      body: Obx(() {
        if (_vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_vm.patients.isEmpty) {
          return DfEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'Aucun patient',
            subtitle: _vm.searchQuery.value.isEmpty
                ? 'Ajoutez votre premier patient en appuyant sur le bouton ci-dessous.'
                : 'Aucun patient trouvé correspondant à la recherche.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => _vm.loadPatients(),
          child: ListView.separated(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
            itemCount:
                _vm.patients.length + 1 + (_vm.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              // Header: count badge.
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      const Spacer(),
                      DfPill(
                        label: '${_vm.totalCount.value} dossiers trouvés',
                        color: DfColors.mutedTextColor(context),
                        backgroundColor: DfColors.surface2(context),
                      ),
                    ],
                  ),
                );
              }
              final int patientIndex = index - 1;
              if (patientIndex == _vm.patients.length) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ));
              }
              final Patient patient = _vm.patients[patientIndex];
              return _PatientCard(
                patient: patient,
                onTap: () =>
                    Get.toNamed('/patient-profile', arguments: patient),
                onEdit: () => _openEditSheet(patient),
                onDelete: () => _confirmArchive(patient),
              );
            },
          ),
        );
      }),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _formatDob(String? iso) {
    if (iso == null || iso.isEmpty) return 'Non renseigné';
    final DateTime? d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAntecedents =
        patient.antecedentsMedicaux != null &&
            patient.antecedentsMedicaux!.trim().isNotEmpty;

    return DfCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DfColors.brandFaint(context),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  patient.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: DfColors.brandPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Né(e) le ${_formatDob(patient.dateNaissance)}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DfColors.dimTextColor(context))),
                  ],
                ),
              ),
              if (patient.groupSanguin != null &&
                  patient.groupSanguin!.isNotEmpty)
                DfStatusBadge.danger(context, 'Gr. ${patient.groupSanguin}'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Contact
          if (patient.phone != null && patient.phone!.isNotEmpty)
            _contactLine(context, Icons.phone_outlined, patient.phone!),
          _contactLine(context, Icons.email_outlined,
              (patient.email?.isNotEmpty == true)
                  ? patient.email!
                  : 'Pas de courriel'),
          const SizedBox(height: AppSpacing.sm),
          // Antecedents snippet
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: DfColors.warning(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasAntecedents
                      ? patient.antecedentsMedicaux!
                      : 'Aucun antécédent majeur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: DfColors.mutedTextColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: DfColors.borderColor(context)),
          const SizedBox(height: AppSpacing.xs),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionBtn(context, Icons.folder_open_rounded, 'Fiche', onTap),
              _iconBtn(context, Icons.edit_outlined, onEdit),
              _iconBtn(context, Icons.delete_outline_rounded, onDelete,
                  danger: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactLine(BuildContext context, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: DfColors.dimTextColor(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DfColors.subTextColor(context))),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      ),
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      icon: Icon(icon,
          color: danger
              ? DfColors.danger(context)
              : DfColors.mutedTextColor(context)),
    );
  }
}
