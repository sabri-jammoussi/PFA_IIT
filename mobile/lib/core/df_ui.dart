import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================================
// SPACING
// ============================================================================

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

// ============================================================================
// BORDER RADIUS
// ============================================================================

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 999;
}

// ============================================================================
// TEXT STYLES — monospace for numeric data
// ============================================================================

class DfTextStyles {
  static TextStyle monoLg(Color color) => TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.9,
      );

  static TextStyle monoMd(Color color) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle kpiNumber(Color color) => TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -1.5,
      );
}

// ============================================================================
// COLOR PALETTE — DentiFlow (teal/blue, professional healthcare)
// ============================================================================

class DfColors {
  // ===== BRAND — Dental teal/blue =====
  static const Color primary = Color(0xFF0284C7);      // sky-600 — dark mode
  static const Color primaryLight = Color(0xFF38BDF8);  // sky-400 — light primary
  static const Color primaryDim = Color(0xFF0369A1);    // sky-700 — pressed

  static const Color primaryFaintDark = Color(0x1F0284C7);
  static const Color primaryFaintLight = Color(0x1A0284C7);

  // ===== SEMANTIC =====
  static const Color orange = Color(0xFFFF9800);
  static const Color orangeFaintDark = Color(0x1FFF9800);
  static const Color orangeFaintLight = Color(0x1EF59E0B);

  static const Color red = Color(0xFFFF4444);
  static const Color redFaintDark = Color(0x1FFF4444);
  static const Color redFaintLight = Color(0x1EEF4444);

  static const Color green = Color(0xFF22C55E);
  static const Color greenFaintDark = Color(0x1F22C55E);
  static const Color greenFaintLight = Color(0x1A22C55E);

  static const Color blue = Color(0xFF3B82F6);
  static const Color blueFaintDark = Color(0x1F3B82F6);
  static const Color blueFaintLight = Color(0x1A3B82F6);

  // ===== DARK MODE BACKGROUNDS =====
  static const Color bgPageDark = Color(0xFF0A0F14);
  static const Color bgAppDark = Color(0xFF111820);
  static const Color bgCardDark = Color(0xFF1A2330);
  static const Color bgElevDark = Color(0xFF202C3A);
  static const Color bgInputDark = Color(0xFF162030);

  // ===== LIGHT MODE BACKGROUNDS =====
  static const Color bgPageLight = Color(0xFFEFF6FF);
  static const Color bgAppLight = Color(0xFFF0F9FF);
  static const Color bgCardLight = Color(0xFFFFFFFF);
  static const Color bgElevLight = Color(0xFFE0F2FE);
  static const Color bgInputLight = Color(0xFFEFF6FF);

  // ===== DARK MODE BORDERS =====
  static const Color borderDark = Color(0x0FFFFFFF);
  static const Color borderStrongDark = Color(0x1EFFFFFF);

  // ===== LIGHT MODE BORDERS =====
  static const Color borderLight = Color(0x120284C7);
  static const Color borderStrongLight = Color(0x210284C7);

  // ===== DARK MODE TEXT =====
  static const Color fgDark = Color(0xFFFFFFFF);
  static const Color fg2Dark = Color(0xFFC8D8E8);
  static const Color fgMutedDark = Color(0xFF8099AA);
  static const Color fgDimDark = Color(0xFF5A7080);

  // ===== LIGHT MODE TEXT =====
  static const Color fgLight = Color(0xFF0C1A27);
  static const Color fg2Light = Color(0xFF1E3A52);
  static const Color fgMutedLight = Color(0xFF5A7A8F);
  static const Color fgDimLight = Color(0xFF8AACCF);

  // ===== BRIGHTNESS-AWARE HELPERS =====

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color brandPrimary(BuildContext context) =>
      _dark(context) ? primaryLight : primary;

  static Color brandFaint(BuildContext context) =>
      _dark(context) ? primaryFaintDark : primaryFaintLight;

  static Color surface1(BuildContext context) =>
      _dark(context) ? bgCardDark : bgCardLight;

  static Color surface2(BuildContext context) =>
      _dark(context) ? bgElevDark : bgElevLight;

  static Color surface3(BuildContext context) =>
      _dark(context) ? bgInputDark : bgInputLight;

  static Color textColor(BuildContext context) =>
      _dark(context) ? fgDark : fgLight;

  static Color subTextColor(BuildContext context) =>
      _dark(context) ? fg2Dark : fg2Light;

