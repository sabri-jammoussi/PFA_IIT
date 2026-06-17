import 'package:flutter/material.dart';
import '../df_ui.dart';

typedef DfDropdownItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef DfDropdownLabelOf<T> = String Function(T item);

/// Generic dropdown-via-bottom-sheet field.
/// Opens a DraggableScrollableSheet with a search bar and list of items.
/// Use [labelOf] to get the display string from an item.
class DfDropdownField<T> extends StatefulWidget {
  const DfDropdownField({
    required this.label,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.value,
    this.hint = 'Sélectionner',
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.itemBuilder,
    super.key,
  });

  final String label;
  final List<T> items;
  final DfDropdownLabelOf<T> labelOf;
  final void Function(T?) onChanged;
  final T? value;
  final String hint;
  final IconData icon;
  final bool enabled;
  final bool required;
  final String? errorText;
  final DfDropdownItemBuilder<T>? itemBuilder;

  @override
  State<DfDropdownField<T>> createState() => _DfDropdownFieldState<T>();
}

class _DfDropdownFieldState<T> extends State<DfDropdownField<T>> {
  Future<void> _openPicker() async {
    if (!widget.enabled) return;

    final T? selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DfDropdownPicker<T>(
        label: widget.label,
        items: widget.items,
        labelOf: widget.labelOf,
        selected: widget.value,
        itemBuilder: widget.itemBuilder,
      ),
    );

    if (selected != null) widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasValue = widget.value != null;
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DfColors.dimTextColor(context),
                letterSpacing: 1.2,
              ),
            ),
            if (widget.required)
              Text(' *', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
              )),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled ? _openPicker : null,
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
                    hasValue ? widget.labelOf(widget.value as T) : widget.hint,
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
                Icon(widget.icon, size: 18, color: DfColors.subTextColor(context)),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(widget.errorText!, style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          )),
        ],
      ],
    );
  }
}

class _DfDropdownPicker<T> extends StatefulWidget {
  const _DfDropdownPicker({
    required this.label,
    required this.items,
    required this.labelOf,
    this.selected,
    this.itemBuilder,
    super.key,
  });

  final String label;
  final List<T> items;
  final DfDropdownLabelOf<T> labelOf;
  final T? selected;
  final DfDropdownItemBuilder<T>? itemBuilder;

  @override
  State<_DfDropdownPicker<T>> createState() => _DfDropdownPickerState<T>();
}

class _DfDropdownPickerState<T> extends State<_DfDropdownPicker<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<T> get _filtered => widget.items
      .where((item) => widget.labelOf(item).toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.40,
      maxChildSize: 0.92,
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
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.label, style: theme.textTheme.titleMedium),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() {
                              _query = '';
                              _searchCtrl.clear();
                            }),
                          )
                        : null,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: DfColors.borderColor(context),
                  ),
                  itemBuilder: (context, index) {
                    final T item = _filtered[index];
                    final bool isSelected = widget.selected == item;

                    if (widget.itemBuilder != null) {
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, item),
                        child: widget.itemBuilder!(context, item),
                      );
                    }

                    return ListTile(
                      title: Text(
                        widget.labelOf(item),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? DfColors.brandPrimary(context)
                              : DfColors.textColor(context),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded, color: DfColors.brandPrimary(context))
                          : null,
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
