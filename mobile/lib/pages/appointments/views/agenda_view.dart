import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import '../models/appointment_model.dart';
import '../viewmodels/appointments_viewmodel.dart';
import 'appointment_add_sheet.dart';

class AgendaView extends StatelessWidget {
  const AgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentsViewModel vm = Get.put(AppointmentsViewModel());
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
              _DateBar(vm: vm, dayFmt: dayFmt),
              _DentistFilter(vm: vm),
              Expanded(
                child: vm.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: vm.refreshAppointments,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.base,
                              AppSpacing.base, AppSpacing.base, 100),
                          children: [
                            if (vm.hasConflict) ...[
                              const _ConflictBanner(),
                              const SizedBox(height: AppSpacing.base),
                            ],
                            const DfSectionLabel(
                              title: 'Rendez-vous de la journée',
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            ),
                            if (vm.appointments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: DfEmptyState(
                                  icon: Icons.event_available_rounded,
                                  title: 'Aucun rendez-vous',
                                  subtitle:
                                      'Aucun rendez-vous planifié pour cette journée.',
                                ),
                              )
                            else
                              ...vm.appointments.map((appt) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm),
                                    child: _AppointmentCard(
                                      appt: appt,
                                      onCancel: () =>
                                          _confirmCancel(context, vm, appt),
                                      onArrival: () =>
                                          vm.confirmArrival(appt.id),
                                    ),
                                  )),
                            const SizedBox(height: AppSpacing.lg),
                            const DfSectionLabel(
                              title: 'Créneaux disponibles',
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                            ),
                            _SlotsGrid(vm: vm),
                          ],
                        ),
                      ),
              ),
            ],
          )),
    );
  }

  void _confirmCancel(
      BuildContext context, AppointmentsViewModel vm, Appointment appt) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content: Text(
            'Voulez-vous vraiment annuler le rendez-vous de ${appt.patientFullName.isEmpty ? "ce patient" : appt.patientFullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non, conserver'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.cancelAppointment(appt.id);
            },
            child: Text('Oui, annuler',
                style: TextStyle(color: DfColors.danger(context))),
          ),
        ],
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({required this.vm, required this.dayFmt});
  final AppointmentsViewModel vm;
  final DateFormat dayFmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: DfColors.surface1(context),
        border:
            Border(bottom: BorderSide(color: DfColors.borderColor(context))),
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
                  locale: const Locale('fr', 'FR'),
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
          TextButton(onPressed: vm.goToToday, child: const Text('Auj.')),
        ],
      ),
    );
  }
}

class _DentistFilter extends StatelessWidget {
  const _DentistFilter({required this.vm});
  final AppointmentsViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.dentists.isEmpty) return const SizedBox.shrink();
    final Dentist? selected = vm.dentists
        .firstWhereOrNull((d) => d.id == vm.selectedDentistId.value);
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, AppSpacing.md, AppSpacing.base, AppSpacing.sm),
      child: DfDropdownField<Dentist>(
        label: 'Médecin traitant',
        items: vm.dentists.toList(),
        labelOf: (d) => d.fullName,
        value: selected,
        hint: 'Tous les praticiens',
        icon: Icons.medical_services_rounded,
        onChanged: (d) => vm.setDentist(d?.id),
      ),
    );
  }
}

class _ConflictBanner extends StatelessWidget {
  const _ConflictBanner();

  @override
  Widget build(BuildContext context) {
    final Color warn = DfColors.warning(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: DfColors.warningFaint(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: warn.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: warn, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détection de surréservation',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: warn,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Deux rendez-vous sont planifiés sur le même créneau horaire.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DfColors.subTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appt,
    required this.onCancel,
    required this.onArrival,
  });

  final Appointment appt;
  final VoidCallback onCancel;
  final VoidCallback onArrival;

  ({Color color, Color faint}) _statusColors(BuildContext context) {
    if (appt.isComplete) {
      return (color: DfColors.green, faint: DfColors.successFaint(context));
    }
    if (appt.isAnnule) {
      return (color: DfColors.red, faint: DfColors.dangerFaint(context));
    }
    if (appt.isConfirme || appt.isEnConsultation) {
      return (
        color: DfColors.brandPrimary(context),
        faint: DfColors.brandFaint(context)
      );
    }
    return (color: DfColors.blue, faint: DfColors.infoFaint(context));
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);
    final bool imminent = appt.isImminent;
    final sc = _statusColors(context);

    return Container(
      decoration: BoxDecoration(
        color: DfColors.surface1(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: imminent ? DfColors.green : DfColors.borderColor(context),
          width: imminent ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Time badge
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
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
                    Text(
                      appt.patientFullName.isEmpty
                          ? 'Patient #${appt.patientId ?? ''}'
                          : appt.patientFullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: DfColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (appt.motif?.isNotEmpty == true)
                          Text('Motif: ${appt.motif}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: DfColors.mutedTextColor(context))),
                        Text('• ${appt.formattedDuration}',
                            style: TextStyle(
                                fontSize: 11,
                                color: DfColors.dimTextColor(context))),
                      ],
                    ),
                  ],
                ),
              ),
              DfStatusBadge(
                label: appt.statutLabel,
                color: sc.color,
                faintColor: sc.faint,
              ),
            ],
          ),
          if (imminent || (!appt.isComplete && !appt.isAnnule)) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (imminent)
                  Expanded(
                    child: _ArrivalButton(onTap: onArrival),
                  ),
                if (imminent) const SizedBox(width: AppSpacing.sm),
                if (!appt.isComplete && !appt.isAnnule)
                  _DeleteButton(onTap: onCancel),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Pulsing "Confirmer Arrivée" button (imminent appointments only).
class _ArrivalButton extends StatefulWidget {
  const _ArrivalButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ArrivalButton> createState() => _ArrivalButtonState();
}

class _ArrivalButtonState extends State<_ArrivalButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(milliseconds: 1100),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: 0.75 + (_ctrl.value * 0.25),
        child: child,
      ),
      child: Material(
        color: DfColors.green,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Confirmer arrivée',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DfColors.dangerFaint(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.delete_outline_rounded,
            size: 18, color: DfColors.danger(context)),
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  const _SlotsGrid({required this.vm});
  final AppointmentsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final slots = vm.availableSlots;
    if (slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: DfColors.dangerFaint(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          'Tous les créneaux de cette journée sont complets.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DfColors.danger(context),
          ),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: slots
          .map((slot) => InkWell(
                onTap: () => DfBottomSheet.show(
                  context,
                  child: AppointmentAddSheet(vm: vm, initialSlot: slot),
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: DfColors.surface1(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border:
                        Border.all(color: DfColors.borderColor(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 13,
                          color: DfColors.brandPrimary(context)),
                      const SizedBox(width: 4),
                      Text(
                        slot,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DfColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
