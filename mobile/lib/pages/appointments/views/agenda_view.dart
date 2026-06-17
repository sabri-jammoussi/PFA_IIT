import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/appointment_model.dart';
import '../viewmodels/appointments_viewmodel.dart';
import 'appointment_add_sheet.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentsViewModel vm = Get.put(AppointmentsViewModel());
    final Color primary = DfColors.brandPrimary(context);
    final DateFormat dayFmt = DateFormat('EEEE d MMMM', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DfBottomSheet.show(
          context,
          child: AppointmentAddSheet(vm: vm),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Rendez-vous'),
      ),
      body: Obx(() => Column(
            children: [
              // Date navigation bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: DfColors.surface1(context),
                  border: Border(
                      bottom: BorderSide(color: DfColors.borderColor(context))),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: vm.goToPrevDay,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: vm.selectedDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) vm.loadAppointments(picked);
                        },
                        child: Text(
                          dayFmt.format(vm.selectedDate.value),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: DfColors.textColor(context),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: vm.goToNextDay,
                    ),
                    TextButton(
                      onPressed: vm.goToToday,
                      child: const Text("Auj."),
                    ),
                  ],
                ),
              ),
              // Appointments list
              Expanded(
                child: vm.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () =>
                            vm.loadAppointments(vm.selectedDate.value),
                        child: vm.appointments.isEmpty
                            ? ListView(
                                children: [
                                  DfEmptyState(
                                    icon: Icons.event_available_rounded,
                                    title: 'Aucun rendez-vous',
                                    subtitle:
                                        'Aucun rendez-vous pour cette journée.',
                                  )
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.base,
                                    AppSpacing.base,
                                    AppSpacing.base,
                                    100),
                                itemCount: vm.appointments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final Appointment appt =
                                      vm.appointments[index];
                                  return _AppointmentCard(
                                    appt: appt,
                                    primary: primary,
                                    onCancel: () =>
                                        vm.cancelAppointment(appt.id),
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

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appt,
    required this.primary,
    required this.onCancel,
  });

  final Appointment appt;
  final Color primary;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bool done = appt.statut.toLowerCase() == 'terminé';
    final bool cancelled = appt.statut.toLowerCase() == 'annulé';

    return DfCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DfColors.brandFaint(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              appt.formattedTime,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.patientFullName.isNotEmpty
                    ? appt.patientFullName
                    : 'Patient'),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (appt.statut.isNotEmpty)
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
              if (!done && !cancelled) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onCancel,
                  child: const Icon(Icons.cancel_outlined,
                      size: 18, color: DfColors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
