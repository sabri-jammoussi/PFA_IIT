import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import '../models/patient_model.dart';
import '../viewmodels/patients_viewmodel.dart';
import 'patient_add_sheet.dart';

class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  State<PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<PatientsListView> {
  final PatientsViewModel _vm = Get.put(PatientsViewModel());
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _vm.loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    DfBottomSheet.show(
      context,
      child: PatientAddSheet(onSaved: _vm.addPatient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintStyle:
                      TextStyle(color: DfColors.mutedTextColor(context)),
                ),
                onChanged: _vm.search,
              )
            : const Text('Patients'),
        actions: [
          IconButton(
            icon:
                Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                _vm.search('');
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nouveau patient'),
      ),
      body: Obx(() {
        if (_vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_vm.patients.isEmpty) {
          return const DfEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'Aucun patient',
            subtitle:
                'Ajoutez votre premier patient en appuyant sur le bouton ci-dessous.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => _vm.loadPatients(),
          child: ListView.separated(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
            itemCount:
                _vm.patients.length + (_vm.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == _vm.patients.length) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ));
              }
              final Patient patient = _vm.patients[index];
              return _PatientCard(
                patient: patient,
                onTap: () =>
                    Get.toNamed('/patient-profile', arguments: patient),
              );
            },
          ),
        );
      }),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onTap});

  final Patient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DfColors.brandFaint(context),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              patient.initials,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: DfColors.brandPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                if (patient.phone != null && patient.phone!.isNotEmpty)
                  Text(patient.phone!,
                      style: TextStyle(
                          fontSize: 13,
                          color: DfColors.mutedTextColor(context))),
                if (patient.email != null && patient.email!.isNotEmpty)
                  Text(patient.email!,
                      style: TextStyle(
                          fontSize: 12,
                          color: DfColors.dimTextColor(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 18, color: DfColors.mutedTextColor(context)),
        ],
      ),
    );
  }
}
