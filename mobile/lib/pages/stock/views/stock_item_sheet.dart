import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/stock_model.dart';

class StockItemSheet extends StatefulWidget {
  const StockItemSheet({required this.onSave, this.item, super.key});

  final StockItem? item;
  final void Function(StockItem) onSave;

  @override
  State<StockItemSheet> createState() => _StockItemSheetState();
}

class _StockItemSheetState extends State<StockItemSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _libelleCtrl;
  late final TextEditingController _quantiteCtrl;
  late final TextEditingController _prixCtrl;
  late final TextEditingController _fournisseurCtrl;

  @override
  void initState() {
    super.initState();
    _libelleCtrl =
        TextEditingController(text: widget.item?.libelle ?? '');
    _quantiteCtrl =
        TextEditingController(text: widget.item?.quantite.toString() ?? '');
    _prixCtrl = TextEditingController(
        text: widget.item?.prixUnitaire.toStringAsFixed(2) ?? '');
    _fournisseurCtrl =
        TextEditingController(text: widget.item?.fournisseur ?? '');
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    _fournisseurCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(StockItem(
      id: widget.item?.id ?? 0,
      libelle: _libelleCtrl.text.trim(),
      quantite: int.tryParse(_quantiteCtrl.text) ?? 0,
      prixUnitaire: double.tryParse(_prixCtrl.text) ?? 0.0,
      fournisseur: _fournisseurCtrl.text.trim().isEmpty
          ? null
          : _fournisseurCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.item != null;
    return DfBottomSheet(
      title: isEdit ? 'Modifier l\'article' : 'Nouvel article',
      icon: Icons.inventory_2_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfTextField(
              label: 'Libellé',
              hint: 'Nom de l\'article',
              controller: _libelleCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Quantité',
              hint: '0',
              controller: _quantiteCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Prix unitaire (DT)',
              hint: '0.00',
              controller: _prixCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Fournisseur',
              hint: 'Nom du fournisseur (optionnel)',
              controller: _fournisseurCtrl,
            ),
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: isEdit ? 'Enregistrer' : 'Ajouter',
              icon: isEdit ? Icons.save_rounded : Icons.add_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
