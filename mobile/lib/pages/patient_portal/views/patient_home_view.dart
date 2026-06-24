import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/screens/home_screen.dart';
import '../models/patient_portal_model.dart';
import '../viewmodels/patient_portal_viewmodel.dart';
import 'patient_book_view.dart';

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
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => HomeScreen.scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        body: Obx(() {
          if (vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroHeader(vm: vm),
                      const SizedBox(height: AppSpacing.base),
                      _KpiGrid(vm: vm),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            ],
            body: Column(
              children: [
                Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
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
                      Tab(
                          icon: Icon(Icons.calendar_today_rounded, size: 18),
                          text: 'Rendez-vous'),
                      Tab(
                          icon: Icon(Icons.medical_services_rounded, size: 18),
                          text: 'Soins'),
                      Tab(
                          icon: Icon(Icons.description_rounded, size: 18),
                          text: 'Ordonnances'),
                      Tab(
                          icon: Icon(Icons.receipt_long_rounded, size: 18),
                          text: 'Facturation'),
                    ],
                  ),
                ),
                Divider(height: 1, color: DfColors.borderColor(context)),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AppointmentsTab(vm: vm),
                      _ConsultationsTab(vm: vm),
                      _PrescriptionsTab(vm: vm),
                      _BillingTab(vm: vm),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── HERO HEADER ───────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final PatientPortalViewModel vm;
  const _HeroHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DfColors.primaryDim, DfColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Center(
                  child: Text('🧬', style: TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${vm.patientName.value}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vm.cabinetName.value.isEmpty
                          ? 'Votre espace de santé patient'
                          : vm.cabinetName.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          GestureDetector(
            onTap: () => Get.to(() => const PatientBookView()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 18, color: DfColors.primaryDim),
                  SizedBox(width: 8),
                  Text(
                    'Demander un rendez-vous',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DfColors.primaryDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KPI GRID ───────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final PatientPortalViewModel vm;
  const _KpiGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    final MyAppointment? next = vm.nextAppointment;
    final double balance = vm.outstandingBalance;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Prochain RDV',
                value: next?.formattedShort ?? 'Aucun',
                icon: Icons.event_rounded,
                color: DfColors.info(context),
                faint: DfColors.infoFaint(context),
                small: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _KpiCard(
                label: 'Consultations',
                value: '${vm.totalConsultations}',
                icon: Icons.medical_services_rounded,
                color: DfColors.success(context),
                faint: DfColors.successFaint(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Ordonnances',
                value: '${vm.totalPrescriptions}',
                icon: Icons.description_rounded,
                color: const Color(0xFF8B5CF6),
                faint: const Color(0x1A8B5CF6),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _KpiCard(
                label: 'Solde restant',
                value: '${balance.toStringAsFixed(2)} DT',
                icon: Icons.account_balance_wallet_rounded,
                color: DfColors.warning(context),
                faint: DfColors.warningFaint(context),
                valueColor:
                    balance > 0 ? DfColors.red : DfColors.green,
                small: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.faint,
    this.valueColor,
    this.small = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color faint;
  final Color? valueColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: faint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: small ? 18 : 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
                color: valueColor ?? DfColors.textColor(context),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: DfColors.mutedTextColor(context),
            ),
          ),
        ],
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
      return DfEmptyState(
        icon: Icons.event_available_rounded,
        title: 'Aucun rendez-vous',
        subtitle: 'Demandez un rendez-vous depuis le bouton ci-dessus.',
        action: DfPill(
          label: '${vm.myAppointments.length} rendez-vous',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: vm.loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
        itemCount: vm.myAppointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          return _AppointmentCard(appt: vm.myAppointments[index]);
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final MyAppointment appt;
  const _AppointmentCard({required this.appt});

  @override
  Widget build(BuildContext context) {
    final StatusVisual sv = StatusVisual.appointment(context, appt.statut);
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
              label: appt.statut, color: sv.color, faintColor: sv.faint),
        ],
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
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
              // Acts (act title + price only — no tooth-face clinical schema)
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
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      soin['numeroDent'] != null &&
                                              (soin['numeroDent'] as num) != 0
                                          ? soin['numeroDent'].toString()
                                          : 'G',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              DfColors.brandPrimary(context)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          soin['acteLibelle']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      if (soin['faceDentaire'] != null &&
                                          soin['faceDentaire'].toString().isNotEmpty)
                                        Text(
                                          'Face : ${soin['faceDentaire']}',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: DfColors.dimTextColor(context)),
                                        ),
                                    ],
                                  ),
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
      itemCount: prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final PatientPrescription p = prescriptions[index];
        return DfCard(
          onTap: () => _showPrescription(context, p),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1A8B5CF6),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded,
                        size: 14, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 5),
                    Text('Voir',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8B5CF6))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrescription(BuildContext context, PatientPrescription p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrescriptionSheet(presc: p),
    );
  }
}

class _PrescriptionSheet extends StatelessWidget {
  final PatientPrescription presc;
  const _PrescriptionSheet({required this.presc});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PatientPortalViewModel vm = Get.find<PatientPortalViewModel>();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0x1A8B5CF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: Color(0xFF8B5CF6)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ordonnance médicale',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          Text('Émise le ${presc.formattedDate}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: DfColors.subTextColor(context))),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? DfColors.surface1(context)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: DfColors.borderColor(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Clinic
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    vm.cabinetName.value.isNotEmpty
                                        ? vm.cabinetName.value.toUpperCase()
                                        : 'CLINIQUE DENTAIRE DENTIFLOW',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: DfColors.textColor(context),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Médecine & Soins Bucco-Dentaires',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: DfColors.mutedTextColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (presc.dentisteNom?.isNotEmpty == true)
                                    Text(
                                      'Responsable : Dr. ${presc.dentisteNom}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: DfColors.dimTextColor(context),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 1.5,
                              color: DfColors.textColor(context).withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            // Date & Patient Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date : ${presc.formattedDate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: DfColors.textColor(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Patient : ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: DfColors.mutedTextColor(context),
                                    ),
                                  ),
                                  TextSpan(
                                    text: vm.patientName.value,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: DfColors.textColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Content
                            Text(
                              'Ordonnance :',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: DfColors.textColor(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              constraints: const BoxConstraints(minHeight: 180),
                              child: Text(
                                presc.traitement?.isNotEmpty == true
                                    ? presc.traitement!
                                    : 'Aucun traitement prescrit.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: DfColors.textColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Signature
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Signature et Cachet :',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: DfColors.dimTextColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 35),
                                  if (presc.dentisteNom?.isNotEmpty == true)
                                    Text(
                                      'Dr. ${presc.dentisteNom}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: DfColors.textColor(context),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
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
                child: Icon(Icons.account_balance_wallet_rounded,
                    size: 22, color: DfColors.warning(context)),
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
                          color: totalDue > 0 ? DfColors.red : DfColors.green,
                          letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        ...invoices.map((inv) {
          final String statut = inv.statutPaiement ?? 'Impayé';
          final StatusVisual sv = StatusVisual.invoice(context, statut);

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
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(inv.formattedDate,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DfColors.mutedTextColor(context))),
                          ],
                        ),
                      ),
                      DfStatusBadge(
                          label: statut,
                          color: sv.color,
                          faintColor: sv.faint),
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
                          value: '${inv.montantPaye.toStringAsFixed(2)} DT',
                          color: DfColors.green),
                      _AmountItem(
                          label: 'Reste',
                          value: '${inv.reste.toStringAsFixed(2)} DT',
                          color: inv.reste > 0 ? DfColors.red : DfColors.green),
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
