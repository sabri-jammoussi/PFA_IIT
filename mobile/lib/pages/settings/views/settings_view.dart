import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/controllers/app_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          // Appearance section
          const DfSectionLabel(title: 'Apparence'),
          const SizedBox(height: AppSpacing.sm),
          DfCard(
            child: Column(
              children: [
                GetBuilder<AppController>(
                  builder: (c) => DfSettingRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'Mode sombre',
                    trailing: Switch(
                      value: c.themeMode == ThemeMode.dark,
                      onChanged: (_) => c.toggleTheme(),
                      activeColor: DfColors.brandPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Language section
          const DfSectionLabel(title: 'Langue'),
          const SizedBox(height: AppSpacing.sm),
          DfCard(
            child: Column(
              children: [
                GetBuilder<AppController>(
                  builder: (c) => DfSettingRow(
                    icon: Icons.language_rounded,
                    label: 'Langue de l\'interface',
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: DfColors.surface2(context),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                            color: DfColors.borderColor(context)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: c.locale.languageCode,
                          isDense: true,
                          dropdownColor: DfColors.surface1(context),
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                                value: 'fr',
                                child: Text('Français',
                                    style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'en',
                                child: Text('English',
                                    style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (lang) {
                            if (lang == null) return;
                            c.changeLocale(lang == 'fr'
                                ? const Locale('fr', 'FR')
                                : const Locale('en', 'US'));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // About section
          const DfSectionLabel(title: 'À propos'),
          const SizedBox(height: AppSpacing.sm),
          DfCard(
            child: Column(
              children: [
                DfInfoRow(
                  icon: Icons.medical_services_rounded,
                  label: 'Application',
                  value: 'DentiFlow',
                ),
                DfInfoRow(
                  icon: Icons.tag_rounded,
                  label: 'Version',
                  value: _version.isNotEmpty ? _version : '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
