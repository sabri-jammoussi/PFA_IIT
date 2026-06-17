import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../df_ui.dart';

class DfTextField extends StatelessWidget {
  const DfTextField({
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.enabled = true,
    this.inputFormatters,
    this.maxLines = 1,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: DfColors.dimTextColor(context),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          enabled: enabled,
          inputFormatters: inputFormatters,
          maxLines: obscureText ? 1 : maxLines,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

// Tap-to-pick field (calendar, person, dropdown)
class DfPickerField extends StatelessWidget {
  const DfPickerField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.errorText,
    this.required = false,
    super.key,
  });

  final String label;
  final String? value;
  final String hint;
  final VoidCallback? onTap;
  final IconData icon;
  final String? errorText;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasValue = value != null && value!.isNotEmpty;
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DfColors.dimTextColor(context),
                letterSpacing: 1.2,
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              )),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            constraints: const BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: DfColors.surface3(context),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: hasError
                    ? theme.colorScheme.error
                    : DfColors.borderColor(context),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasValue
                          ? DfColors.textColor(context)
                          : DfColors.subTextColor(context),
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(icon, size: 18, color: DfColors.subTextColor(context)),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          )),
        ],
      ],
    );
  }
}

// Date field with calendar icon
class DfDateField extends StatelessWidget {
  const DfDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
    this.required = false,
    super.key,
  });

  final String label;
  final DateTime? value;
  final VoidCallback? onTap;
  final String? errorText;
  final bool required;

  String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DfColors.dimTextColor(context),
                letterSpacing: 1.2,
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              )),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: DfColors.surface3(context),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: hasError ? theme.colorScheme.error : DfColors.borderColor(context),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16,
                    color: DfColors.subTextColor(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value == null ? 'Sélectionner une date' : _format(value!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value == null
                          ? DfColors.subTextColor(context)
                          : DfColors.textColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          )),
        ],
      ],
    );
  }
}