  static Color mutedTextColor(BuildContext context) =>
      _dark(context) ? fgMutedDark : fgMutedLight;

  static Color dimTextColor(BuildContext context) =>
      _dark(context) ? fgDimDark : fgDimLight;

  static Color borderColor(BuildContext context) =>
      _dark(context) ? borderDark : borderLight;

  static Color borderStrongColor(BuildContext context) =>
      _dark(context) ? borderStrongDark : borderStrongLight;

  static Color success(BuildContext context) => green;
  static Color warning(BuildContext context) => orange;
  static Color danger(BuildContext context) => red;
  static Color info(BuildContext context) => blue;

  static Color successFaint(BuildContext context) =>
      _dark(context) ? greenFaintDark : greenFaintLight;
  static Color warningFaint(BuildContext context) =>
      _dark(context) ? orangeFaintDark : orangeFaintLight;
  static Color dangerFaint(BuildContext context) =>
      _dark(context) ? redFaintDark : redFaintLight;
  static Color infoFaint(BuildContext context) =>
      _dark(context) ? blueFaintDark : blueFaintLight;

  // ===== THEME FACTORIES =====

  static ThemeData light() => _buildTheme(Brightness.light);
  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color appBackground = isDark ? bgAppDark : bgAppLight;
    final Color cardBackground = isDark ? bgCardDark : bgCardLight;
    final Color elevatedBackground = isDark ? bgElevDark : bgElevLight;
    final Color inputBackground = isDark ? bgInputDark : bgInputLight;
    final Color borderValue = isDark ? borderDark : borderLight;
    final Color borderStrongValue = isDark ? borderStrongDark : borderStrongLight;
    final Color primaryText = isDark ? fgDark : fgLight;
    final Color secondaryText = isDark ? fg2Dark : fg2Light;
    final Color mutedText = isDark ? fgMutedDark : fgMutedLight;
    final Color dimText = isDark ? fgDimDark : fgDimLight;
    final Color primaryColor = isDark ? primaryLight : primary;

    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF0C2A3E) : const Color(0xFFBAE6FD),
      onPrimaryContainer: primaryText,
      secondary: green,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF0A2E18) : const Color(0xFFDCFCE7),
      onSecondaryContainer: primaryText,
      tertiary: orange,
      onTertiary: const Color(0xFF1A1200),
      tertiaryContainer: isDark ? const Color(0xFF4D3300) : const Color(0xFFFFEDD5),
      onTertiaryContainer: primaryText,
      error: red,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF4A1A1A) : const Color(0xFFFFE4E4),
      onErrorContainer: primaryText,
      surface: appBackground,
      onSurface: primaryText,
      surfaceContainerHighest: elevatedBackground,
      onSurfaceVariant: secondaryText,
      outline: borderValue,
      outlineVariant: borderStrongValue,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isDark ? const Color(0xFFEDF6FF) : const Color(0xFF111820),
      onInverseSurface: isDark ? const Color(0xFF0A0F14) : const Color(0xFFF0F9FF),
      inversePrimary: primaryColor,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: 'SpaceGrotesk',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? bgPageDark : bgAppLight,
      canvasColor: appBackground,
      cardColor: cardBackground,
      dividerColor: borderValue,
      primaryColor: primaryColor,
      textTheme: _buildTextTheme(primaryText, secondaryText, mutedText, dimText),
      appBarTheme: AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.44,
          color: primaryText,
        ),
        iconTheme: IconThemeData(color: primaryText),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderValue),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),
      iconTheme: IconThemeData(color: primaryText, size: 20),
      dividerTheme: DividerThemeData(color: borderValue, thickness: 1, space: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? const Color(0xFF1A2A38) : const Color(0xFFE0F2FE),
          disabledForegroundColor: dimText,
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          side: BorderSide(color: borderStrongValue),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderValue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderValue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: red, width: 1.5),
        ),
        hintStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: dimText,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevatedBackground,
        selectedColor: isDark ? primaryFaintDark : primaryFaintLight,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        brightness: brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide(color: borderValue),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF202C3A) : const Color(0xFFF0F9FF),
        contentTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
        actionTextColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: borderStrongValue),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(
      Color primary, Color secondary, Color muted, Color dim) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, color: primary, letterSpacing: -1.5),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.9),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.7),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.6),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primary, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.2),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: primary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondary),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.2),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: dim, letterSpacing: 1.4),
    );
  }
}

