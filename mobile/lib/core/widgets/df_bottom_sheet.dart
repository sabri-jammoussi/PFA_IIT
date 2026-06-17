import 'package:flutter/material.dart';
import '../df_ui.dart';

/// Base bottom sheet wrapper used by all form sheets in the app.
/// Shows a drag handle, header row (icon + title/subtitle + close), a divider,
/// and a scrollable body passed as [child].
class DfBottomSheet extends StatelessWidget {
  const DfBottomSheet({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.initialChildSize = 0.78,
    this.minChildSize = 0.45,
    this.maxChildSize = 0.95,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  /// Static helper to show this sheet as a modal.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color effectiveIconColor = iconColor ?? DfColors.brandPrimary(context);

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Drag handle
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: effectiveIconColor),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                          if (subtitle != null)
                            Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(
                              color: DfColors.subTextColor(context),
                            )),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
