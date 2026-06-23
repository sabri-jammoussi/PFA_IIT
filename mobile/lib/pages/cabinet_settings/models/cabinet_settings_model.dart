/// SMTP configuration of the cabinet — mirrors the web
/// `CabinetSettingsView.vue` (GET/POST /cabinet/settings/smtp).
/// The password is write-only: the API never returns it, so [smtpPassword]
/// is only populated when the user types a new one and is omitted from the
/// payload when left blank (server keeps the stored value).
class CabinetSettings {
  String senderName;
  String smtpHost;
  String? smtpPort;
  String smtpUsername;
  String smtpPassword;
  bool smtpEnableSsl;

  /// True when the cabinet already has SMTP credentials stored server-side.
  /// Used to show the "leave blank to keep" password hint, like the web page.
  final bool hasStoredPassword;

  CabinetSettings({
    this.senderName = '',
    this.smtpHost = '',
    this.smtpPort,
    this.smtpUsername = '',
    this.smtpPassword = '',
    this.smtpEnableSsl = true,
    this.hasStoredPassword = false,
  });

  factory CabinetSettings.fromJson(Map<String, dynamic> j) => CabinetSettings(
        senderName: (j['senderName'] ?? '') as String,
        smtpHost: (j['smtpHost'] ?? '') as String,
        smtpPort: j['smtpPort']?.toString(),
        smtpUsername: (j['smtpUsername'] ?? '') as String,
        smtpPassword: '',
        smtpEnableSsl: (j['smtpEnableSsl'] ?? true) as bool,
        // Web treats the cabinet as "configured" when a username exists.
        hasStoredPassword:
            ((j['smtpUsername'] ?? '') as String).trim().isNotEmpty,
      );

  Map<String, dynamic> toJson() => {
        'senderName': senderName.trim(),
        'smtpHost': smtpHost.trim(),
        'smtpPort': (smtpPort != null && smtpPort!.trim().isNotEmpty)
            ? int.tryParse(smtpPort!.trim())
            : null,
        'smtpUsername': smtpUsername.trim(),
        // Omit the password when blank so the server keeps the stored one.
        'smtpPassword':
            smtpPassword.trim().isEmpty ? null : smtpPassword.trim(),
        'smtpEnableSsl': smtpEnableSsl,
      };
}
