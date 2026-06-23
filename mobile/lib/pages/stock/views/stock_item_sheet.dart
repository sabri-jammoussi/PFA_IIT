import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
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
  late final TextEditingController _nomCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _quantiteCtrl;
  late final TextEditingController _seuilCtrl;
  late String _unite;

  static const List<String> _uniteOptions = [
    'Unité', 'Boîte', 'Flacon', 'Seringue', 'Paire', 'Sachet', 'Tube', 'Cartouche',
  ];

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.item?.nom ?? '');
    _descriptionCtrl =
        TextEditingController(text: widget.item?.description ?? '');
    _quantiteCtrl = TextEditingController(
        text: widget.item?.quantiteEnStock.toString() ?? '');
    _seuilCtrl =
        TextEditingController(text: widget.item?.seuilAlerte.toString() ?? '');
    _unite = widget.item?.unite ?? 'Unité';
    if (!_uniteOptions.contains(_unite)) _unite = 'Unité';
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _descriptionCtrl.dispose();
    _quantiteCtrl.dispose();
    _seuilCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(StockItem(
      id: widget.item?.id ?? 0,
      nom: _nomCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      quantiteEnStock: int.tryParse(_quantiteCtrl.text) ?? 0,
      seuilAlerte: int.tryParse(_seuilCtrl.text) ?? 0,
      unite: _unite,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DfBottomSheet(
      title: _isEdit ? 'Modifier l\'article' : 'Nouvel article',
      subtitle: _isEdit
          ? widget.item!.nom
          : 'Ajouter un consommable au catalogue',
      icon: Icons.inventory_2_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfTextField(
              label: 'Nom de l\'article',
              hint: 'Ex: Anesthésique Articaine',
              controller: _nomCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Description',
              hint: 'Description ou référence fournisseur (optionnel)',
              controller: _descriptionCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.base),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DfTextField(
                    label: _isEdit ? 'Qté en stock' : 'Qté initiale',
                    hint: '0',
                    controller: _quantiteCtrl,
                    enabled: !_isEdit,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DfTextField(
                    label: 'Seuil alerte',
                    hint: '0',
                    controller: _seuilCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            DfDropdownField<String>(
              label: 'Unité',
              items: _uniteOptions,
              labelOf: (s) => s,
              value: _unite,
              onChanged: (v) => setState(() => _unite = v ?? 'Unité'),
            ),
            if (_isEdit) ...[
              const SizedBox(height: AppSpacing.base),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: DfColors.warningFaint(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: DfColors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pour modifier la quantité, utilisez le bouton « Réappro. » sur la liste.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DfColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: _isEdit ? 'Mettre à jour' : 'Enregistrer',
              icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
