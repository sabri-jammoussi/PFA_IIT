import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import '../models/billing_model.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({required this.invoice, required this.onSave, super.key});

  final Invoice invoice;
  final void Function(Payment) onSave;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final TextEditingController _amountCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _date;
  String _mode = 'Espèces';
  final List<String> _modes = ['Espèces', 'Chèque', 'Carte'];

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.invoice.balance.toStringAsFixed(2);
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(Payment(
      factureId: widget.invoice.id,
      montant: double.tryParse(_amountCtrl.text) ?? 0,
      datePaiement: (_date ?? DateTime.now()).toIso8601String(),
      modePaiement: _mode,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DfBottomSheet(
      title: 'Enregistrer un paiement',
      icon: Icons.payments_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary
            DfCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.invoice.patientFullName.isNotEmpty
                        ? widget.invoice.patientFullName
                        : 'Facture #${widget.invoice.id}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '${widget.invoice.balance.toStringAsFixed(2)} DT dû',
                    style: const TextStyle(
                        color: DfColors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Montant (DT)',
              hint: '0.00',
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ requis';
                final double? val = double.tryParse(v);
                if (val == null || val <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.base),
            // Mode picker
            Text('MODE DE PAIEMENT',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.dimTextColor(context),
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: DfColors.surface3(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: DfColors.borderColor(context)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mode,
                  isExpanded: true,
                  dropdownColor: DfColors.surface1(context),
                  items: _modes
                      .map((m) => DropdownMenuItem<String>(
                            value: m,
                            child: Text(m,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _mode = v!),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            DfDateField(
              label: 'Date de paiement',
              value: _date,
              onTap: () => showDfDatePicker(
                context,
                _date,
                (d) => setState(() => _date = d),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: 'Enregistrer',
              icon: Icons.save_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
