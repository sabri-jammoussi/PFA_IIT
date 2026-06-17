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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon espace'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: vm.loadAll,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // Medical record summary
              if (vm.medicalRecord.value != null) ...[
                const DfSectionLabel(title: 'Mon dossier'),
                const SizedBox(height: AppSpacing.sm),
                DfCard(
                  child: Row(
                    children: [
                      _SummaryItem(
                        label: 'Consultations',
                        value: vm.medicalRecord.value!.totalConsultations
                            .toString(),
                        icon: Icons.medical_services_rounded,
                        color: primary,
                        faint: DfColors.brandFaint(context),
                      ),
                      Container(
                          width: 1,
                          height: 50,
                          color: DfColors.borderColor(context)),
                      _SummaryItem(
                        label: 'Traitements',
                        value: vm.medicalRecord.value!.totalTreatments
                            .toString(),
                        icon: Icons.healing_rounded,
                        color: DfColors.green,
                        faint: DfColors.successFaint(context),
                      ),
                    ],
                  ),
                ),
                if (vm.medicalRecord.value!.lastVisit != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DfCard(
                    child: DfInfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Dernière visite',
                      value: vm.medicalRecord.value!.lastVisit!,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
              // Upcoming appointments
              const DfSectionLabel(title: 'Mes prochains rendez-vous'),
              const SizedBox(height: AppSpacing.sm),
              if (vm.myAppointments.isEmpty)
                const DfEmptyState(
                  icon: Icons.event_available_rounded,
                  title: 'Aucun rendez-vous',
                  subtitle:
                      'Réservez un rendez-vous depuis l\'onglet Réserver.',
                )
              else
                ...vm.myAppointments.take(5).map(
                      (appt) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _AppointmentCard(appt: appt),
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.faint,
  });

  final String label, value;
  final IconData icon;
  final Color color, faint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: faint,
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: DfColors.mutedTextColor(context))),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appt});

  final MyAppointment appt;

  @override
  Widget build(BuildContext context) {
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
  }
}
