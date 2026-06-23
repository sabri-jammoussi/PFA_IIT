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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes rendez-vous'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: DfColors.brandPrimary(context),
                unselectedLabelColor: DfColors.mutedTextColor(context),
                indicatorColor: DfColors.brandPrimary(context),
                labelStyle: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'À venir'),
                  Tab(text: 'Historique'),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (vm.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            children: [
              _AppointmentsTab(
                appointments: vm.upcomingAppointments,
                emptyTitle: 'Aucun rendez-vous à venir',
                emptySubtitle: 'Vos demandes et rendez-vous futurs s\'afficheront ici.',
                vm: vm,
              ),
              _AppointmentsTab(
                appointments: vm.pastAppointments,
                emptyTitle: 'Aucun historique',
                emptySubtitle: 'L\'historique de vos rendez-vous passés s\'affichera ici.',
                vm: vm,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  final List<MyAppointment> appointments;
  final String emptyTitle;
  final String emptySubtitle;
  final PatientPortalViewModel vm;

  const _AppointmentsTab({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return DfEmptyState(
        icon: Icons.calendar_today_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return RefreshIndicator(
      onRefresh: vm.loadAll,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          return _AppointmentCard(appt: appointments[index]);
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

