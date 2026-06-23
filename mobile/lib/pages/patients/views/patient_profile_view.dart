import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/api_service.dart';
import 'package:dentiflow/core/services/user_claims_service.dart';
import 'package:dentiflow/core/constants/user_role.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_tooth_grid.dart';
import '../models/patient_model.dart';

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView>
    with SingleTickerProviderStateMixin {
  late Patient _patient;
  TabController? _tabCtrl;

  List<Map<String, dynamic>> _consultations = [];
  List<Map<String, dynamic>> _soins = [];
  List<Map<String, dynamic>> _ordonnances = [];
  List<Map<String, dynamic>> _actes = [];

  bool _loading = true;
  bool _isSecretary = false;
  int? _selectedTooth;

  @override
  void initState() {
    super.initState();
    _patient = Get.arguments as Patient;
    _resolveRole();
    _loadAll();
  }

  Future<void> _resolveRole() async {
    final UserClaims user = await UserClaimsService.currentUser();
    final bool secretary = user.role == UserRole.secretary;
    setState(() {
      _isSecretary = secretary;
      // Secretary: only "Schéma Dentaire". Others: 3 tabs.
      _tabCtrl = TabController(length: secretary ? 1 : 3, vsync: this);
    });
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      // Refresh the full patient record (list cards may carry partial data).
      try {
        final dynamic pData = await ApiService.get('/patients/${_patient.id}');
        if (pData is Map<String, dynamic>) {
          _patient = Patient.fromJson(pData);
        }
      } catch (_) {}

      final results = await Future.wait([
        ApiService.get('/actes-medicaux'),
        ApiService.get(
            '/soins-effectues?patientId=${_patient.id}&pageSize=100'),
        ApiService.get(
            '/consultations?patientId=${_patient.id}&pageSize=100'),
        ApiService.get('/ordonnances?patientId=${_patient.id}&pageSize=100'),
      ]);
      _actes = _toList(results[0]);
      _soins = _toList(results[1]);
      _consultations = _toList(results[2]);
      _ordonnances = _toList(results[3]);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic> && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ---- Tooth helpers (mirror Vue getToothStatus) -------------------------

  List<Map<String, dynamic>> _soinsForTooth(int tooth) =>
      _soins.where((s) => s['numeroDent'] == tooth).toList();

  ToothStatus _statusOf(int tooth) {
    final List<Map<String, dynamic>> t = _soinsForTooth(tooth);
    if (t.isEmpty) return ToothStatus.healthy;
    final bool pathology = t.any((s) {
      final String lib =
          (s['acteMedicalLibelle'] ?? '').toString().toLowerCase();
      return lib.contains('canal') || lib.contains('extraction');
    });
    return pathology ? ToothStatus.pathology : ToothStatus.treated;
  }

  int _countOf(int tooth) => _soinsForTooth(tooth).length;

  // ---- Formatting --------------------------------------------------------

  String _fmtDate(dynamic iso, {bool long = false}) {
    if (iso == null || iso.toString().isEmpty) return 'Non renseigné';
    final DateTime? d = DateTime.tryParse(iso.toString());
    if (d == null) return iso.toString();
    if (long) {
      const months = [
        'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _fmtPrice(dynamic v) {
    final double d = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
    return '${d.toStringAsFixed(2)} DT';
  }

  @override
  void dispose() {
    _tabCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TabController? tab = _tabCtrl;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dossier Clinique'),
        bottom: (_loading || tab == null)
            ? null
            : TabBar(
                controller: tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  const Tab(text: 'Schéma Dentaire'),
                  if (!_isSecretary) const Tab(text: 'Historique des Soins'),
                  if (!_isSecretary) const Tab(text: 'Prescriptions'),
                ],
              ),
      ),
      body: (_loading || tab == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeaderCards(),
                Expanded(
                  child: TabBarView(
                    controller: tab,
                    children: [
                      _buildSchemaTab(),
                      if (!_isSecretary) _buildHistoryTab(),
                      if (!_isSecretary) _buildPrescriptionsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ---- Demographics + alert (always visible) -----------------------------

  Widget _buildHeaderCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
      child: Column(
        children: [
          DfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: DfColors.brandFaint(context),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(_patient.initials,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: DfColors.brandPrimary(context))),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_patient.fullName,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          Text('Dossier #${_patient.id}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: DfColors.dimTextColor(context))),
                        ],
                      ),
                    ),
                    if (_patient.groupSanguin != null &&
                        _patient.groupSanguin!.isNotEmpty)
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: DfColors.dangerFaint(context),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color:
                                  DfColors.danger(context).withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('SANG',
                                style: TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: DfColors.danger(context))),
                            Text(_patient.groupSanguin!,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: DfColors.danger(context))),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DfInfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Date de naissance',
                    value: _fmtDate(_patient.dateNaissance, long: true)),
                if (_patient.phone?.isNotEmpty == true)
                  DfInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: _patient.phone!),
                DfInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _patient.email?.isNotEmpty == true
                        ? _patient.email!
                        : 'Non renseigné'),
                DfInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Adresse',
                    value: _patient.adresse?.isNotEmpty == true
                        ? _patient.adresse!
                        : 'Non renseigné'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAlertBox(),
        ],
      ),
    );
  }

  Widget _buildAlertBox() {
    final bool has = _patient.antecedentsMedicaux?.trim().isNotEmpty == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: DfColors.dangerFaint(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border:
            Border.all(color: DfColors.danger(context).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: DfColors.danger(context)),
              const SizedBox(width: 6),
              Text('ANTÉCÉDENTS & ALERTES',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: DfColors.danger(context))),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            has
                ? _patient.antecedentsMedicaux!
                : 'Aucun antécédent médical signalé par le patient.',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: DfColors.danger(context)),
          ),
        ],
      ),
    );
  }

  // ---- Tab 1: Schéma Dentaire --------------------------------------------

  Widget _buildSchemaTab() {
    final List<Map<String, dynamic>> toothSoins =
        _selectedTooth == null ? [] : _soinsForTooth(_selectedTooth!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, 0, AppSpacing.base, AppSpacing.xxl),
      children: [
        DfToothGrid(
          selectedTooth: _selectedTooth,
          statusOf: _statusOf,
          countOf: _countOf,
          onToothSelected: (t) => setState(() => _selectedTooth = t),
        ),
        const SizedBox(height: AppSpacing.base),
        // Selected tooth history
        DfSectionLabel(
            title: _selectedTooth == null
                ? 'Sélectionnez une dent'
                : 'Dent $_selectedTooth — Historique clinique',
            padding: const EdgeInsets.only(bottom: AppSpacing.sm)),
        if (_selectedTooth == null)
          _hint('Touchez une dent du schéma pour inspecter son historique.')
        else if (toothSoins.isEmpty)
          _hint('Aucun traitement enregistré sur la dent $_selectedTooth.')
        else
          ...toothSoins.map(_toothSoinCard),

        // Treatment logger — hidden for secretary (role 3).
        if (!_isSecretary) ...[
          const SizedBox(height: AppSpacing.lg),
          DfSecondaryButton(
            label: _selectedTooth == null
                ? 'Sélectionnez une dent pour enregistrer un soin'
                : 'Enregistrer un soin sur la dent $_selectedTooth',
            icon: Icons.add_circle_outline_rounded,
            onPressed:
                _selectedTooth == null ? null : () => _openSoinLogger(),
          ),
        ],
      ],
    );
  }

  Widget _toothSoinCard(Map<String, dynamic> soin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DfCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(soin['acteMedicalLibelle']?.toString() ?? '-',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                Text(_fmtDate(soin['consultationDate']),
                    style: TextStyle(
                        fontSize: 11,
                        color: DfColors.mutedTextColor(context))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                DfStatusBadge.info(
                    context, 'Face ${soin['faceDentaire'] ?? '-'}'),
                const SizedBox(width: AppSpacing.sm),
                Text(_fmtPrice(soin['prixApplique']),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DfColors.brandPrimary(context))),
              ],
            ),
            if ((soin['notes']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(soin['notes'].toString(),
                  style: TextStyle(
                      fontSize: 12,
                      color: DfColors.mutedTextColor(context))),
            ],
          ],
        ),
      ),
    );
  }

  void _openSoinLogger() {
    DfBottomSheet.show(
      context,
      child: _SoinLoggerSheet(
        toothNumber: _selectedTooth!,
        actes: _actes,
        onSubmit: _submitSoin,
      ),
    );
  }

  Future<void> _submitSoin(Map<String, dynamic> form) async {
    // Find/create an active consultation (mirrors Vue handleAddSoin).
    int? consultationId;
    if (_consultations.isNotEmpty) {
      consultationId = _consultations.first['id'] as int?;
    } else {
      try {
        final UserClaims user = await UserClaimsService.currentUser();
        final dynamic created = await ApiService.post('/consultations', body: {
          'dateConsultation': DateTime.now().toIso8601String(),
          'notesObservations': 'Créée automatiquement pour actes cliniques',
          'patientId': _patient.id,
          'dentisteId': int.tryParse(user.id) ?? 1,
        });
        consultationId =
            (created is Map ? created['id'] : created) as int? ?? null;
        if (consultationId != null) {
          _consultations.insert(0, {'id': consultationId});
        }
      } catch (_) {}
    }

    try {
      await ApiService.post('/soins-effectues', body: {
        'numeroDent': _selectedTooth,
        'faceDentaire': form['faceDentaire'],
        'prixApplique': form['prixApplique'],
        'notes': form['notes'],
        'acteMedicalId': form['acteMedicalId'],
        'consultationId': consultationId,
      });
      showThemedSnackbar('Soin enregistré', 'Acte ajouté à la fiche clinique.',
          type: SnackbarType.success);
      if (mounted) Navigator.pop(context);
      await _loadAll();
    } catch (_) {}
  }

  // ---- Tab 2: Historique des Soins ---------------------------------------

  Widget _buildHistoryTab() {
    if (_soins.isEmpty) {
      return const DfEmptyState(
        icon: Icons.healing_outlined,
        title: 'Aucun traitement',
        subtitle: 'Aucun traitement clinique répertorié.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: _soins.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final s = _soins[i];
        return DfCard(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DfColors.brandFaint(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text('${s['numeroDent'] ?? '-'}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: DfColors.brandPrimary(context))),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['acteMedicalLibelle']?.toString() ?? '-',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                        '${_fmtDate(s['consultationDate'])}  •  Face ${s['faceDentaire'] ?? '-'}',
                        style: TextStyle(
                            fontSize: 11,
                            color: DfColors.mutedTextColor(context))),
                    if ((s['notes']?.toString() ?? '').isNotEmpty)
                      Text(s['notes'].toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: DfColors.dimTextColor(context))),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(_fmtPrice(s['prixApplique']),
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: DfColors.textColor(context))),
            ],
          ),
        );
      },
    );
  }

  // ---- Tab 3: Prescriptions ----------------------------------------------

  Widget _buildPrescriptionsTab() {
    if (_ordonnances.isEmpty) {
      return const DfEmptyState(
        icon: Icons.description_outlined,
        title: 'Aucune ordonnance',
        subtitle: 'Aucune ordonnance émise pour ce patient.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: _ordonnances.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final o = _ordonnances[i];
        return DfCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Ordonnance #ORD-${o['id']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  IconButton(
                    onPressed: () => showThemedSnackbar('Impression',
                        'Fonction d\'impression bientôt disponible.',
                        type: SnackbarType.info),
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    icon: Icon(Icons.print_outlined,
                        color: DfColors.mutedTextColor(context)),
                  ),
                ],
              ),
              Text('Émise le ${_fmtDate(o['dateEmission'])}',
                  style: TextStyle(
                      fontSize: 11,
                      color: DfColors.mutedTextColor(context))),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: DfColors.surface3(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: DfColors.borderColor(context)),
                ),
                child: Text(o['traitement']?.toString() ?? '-',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: DfColors.textColor(context))),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: DfColors.mutedTextColor(context))),
        ),
      );
}

