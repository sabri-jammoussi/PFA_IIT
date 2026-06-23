import 'package:flutter/material.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import '../models/patient_model.dart';

const List<String> kBloodGroups = [
  'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
];

/// Add OR edit patient sheet — mirrors Vue PatientAddDialog / PatientUpdateDialog.
/// Pass [patient] to edit an existing record; leave null to create a new one.
class PatientAddSheet extends StatefulWidget {
  const PatientAddSheet({
    required this.onSaved,
    this.onUpdated,
    this.patient,
    super.key,
  });

  /// Called for a new patient. [invite] true => create + email portal invitation.
  final void Function(Patient patient, {bool invite}) onSaved;

  /// Called when editing an existing patient.
  final void Function(Patient patient)? onUpdated;

  final Patient? patient;

  bool get isEdit => patient != null;

  @override
  State<PatientAddSheet> createState() => _PatientAddSheetState();
}

class _PatientAddSheetState extends State<PatientAddSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _antecedentsCtrl = TextEditingController();
  DateTime? _dateNaissance;
  String? _groupSanguin;
  bool _invite = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Patient? p = widget.patient;
    if (p != null) {
      _nomCtrl.text = p.nom;
      _prenomCtrl.text = p.prenom;
      _emailCtrl.text = p.email ?? '';
      _phoneCtrl.text = p.phone ?? '';
      _adresseCtrl.text = p.adresse ?? '';
      _antecedentsCtrl.text = p.antecedentsMedicaux ?? '';
      _groupSanguin = p.groupSanguin?.isEmpty == true ? null : p.groupSanguin;
      if (p.dateNaissance != null && p.dateNaissance!.isNotEmpty) {
        _dateNaissance = DateTime.tryParse(p.dateNaissance!);
      }
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _adresseCtrl.dispose();
    _antecedentsCtrl.dispose();
    super.dispose();
  }

  Patient _buildPatient() => Patient(
        id: widget.patient?.id ?? 0,
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        adresse:
            _adresseCtrl.text.trim().isEmpty ? null : _adresseCtrl.text.trim(),
        antecedentsMedicaux: _antecedentsCtrl.text.trim().isEmpty
            ? null
            : _antecedentsCtrl.text.trim(),
        groupSanguin: _groupSanguin,
        dateNaissance: _dateNaissance == null
            ? null
            : _dateNaissance!.toIso8601String().split('T').first,
        isActive: widget.patient?.isActive ?? true,
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final Patient p = _buildPatient();
      if (widget.isEdit) {
        widget.onUpdated?.call(p);
      } else {
        final bool willInvite =
            _invite && (p.email != null && p.email!.isNotEmpty);
        widget.onSaved(p, invite: willInvite);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Champ requis' : null;

  @override
  Widget build(BuildContext context) {
    final bool hasEmail = _emailCtrl.text.trim().isNotEmpty;

    return DfBottomSheet(
      title: widget.isEdit ? 'Modifier la fiche patient' : 'Nouveau patient',
      subtitle: widget.isEdit
          ? 'Mettre à jour les informations du dossier.'
          : 'Créez un nouveau dossier patient.',
      icon: widget.isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfTextField(
              label: 'Prénom',
              hint: 'Ex: Sophie',
              controller: _prenomCtrl,
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Nom',
              hint: 'Ex: Martin',
              controller: _nomCtrl,
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.base),
            DfDateField(
              label: 'Date de naissance',
              value: _dateNaissance,
              onTap: () => showDfDatePicker(
                context,
                _dateNaissance,
                (d) => setState(() => _dateNaissance = d),
                lastDate: DateTime.now(),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Téléphone',
              hint: 'Ex: 06 12 34 56 78',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: _requiredValidator,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Email',
              hint: 'Ex: sophie.m@mail.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.base),
            DfDropdownField<String>(
              label: 'Groupe sanguin',
              hint: 'Groupe',
              items: kBloodGroups,
              labelOf: (g) => g,
              value: _groupSanguin,
              onChanged: (g) => setState(() => _groupSanguin = g),
            ),
            // Invite checkbox — only when creating AND an email is present.
            if (!widget.isEdit && hasEmail) ...[
              const SizedBox(height: AppSpacing.base),
              _InviteCheckbox(
                value: _invite,
                onChanged: (v) => setState(() => _invite = v),
              ),
            ],
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Adresse résidence',
              hint: 'Ex: 15 Rue de Tunis, Sfax',
              controller: _adresseCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Antécédents médicaux / Allergies',
              hint: 'Ex: Allergique à la Pénicilline, Asthme...',
              controller: _antecedentsCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: 'Enregistrer',
              loading: _saving,
              icon: Icons.save_rounded,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}

class _InviteCheckbox extends StatelessWidget {
  const _InviteCheckbox({required this.value, required this.onChanged});

  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: DfColors.brandFaint(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: DfColors.borderColor(context)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: DfColors.brandPrimary(context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Créer un compte portail patient et envoyer une invitation par e-mail',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DfColors.textColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
