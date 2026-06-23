import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthViewModel _vm = Get.put(AuthViewModel());
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _resetCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  Widget _errorAlert(BuildContext context, String err) {
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
          const Icon(Icons.error_outline_rounded, size: 16, color: DfColors.red),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            child: Obx(
              () => _vm.isResetMode.value
                  ? _buildResetForm(context)
                  : _buildLoginForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle,
      IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: DfColors.brandFaint(context),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Icon(icon, size: 38, color: DfColors.brandPrimary(context)),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: TextStyle(
            color: DfColors.mutedTextColor(context),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            context,
            'DentiFlow',
            'Connectez-vous à votre espace',
            Icons.medical_services_rounded,
          ),
          DfTextField(
            label: 'Identifiant',
            hint: "Votre nom d'utilisateur",
            controller: _usernameCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
          ),
          const SizedBox(height: AppSpacing.base),
          DfTextField(
            label: 'Mot de passe',
            hint: '••••••••',
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
            validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _vm.toggleResetMode(true),
              child: const Text('Mot de passe oublié ?'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(() => _errorAlert(context, _vm.errorMessage.value)),
          Obx(() => DfPrimaryButton(
                label: 'Se connecter',
                loading: _vm.isLoading.value,
                icon: Icons.login_rounded,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _vm.login(_usernameCtrl.text, _passwordCtrl.text);
                  }
                },
              )),
          const SizedBox(height: AppSpacing.xl),
          // Onboarding registration link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nouveau praticien ? ',
                style: TextStyle(
                  color: DfColors.mutedTextColor(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/register'),
                child: Text(
                  'Créer un compte cabinet',
                  style: TextStyle(
                    color: DfColors.brandPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm(BuildContext context) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            context,
            'Mot de passe oublié',
            'Saisissez votre email ou matricule pour récupérer votre compte',
            Icons.lock_reset_rounded,
          ),
          DfTextField(
            label: 'Email ou Matricule',
            hint: 'Ex: dr.martin@clinique.com',
            controller: _resetCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
          ),
          const SizedBox(height: AppSpacing.base),
          Obx(() => _errorAlert(context, _vm.resetError.value)),
          Obx(() => DfPrimaryButton(
                label: 'Envoyer un email',
                loading: _vm.isResetLoading.value,
                icon: Icons.send_rounded,
                onPressed: () {
                  if (_resetFormKey.currentState!.validate()) {
                    _vm.forgetPassword(_resetCtrl.text);
                  }
                },
              )),
          const SizedBox(height: AppSpacing.md),
          DfSecondaryButton(
            label: 'Retour à la connexion',
            icon: Icons.arrow_back_rounded,
            onPressed: () => _vm.toggleResetMode(false),
          ),
        ],
      ),
    );
  }
}
