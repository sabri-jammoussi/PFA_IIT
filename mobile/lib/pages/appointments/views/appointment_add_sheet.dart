import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import 'package:dentiflow/pages/patients/models/patient_model.dart';
import 'package:dentiflow/pages/patients/services/patient_service.dart';
import '../models/appointment_model.dart';
import '../viewmodels/appointments_viewmodel.dart';

class AppointmentAddSheet extends StatefulWidget {
  const AppointmentAddSheet({required this.vm, super.key});

  final AppointmentsViewModel vm;

  @override
  State<AppointmentAddSheet> createState() => _AppointmentAddSheetState();
}

class _AppointmentAddSheetState extends State<AppointmentAddSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _motifCtrl = TextEditingController();

  List<Patient> _patients = [];
  Patient? _selectedPatient;
  Dentist? _selectedDentist;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _saving = false;
  bool _loadingPatients = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _loadingPatients = true);
    try {
      _patients = await PatientService.getPatients(pageSize: 100);
      if (mounted) setState(() {});
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      showThemedSnackbar('Date requise', 'Sélectionnez une date.',
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
        patientId: _selectedPatient?.id,
        dentisteId: _selectedDentist?.id,
        dateHeure: dateTime.toIso8601String(),
        motif: _motifCtrl.text.trim().isEmpty ? null : _motifCtrl.text.trim(),
        statut: 'PLANIFIÉ',
      );
      await widget.vm.addAppointment(appt);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DfBottomSheet(
      title: 'Nouveau rendez-vous',
      icon: Icons.calendar_month_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient picker
            Text('PATIENT',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.dimTextColor(context),
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: DfColors.surface3(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: DfColors.borderColor(context)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Patient>(
                  value: _selectedPatient,
                  isExpanded: true,
                  hint: Text(
                      _loadingPatients
                          ? 'Chargement...'
                          : 'Sélectionner un patient',
                      style: TextStyle(
                          color: DfColors.subTextColor(context), fontSize: 14)),
                  dropdownColor: DfColors.surface1(context),
                  items: _patients
                      .map((p) => DropdownMenuItem<Patient>(
                            value: p,
                            child: Text(p.fullName,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (p) => setState(() => _selectedPatient = p),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            // Dentist picker
            Text('DENTISTE',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.dimTextColor(context),
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: DfColors.surface3(context),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: DfColors.borderColor(context)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: Obx(() => DropdownButton<Dentist>(
                      value: _selectedDentist,
                      isExpanded: true,
                      hint: Text('Sélectionner un dentiste',
                          style: TextStyle(
                              color: DfColors.subTextColor(context),
                              fontSize: 14)),
                      dropdownColor: DfColors.surface1(context),
                      items: widget.vm.dentists
                          .map((d) => DropdownMenuItem<Dentist>(
                                value: d,
                                child: Text(d.fullName,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (d) => setState(() => _selectedDentist = d),
                    )),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            DfDateField(
              label: 'Date',
              value: _selectedDate,
              onTap: () => showDfDatePicker(
                context,
                _selectedDate,
                (d) => setState(() => _selectedDate = d),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            DfPickerField(
              label: 'Heure',
              value: _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : null,
              hint: 'Sélectionner l\'heure',
              icon: Icons.access_time_rounded,
              onTap: () async {
                final t = await showDfTimePicker(context, _selectedTime);
                if (t != null) setState(() => _selectedTime = t);
              },
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Motif',
              hint: 'Raison du rendez-vous',
              controller: _motifCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),
            DfPrimaryButton(
              label: 'Enregistrer',
              loading: _saving,
              icon: Icons.save_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
