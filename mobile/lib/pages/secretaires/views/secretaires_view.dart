import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_bottom_sheet.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/secretaire_model.dart';
import '../viewmodels/secretaires_viewmodel.dart';

class SecretairesView extends StatelessWidget {
  const SecretairesView({super.key});

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final SecretairesViewModel vm = Get.put(SecretairesViewModel());
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Secrétaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Ajouter une secrétaire',
            onPressed: () => _openForm(context, vm),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.base, AppSpacing.base, AppSpacing.base, AppSpacing.sm),
            child: TextField(
              onChanged: vm.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom, e-mail ou identifiant...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (vm.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.secretaires.isEmpty) {
                return DfEmptyState(
                  icon: Icons.badge_outlined,
                  title: vm.search.value.isEmpty
                      ? 'Aucune secrétaire enregistrée'
                      : 'Aucun résultat',
                  subtitle: vm.search.value.isEmpty
                      ? 'Ajoutez une secrétaire et envoyez-lui ses identifiants.'
                      : 'Aucune secrétaire ne correspond à votre recherche.',
                  action: vm.search.value.isEmpty
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.person_add_rounded, size: 18),
                          label: const Text('Ajouter'),
                          onPressed: () => _openForm(context, vm),
                        )
                      : null,
                );
              }
              return RefreshIndicator(
                onRefresh: vm.loadSecretaires,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, AppSpacing.sm, AppSpacing.base, 100),
                  itemCount: vm.secretaires.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final Secretaire s = vm.secretaires[index];
                    return DfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Avatar circle
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: s.isActive
                                      ? DfColors.brandFaint(context)
                                      : DfColors.surface2(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    s.initials,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: s.isActive
                                          ? primary
                                          : DfColors.mutedTextColor(context),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.displayName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                                    if (s.username.isNotEmpty)
                                      Text(
                                        '@${s.username}',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          color:
                                              DfColors.mutedTextColor(context),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              s.isActive
                                  ? DfStatusBadge.success(context, 'Actif')
                                  : DfStatusBadge(
                                      label: 'Inactif',
                                      color: DfColors.mutedTextColor(context),
                                      faintColor: DfColors.surface2(context),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (s.email?.isNotEmpty == true)
                            DfInfoRow(
                              icon: Icons.email_outlined,
                              label: 'E-mail',
                              value: s.email!,
                            ),
                          DfInfoRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Créé le',
                            value: _formatDate(s.createdAt),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: DfColors.borderColor(context), height: 1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _openForm(context, vm, edit: s),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Modifier'),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: () =>
                                    _confirmDelete(context, vm, s),
                                style: TextButton.styleFrom(
                                    foregroundColor: DfColors.red),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    size: 16),
                                label: const Text('Supprimer'),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, vm),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  void _openForm(BuildContext context, SecretairesViewModel vm,
      {Secretaire? edit}) {
    DfBottomSheet.show(
      context,
      child: _SecretaireFormSheet(vm: vm, edit: edit),
    );
  }

  void _confirmDelete(
      BuildContext context, SecretairesViewModel vm, Secretaire s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement le compte de ${s.displayName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: DfColors.red),
            onPressed: () {
              Navigator.pop(ctx);
              vm.deleteSecretaire(s);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _SecretaireFormSheet extends StatefulWidget {
  final SecretairesViewModel vm;
  final Secretaire? edit;
  const _SecretaireFormSheet({required this.vm, this.edit});

  @override
  State<_SecretaireFormSheet> createState() => _SecretaireFormSheetState();
}

class _SecretaireFormSheetState extends State<_SecretaireFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _isActive = true;

  bool get _isEdit => widget.edit != null;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    if (e != null) {
      _prenomCtrl.text = e.prenom;
      _nomCtrl.text = e.nom;
      _emailCtrl.text = e.email ?? '';
      _usernameCtrl.text = e.username;
      _isActive = e.isActive;
    } else {
      _pwdCtrl.text = _generatePassword();
    }
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final rnd = Random.secure();
    return List.generate(10, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    bool ok;
    if (_isEdit) {
      ok = await widget.vm.updateSecretaire(
        original: widget.edit!,
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        isActive: _isActive,
        username: _usernameCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
    } else {
      ok = await widget.vm.createSecretaire(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
        username: _usernameCtrl.text.trim(),
      );
    }
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DfBottomSheet(
      title: _isEdit ? 'Modifier Secrétaire' : 'Ajouter une Secrétaire',
      subtitle: _isEdit
          ? 'Mettez à jour les informations du compte.'
          : 'Créez un compte et envoyez les identifiants.',
      icon: _isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DfTextField(
              label: 'Prénom',
              hint: 'Ex: Fatma',
              controller: _prenomCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DfTextField(
              label: 'Nom',
              hint: 'Ex: Ben Ali',
              controller: _nomCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DfTextField(
              label: 'Adresse e-mail',
              hint: 'Ex: secretaire@cabinet.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            DfTextField(
              label: "Nom d'utilisateur (optionnel)",
              hint: "Laissez vide pour utiliser l'e-mail",
              controller: _usernameCtrl,
            ),
            const SizedBox(height: AppSpacing.md),
            // Password field with "Générer" button
            Row(
              children: [
                Text(
                  (_isEdit
                          ? 'Mot de passe (laisser vide si inchangé)'
                          : "Mot de passe temporaire d'invitation")
                      .toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DfColors.dimTextColor(context),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _pwdCtrl.text = _generatePassword()),
                  child: Text(
                    'GÉNÉRER',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: DfColors.brandPrimary(context),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pwdCtrl,
              inputFormatters: [],
              decoration: const InputDecoration(
                hintText: 'Saisissez ou générez un mot de passe',
              ),
              validator: (v) {
                if (_isEdit) return null;
                if (v == null || v.length < 6) return 'Minimum 6 caractères';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // Active checkbox (edit only)
            if (_isEdit)
              InkWell(
                onTap: () => setState(() => _isActive = !_isActive),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isActive,
                        onChanged: (v) =>
                            setState(() => _isActive = v ?? true),
                        activeColor: DfColors.brandPrimary(context),
                      ),
                      Text(
                        'Compte actif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DfColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Info box (add only)
            if (!_isEdit) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: DfColors.infoFaint(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: DfColors.info(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "En validant, le compte de la secrétaire sera automatiquement créé pour votre cabinet, et un e-mail d'invitation avec ses identifiants lui sera envoyé immédiatement.",
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: DfColors.subTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Obx(() => DfPrimaryButton(
                  label: _isEdit ? 'Mettre à jour' : 'Enregistrer',
                  loading: widget.vm.isSubmitting.value,
                  icon: _isEdit ? Icons.save_rounded : Icons.person_add_rounded,
                  onPressed: _submit,
                )),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }
}
