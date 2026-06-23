import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import '../models/appointment_model.dart';
import '../viewmodels/appointments_viewmodel.dart';

class PendingRequestsView extends StatelessWidget {
  const PendingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentsViewModel vm = Get.isRegistered<AppointmentsViewModel>()
        ? Get.find<AppointmentsViewModel>()
        : Get.put(AppointmentsViewModel());

    return Scaffold(
      appBar: AppBar(title: const Text('Demandes en attente')),
      body: Obx(() {
        if (vm.isLoadingPending.value && vm.pendingRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.pendingRequests.isEmpty) {
          return RefreshIndicator(
            onRefresh: vm.loadPending,
            child: ListView(
              children: const [
                SizedBox(height: 80),
                DfEmptyState(
                  icon: Icons.check_circle_rounded,
                  title: 'Aucune demande en attente',
                  subtitle:
                      'Toutes les demandes de rendez-vous ont été traitées.',
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: vm.loadPending,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: vm.pendingRequests.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Demandes patients (${vm.pendingRequests.length})',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: DfColors.dimTextColor(context),
                    ),
                  ),
                );
              }
              final Appointment req = vm.pendingRequests[index - 1];
              return _RequestCard(
                request: req,
                onAccept: () => _openAcceptSheet(context, vm, req),
                onReject: () => _confirmReject(context, vm, req),
              );
            },
          ),
        );
      }),
    );
  }

  void _openAcceptSheet(
      BuildContext context, AppointmentsViewModel vm, Appointment req) {
    DfBottomSheet.show(
      context,
      child: _AcceptScheduleSheet(vm: vm, request: req),
    );
  }

  void _confirmReject(
      BuildContext context, AppointmentsViewModel vm, Appointment req) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter la demande'),
        content: Text(
            'Voulez-vous rejeter la demande de rendez-vous de ${req.patientFullName.isEmpty ? "ce patient" : req.patientFullName} ? Le créneau sera libéré.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.rejectRequest(req);
            },
            child: Text('Rejeter',
                style: TextStyle(color: DfColors.danger(context))),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final Appointment request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  String _initial() {
    final name = request.patientFullName;
    return name.isNotEmpty ? name.characters.first.toUpperCase() : 'P';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? dt = request.dateTime;
    final String dateLabel = dt != null
        ? DateFormat('EEEE d MMMM y', 'fr_FR').format(dt)
        : request.dateHeure;
    final String timeLabel =
        dt != null ? DateFormat('HH:mm', 'fr_FR').format(dt) : '';

    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DfColors.brandFaint(context),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial(),
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontWeight: FontWeight.w700,
                    color: DfColors.brandPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.patientFullName.isEmpty
                          ? 'Patient'
                          : request.patientFullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: DfColors.textColor(context),
                      ),
                    ),
                    Text(
                      'ID Patient: #${request.patientId ?? '—'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: DfColors.dimTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              DfStatusBadge.warning(context, 'En attente'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Date souhaitée
          Row(
            children: [
              Icon(Icons.event_rounded,
                  size: 16, color: DfColors.mutedTextColor(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  timeLabel.isEmpty ? dateLabel : '$dateLabel • $timeLabel',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DfColors.subTextColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Motif pill
          DfPill(
            label: request.motif?.isNotEmpty == true
                ? request.motif!
                : 'Non spécifié',
            backgroundColor: DfColors.surface3(context),
            color: DfColors.subTextColor(context),
          ),
          const SizedBox(height: AppSpacing.base),
          // Actions
          Row(
            children: [
              Expanded(
                child: DfPrimaryButton(
                  label: 'Accepter & Planifier',
                  icon: Icons.check_rounded,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 52,
                height: 56,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DfColors.danger(context),
                    side: BorderSide(
                        color: DfColors.danger(context).withOpacity(0.5)),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.close_rounded, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet: confirm a pending request -> Planifie.
class _AcceptScheduleSheet extends StatefulWidget {
  const _AcceptScheduleSheet({required this.vm, required this.request});
  final AppointmentsViewModel vm;
  final Appointment request;

  @override
  State<_AcceptScheduleSheet> createState() => _AcceptScheduleSheetState();
}

class _AcceptScheduleSheetState extends State<_AcceptScheduleSheet> {
  late DateTime? _date;
  late TimeOfDay? _time;
  Dentist? _dentist;
  _DurationOption _duration = _durations[1];
  final TextEditingController _noteCtrl =
      TextEditingController(text: 'Demande validée par le secrétariat');
  bool _saving = false;
  bool _dateError = false;

  @override
  void initState() {
    super.initState();
    final dt = widget.request.dateTime;
    _date = dt;
    _time = dt != null ? TimeOfDay(hour: dt.hour, minute: dt.minute) : null;
    _dentist = widget.vm.dentists
        .where((d) => d.id == widget.request.dentisteId)
        .cast<Dentist?>()
        .firstWhere((_) => true, orElse: () => null);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _dateError = _date == null);
    if (_dateError) return;
    if (_dentist == null) {
      showThemedSnackbar('Praticien requis',
          'Sélectionnez un médecin traitant.',
          type: SnackbarType.warning);
      return;
    }
    setState(() => _saving = true);
    try {
      final DateTime dateTime = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time?.hour ?? 9,
        _time?.minute ?? 0,
      );
      final scheduled = Appointment(
        id: widget.request.id,
        patientId: widget.request.patientId,
        dentisteId: _dentist!.id,
        dateHeure: dateTime.toIso8601String(),
        dureeEstimee: _duration.value,
        motif: widget.request.motif ?? 'Consultation',
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        statut: 'Planifie',
      );
      final ok = await widget.vm.acceptAndSchedule(scheduled);
      if (ok && mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeLabel = _time != null
        ? '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'
        : '';

    return DfBottomSheet(
      title: 'Valider la demande',
      subtitle: widget.request.patientFullName.isEmpty
          ? 'Confirmez le créneau du rendez-vous'
          : 'Patient: ${widget.request.patientFullName}',
      icon: Icons.event_available_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DfDateField(
                  label: 'Date confirmée',
                  required: true,
                  value: _date,
                  errorText: _dateError ? 'Date requise' : null,
                  onTap: () => showDfDatePicker(
                    context,
                    _date,
                    (d) => setState(() {
                      _date = d;
                      _dateError = false;
                    }),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DfPickerField(
                  label: 'Heure',
                  value: timeLabel,
                  hint: 'Heure',
                  icon: Icons.access_time_rounded,
                  onTap: () async {
                    final t = await showDfTimePicker(context, _time);
                    if (t != null) setState(() => _time = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          DfDropdownField<Dentist>(
            label: 'Médecin traitant',
            required: true,
            items: widget.vm.dentists.toList(),
            labelOf: (d) => d.fullName,
            value: _dentist,
            hint: 'Sélectionner un praticien',
            onChanged: (d) => setState(() => _dentist = d),
          ),
          const SizedBox(height: AppSpacing.base),
          DfDropdownField<_DurationOption>(
            label: 'Durée estimée',
            items: _durations,
            labelOf: (d) => d.label,
            value: _duration,
            onChanged: (d) => setState(() => _duration = d ?? _durations[1]),
          ),
          const SizedBox(height: AppSpacing.base),
          DfTextField(
            label: 'Note / Annotation',
            controller: _noteCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.xl),
          DfPrimaryButton(
            label: 'Planifier le RDV',
            loading: _saving,
            icon: Icons.check_rounded,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}

/// Duration options shared with the add sheet.
class _DurationOption {
  const _DurationOption(this.value, this.label);
  final String value;
  final String label;
}

const List<_DurationOption> _durations = [
  _DurationOption('00:15:00', '15 minutes'),
  _DurationOption('00:30:00', '30 minutes'),
  _DurationOption('00:45:00', '45 minutes'),
  _DurationOption('01:00:00', '1 heure'),
];
