import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../viewmodels/register_clinic_viewmodel.dart';

/// Full-page (scrollable) clinic onboarding form.
/// Mirrors the Vue RegisterClinicView fields:
///   nomCabinet, adresse, doctorNom, doctorPrenom, doctorEmail, doctorPassword.
/// On success shows a confirmation state then routes to /login.
class RegisterClinicView extends StatefulWidget {
  const RegisterClinicView({super.key});

  @override
  State<RegisterClinicView> createState() => _RegisterClinicViewState();
}

class _RegisterClinicViewState extends State<RegisterClinicView> {
  final RegisterClinicViewModel _vm = Get.put(RegisterClinicViewModel());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomCabinetCtrl = TextEditingController();
  final TextEditingController _adresseCtrl = TextEditingController();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nomCabinetCtrl.dispose();
    _adresseCtrl.dispose();
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _vm.register(
      nomCabinet: _nomCabinetCtrl.text,
      adresse: _adresseCtrl.text,
      doctorNom: _nomCtrl.text,
      doctorPrenom: _prenomCtrl.text,
      doctorEmail: _emailCtrl.text,
      doctorPassword: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un cabinet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.offAllNamed('/login'),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => _vm.success.value
              ? _buildSuccess(context)
              : _buildForm(context),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 16, color: DfColors.brandPrimary(context)),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: DfColors.dimTextColor(context),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.xxl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rejoignez la révolution DentiFlow.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Enregistrez votre clinique et accédez immédiatement à votre espace de travail sécurisé.',
              style: TextStyle(
                color: DfColors.mutedTextColor(context),
                fontSize: 14,
              ),
            ),

            // ===== Clinic details =====
            _sectionLabel(context, Icons.business_rounded, 'Votre cabinet'),
            DfTextField(
              label: 'Nom du cabinet',
              hint: 'Ex: Clinique Dentaire Jasmin',
              controller: _nomCabinetCtrl,
              prefixIcon: const Icon(Icons.business_rounded, size: 18),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Adresse (optionnelle)',
              hint: 'Ex: Route de Téniour, Sfax',
              controller: _adresseCtrl,
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
            ),

            // ===== Owner / dentist details =====
            _sectionLabel(
                context, Icons.person_outline_rounded, 'Compte propriétaire'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DfTextField(
                    label: 'Nom',
                    hint: 'Ex: Ben Ali',
                    controller: _nomCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Champ requis'
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DfTextField(
                    label: 'Prénom',
                    hint: 'Ex: Ahmed',
                    controller: _prenomCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Champ requis'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Adresse email',
              hint: 'Ex: dr.ahmed@cabinet.tn',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.base),
            DfTextField(
              label: 'Mot de passe',
              hint: 'Minimum 8 caractères',
              controller: _passwordCtrl,
              obscureText: _obscure,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ requis';
                if (v.length < 8) return 'Minimum 8 caractères';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),
            Obx(() {
              final String err = _vm.errorMessage.value;
              if (err.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: DfColors.dangerFaint(context),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: DfColors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 16, color: DfColors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        err,
                        style: const TextStyle(
                            color: DfColors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Obx(() => DfPrimaryButton(
                  label: 'Créer le cabinet',
                  loading: _vm.isLoading.value,
                  icon: Icons.check_rounded,
                  onPressed: _submit,
                )),
            const SizedBox(height: AppSpacing.md),
            DfSecondaryButton(
              label: 'Retour à la connexion',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Get.offAllNamed('/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DfEmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: 'Félicitations !',
            subtitle:
                'Le cabinet "${_nomCabinetCtrl.text}" a été configuré avec succès. '
                'Le compte de Dr. ${_prenomCtrl.text} ${_nomCtrl.text} est actif.',
          ),
          const SizedBox(height: AppSpacing.lg),
          DfCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DfInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Identifiant / Email',
                  value: _emailCtrl.text,
                ),
                DfInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Rôle',
                  value: 'Dentiste (Directeur)',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          DfPrimaryButton(
            label: 'Se connecter à DentiFlow',
            icon: Icons.login_rounded,
            onPressed: () => Get.offAllNamed('/login'),
          ),
        ],
      ),
    );
  }
}