// ============================================================================
// SNACKBAR
// ============================================================================

enum SnackbarType { success, error, warning, info }

void showThemedSnackbar(
  String title,
  String message, {
  SnackbarType type = SnackbarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  Color color;
  IconData icon;
  switch (type) {
    case SnackbarType.success:
      color = DfColors.green;
      icon = Icons.check_circle_outline_rounded;
      break;
    case SnackbarType.error:
      color = DfColors.red;
      icon = Icons.error_outline_rounded;
      break;
    case SnackbarType.warning:
      color = DfColors.orange;
      icon = Icons.warning_amber_rounded;
      break;
    case SnackbarType.info:
      color = DfColors.blue;
      icon = Icons.info_outline_rounded;
      break;
  }
  Get.snackbar(
    title,
    message,
    icon: Icon(icon, color: color),
    snackPosition: SnackPosition.BOTTOM,
    duration: duration,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
  );
}

// ============================================================================
// WIDGETS
// ============================================================================

class DfCard extends StatelessWidget {
  const DfCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.elevation,
    this.backgroundColor,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? elevation;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: elevation ?? 0,
      color: backgroundColor ?? theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class DfPageShell extends StatelessWidget {
  const DfPageShell({
    required this.child,
    this.appBar,
    this.padding,
    super.key,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }
}

class DfDot extends StatefulWidget {
  const DfDot({
    required this.color,
    this.pulse = false,
    this.size = 10,
    super.key,
  });

  final Color color;
  final bool pulse;
  final double size;

  @override
  State<DfDot> createState() => _DfDotState();
}

class _DfDotState extends State<DfDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    if (widget.pulse) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(DfDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !old.pulse) _ctrl.repeat();
    if (!widget.pulse && old.pulse) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: widget.pulse ? (1.0 - (_ctrl.value * 0.65)) : 1.0,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class DfStatusBadge extends StatelessWidget {
  const DfStatusBadge({
    required this.label,
    required this.color,
    required this.faintColor,
    super.key,
  });

  final String label;
  final Color color;
  final Color faintColor;

  factory DfStatusBadge.success(BuildContext context, String label) =>
      DfStatusBadge(label: label, color: DfColors.success(context), faintColor: DfColors.successFaint(context));

  factory DfStatusBadge.warning(BuildContext context, String label) =>
      DfStatusBadge(label: label, color: DfColors.warning(context), faintColor: DfColors.warningFaint(context));

  factory DfStatusBadge.danger(BuildContext context, String label) =>
      DfStatusBadge(label: label, color: DfColors.danger(context), faintColor: DfColors.dangerFaint(context));

  factory DfStatusBadge.info(BuildContext context, String label) =>
      DfStatusBadge(label: label, color: DfColors.info(context), faintColor: DfColors.infoFaint(context));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: faintColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class DfPill extends StatelessWidget {
  const DfPill({
    required this.label,
    this.color,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    super.key,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          color: color ?? theme.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DfSectionLabel extends StatelessWidget {
  const DfSectionLabel({
    required this.title,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.base,
      vertical: AppSpacing.md,
    ),
    super.key,
  });

  final String title;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: DfColors.dimTextColor(context),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class DfInfoRow extends StatelessWidget {
  const DfInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: DfColors.mutedTextColor(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: TextStyle(
              fontSize: 13,
              color: DfColors.mutedTextColor(context),
            )),
          ),
          Text(value, style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: DfColors.textColor(context),
          )),
        ],
      ),
    );
  }
}

class DfSettingRow extends StatelessWidget {
  const DfSettingRow({
    required this.icon,
    required this.label,
    this.subLabel,
    required this.trailing,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? subLabel;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DfColors.brandFaint(context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: DfColors.brandPrimary(context)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DfColors.textColor(context),
                  )),
                  if (subLabel != null)
                    Text(subLabel!, style: TextStyle(
                      fontSize: 12,
                      color: DfColors.mutedTextColor(context),
                    )),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// Shimmer loading placeholder
class DfShimmerBox extends StatelessWidget {
  const DfShimmerBox({this.height = 60, this.borderRadius = AppRadius.lg, super.key});
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202C3A) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Empty state widget
class DfEmptyState extends StatelessWidget {
  const DfEmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DfColors.brandFaint(context),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: DfColors.brandPrimary(context)),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: TextStyle(color: DfColors.mutedTextColor(context)), textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
