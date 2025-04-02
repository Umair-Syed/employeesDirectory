import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime?) onDateSelected;
  final bool isToDate;
  final DateTime? fromDate; // Used for disabling dates in 'to date' picker

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.isToDate = false,
    this.fromDate,
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime? _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.initialDate ?? (widget.isToDate ? null : DateTime.now());

    _currentMonth =
        _selectedDate != null
            ? DateTime(_selectedDate!.year, _selectedDate!.month)
            : DateTime(DateTime.now().year, DateTime.now().month);

    // Validity checks for selectedDate
    if (_selectedDate != null) {
      if (_selectedDate!.isBefore(widget.firstDate)) {
        _selectedDate = widget.firstDate;
      } else if (_selectedDate!.isAfter(widget.lastDate)) {
        _selectedDate = widget.lastDate;
      }

      // For 'to date', check against fromDate. ToDate shouldn't be before fromDate
      if (widget.isToDate &&
          widget.fromDate != null &&
          _selectedDate!.isBefore(widget.fromDate!)) {
        _selectedDate = null;
      }
    }
  }

  bool _isSelectable(DateTime day) {
    // Check if day is within allowed range
    if (day.isBefore(widget.firstDate) || day.isAfter(widget.lastDate)) {
      return false;
    }

    // For 'to date', ensure the day is after fromDate
    if (widget.isToDate && widget.fromDate != null) {
      final DateTime normalizedDay = DateTime(day.year, day.month, day.day);
      final DateTime normalizedFromDate = DateTime(
        widget.fromDate!.year,
        widget.fromDate!.month,
        widget.fromDate!.day,
      );

      return normalizedDay.isAfter(normalizedFromDate);
    }

    return true;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _handleShortcutSelection(DateTime? date) {
    if (date != null) {
      // Ensure date is valid
      if (!_isSelectable(date)) {
        // For 'to date', try to find the next selectable date. Eg if today is selected by today is before fromDate
        if (widget.isToDate && widget.fromDate != null) {
          DateTime nextDate = date;
          while (!_isSelectable(nextDate) &&
              nextDate.isBefore(widget.lastDate)) {
            nextDate = nextDate.add(const Duration(days: 1));
          }

          // If we found a valid date, use it; otherwise keep current selection
          if (_isSelectable(nextDate)) {
            date = nextDate;
          } else {
            date = _selectedDate;
            return;
          }
        } else {
          // If not 'to date', just keep current selection
          date = _selectedDate;
          return;
        }
      }

      setState(() {
        _selectedDate = date;
        _currentMonth = DateTime(date!.year, date.month);
      });
    } else if (widget.isToDate) {
      // No date selected, only for 'to date' picker
      setState(() {
        _selectedDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final dateFormat = DateFormat('d MMM yyyy');
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    Widget buildShortcutButton(String label, DateTime? date) {
      bool isSelected;
      if (date == null && _selectedDate == null && widget.isToDate) {
        isSelected = true;
      } else if (date != null && _selectedDate != null) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        final selectedDateOnly = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        isSelected = dateOnly.isAtSameMomentAs(selectedDateOnly);
      } else {
        isSelected = false;
      }

      return SizedBox(
        height: 40,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150, minWidth: 140),
          child: ElevatedButton(
            onPressed: () => _handleShortcutSelection(date),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.primary.withAlpha(40),
              foregroundColor:
                  isSelected ? colorScheme.onPrimary : colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(label),
          ),
        ),
      );
    }

    List<Widget> shortcutButtons;
    if (widget.isToDate) {
      shortcutButtons = [
        buildShortcutButton('No date', null),
        buildShortcutButton('Today', todayDateOnly),
      ];
    } else {
      // Calculate dates for 'from date' shortcuts
      final nextMonday = _nextWeekday(todayDateOnly, DateTime.monday);
      final nextTuesday = _nextWeekday(todayDateOnly, DateTime.tuesday);
      final after1Week = todayDateOnly.add(const Duration(days: 7));

      shortcutButtons = [
        buildShortcutButton('Today', todayDateOnly),
        buildShortcutButton('Next Monday', nextMonday),
        buildShortcutButton('Next Tuesday', nextTuesday),
        buildShortcutButton('After 1 week', after1Week),
      ];
    }

    // MARK: - Calendar
    Widget buildCalendar() {
      final DateTime firstDayOfMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        1,
      );

      final DateTime lastDayOfMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        0,
      );

      // Calculate the first day to display (might be from previous month)
      // We want to start from Sunday of the week containing the first day
      final int daysBeforeMonthStart = firstDayOfMonth.weekday % 7;
      final DateTime firstDisplayedDay = firstDayOfMonth.subtract(
        Duration(days: daysBeforeMonthStart),
      );

      // Calculate number of days to display (up to 6 weeks)
      final int daysInMonth = lastDayOfMonth.day;
      final int totalDays = daysBeforeMonthStart + daysInMonth;
      final int rowsNeeded = (totalDays / 7).ceil();
      final int daysToDisplay = rowsNeeded * 7;

      List<DateTime> days = List.generate(
        daysToDisplay,
        (index) => firstDisplayedDay.add(Duration(days: index)),
      );

      final headerMonth = DateFormat('MMMM yyyy').format(_currentMonth);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left_rounded),
                onPressed: _previousMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 32,
                color: colorScheme.onSurface.withAlpha(120),
              ),
              Text(
                headerMonth,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right_rounded),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 32,
                color: colorScheme.onSurface.withAlpha(120),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Sun', style: TextStyle(fontSize: 14)),
              Text('Mon', style: TextStyle(fontSize: 14)),
              Text('Tue', style: TextStyle(fontSize: 14)),
              Text('Wed', style: TextStyle(fontSize: 14)),
              Text('Thu', style: TextStyle(fontSize: 14)),
              Text('Fri', style: TextStyle(fontSize: 14)),
              Text('Sat', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days in a week
              childAspectRatio: 1, // Square cells
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final DateTime day = days[index];
              final bool isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final bool isSelected =
                  _selectedDate != null &&
                  day.year == _selectedDate!.year &&
                  day.month == _selectedDate!.month &&
                  day.day == _selectedDate!.day;
              final bool isThisMonth = day.month == _currentMonth.month;
              final bool isSelectable = _isSelectable(day);

              final textStyle = TextStyle(
                color:
                    !isThisMonth
                        ? Colors.grey.withAlpha(100) // Other month
                        : !isSelectable
                        ? Colors.grey.withAlpha(100) // Not selectable
                        : isSelected
                        ? colorScheme
                            .onPrimary // Selected day
                        : isToday
                        ? colorScheme
                            .primary // Today
                        : null, // Normal day
                fontWeight: isToday || isSelected ? FontWeight.bold : null,
              );

              return GestureDetector(
                onTap:
                    isThisMonth && isSelectable
                        ? () {
                          setState(() {
                            _selectedDate = day;
                          });
                        }
                        : null,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : null,
                    shape: BoxShape.circle,
                    border:
                        isToday && !isSelected
                            ? Border.all(color: colorScheme.primary, width: 1.5)
                            : null,
                  ),
                  child: Center(
                    child: Text(day.day.toString(), style: textStyle),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shortcut buttons
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 308),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.start,
                    children: shortcutButtons,
                  ),
                ),
                const SizedBox(height: 16),

                // Custom calendar
                buildCalendar(),
                const SizedBox(height: 16),

                const Divider(),
                // Bottom bar
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null
                          ? dateFormat.format(_selectedDate!)
                          : 'No date',
                      style: textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.primary.withAlpha(20),
                        foregroundColor: colorScheme.primary,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        widget.onDateSelected(_selectedDate);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _nextWeekday(DateTime date, int weekday) {
    var daysUntil = weekday - date.weekday;
    if (daysUntil <= 0) {
      daysUntil += 7;
    }
    return date.add(Duration(days: daysUntil));
  }
}
