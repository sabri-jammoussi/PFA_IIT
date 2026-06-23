import 'package:flutter/material.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import 'package:dentiflow/pages/patients/models/patient_model.dart';
import 'package:dentiflow/pages/patients/services/patient_service.dart';
import '../models/appointment_model.dart';
import '../viewmodels/appointments_viewmodel.dart';

/// Duration options mirroring AppointmentAddDialog.vue.
class _DurationOption {
  const _DurationOption(this.value, this.label);
  final String value; // "HH:mm:ss"
  final String label;
}

const List<_DurationOption> _durations = [
  _DurationOption('00:15:00', '15 minutes'),
  _DurationOption('00:30:00', '30 minutes'),
  _DurationOption('00:45:00', '45 minutes'),
  _DurationOption('01:00:00', '1 heure'),
];

class AppointmentAddSheet extends StatefulWidget {
  const AppointmentAddSheet({required this.vm, this.initialSlot, super.key});

  final AppointmentsViewModel vm;

  /// Optional "HH:mm" pre-selected time when opened from a free slot.
  final String? initialSlot;

  @override
  State<AppointmentAddSheet> createState() => _AppointmentAddSheetState();
}

class _AppointmentAddSheetState extends State<AppointmentAddSheet> {
  final TextEditingController _motifCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  List<Patient> _patients = [];
  Patient? _selectedPatient;
  Dentist? _selectedDentist;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  _DurationOption _duration = _durations[1]; // 30 min default
  bool _saving = false;
  bool _loadingPatients = false;

  bool _patientError = false;
  bool _dateError = false;

  @override
  void initState() {
    super.initState();
    // Default date = agenda's currently selected day.
    _selectedDate = widget.vm.selectedDate.value;
    // Default time from tapped slot.
    if (widget.initialSlot != null) {
      final parts = widget.initialSlot!.split(':');
      if (parts.length >= 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    // Default dentist = agenda's filter selection.
    _selectedDentist = widget.vm.dentists
        .where((d) => d.id == widget.vm.selectedDentistId.value)
        .cast<Dentist?>()
        .firstWhere((_) => true, orElse: () => null);
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _loadingPatients = true);
    try {
      _patients = await PatientService.getPatients(pageSize: 100);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _patientError = _selectedPatient == null;
      _dateError = _selectedDate == null;
    });
    if (_patientError || _dateError) return;
    if (_selectedDentist == null) {
      showThemedSnackbar('Praticien requis',
          'Sélectionnez un médecin traitant.',
          type: SnackbarType.warning);
      return;
    }

    setState(() => _saving = true);
    try {
      final DateTime dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 9,
        _selectedTime?.minute ?? 0,
      );
      final appt = Appointment(
        id: 0,
        patientId: _selectedPatient!.id,
        dentisteId: _selectedDentist!.id,
        dateHeure: dateTime.toIso8601String(),
        dureeEstimee: _duration.value,
        motif: _motifCtrl.text.trim().isEmpty ? null : _motifCtrl.text.trim(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        statut: 'Planifie',
      );
      final ok = await widget.vm.addAppointment(appt);
      if (ok && mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeLabel = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : '';

    return DfBottomSheet(
      title: 'Planification RDV',
      subtitle: 'Renseignez les informations du rendez-vous',
      icon: Icons.calendar_month_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Patient
          DfDropdownField<Patient>(
            label: 'Patient',
            required: true,
            items: _patients,
            labelOf: (p) => p.fullName,
            value: _selectedPatient,
            hint: _loadingPatients
                ? 'Chargement...'
                : 'Sélectionner le patient',
            errorText: _patientError ? 'Patient requis' : null,
            onChanged: (p) => setState(() {
              _selectedPatient = p;
              _patientError = false;
            }),
          ),
          const SizedBox(height: AppSpacing.base),
          // Dentist
          DfDropdownField<Dentist>(
            label: 'Assigner praticien',
            items: widget.vm.dentists.toList(),
            labelOf: (d) => d.fullName,
            value: _selectedDentist,
            hint: 'Choisir un médecin',
            onChanged: (d) => setState(() => _selectedDentist = d),
          ),
          const SizedBox(height: AppSpacing.base),
          // Date + Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DfDateField(
                  label: 'Date',
                  required: true,
                  value: _selectedDate,
                  errorText: _dateError ? 'Date requise' : null,
                  onTap: () => showDfDatePicker(
                    context,
                    _selectedDate,
                    (d) => setState(() {
                      _selectedDate = d;
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
                    final t = await showDfTimePicker(context, _selectedTime);
                    if (t != null) setState(() => _selectedTime = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          // Duration
          DfDropdownField<_DurationOption>(
            label: 'Durée estimée',
            items: _durations,
            labelOf: (d) => d.label,
            value: _duration,
            onChanged: (d) => setState(() => _duration = d ?? _durations[1]),
          ),
          const SizedBox(height: AppSpacing.base),
          // Motif
          DfTextField(
            label: 'Motif de consultation',
            hint: 'Ex: Détartrage, Soin carie, Urgence...',
            controller: _motifCtrl,
          ),
          const SizedBox(height: AppSpacing.base),
          // Notes
          DfTextField(
            label: 'Notes additionnelles',
            hint: 'Annotations optionnelles...',
            controller: _noteCtrl,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.xl),
          DfPrimaryButton(
            label: 'Valider le rendez-vous',
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
