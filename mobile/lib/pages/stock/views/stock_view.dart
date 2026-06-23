import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/stock_model.dart';
import '../viewmodels/stock_viewmodel.dart';
import 'stock_item_sheet.dart';
import 'restock_sheet.dart';

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
          child: StockItemSheet(onSave: (item) => vm.addItem(item)),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvel article'),
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<StockItem> list = vm.filtered;

        return RefreshIndicator(
          onRefresh: vm.loadItems,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
            children: [
              // Low-stock alert banner
              if (vm.lowStockCount > 0) ...[
                _LowStockBanner(count: vm.lowStockCount),
                const SizedBox(height: AppSpacing.md),
              ],

              // Search
              if (vm.items.isNotEmpty) ...[
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un article...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: vm.search.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => vm.search.value = '',
                          )
                        : null,
                  ),
                  onChanged: (v) => vm.search.value = v,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Content
              if (vm.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: DfEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Stock vide',
                    subtitle: 'Ajoutez vos premiers articles.',
                  ),
                )
              else if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: DfEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Aucun résultat',
                    subtitle: 'Aucun article ne correspond à la recherche.',
                  ),
                )
              else
                ...list.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _StockCard(
                        item: item,
                        primary: primary,
                        onEdit: () => DfBottomSheet.show(
                          context,
                          child: StockItemSheet(
                            item: item,
                            onSave: (i) => vm.updateItem(i),
                          ),
                        ),
                        onRestock: () => DfBottomSheet.show(
                          context,
                          child: RestockSheet(
                            item: item,
                            onRestock: (qty) => vm.restock(item.id, qty),
                          ),
                        ),
                        onDelete: () => _confirmDelete(context, vm, item),
                      ),
                    )),

              if (vm.items.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${vm.items.length} article${vm.items.length > 1 ? 's' : ''} référencé${vm.items.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: DfColors.dimTextColor(context),
                        ),
                      ),
                      if (vm.lowStockCount > 0)
                        Text(
                          '${vm.lowStockCount} en alerte',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: DfColors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, StockViewModel vm, StockItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'article'),
        content: Text(
            'Voulez-vous vraiment supprimer « ${item.nom} » du catalogue ? Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: DfColors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: DfColors.dangerFaint(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: DfColors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DfColors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.warning_amber_rounded,
                color: DfColors.red, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count article${count > 1 ? 's' : ''} sous le seuil d\'alerte',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: DfColors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'À réapprovisionner en urgence.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DfColors.red.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const DfDot(color: Color(0xFFFF4444), pulse: true, size: 12),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({
    required this.item,
    required this.primary,
    required this.onEdit,
    required this.onRestock,
    required this.onDelete,
  });

  final StockItem item;
  final Color primary;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool critical = item.isLowStock;

    // Qty badge color semantics (match web): <=0 danger, <=seuil warning, else success.
    final Color qtyColor = item.isOutOfStock
        ? DfColors.red
        : critical
            ? DfColors.orange
            : DfColors.green;
    final Color qtyFaint = item.isOutOfStock
        ? DfColors.dangerFaint(context)
        : critical
            ? DfColors.warningFaint(context)
            : DfColors.successFaint(context);

    return Stack(
      children: [
        DfCard(
          onTap: onEdit,
          child: Padding(
            // leave room for the left accent on critical rows
            padding: EdgeInsets.only(left: critical ? 8 : 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (critical) ...[
                                const DfDot(
                                    color: Color(0xFFFF4444),
                                    pulse: true,
                                    size: 8),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  item.nom,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (item.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: DfColors.mutedTextColor(context)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Qty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: qtyFaint,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '${item.quantiteEnStock} ${item.unite}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: qtyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined,
                        size: 13, color: DfColors.dimTextColor(context)),
                    const SizedBox(width: 4),
                    Text(
                      'Seuil ${item.seuilAlerte}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DfColors.mutedTextColor(context),
                      ),
                    ),
                    const Spacer(),
                    // Actions
                    _ActionBtn(
                      icon: Icons.add_box_rounded,
                      color: DfColors.green,
                      filled: true,
                      label: 'Réappro.',
                      onTap: onRestock,
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      icon: Icons.edit_outlined,
                      color: DfColors.mutedTextColor(context),
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      icon: Icons.delete_outline_rounded,
                      color: DfColors.red,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Left danger accent
        if (critical)
          Positioned(
            left: 0,
            top: 10,
            bottom: 10,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: DfColors.red,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.label,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: label != null ? 10 : 8, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: filled ? color.withOpacity(0.3) : DfColors.borderColor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            if (label != null) ...[
              const SizedBox(width: 5),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
