import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/services/api_service.dart';
import '../models/patient_model.dart';

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView>
    with SingleTickerProviderStateMixin {
  late final Patient _patient;
  late final TabController _tabCtrl;

  List<Map<String, dynamic>> _consultations = [];
  List<Map<String, dynamic>> _traitements = [];
  List<Map<String, dynamic>> _ordonnances = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _patient = Get.arguments as Patient;
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/consultations?patientId=${_patient.id}'),
        ApiService.get('/soins-effectues?patientId=${_patient.id}'),
        ApiService.get('/ordonnances?patientId=${_patient.id}'),
      ]);
      setState(() {
        _consultations = _toList(results[0]);
        _traitements = _toList(results[1]);
        _ordonnances = _toList(results[2]);
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.fullName),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Infos'),
            Tab(text: 'Consultations'),
            Tab(text: 'Traitements'),
            Tab(text: 'Ordonnances'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                // Info tab
                ListView(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.base),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: DfColors.brandFaint(context),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _patient.initials,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: DfColors.brandPrimary(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(_patient.fullName,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.xs),
                          DfStatusBadge(
                            label: _patient.isActive ? 'Actif' : 'Archivé',
                            color: _patient.isActive
                                ? DfColors.green
                                : DfColors.orange,
                            faintColor: _patient.isActive
                                ? DfColors.greenFaintLight
                                : DfColors.orangeFaintLight,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                    DfCard(
                      child: Column(
                        children: [
                          DfInfoRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Prénom',
                              value: _patient.prenom),
                          DfInfoRow(
                              icon: Icons.badge_outlined,
                              label: 'Nom',
                              value: _patient.nom),
                          if (_patient.email?.isNotEmpty == true)
                            DfInfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _patient.email!),
                          if (_patient.phone?.isNotEmpty == true)
                            DfInfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Téléphone',
                                value: _patient.phone!),
                          if (_patient.dateNaissance?.isNotEmpty == true)
                            DfInfoRow(
                                icon: Icons.cake_outlined,
                                label: 'Date de naissance',
                                value: _fmtDate(_patient.dateNaissance)),
                          if (_patient.adresse?.isNotEmpty == true)
                            DfInfoRow(
                                icon: Icons.location_on_outlined,
                                label: 'Adresse',
                                value: _patient.adresse!),
                        ],
                      ),
                    ),
                  ],
                ),
                // Consultations tab
                _buildListTab(
                  _consultations,
                  Icons.medical_services_outlined,
                  'Aucune consultation',
                  (item) => _SimpleListTile(
                    title: _fmtDate(item['dateConsultation'] ?? item['date']),
                    subtitle: item['notes'] ?? item['diagnose'] ?? '',
                    icon: Icons.event_note_rounded,
                  ),
                ),
                // Traitements tab
                _buildListTab(
                  _traitements,
                  Icons.healing_outlined,
                  'Aucun traitement',
                  (item) => _SimpleListTile(
                    title:
                        'Dent ${item['numeroDent'] ?? '-'} — Face ${item['faceDentaire'] ?? '-'}',
                    subtitle:
                        '${item['prixApplique'] ?? '-'} DT • ${_fmtDate(item['dateIntervention'])}',
                    icon: Icons.vaccines_rounded,
                  ),
                ),
                // Ordonnances tab
                _buildListTab(
                  _ordonnances,
                  Icons.description_outlined,
                  'Aucune ordonnance',
                  (item) => _SimpleListTile(
                    title: _fmtDate(item['dateOrdonnance'] ?? item['date']),
                    subtitle: item['contenu'] ?? '',
                    icon: Icons.article_outlined,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildListTab(
    List<Map<String, dynamic>> items,
    IconData emptyIcon,
    String emptyTitle,
    Widget Function(Map<String, dynamic>) builder,
  ) {
    if (items.isEmpty) {
      return DfEmptyState(icon: emptyIcon, title: emptyTitle);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => builder(items[i]),
    );
  }
}

class _SimpleListTile extends StatelessWidget {
  const _SimpleListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: DfColors.brandFaint(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: DfColors.brandPrimary(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: DfColors.mutedTextColor(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
