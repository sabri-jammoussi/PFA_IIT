import 'dart:ui';

import 'package:flutter/material.dart';

class GlassTabItem {
  const GlassTabItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final VoidCallback onTap;

  IconData get activeIcon => selectedIcon ?? icon;
}

/// Frosted-glass floating tab bar.
/// Use with `Scaffold(extendBody: true)`.
/// [position] is the live fractional page position so the lozenge follows swipes.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    required this.items,
    required this.accentColor,
    required this.position,
    this.showLabels = true,
    super.key,
  });

  final List<GlassTabItem> items;
  final Color accentColor;
  final double position;
  final bool showLabels;

  static const double _height = 56;
  static const double _innerPad = 6;
  static const double _lozengeGap = 4;
  static const double _maxPillWidth = 48;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> glassGradient = isDark
        ? [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0.05)]
        : [Colors.white.withValues(alpha: 0.75), Colors.white.withValues(alpha: 0.45)];

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.70);

    final int selectedIndex = position.round();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: _height,
              padding: const EdgeInsets.symmetric(horizontal: _innerPad),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: glassGradient,
                ),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double slot = constraints.maxWidth / items.length;
                  final double pillWidth = (slot - _lozengeGap * 2 > _maxPillWidth)
                      ? _maxPillWidth
                      : slot - _lozengeGap * 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 7,
                        bottom: 7,
                        left: position * slot + (slot - pillWidth) / 2,
                        width: pillWidth,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.16)
                                : Colors.white.withValues(alpha: 0.60),
                            borderRadius: BorderRadius.circular(_height),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : Colors.white.withValues(alpha: 0.75),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: isDark ? 0.18 : 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                                spreadRadius: -3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(items.length, (index) {
                          return Expanded(
                            child: _GlassTab(
                              item: items[index],
                              accentColor: accentColor,
                              isDark: isDark,
                              showLabel: showLabels,
                              selected: index == selectedIndex,
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTab extends StatelessWidget {
  const _GlassTab({
    required this.item,
    required this.accentColor,
    required this.isDark,
    required this.showLabel,
    required this.selected,
  });

  final GlassTabItem item;
  final Color accentColor;
  final bool isDark;
  final bool showLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.black.withValues(alpha: 0.55);
    final Color contentColor = selected ? accentColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutBack,
            scale: selected ? 1.06 : 1.0,
            child: Icon(
              selected ? item.activeIcon : item.icon,
              size: 23,
              color: contentColor,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              style: TextStyle(
                fontSize: 10.5,
                height: 1.1,
                color: contentColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ],
      ),
    );
  }
}
