import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/stock_model.dart';
import '../viewmodels/stock_viewmodel.dart';
import 'stock_item_sheet.dart';

class StockView extends StatelessWidget {
  const StockView({super.key});

  @override
  Widget build(BuildContext context) {
    final StockViewModel vm = Get.put(StockViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DfBottomSheet.show(
          context,
          child: StockItemSheet(
            onSave: (item) => vm.addItem(item),
          ),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvel article'),
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.items.isEmpty) {
          return const DfEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Stock vide',
            subtitle: 'Ajoutez vos premiers articles.',
          );
        }
        return RefreshIndicator(
          onRefresh: vm.loadItems,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
            itemCount: vm.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final StockItem item = vm.items[index];
              return DfCard(
                onTap: () => DfBottomSheet.show(
                  context,
                  child: StockItemSheet(
                    item: item,
                    onSave: (i) => vm.updateItem(i),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DfColors.brandFaint(context),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.inventory_2_rounded,
                          size: 22, color: primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.libelle,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                          if (item.fournisseur?.isNotEmpty == true)
                            Text(item.fournisseur!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        DfColors.mutedTextColor(context))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: item.quantite <= 5
                                ? DfColors.warningFaint(context)
                                : DfColors.brandFaint(context),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${item.quantite} u.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.quantite <= 5
                                  ? DfColors.orange
                                  : primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.prixUnitaire.toStringAsFixed(2)} DT',
                          style: TextStyle(
                            fontSize: 12,
                            color: DfColors.mutedTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
