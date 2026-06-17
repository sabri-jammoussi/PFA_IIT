import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import 'package:dentiflow/core/widgets/df_time_picker.dart';
import '../viewmodels/patient_portal_viewmodel.dart';

class PatientBookView extends StatefulWidget {
  const PatientBookView({super.key});

  @override
  State<PatientBookView> createState() => _PatientBookViewState();
}

class _PatientBookViewState extends State<PatientBookView> {
  late final PatientPortalViewModel _vm;
  final TextEditingController _motifCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = Get.find<PatientPortalViewModel>();
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Réserver un rendez-vous')),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DfSectionLabel(title: 'Sélectionner un dentiste'),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: DfColors.surface3(context),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: DfColors.borderColor(context)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _vm.selectedDentisteId.value == 0
                          ? null
                          : _vm.selectedDentisteId.value,
                      isExpanded: true,
                      hint: Text('Choisir un dentiste',
                          style: TextStyle(
                              color: DfColors.subTextColor(context),
                              fontSize: 14)),
                      dropdownColor: DfColors.surface1(context),
                      items: _vm.dentists
                          .map((d) => DropdownMenuItem<int>(
                                value: (d['id'] ?? 0) as int,
                                child: Text(
                                    '${d['prenom'] ?? ''} ${d['nom'] ?? ''}'
                                        .trim(),
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (id) {
                        if (id != null) {
                          _vm.selectedDentisteId.value = id;
                          _vm.loadAvailability();
                        }
                      },
                    ),
                  ),
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
                    ))
                  else if (_vm.availableSlots.isEmpty)
                    const DfEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'Aucun créneau',
                      subtitle:
                          'Aucun créneau disponible pour cette date. Essayez une autre date.',
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _vm.availableSlots.map((slot) {
                        final bool selected =
                            _vm.selectedSlot.value == slot;
                        return GestureDetector(
                          onTap: () => _vm.selectedSlot.value = slot,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primary
                                  : DfColors.surface2(context),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: selected
                                    ? primary
                                    : DfColors.borderColor(context),
                              ),
                            ),
                            child: Text(
                              slot,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: selected
                                    ? Colors.white
                                    : DfColors.textColor(context),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: 'Motif',
                  hint: 'Raison de votre visite',
                  controller: _motifCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
                DfPrimaryButton(
                  label: 'Envoyer la demande',
                  loading: _vm.isRequesting.value,
                  icon: Icons.send_rounded,
                  onPressed: () => _vm.requestAppointment(_motifCtrl.text.trim()),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          )),
    );
  }
}
