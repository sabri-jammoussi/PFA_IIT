import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/secretaire_model.dart';
import '../viewmodels/secretaires_viewmodel.dart';

class SecretairesView extends StatelessWidget {
  const SecretairesView({super.key});

  @override
  Widget build(BuildContext context) {
    final SecretairesViewModel vm = Get.put(SecretairesViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Secrétaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Ajouter un secrétaire',
            onPressed: () => _showAddSheet(context, vm),
          ),
        ],
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.secretaires.isEmpty) {
          return DfEmptyState(
            icon: Icons.badge_outlined,
            title: 'Aucun secrétaire',
            subtitle: 'Ajoutez des secrétaires pour gérer votre cabinet.',
            action: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Ajouter'),
              onPressed: () => _showAddSheet(context, vm),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: vm.loadSecretaires,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, 100),
            itemCount: vm.secretaires.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final Secretaire s = vm.secretaires[index];
              return DfCard(
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: s.isActive
                            ? DfColors.brandFaint(context)
                            : DfColors.warningFaint(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          s.initials,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: s.isActive ? primary : DfColors.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          if (s.email?.isNotEmpty == true)
                            Text(s.email!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DfColors.mutedTextColor(context))),
                        ],
                      ),
                    ),
                    // Active toggle
                    Column(
                      children: [
                        DfStatusBadge(
                          label: s.isActive ? 'Actif' : 'Inactif',
                          color: s.isActive ? DfColors.green : DfColors.orange,
                          faintColor: s.isActive
                              ? DfColors.greenFaintLight
                              : DfColors.orangeFaintLight,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => vm.toggleActive(s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: s.isActive
                                      ? DfColors.warningFaint(context)
                                      : DfColors.successFaint(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.isActive ? 'Désactiver' : 'Activer',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: s.isActive
                                        ? DfColors.orange
                                        : DfColors.green,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, vm),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  void _showAddSheet(BuildContext context, SecretairesViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSecretaireSheet(vm: vm),
    );
  }
}

class _AddSecretaireSheet extends StatefulWidget {
  final SecretairesViewModel vm;
  const _AddSecretaireSheet({required this.vm});

  @override
  State<_AddSecretaireSheet> createState() => _AddSecretaireSheetState();
}

class _AddSecretaireSheetState extends State<_AddSecretaireSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: DfColors.surface1(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: DfColors.borderColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Nouveau Secrétaire',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DfColors.textColor(context),
                  )),
              const SizedBox(height: AppSpacing.base),
              DfTextField(
                label: 'Prénom',
                hint: 'Prénom',
                controller: _prenomCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              DfTextField(
                label: 'Nom',
                hint: 'Nom de famille',
                controller: _nomCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              DfTextField(
                label: 'Email',
                hint: 'adresse@email.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              DfTextField(
                label: 'Mot de passe',
                hint: '••••••••',
                controller: _pwdCtrl,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Obx(() => DfPrimaryButton(
                    label: 'Créer le compte',
                    loading: widget.vm.isSubmitting.value,
                    icon: Icons.person_add_rounded,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.vm
                            .createSecretaire(
                              nom: _nomCtrl.text.trim(),
                              prenom: _prenomCtrl.text.trim(),
                              email: _emailCtrl.text.trim(),
                              password: _pwdCtrl.text,
                            )
                            .then((_) => Navigator.pop(context));
                      }
                    },
                  )),
              const SizedBox(height: AppSpacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
