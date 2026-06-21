import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/patient_portal_model.dart';
import '../viewmodels/patient_portal_viewmodel.dart';

class PatientHomeView extends StatelessWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final PatientPortalViewModel vm = Get.put(PatientPortalViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon espace santé'),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: primary,
            unselectedLabelColor: DfColors.mutedTextColor(context),
            indicatorColor: primary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.calendar_today_rounded, size: 18), text: 'Rendez-vous'),
              Tab(icon: Icon(Icons.medical_services_rounded, size: 18), text: 'Soins'),
              Tab(icon: Icon(Icons.description_rounded, size: 18), text: 'Ordonnances'),
              Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Facturation'),
            ],
          ),
        ),
        body: Obx(() {
          if (vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _AppointmentsTab(vm: vm),
              _ConsultationsTab(vm: vm),
              _PrescriptionsTab(vm: vm),
              _BillingTab(vm: vm),
            ],
          );
        }),
      ),
    );
  }
}

// ─── TAB 1: Appointments ──────────────────────────────────────────────────

class _AppointmentsTab extends StatelessWidget {
  final PatientPortalViewModel vm;
  const _AppointmentsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.myAppointments.isEmpty) {
      return const DfEmptyState(
        icon: Icons.event_available_rounded,
        title: 'Aucun rendez-vous',
        subtitle: 'Réservez un rendez-vous depuis l\'onglet Réserver.',
      );
    }
    return RefreshIndicator(
      onRefresh: vm.loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: vm.myAppointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final MyAppointment appt = vm.myAppointments[index];
          final bool done = appt.statut.toLowerCase() == 'terminé';
          final bool cancelled = appt.statut.toLowerCase() == 'annulé';

          return DfCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DfColors.brandFaint(context),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.calendar_month_rounded,
                      size: 22, color: DfColors.brandPrimary(context)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt.formattedDate,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      if (appt.dentisteNom?.isNotEmpty == true)
                        Text('Dr. ${appt.dentisteNom}',
                            style: TextStyle(
                                fontSize: 12,
                                color: DfColors.mutedTextColor(context))),
                      if (appt.motif?.isNotEmpty == true)
                        Text(appt.motif!,
                            style: TextStyle(
                                fontSize: 12,
                                color: DfColors.dimTextColor(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                DfStatusBadge(
                  label: appt.statut,
                  color: done
                      ? DfColors.green
                      : cancelled
                          ? DfColors.red
                          : DfColors.orange,
                  faintColor: done
                      ? DfColors.greenFaintLight
                      : cancelled
                          ? DfColors.redFaintLight
                          : DfColors.orangeFaintLight,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── TAB 2: Consultations / Soins ─────────────────────────────────────────

class _ConsultationsTab extends StatelessWidget {
  final PatientPortalViewModel vm;
  const _ConsultationsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final consultations = vm.fullMedicalRecord.value?.consultations ?? [];
    if (consultations.isEmpty) {
      return const DfEmptyState(
        icon: Icons.healing_rounded,
        title: 'Aucun soin enregistré',
        subtitle: 'Vos séances cliniques apparaîtront ici.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: consultations.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final PatientConsultation c = consultations[index];
        return DfCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: DfColors.surface2(context),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.lg)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Séance clinique',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: DfColors.dimTextColor(context),
                                  letterSpacing: 0.8)),
                          Text(c.formattedDate,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                    if (c.dentisteNom != null)
                      Text('Dr. ${c.dentisteNom}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: DfColors.mutedTextColor(context))),
                  ],
                ),
              ),
              // Observations
              if (c.notesObservations?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Observations',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: DfColors.dimTextColor(context),
                              letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text(c.notesObservations!,
                          style: TextStyle(
                              fontSize: 13,
                              color: DfColors.textColor(context))),
                    ],
                  ),
                ),
              // Acts
              if (c.soins.isNotEmpty) ...[
                Divider(height: 1, color: DfColors.borderColor(context)),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Soins effectués',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: DfColors.dimTextColor(context),
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      ...c.soins.map((soin) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: DfColors.brandFaint(context),
                                    borderRadius:
                                        BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      soin['numeroDent']
                                              ?.toString() ??
                                          'G',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: DfColors.brandPrimary(
                                              context)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                      soin['acteLibelle']?.toString() ??
                                          '',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  '${((soin['prixApplique'] ?? 0) as num).toStringAsFixed(2)} DT',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── TAB 3: Prescriptions ─────────────────────────────────────────────────

class _PrescriptionsTab extends StatelessWidget {
  final PatientPortalViewModel vm;
  const _PrescriptionsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final prescriptions = vm.fullMedicalRecord.value?.prescriptions ?? [];
    if (prescriptions.isEmpty) {
      return const DfEmptyState(
        icon: Icons.description_outlined,
        title: 'Aucune ordonnance',
        subtitle: 'Vos ordonnances médicales apparaîtront ici.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final PatientPrescription p = prescriptions[index];
        return DfCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x1A8B5CF6),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.description_rounded,
                    size: 22, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ordonnance du ${p.formattedDate}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    if (p.dentisteNom?.isNotEmpty == true)
                      Text('Dr. ${p.dentisteNom}',
                          style: TextStyle(
                              fontSize: 12,
                              color: DfColors.mutedTextColor(context))),
                    if (p.traitement?.isNotEmpty == true)
                      Text(p.traitement!,
                          style: TextStyle(
                              fontSize: 12,
                              color: DfColors.dimTextColor(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: DfColors.dimTextColor(context)),
            ],
          ),
        );
      },
    );
  }
}

// ─── TAB 4: Billing / Facturation ─────────────────────────────────────────

class _BillingTab extends StatelessWidget {
  final PatientPortalViewModel vm;
  const _BillingTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final invoices = vm.fullMedicalRecord.value?.invoices ?? [];
    if (invoices.isEmpty) {
      return const DfEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune facture',
        subtitle: 'Vos factures apparaîtront ici.',
      );
    }

    final double totalDue = invoices.fold(0.0, (s, inv) => s + inv.reste);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        // Summary card
        DfCard(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DfColors.warningFaint(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 22, color: Color(0xFFFF9800)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solde restant à payer',
                      style: TextStyle(
                          fontSize: 11,
                          color: DfColors.mutedTextColor(context),
                          fontWeight: FontWeight.w600)),
                  Text('${totalDue.toStringAsFixed(2)} DT',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: totalDue > 0
                              ? DfColors.red
                              : DfColors.green,
                          letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        ...invoices.map((inv) {
          final String statut = inv.statutPaiement ?? 'Impayé';
          final bool paid = statut == 'Payé';
          final bool partial = statut == 'Partiel';

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: DfCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inv.numeroFacture ?? 'Facture #${inv.id}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                            Text(inv.formattedDate,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        DfColors.mutedTextColor(context))),
                          ],
                        ),
                      ),
                      DfStatusBadge(
                        label: statut,
                        color: paid
                            ? DfColors.green
                            : partial
                                ? DfColors.orange
                                : DfColors.red,
                        faintColor: paid
                            ? DfColors.greenFaintLight
                            : partial
                                ? DfColors.orangeFaintLight
                                : DfColors.redFaintLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Divider(height: 1, color: DfColors.borderColor(context)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _AmountItem(
                          label: 'Total',
                          value: '${inv.montantTotal.toStringAsFixed(2)} DT',
                          color: DfColors.textColor(context)),
                      _AmountItem(
                          label: 'Payé',
                          value:
                              '${inv.montantPaye.toStringAsFixed(2)} DT',
                          color: DfColors.green),
                      _AmountItem(
                          label: 'Reste',
                          value: '${inv.reste.toStringAsFixed(2)} DT',
                          color:
                              inv.reste > 0 ? DfColors.red : DfColors.green),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AmountItem extends StatelessWidget {
  const _AmountItem({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: DfColors.dimTextColor(context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
