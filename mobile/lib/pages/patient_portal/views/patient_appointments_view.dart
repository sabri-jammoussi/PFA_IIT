import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import '../models/patient_portal_model.dart';
import '../viewmodels/patient_portal_viewmodel.dart';

class PatientAppointmentsView extends StatelessWidget {
  const PatientAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final PatientPortalViewModel vm = Get.find<PatientPortalViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes rendez-vous')),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.myAppointments.isEmpty) {
          return const DfEmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'Aucun rendez-vous',
            subtitle: 'Vous n\'avez pas encore de rendez-vous.',
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
              final MyAppointment appt = vm.myAppointments[index];
              final bool done = appt.statut.toLowerCase() == 'terminé';
              final bool cancelled =
                  appt.statut.toLowerCase() == 'annulé';

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
                          size: 22,
                          color: DfColors.brandPrimary(context)),
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
                                    color:
                                        DfColors.mutedTextColor(context))),
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
      }),
    );
  }
}