// ===========================================================================
// Treatment logger sheet (dentist only)
// ===========================================================================

class _SoinLoggerSheet extends StatefulWidget {
  const _SoinLoggerSheet({
    required this.toothNumber,
    required this.actes,
    required this.onSubmit,
  });

  final int toothNumber;
  final List<Map<String, dynamic>> actes;
  final Future<void> Function(Map<String, dynamic> form) onSubmit;

  @override
  State<_SoinLoggerSheet> createState() => _SoinLoggerSheetState();
}

class _SoinLoggerSheetState extends State<_SoinLoggerSheet> {
  static const List<Map<String, String>> _faces = [
    {'value': 'O', 'label': 'O - Occlusale (dessus)'},
    {'value': 'V', 'label': 'V - Vestibulaire (extérieur)'},
    {'value': 'L', 'label': 'L - Linguale (intérieur)'},
    {'value': 'M', 'label': 'M - Mésiale (avant)'},
    {'value': 'D', 'label': 'D - Distale (arrière)'},
  ];

  Map<String, dynamic>? _acte;
  String _face = 'O';
  final TextEditingController _prixCtrl = TextEditingController(text: '0');
  final TextEditingController _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _prixCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onActeSelected(Map<String, dynamic>? a) {
    setState(() {
      _acte = a;
      if (a != null && a['tarifDeBase'] != null) {
        _prixCtrl.text = '${a['tarifDeBase']}';
      }
    });
  }

