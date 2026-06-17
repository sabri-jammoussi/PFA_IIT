import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _vm = Get.put(ProfileViewModel());
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _currentPwCtrl = TextEditingController();
  final TextEditingController _newPwCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    ever(_vm.profile, (UserProfile? p) {
      if (p != null && !_profileLoaded) {
        _profileLoaded = true;
        _prenomCtrl.text = p.prenom;
        _nomCtrl.text = p.nom;
        _emailCtrl.text = p.email;
        _usernameCtrl.text = p.username;
      }
    });
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final UserProfile? current = _vm.profile.value;
    if (current == null) return;
    await _vm.save(UserProfile(
      id: current.id,
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      isActive: current.isActive,
    ));
  }

  Future<void> _changePassword() async {
    if (_currentPwCtrl.text.isEmpty || _newPwCtrl.text.isEmpty) {
      showThemedSnackbar('Champ requis', 'Remplissez les deux champs.',
          type: SnackbarType.warning);
      return;
    }
    await _vm.changePassword(_currentPwCtrl.text, _newPwCtrl.text);
    _currentPwCtrl.clear();
    _newPwCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = DfColors.brandPrimary(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: Obx(() {
        if (_vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final UserProfile? profile = _vm.profile.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: DfColors.brandFaint(context),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profile?.initials ?? '?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (profile != null)
                        Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const DfSectionLabel(title: 'Informations personnelles'),
                const SizedBox(height: AppSpacing.sm),
                DfTextField(
                  label: 'Prénom',
                  hint: 'Votre prénom',
                  controller: _prenomCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: 'Nom',
                  hint: 'Votre nom',
                  controller: _nomCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: 'Email',
                  hint: 'adresse@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: "Nom d'utilisateur",
                  hint: 'username',
                  controller: _usernameCtrl,
                ),
                const SizedBox(height: AppSpacing.base),
                Obx(() => DfPrimaryButton(
                      label: 'Mettre à jour',
                      loading: _vm.isSaving.value,
                      icon: Icons.save_rounded,
                      onPressed: _saveProfile,
                    )),
                const SizedBox(height: AppSpacing.xxl),
                const DfSectionLabel(title: 'Changer le mot de passe'),
                const SizedBox(height: AppSpacing.sm),
                DfTextField(
                  label: 'Mot de passe actuel',
                  hint: '••••••••',
                  controller: _currentPwCtrl,
                  obscureText: _obscureCurrent,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: 'Nouveau mot de passe',
                  hint: '••••••••',
                  controller: _newPwCtrl,
                  obscureText: _obscureNew,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                DfSecondaryButton(
                  label: 'Changer le mot de passe',
                  icon: Icons.lock_reset_rounded,
                  onPressed: _changePassword,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      }),
    );
  }
}
