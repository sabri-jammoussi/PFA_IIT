import 'package:flutter/material.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';

class PatientAddSheet extends StatefulWidget {
  const PatientAddSheet({required this.onSaved, super.key});

  final void Function(Patient) onSaved;

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
  DateTime? _dateNaissance;
  bool _saving = false;
  bool _inviting = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _adresseCtrl.dispose();
    super.dispose();
  }

  Patient _buildPatient() => Patient(
        id: 0,
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        adresse:
            _adresseCtrl.text.trim().isEmpty ? null : _adresseCtrl.text.trim(),
        dateNaissance: _dateNaissance?.toIso8601String(),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      widget.onSaved(_buildPatient());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _invite() async {
    if (_emailCtrl.text.trim().isEmpty) {
      showThemedSnackbar('Champ requis', 'Veuillez saisir un email.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _inviting = true);
    try {
      await PatientService.invitePatient(_buildPatient());
      showThemedSnackbar(
        'Invitation envoyée',
        'Un email a été envoyé à ${_emailCtrl.text.trim()}.',
        type: SnackbarType.success,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _inviting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DfBottomSheet(
      title: 'Nouveau patient',
      icon: Icons.person_add_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfTextField(
              label: 'Prénom',
              hint: 'Prénom du patient',
              controller: _prenomCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Nom',
              hint: 'Nom de famille',
              controller: _nomCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Email',
              hint: 'adresse@email.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Téléphone',
              hint: '+216 XX XXX XXX',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Adresse',
              hint: 'Adresse du patient',
              controller: _adresseCtrl,
              maxLines: 2,
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
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: 'Enregistrer',
              loading: _saving,
              icon: Icons.save_rounded,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.sm),
            DfSecondaryButton(
              label: 'Inviter par email',
              icon: Icons.email_outlined,
              onPressed: _inviting ? null : _invite,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