  Future<void> _submit() async {
    if (_acte == null) {
      showThemedSnackbar('Acte requis', 'Veuillez sélectionner un acte médical.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _saving = true);
    await widget.onSubmit({
      'acteMedicalId': _acte!['id'],
      'faceDentaire': _face,
      'prixApplique': double.tryParse(_prixCtrl.text.trim()) ?? 0,
      'notes': _notesCtrl.text.trim(),
    });
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return DfBottomSheet(
      title: 'Soin sur la dent ${widget.toothNumber}',
      subtitle: 'Enregistrer un acte clinique.',
      icon: Icons.medical_services_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DfDropdownField<Map<String, dynamic>>(
            label: 'Acte médical',
            hint: 'Sélectionner un acte',
            required: true,
            items: widget.actes,
            value: _acte,
            labelOf: (a) =>
                '${a['libelle']} (${a['tarifDeBase']} DT)',
            onChanged: _onActeSelected,
          ),
          const SizedBox(height: AppSpacing.base),
          DfDropdownField<Map<String, String>>(
            label: 'Face dentaire',
            required: true,
            items: _faces,
            value: _faces.firstWhere((f) => f['value'] == _face),
            labelOf: (f) => f['label']!,
            onChanged: (f) =>
                setState(() => _face = f?['value'] ?? 'O'),
          ),
          const SizedBox(height: AppSpacing.base),
          DfTextField(
            label: 'Tarif appliqué (DT)',
            controller: _prixCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.base),
          DfTextField(
            label: 'Observations / Notes',
            hint: 'Détails techniques du soin posé...',
            controller: _notesCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xl),
          DfPrimaryButton(
            label: 'Valider l\'acte clinique',
            icon: Icons.save_rounded,
            loading: _saving,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}
