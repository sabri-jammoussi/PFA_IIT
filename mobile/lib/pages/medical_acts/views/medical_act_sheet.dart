import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/medical_act_model.dart';

class MedicalActSheet extends StatefulWidget {
  const MedicalActSheet({required this.onSave, this.act, super.key});

  final MedicalAct? act;
  final void Function(MedicalAct) onSave;

  @override
  State<MedicalActSheet> createState() => _MedicalActSheetState();
}

class _MedicalActSheetState extends State<MedicalActSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _libelleCtrl;
  late final TextEditingController _tarifCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _libelleCtrl = TextEditingController(text: widget.act?.libelle ?? '');
    _tarifCtrl = TextEditingController(
        text: widget.act?.tarifDeBase.toStringAsFixed(2) ?? '');
    _descCtrl = TextEditingController(text: widget.act?.description ?? '');
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _tarifCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(MedicalAct(
      id: widget.act?.id ?? 0,
      libelle: _libelleCtrl.text.trim(),
      tarifDeBase: double.tryParse(_tarifCtrl.text) ?? 0.0,
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.act != null;
    return DfBottomSheet(
      title: isEdit ? "Modifier l'acte" : 'Nouvel acte médical',
      icon: Icons.healing_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfTextField(
              label: 'Libellé',
              hint: 'Ex: Détartrage, Extraction...',
              controller: _libelleCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Prix de base (DT)',
              hint: '0.00',
              controller: _tarifCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ requis';
                if (double.tryParse(v) == null) return 'Valeur invalide';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Description',
              hint: 'Description optionnelle...',
              controller: _descCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: isEdit
                  ? 'Enregistrer les modifications'
                  : "Créer l'acte",
              icon: isEdit
                  ? Icons.save_rounded
                  : Icons.add_circle_outline_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
