import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import 'package:dentiflow/core/widgets/df_dropdown_field.dart';
import '../viewmodels/patient_portal_viewmodel.dart';

class PatientBookView extends StatefulWidget {
  const PatientBookView({super.key});

  @override
  State<PatientBookView> createState() => _PatientBookViewState();
}

class _PatientBookViewState extends State<PatientBookView> {
  late final PatientPortalViewModel _vm;
  final TextEditingController _motifCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = Get.find<PatientPortalViewModel>();
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Réserver un rendez-vous')),
      body: Obx(() {
        final Map<String, dynamic>? selectedDentist = _vm.selectedDentisteId.value == 0
            ? null
            : _vm.dentists.firstWhere(
                (d) => (d['id'] ?? 0) == _vm.selectedDentisteId.value,
                orElse: () => <String, dynamic>{},
              );

        final Map<String, dynamic>? effectiveDentistValue =
            (selectedDentist == null || selectedDentist.isEmpty) ? null : selectedDentist;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DfDropdownField<Map<String, dynamic>>(
                label: 'Dentiste',
                hint: 'Choisir un dentiste',
                required: true,
                items: _vm.dentists,
                value: effectiveDentistValue,
                labelOf: (d) => 'Dr. ${d['prenom'] ?? ''} ${d['nom'] ?? ''}'.trim(),
                onChanged: (d) {
                  if (d != null) {
                    _vm.selectedDentisteId.value = (d['id'] ?? 0) as int;
                    _vm.loadAvailability();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.base),
              DfDateField(
                label: 'Date souhaitée',
                value: _vm.selectedDate.value,
                onTap: () => showDfDatePicker(
                  context,
                  _vm.selectedDate.value,
                  (d) {
                    _vm.selectedDate.value = d;
                    _vm.loadAvailability();
                  },
                  firstDate: DateTime.now(),
                ),
              ),
              // Slots
              if (_vm.selectedDentisteId.value != 0) ...[
                const SizedBox(height: AppSpacing.base),
                const DfSectionLabel(title: 'Créneaux disponibles'),
                const SizedBox(height: AppSpacing.sm),
                if (_vm.isLoadingSlots.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.base),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_vm.availableSlots.isEmpty)
                  const DfEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: 'Aucun créneau',
                    subtitle: 'Aucun créneau disponible pour cette date. Essayez une autre date.',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _vm.availableSlots.length,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        final slot = _vm.availableSlots[index];
                        final bool selected = _vm.selectedSlot.value == slot;
                        final bool isAvailable = slot.isAvailable;

                        return GestureDetector(
                          onTap: isAvailable ? () => _vm.selectedSlot.value = slot : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isAvailable
                                  ? (Theme.of(context).brightness == Brightness.dark
                                      ? DfColors.surface3(context)
                                      : Colors.grey.shade200)
                                  : selected
                                      ? primary
                                      : DfColors.surface2(context),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: selected ? primary : DfColors.borderColor(context),
                              ),
                            ),
                            child: Text(
                              slot.time,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: !isAvailable ? TextDecoration.lineThrough : null,
                                color: !isAvailable
                                    ? DfColors.dimTextColor(context)
                                    : selected
                                        ? Colors.white
                                        : DfColors.textColor(context),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
              ],
              const SizedBox(height: AppSpacing.base),
              DfTextField(
                label: 'Motif',
                hint: 'Ex: Contrôle annuel, Rage de dent, Détartrage...',
                controller: _motifCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.base),
              DfTextField(
                label: 'Notes ou précisions (Optionnel)',
                hint: 'Saisissez des détails supplémentaires...',
                controller: _noteCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              DfPrimaryButton(
                label: 'Envoyer la demande',
                loading: _vm.isRequesting.value,
                icon: Icons.send_rounded,
                onPressed: () => _vm.requestAppointment(
                  _motifCtrl.text.trim(),
                  note: _noteCtrl.text.trim(),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      }),
    );
  }
}

