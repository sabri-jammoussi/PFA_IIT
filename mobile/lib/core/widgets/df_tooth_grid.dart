import 'package:flutter/material.dart';
import '../df_ui.dart';

/// Clinical health status of a tooth, derived from its recorded treatments.
enum ToothStatus { healthy, treated, pathology }

/// Reusable FDI 32-tooth dental chart.
///
/// Renders the four quadrants (upper-right 18-11, upper-left 21-28,
/// lower-right 48-41, lower-left 31-38) split into upper / lower jaws with a
/// midline divider, a per-tooth treatment-count badge, a selection ring and a
/// legend. Colors follow the design system:
///   healthy   -> surface / white
///   treated   -> success (green)
///   pathology -> danger (red)
///   selected  -> info (blue)
///
/// Shared so it can later back the consultation screen as well. It is purely
/// presentational: callers provide [statusOf] and [countOf] and react to
/// [onToothSelected].
class DfToothGrid extends StatelessWidget {
  const DfToothGrid({
    required this.statusOf,
    required this.countOf,
    required this.onToothSelected,
    this.selectedTooth,
    super.key,
  });

  final int? selectedTooth;
  final ToothStatus Function(int tooth) statusOf;
  final int Function(int tooth) countOf;
  final void Function(int tooth) onToothSelected;

  static const List<int> upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
  static const List<int> upperLeft = [21, 22, 23, 24, 25, 26, 27, 28];
  static const List<int> lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];
  static const List<int> lowerLeft = [31, 32, 33, 34, 35, 36, 37, 38];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: DfColors.surface2(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: DfColors.borderColor(context)),
      ),
      child: Column(
        children: [
          _JawLabel(context, 'Mâchoire Supérieure'),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildJaw(context, upperRight, upperLeft),
          ),
          const SizedBox(height: AppSpacing.lg),
          _JawLabel(context, 'Mâchoire Inférieure'),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildJaw(context, lowerRight, lowerLeft),
          ),
          const SizedBox(height: AppSpacing.base),
          Divider(height: 1, color: DfColors.borderColor(context)),
          const SizedBox(height: AppSpacing.md),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildJaw(BuildContext context, List<int> left, List<int> right) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: left.map((t) => _tooth(context, t)).toList(),
        ),
        Container(
          width: 2,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          color: DfColors.borderStrongColor(context),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: right.map((t) => _tooth(context, t)).toList(),
        ),
      ],
    );
  }

  Widget _tooth(BuildContext context, int tooth) {
    final bool isSelected = selectedTooth == tooth;
    final ToothStatus status = statusOf(tooth);
    final int count = countOf(tooth);

    Color bg;
    Color border;
    Color fg;
    if (isSelected) {
      bg = DfColors.info(context);
      border = DfColors.info(context);
      fg = Colors.white;
    } else {
      switch (status) {
        case ToothStatus.pathology:
          bg = DfColors.dangerFaint(context);
          border = DfColors.danger(context).withOpacity(0.4);
          fg = DfColors.danger(context);
          break;
        case ToothStatus.treated:
          bg = DfColors.successFaint(context);
          border = DfColors.success(context).withOpacity(0.4);
          fg = DfColors.success(context);
          break;
        case ToothStatus.healthy:
          bg = DfColors.surface1(context);
          border = DfColors.borderColor(context);
          fg = DfColors.textColor(context);
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => onToothSelected(tooth),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 34,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isSelected ? DfColors.info(context) : border,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$tooth',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              if (count > 0)
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : DfColors.mutedTextColor(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.base,
      runSpacing: AppSpacing.sm,
      children: [
        _legendItem(context, DfColors.surface1(context),
            DfColors.borderStrongColor(context), 'Sain'),
        _legendItem(context, DfColors.successFaint(context),
            DfColors.success(context), 'Soigné'),
        _legendItem(context, DfColors.dangerFaint(context),
            DfColors.danger(context), 'Pathologie / Retrait'),
      ],
    );
  }

  Widget _legendItem(
      BuildContext context, Color bg, Color border, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: DfColors.mutedTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _JawLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: DfColors.dimTextColor(context),
      ),
    );
  }
}
