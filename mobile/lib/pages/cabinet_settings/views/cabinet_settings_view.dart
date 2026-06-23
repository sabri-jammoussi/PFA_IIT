import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import 'package:dentiflow/core/widgets/df_text_field.dart';
import '../models/cabinet_settings_model.dart';
import '../viewmodels/cabinet_settings_viewmodel.dart';

/// Cabinet SMTP settings — parity with web `CabinetSettingsView.vue`.
/// Suggested route: '/cabinet-settings'.
class CabinetSettingsView extends StatefulWidget {
  const CabinetSettingsView({super.key});

  @override
  State<CabinetSettingsView> createState() => _CabinetSettingsViewState();
}

class _CabinetSettingsViewState extends State<CabinetSettingsView> {
  final CabinetSettingsViewModel vm = Get.put(CabinetSettingsViewModel());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _senderNameCtrl = TextEditingController();
  final TextEditingController _hostCtrl = TextEditingController();
  final TextEditingController _portCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _ssl = true;
  bool _hasStoredPassword = false;
  bool _hydrated = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _senderNameCtrl.dispose();
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _hydrate(CabinetSettings s) {
    _senderNameCtrl.text = s.senderName;
    _hostCtrl.text = s.smtpHost;
    _portCtrl.text = s.smtpPort ?? '';
    _usernameCtrl.text = s.smtpUsername;
    _passwordCtrl.text = '';
    _ssl = s.smtpEnableSsl;
    _hasStoredPassword = s.hasStoredPassword;
    _hydrated = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final bool typedPassword = _passwordCtrl.text.trim().isNotEmpty;
    await vm.save(CabinetSettings(
      senderName: _senderNameCtrl.text,
      smtpHost: _hostCtrl.text,
      smtpPort: _portCtrl.text,
      smtpUsername: _usernameCtrl.text,
      smtpPassword: _passwordCtrl.text,
      smtpEnableSsl: _ssl,
    ));
    // On success the VM re-fetched; reset the write-only password field and
    // flag that credentials are now stored (mirrors the web behaviour).
    if (!mounted) return;
    _passwordCtrl.clear();
    if (typedPassword || _usernameCtrl.text.trim().isNotEmpty) {
      setState(() => _hasStoredPassword = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres du cabinet')),
      body: Obx(() {
        if (vm.isLoading.value && vm.settings.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final CabinetSettings? s = vm.settings.value;
        // Hydrate the controllers once when the settings first arrive.
        // (After a save the VM re-fetches; we keep the user's view stable
        // and only reset the password field, handled in _save's snackbar flow.)
        if (s != null && !_hydrated) _hydrate(s);

        return SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base, AppSpacing.sm, AppSpacing.base, AppSpacing.huge),
              children: [
                _intro(context),
                const SizedBox(height: AppSpacing.sm),

                const DfSectionLabel(title: "Expéditeur"),
                DfTextField(
                  label: "Nom d'affichage de l'expéditeur",
                  hint: 'ex. Cabinet Dentaire Sfax - Dr. Dupont',
                  controller: _senderNameCtrl,
                ),

                const SizedBox(height: AppSpacing.base),
                const DfSectionLabel(title: 'Serveur SMTP'),
                DfTextField(
                  label: 'Hôte SMTP',
                  hint: 'ex. smtp.gmail.com',
                  controller: _hostCtrl,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: 'Port SMTP',
                  hint: 'ex. 587',
                  controller: _portCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return int.tryParse(v.trim()) == null
                        ? 'Port invalide'
                        : null;
                  },
                ),

                const SizedBox(height: AppSpacing.base),
                const DfSectionLabel(title: 'Authentification'),
                DfTextField(
                  label: "Nom d'utilisateur SMTP (email de connexion)",
                  hint: 'ex. cabinet.dupont@pro.com',
                  controller: _usernameCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.base),
                DfTextField(
                  label: "Mot de passe SMTP / Clé d'application",
                  hint: _hasStoredPassword
                      ? '•••••••• (laisser vide pour ne pas modifier)'
                      : 'Entrer le mot de passe',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: DfColors.mutedTextColor(context),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                const SizedBox(height: AppSpacing.base),
                _sslToggle(context),

                const SizedBox(height: AppSpacing.xl),
                DfPrimaryButton(
                  label: 'Enregistrer la configuration',
                  icon: Icons.save_rounded,
                  loading: vm.isSaving.value,
                  onPressed: vm.isSaving.value ? null : _save,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _intro(BuildContext context) {
    return DfCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DfColors.brandFaint(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.apartment_rounded,
                size: 22, color: DfColors.brandPrimary(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paramètres privés du cabinet',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DfColors.textColor(context))),
                const SizedBox(height: 2),
                Text(
                  "Serveur SMTP pour l'envoi de vos rappels et ordonnances.",
                  style: TextStyle(
                      fontSize: 12,
                      color: DfColors.mutedTextColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sslToggle(BuildContext context) {
    return DfCard(
      padding: EdgeInsets.zero,
      child: DfSettingRow(
        icon: Icons.lock_outline_rounded,
        label: 'Connexion sécurisée SSL / TLS',
        subLabel: 'Recommandé',
        trailing: Switch(
          value: _ssl,
          onChanged: (v) => setState(() => _ssl = v),
        ),
        onTap: () => setState(() => _ssl = !_ssl),
      ),
    );
  }
}
