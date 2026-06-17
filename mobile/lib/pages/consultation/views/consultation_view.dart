import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/pages/medical_acts/models/medical_act_model.dart';
import 'package:dentiflow/pages/medical_acts/services/medical_acts_service.dart';
import '../models/consultation_model.dart';
import '../viewmodels/consultation_viewmodel.dart';

const List<int> _upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
const List<int> _upperLeft = [21, 22, 23, 24, 25, 26, 27, 28];
const List<int> _lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];
const List<int> _lowerLeft = [31, 32, 33, 34, 35, 36, 37, 38];
const List<String> _faces = ['O', 'V', 'L', 'M', 'D'];

class ConsultationView extends StatefulWidget {
  const ConsultationView({super.key});

  @override
  State<ConsultationView> createState() => _ConsultationViewState();
}

class _ConsultationViewState extends State<ConsultationView> {
  late final ConsultationViewModel _vm;
  late final int _patientId;
  List<MedicalAct> _acts = [];
  MedicalAct? _selectedAct;
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  bool _addingTreatment = false;

  @override
  void initState() {
    super.initState();
    _vm = Get.put(ConsultationViewModel());
    final args = Get.arguments;
    _patientId = args is int
        ? args
        : (args is Map ? (args['patientId'] ?? 0) as int : 0);
    if (_patientId > 0) _vm.loadForPatient(_patientId);
    _loadActs();
  }

  Future<void> _loadActs() async {
    try {
      final acts = await MedicalActsService.getActs();
      if (mounted) setState(() => _acts = acts);
    } catch (_) {}
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTreatment() async {
    if (_vm.selectedTooth.value < 0) {
      showThemedSnackbar('Dent requise', 'Sélectionnez une dent.',
          type: SnackbarType.warning);
      return;
    }
    if (_selectedAct == null) {
      showThemedSnackbar('Acte requis', 'Sélectionnez un acte médical.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _addingTreatment = true);
    try {
      final t = Treatment(
        id: 0,
        patientId: _patientId,
        acteMedicalId: _selectedAct!.id,
        numeroDent: _vm.selectedTooth.value,
        faceDentaire:
            _vm.selectedFace.value.isEmpty ? 'O' : _vm.selectedFace.value,
        prixApplique:
            double.tryParse(_priceCtrl.text) ?? _selectedAct!.tarifDeBase,
        dateIntervention: DateTime.now().toIso8601String(),
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await _vm.addTreatment(t);
      _priceCtrl.clear();
      _notesCtrl.clear();
      setState(() => _selectedAct = null);
      _vm.selectedTooth.value = -1;
      _vm.selectedFace.value = '';
      showThemedSnackbar('Traitement ajouté', '', type: SnackbarType.success);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _addingTreatment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_patientId == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consultation')),
        body: const DfEmptyState(
          icon: Icons.person_search_rounded,
          title: 'Aucun patient sélectionné',
          subtitle:
              'Ouvrez un dossier patient depuis la liste des patients pour démarrer une consultation.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Consultation')),
      body: Obx(() {
        if (_vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => _vm.loadForPatient(_patientId),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              const DfSectionLabel(title: 'Schéma dentaire FDI'),
              const SizedBox(height: AppSpacing.sm),
              _ToothChart(vm: _vm),
              const SizedBox(height: AppSpacing.base),
              Obx(() {
                if (_vm.selectedTooth.value < 0) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DfSectionLabel(
                        title:
                            'Dent ${_vm.selectedTooth.value} — Sélectionner la face'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: _faces
                          .map((f) => Obx(() => _FaceButton(
                                face: f,
                                selected: _vm.selectedFace.value == f,
                                onTap: () => _vm.selectFace(f),
                              )))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],
                );
              }),
              const DfSectionLabel(title: 'Ajouter un traitement'),
              const SizedBox(height: AppSpacing.sm),
              DfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'ACTE MÉDICAL',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DfColors.dimTextColor(context),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: DfColors.surface3(context),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: DfColors.borderColor(context)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<MedicalAct>(
                          value: _selectedAct,
                          isExpanded: true,
                          hint: Text('Sélectionner un acte',
                              style: TextStyle(
                                  color: DfColors.subTextColor(context),
                                  fontSize: 14)),
                          dropdownColor: DfColors.surface1(context),
                          items: _acts
                              .map((a) => DropdownMenuItem<MedicalAct>(
                                    value: a,
                                    child: Text(a.libelle,
                                        style:
                                            const TextStyle(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (act) => setState(() {
                            _selectedAct = act;
                            if (act != null) {
                              _priceCtrl.text =
                                  act.tarifDeBase.toStringAsFixed(2);
                            }
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    DfTextField(
                      label: 'Prix appliqué (DT)',
                      hint: '0.00',
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    DfTextField(
                      label: 'Notes',
                      hint: 'Observations...',
                      controller: _notesCtrl,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    DfPrimaryButton(
                      label: 'Ajouter le traitement',
                      loading: _addingTreatment,
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: _saveTreatment,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_vm.treatments.isNotEmpty) ...[
                const DfSectionLabel(title: 'Traitements récents'),
                const SizedBox(height: AppSpacing.sm),
                ..._vm.treatments.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DfCard(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DfColors.brandFaint(context),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${t.numeroDent}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: DfColors.brandPrimary(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Acte #${t.acteMedicalId}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(
                                    'Face: ${t.faceDentaire} • ${t.prixApplique.toStringAsFixed(2)} DT',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            DfColors.mutedTextColor(context))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }
}

class _ToothChart extends StatelessWidget {
  const _ToothChart({required this.vm});

  final ConsultationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._upperRight.map((n) => _ToothTile(number: n, vm: vm)),
              Container(
                  width: 1,
                  height: 36,
                  color: DfColors.borderColor(context)),
              ..._upperLeft.map((n) => _ToothTile(number: n, vm: vm)),
            ],
          ),
          const SizedBox(height: 4),
          Divider(height: 1, color: DfColors.borderColor(context)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._lowerRight.map((n) => _ToothTile(number: n, vm: vm)),
              Container(
                  width: 1,
                  height: 36,
                  color: DfColors.borderColor(context)),
              ..._lowerLeft.map((n) => _ToothTile(number: n, vm: vm)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToothTile extends StatelessWidget {
  const _ToothTile({required this.number, required this.vm});

  final int number;
  final ConsultationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool selected = vm.selectedTooth.value == number;
      return GestureDetector(
        onTap: () => vm.selectTooth(number),
        child: Container(
          width: 30,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          decoration: BoxDecoration(
            color: selected
                ? DfColors.brandPrimary(context)
                : DfColors.surface2(context),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected
                  ? DfColors.brandPrimary(context)
                  : DfColors.borderColor(context),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color:
                  selected ? Colors.white : DfColors.mutedTextColor(context),
            ),
          ),
        ),
      );
    });
  }
}

class _FaceButton extends StatelessWidget {
  const _FaceButton({
    required this.face,
    required this.selected,
    required this.onTap,
  });

  final String face;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 40,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? DfColors.brandPrimary(context)
              : DfColors.surface2(context),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected
                ? DfColors.brandPrimary(context)
                : DfColors.borderColor(context),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          face,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : DfColors.textColor(context),
          ),
        ),
      ),
    );
  }
}
