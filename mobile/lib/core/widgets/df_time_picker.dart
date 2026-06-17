import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../df_ui.dart';

Future<TimeOfDay?> showDfTimePicker(
  BuildContext context,
  TimeOfDay? initialTime,
) async {
  DateTime selected = DateTime(2000, 1, 1, initialTime?.hour ?? 9, initialTime?.minute ?? 0);
  TimeOfDay? result;

  await showCupertinoModalPopup<void>(
    context: context,
    barrierColor: Colors.black.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.55 : 0.35,
    ),
    builder: (BuildContext ctx) {
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: DfColors.surface1(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: DfColors.subTextColor(context),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close_rounded, size: 28, color: DfColors.red),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        result = TimeOfDay(hour: selected.hour, minute: selected.minute);
                        Navigator.pop(ctx);
                      },
                      child: Icon(Icons.check_rounded, size: 30, color: DfColors.primary),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: DfColors.borderColor(context)),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: selected,
                  onDateTimeChanged: (dt) => selected = dt,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result;
}

void showDfDatePicker(
  BuildContext context,
  DateTime? initialDate,
  void Function(DateTime) onDateSelected, {
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    locale: const Locale('fr', 'FR'),
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2100),
    builder: (context, child) => Theme(
      data: Theme.of(context),
      child: child!,
    ),
  );
  if (picked != null) onDateSelected(picked);
}
