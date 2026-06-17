import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/billing_model.dart';
import '../viewmodels/billing_viewmodel.dart';
import 'payment_sheet.dart';

class BillingView extends StatelessWidget {
  const BillingView({super.key});

  @override
  Widget build(BuildContext context) {
    final BillingViewModel vm = Get.put(BillingViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Facturation')),
      body: Obx(() => Column(
            children: [
              // Search + filters
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une facture...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: vm.search.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  vm.search.value = '';
                                  vm.loadInvoices();
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) {
                        vm.search.value = v;
                        if (v.isEmpty || v.length > 2) vm.loadInvoices();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _FilterChip(
                          label: 'Tous',
                          selected: vm.filter.value == 'all',
                          onTap: () => vm.filter.value = 'all',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Impayés',
                          selected: vm.filter.value == 'unpaid',
                          onTap: () => vm.filter.value = 'unpaid',
                          color: DfColors.red,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Payés',
                          selected: vm.filter.value == 'paid',
                          onTap: () => vm.filter.value = 'paid',
                          color: DfColors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: vm.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: vm.loadInvoices,
                        child: vm.filtered.isEmpty
                            ? ListView(children: [
                                const DfEmptyState(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'Aucune facture',
                                  subtitle: 'Aucune facture trouvée.',
                                )
                              ])
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.base,
                                    0,
                                    AppSpacing.base,
                                    100),
                                itemCount: vm.filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final Invoice inv = vm.filtered[index];
                                  return _InvoiceCard(
                                    invoice: inv,
                                    primary: primary,
                                    onTap: inv.balance > 0
                                        ? () => DfBottomSheet.show(
                                              context,
                                              child: PaymentSheet(
                                                invoice: inv,
                                                onSave: (p) =>
                                                    vm.recordPayment(p),
                                              ),
                                            )
                                        : null,
                                  );
                                },
                              ),
                      ),
              ),
            ],
          )),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = color ?? DfColors.brandPrimary(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? activeColor : DfColors.borderColor(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? activeColor : DfColors.mutedTextColor(context),
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.primary,
    required this.onTap,
  });

  final Invoice invoice;
  final Color primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isPaid = invoice.balance <= 0;

    return DfCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPaid
                  ? DfColors.successFaint(context)
                  : DfColors.dangerFaint(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isPaid ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
              size: 22,
              color: isPaid ? DfColors.green : DfColors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.patientFullName.isNotEmpty
                      ? invoice.patientFullName
                      : 'Patient #${invoice.id}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Text(
                  '${invoice.montantTotal.toStringAsFixed(2)} DT total',
                  style: TextStyle(
                      fontSize: 12, color: DfColors.mutedTextColor(context)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DfStatusBadge(
                label: isPaid ? 'Payé' : 'Impayé',
                color: isPaid ? DfColors.green : DfColors.red,
                faintColor:
                    isPaid ? DfColors.greenFaintLight : DfColors.redFaintLight,
              ),
              if (!isPaid) ...[
                const SizedBox(height: 4),
                Text(
                  '${invoice.balance.toStringAsFixed(2)} DT restant',
                  style: const TextStyle(
                      fontSize: 11,
                      color: DfColors.red,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
