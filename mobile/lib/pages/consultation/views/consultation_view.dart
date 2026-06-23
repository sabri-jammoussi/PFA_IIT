import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import 'package:dentiflow/pages/medical_acts/models/medical_act_model.dart';
import 'package:dentiflow/pages/medical_acts/services/medical_acts_service.dart';
import '../models/consultation_model.dart';
import '../viewmodels/consultation_viewmodel.dart';

const List<int> _upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
const List<int> _upperLeft = [21, 22, 23, 24, 25, 26, 27, 28];
const List<int> _lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];
const List<int> _lowerLeft = [31, 32, 33, 34, 35, 36, 37, 38];

const List<_FaceOption> _faces = [
  _FaceOption('O', 'Occlusale (dessus)'),
  _FaceOption('V', 'Vestibulaire (extérieur)'),
  _FaceOption('L', 'Linguale (intérieur)'),
  _FaceOption('M', 'Mésiale (avant)'),
  _FaceOption('D', 'Distale (arrière)'),
];

class _FaceOption {
  const _FaceOption(this.value, this.label);
  final String value;
  final String label;
  String get display => '$value - $label';
}

String _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final DateTime? d = DateTime.tryParse(iso);
  if (d == null) return '—';
  final DateTime l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.day)}/${two(l.month)}/${l.year}';
}

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
  _FaceOption _selectedFace = _faces.first;
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _treatmentNotesCtrl = TextEditingController();
  final TextEditingController _clinicalNotesCtrl = TextEditingController();
  final TextEditingController _prescriptionCtrl = TextEditingController();

  bool _savingTreatment = false;
  bool _savingNotes = false;
  bool _savingPrescription = false;

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
    _treatmentNotesCtrl.dispose();
    _clinicalNotesCtrl.dispose();
    _prescriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTreatment() async {
    if (_vm.selectedTooth.value < 0) {
      showThemedSnackbar('Dent requise', 'Sélectionnez une dent du schéma.',
          type: SnackbarType.warning);
      return;
    }
    if (_selectedAct == null) {
      showThemedSnackbar('Acte requis', 'Sélectionnez un acte médical.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _savingTreatment = true);
    try {
      await _vm.addTreatment(
        acteMedicalId: _selectedAct!.id,
        numeroDent: _vm.selectedTooth.value,
        faceDentaire: _selectedFace.value,
        prixApplique:
            double.tryParse(_priceCtrl.text) ?? _selectedAct!.tarifDeBase,
        notes: _treatmentNotesCtrl.text,
      );
      _priceCtrl.clear();
      _treatmentNotesCtrl.clear();
      setState(() {
        _selectedAct = null;
        _selectedFace = _faces.first;
      });
      showThemedSnackbar('Soin enregistré', 'L\'acte a été posé avec succès.',
          type: SnackbarType.success);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _savingTreatment = false);
    }
  }

  Future<void> _saveClinicalNote() async {
    if (_clinicalNotesCtrl.text.trim().isEmpty) {
      showThemedSnackbar('Notes vides', 'Saisissez des remarques cliniques.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _savingNotes = true);
    try {
      await _vm.addClinicalNote(_clinicalNotesCtrl.text);
      _clinicalNotesCtrl.clear();
      showThemedSnackbar(
          'Remarques enregistrées', 'Le journal clinique a été mis à jour.',
          type: SnackbarType.success);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _savingNotes = false);
    }
  }

  Future<void> _savePrescription() async {
    if (_prescriptionCtrl.text.trim().isEmpty) {
      showThemedSnackbar('Prescription vide', 'Veuillez rédiger un traitement.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _savingPrescription = true);
    try {
      await _vm.addPrescription(_prescriptionCtrl.text);
      _prescriptionCtrl.clear();
      showThemedSnackbar('Ordonnance enregistrée',
          'Sauvegardée dans l\'historique du patient.',
          type: SnackbarType.success);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _savingPrescription = false);
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
              _MedicalAlertBanner(patient: _vm.patient.value),
              const SizedBox(height: AppSpacing.lg),

              // ===== FDI dental chart =====
              const DfSectionLabel(title: 'Schéma dentaire interactif (FDI)'),
              const SizedBox(height: AppSpacing.sm),
              _ToothChart(vm: _vm),
              const SizedBox(height: AppSpacing.base),

              // ===== Selected tooth history =====
              Obx(() => _ToothHistory(vm: _vm)),
              const SizedBox(height: AppSpacing.lg),

              // ===== Log a treatment =====
              const DfSectionLabel(title: 'Enregistrer un soin'),
              const SizedBox(height: AppSpacing.sm),
              _buildTreatmentForm(context),
              const SizedBox(height: AppSpacing.lg),

              // ===== Clinical notes journal =====
              const DfSectionLabel(title: 'Journal des notes cliniques'),
              const SizedBox(height: AppSpacing.sm),
              _buildNotesJournal(context),
              const SizedBox(height: AppSpacing.lg),

              // ===== Prescription form =====
              const DfSectionLabel(title: 'Formulaire d\'ordonnance'),
              const SizedBox(height: AppSpacing.sm),
              _buildPrescriptionForm(context),
              const SizedBox(height: 90),
            ],
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------------------

  Widget _buildTreatmentForm(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final int tooth = _vm.selectedTooth.value;
            return Text(
              tooth < 0
                  ? 'Sélectionnez une dent du schéma ci-dessus'
                  : 'Soin sur la dent $tooth',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: tooth < 0
                    ? DfColors.mutedTextColor(context)
                    : DfColors.textColor(context),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.base),
          DfDropdownField<MedicalAct>(
            label: 'Acte médical',
            required: true,
            items: _acts,
            value: _selectedAct,
            labelOf: (a) => '${a.libelle} (${a.tarifDeBase.toStringAsFixed(0)} DT)',
            hint: 'Choisir l\'acte',
            onChanged: (act) => setState(() {
              _selectedAct = act;
              if (act != null) {
                _priceCtrl.text = act.tarifDeBase.toStringAsFixed(2);
              }
            }),
          ),
          const SizedBox(height: AppSpacing.base),
          DfDropdownField<_FaceOption>(
            label: 'Face dentaire',
            required: true,
            items: _faces,
            value: _selectedFace,
            labelOf: (f) => f.display,
            onChanged: (f) => setState(() => _selectedFace = f ?? _faces.first),
          ),
          const SizedBox(height: AppSpacing.base),
          DfTextField(
            label: 'Tarif appliqué (DT)',
            hint: '0.00',
            controller: _priceCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          DfTextField(
            label: 'Observations / notes',
            hint: 'Détails cliniques de l\'intervention...',
            controller: _treatmentNotesCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.base),
          DfPrimaryButton(
            label: 'Valider l\'acte clinique',
            loading: _savingTreatment,
            icon: Icons.save_rounded,
            onPressed: _saveTreatment,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesJournal(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DfTextField(
            label: 'Compte-rendu de séance',
            hint: 'Rédiger le compte-rendu textuel de la séance de soin...',
            controller: _clinicalNotesCtrl,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.base),
          DfPrimaryButton(
            label: 'Enregistrer notes séance',
            loading: _savingNotes,
            icon: Icons.check_rounded,
            onPressed: _saveClinicalNote,
          ),
          const SizedBox(height: AppSpacing.base),
          Obx(() {
            final list = _vm.consultations;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DERNIÈRES CONSULTATIONS',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.dimTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (list.isEmpty)
                  Text('Aucune consultation enregistrée.',
                      style: TextStyle(
                          fontSize: 13,
                          color: DfColors.mutedTextColor(context)))
                else
                  ...list.take(8).map((c) => _JournalEntry(
                        title: 'Consultation #${c.id}',
                        date: _fmtDate(c.dateConsultation),
                        body: c.notesObservations ?? '—',
                      )),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrescriptionForm(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DfTextField(
            label: 'Traitement prescrit',
            hint:
                'Ex:\n1. Clamoxyl 1g (matin et soir, 6 jours)\n2. Doliprane 1g (si douleur)',
            controller: _prescriptionCtrl,
            maxLines: 6,
          ),
          const SizedBox(height: AppSpacing.base),
          DfPrimaryButton(
            label: 'Enregistrer l\'ordonnance',
            loading: _savingPrescription,
            icon: Icons.medication_outlined,
            onPressed: _savePrescription,
          ),
          const SizedBox(height: AppSpacing.base),
          Obx(() {
            final list = _vm.prescriptions;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HISTORIQUE ORDONNANCES',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.dimTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (list.isEmpty)
                  Text('Aucune ordonnance enregistrée.',
                      style: TextStyle(
                          fontSize: 13,
                          color: DfColors.mutedTextColor(context)))
                else
                  ...list.take(8).map((o) => _JournalEntry(
                        title: 'ORD-${o.id}',
                        date: _fmtDate(o.dateEmission),
                        body: o.traitement,
                      )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ===========================================================================
// Medical alert banner (blood group + medical history)
// ===========================================================================
class _MedicalAlertBanner extends StatelessWidget {
  const _MedicalAlertBanner({required this.patient});
  final PatientClinical? patient;

  @override
  Widget build(BuildContext context) {
    final Color danger = DfColors.danger(context);
    final Color faint = DfColors.dangerFaint(context);
    final String antecedents = (patient?.antecedentsMedicaux?.trim().isNotEmpty ??
            false)
        ? patient!.antecedentsMedicaux!.trim()
        : 'Aucune allergie ou maladie chronique majeure signalée pour ce patient.';
    final String blood = (patient?.groupSanguin?.trim().isNotEmpty ?? false)
        ? patient!.groupSanguin!.trim()
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: faint,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: danger.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    size: 18, color: danger),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Alerte médicale & antécédents critiques',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: danger,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: DfColors.surface1(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: danger.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SANG ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: DfColors.mutedTextColor(context),
                          letterSpacing: 0.8,
                        )),
                    Text(blood,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: danger,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            antecedents,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: DfColors.subTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// FDI tooth chart
// ===========================================================================
class _ToothChart extends StatelessWidget {
  const _ToothChart({required this.vm});
  final ConsultationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          Obx(() {
            final p = vm.patient.value;
            return Align(
              alignment: Alignment.centerRight,
              child: Text(
                p == null ? '' : 'Patient: ${p.fullName}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DfColors.mutedTextColor(context),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.sm),
          _jawLabel(context, 'Mâchoire supérieure'),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _quadrantRow(context, _upperRight, _upperLeft),
          ),
          const SizedBox(height: AppSpacing.base),
          Divider(height: 1, color: DfColors.borderColor(context)),
          const SizedBox(height: AppSpacing.base),
          _jawLabel(context, 'Mâchoire inférieure'),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _quadrantRow(context, _lowerRight, _lowerLeft),
          ),
          const SizedBox(height: AppSpacing.base),
          Divider(height: 1, color: DfColors.borderColor(context)),
          const SizedBox(height: AppSpacing.md),
          _legend(context),
        ],
      ),
    );
  }

  Widget _jawLabel(BuildContext context, String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: DfColors.dimTextColor(context),
          letterSpacing: 1.4,
        ),
      );

  Widget _quadrantRow(BuildContext context, List<int> right, List<int> left) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...right.map((n) => _ToothTile(number: n, vm: vm)),
        Container(
          width: 2,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: DfColors.borderStrongColor(context),
        ),
        ...left.map((n) => _ToothTile(number: n, vm: vm)),
      ],
    );
  }

  Widget _legend(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.sm,
      children: [
        _legendItem(context, 'Sain', DfColors.surface2(context),
            DfColors.borderStrongColor(context)),
        _legendItem(context, 'Soigné', DfColors.successFaint(context),
            DfColors.success(context)),
        _legendItem(context, 'Pathologie / retrait',
            DfColors.dangerFaint(context), DfColors.danger(context)),
        _legendItem(context, 'Sélection', DfColors.infoFaint(context),
            DfColors.info(context)),
      ],
    );
  }

  Widget _legendItem(
      BuildContext context, String label, Color fill, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: DfColors.mutedTextColor(context),
            letterSpacing: 0.4,
          ),
        ),
      ],
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
      // depend on treatments + selection
      final int selected = vm.selectedTooth.value;
      final bool isSelected = selected == number;
      final ToothStatus status = vm.statusFor(number);
      final int count = vm.treatmentCountFor(number);

      late Color fill;
      late Color border;
      late Color fg;
      if (isSelected) {
        fill = DfColors.infoFaint(context);
        border = DfColors.info(context);
        fg = DfColors.info(context);
      } else {
        switch (status) {
          case ToothStatus.alarm:
            fill = DfColors.dangerFaint(context);
            border = DfColors.danger(context).withOpacity(0.55);
            fg = DfColors.danger(context);
            break;
          case ToothStatus.treated:
            fill = DfColors.successFaint(context);
            border = DfColors.success(context).withOpacity(0.55);
            fg = DfColors.success(context);
            break;
          case ToothStatus.healthy:
            fill = DfColors.surface2(context);
            border = DfColors.borderColor(context);
            fg = DfColors.mutedTextColor(context);
            break;
        }
      }

      return GestureDetector(
        onTap: () => vm.selectTooth(number),
        child: Container(
          width: 30,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
                color: border, width: isSelected ? 1.6 : 1),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$number',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              if (count > 0)
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: fg.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ===========================================================================
// Selected tooth history
// ===========================================================================
class _ToothHistory extends StatelessWidget {
  const _ToothHistory({required this.vm});
  final ConsultationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final int tooth = vm.selectedTooth.value;
    if (tooth < 0) {
      return DfCard(
        child: Row(
          children: [
            Icon(Icons.touch_app_outlined,
                size: 18, color: DfColors.mutedTextColor(context)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Touchez une dent du schéma pour inspecter son historique de soins.',
                style: TextStyle(
                    fontSize: 13, color: DfColors.mutedTextColor(context)),
              ),
            ),
          ],
        ),
      );
    }

    final List<Treatment> list = vm.treatmentsForTooth(tooth);
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dent $tooth — Historique clinique',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: DfColors.textColor(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (list.isEmpty)
            Text(
              'Aucun traitement clinique enregistré pour la dent $tooth.',
              style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: DfColors.mutedTextColor(context)),
            )
          else
            ...list.map((s) => _ToothHistoryItem(soin: s)),
        ],
      ),
    );
  }
}

class _ToothHistoryItem extends StatelessWidget {
  const _ToothHistoryItem({required this.soin});
  final Treatment soin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: DfColors.surface3(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DfColors.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  soin.acteMedicalLibelle ?? 'Acte #${soin.acteMedicalId}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DfColors.textColor(context),
                  ),
                ),
              ),
              Text(
                _fmtDate(soin.consultationDate),
                style: TextStyle(
                    fontSize: 11, color: DfColors.mutedTextColor(context)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Face ${soin.faceDentaire ?? '—'}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: DfColors.mutedTextColor(context),
                ),
              ),
              const SizedBox(width: 8),
              Text('•',
                  style:
                      TextStyle(color: DfColors.mutedTextColor(context))),
              const SizedBox(width: 8),
              Text(
                '${soin.prixApplique.toStringAsFixed(2)} DT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DfColors.info(context),
                ),
              ),
            ],
          ),
          if (soin.notes != null && soin.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              soin.notes!,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: DfColors.subTextColor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
// Journal entry (consultations / prescriptions)
// ===========================================================================
class _JournalEntry extends StatelessWidget {
  const _JournalEntry({
    required this.title,
    required this.date,
    required this.body,
  });
  final String title;
  final String date;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: DfColors.surface3(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: DfColors.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DfColors.subTextColor(context),
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(
                    fontSize: 11, color: DfColors.mutedTextColor(context)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: DfColors.textColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
