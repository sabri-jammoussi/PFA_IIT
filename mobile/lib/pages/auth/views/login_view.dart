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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: DfColors.brandFaint(context),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: 38,
                      color: DfColors.brandPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'DentiFlow',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Connectez-vous Ã  votre espace',
                    style: TextStyle(
                      color: DfColors.mutedTextColor(context),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  DfTextField(
                    label: 'Identifiant',
                    hint: "Votre nom d'utilisateur",
                    controller: _usernameCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon:
                        const Icon(Icons.person_outline_rounded, size: 18),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  DfTextField(
                    label: 'Mot de passe',
                    hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                        border: Border.all(
                            color: DfColors.red.withOpacity(0.3)),
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
                  const SizedBox(height: AppSpacing.base),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
