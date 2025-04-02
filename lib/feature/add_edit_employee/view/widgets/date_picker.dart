import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'custom_date_picker_dialog.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final bool isToDate;
  final DateTime? fromDate;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.isToDate = false,
    this.fromDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');

    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: null,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: const TextStyle(height: 0, color: Colors.transparent),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 12,
          ),
        ),
        child: Text(
          selectedDate != null
              ? dateFormat.format(selectedDate!)
              : (isToDate ? 'No date' : label),
          style: TextStyle(
            color:
                selectedDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? initialDialogDate =
        selectedDate ?? (isToDate ? null : DateTime.now());
    final DateTime firstDate = DateTime(2022);
    final DateTime lastDate = DateTime.now().add(
      const Duration(days: 10 * 365),
    );

    showDialog<DateTime?>(
      context: context,
      builder: (BuildContext context) {
        return CustomDatePickerDialog(
          initialDate: initialDialogDate,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateSelected: onDateSelected,
          isToDate: isToDate,
          fromDate: fromDate,
        );
      },
    );
  }
}
