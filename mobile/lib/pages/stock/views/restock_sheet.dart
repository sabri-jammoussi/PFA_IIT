import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/stock_model.dart';

class RestockSheet extends StatefulWidget {
  const RestockSheet({required this.item, required this.onRestock, super.key});

  final StockItem item;
  final void Function(int quantiteAjoutee) onRestock;

  @override
  State<RestockSheet> createState() => _RestockSheetState();
}

class _RestockSheetState extends State<RestockSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _qtyCtrl = TextEditingController();
  int _added = 0;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final int qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) return;
    widget.onRestock(qty);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final StockItem item = widget.item;
    final Color green = DfColors.green;
    final bool isCritical = item.isLowStock;

    return DfBottomSheet(
      title: 'Approvisionner le stock',
      subtitle: item.nom,
      icon: Icons.add_box_rounded,
      iconColor: green,
      initialChildSize: 0.6,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current state card
            DfCard(
              backgroundColor: DfColors.surface3(context),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STOCK ACTUEL',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: DfColors.dimTextColor(context))),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantiteEnStock} ${item.unite}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isCritical
                                ? DfColors.red
                                : DfColors.textColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('SEUIL ALERTE',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: DfColors.dimTextColor(context))),
                      const SizedBox(height: 4),
                      Text(
                        '${item.seuilAlerte}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: DfColors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Quantité reçue',
              hint: 'Saisir la quantité livrée',
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) =>
                  setState(() => _added = int.tryParse(v) ?? 0),
              validator: (v) {
                final int? n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Quantité invalide';
                return null;
              },
            ),
            if (_added > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 14, color: green),
                  const SizedBox(width: 6),
                  Text(
                    'Nouveau stock : ${item.quantiteEnStock + _added} ${item.unite}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Confirmer la réception'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
