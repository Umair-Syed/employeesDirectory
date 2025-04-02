import 'dart:async';

import 'package:employees_directory_syed_umair/core/blocs/employee_bloc/employee_bloc.dart';
import 'package:employees_directory_syed_umair/core/data/models/employee.dart';
import 'package:employees_directory_syed_umair/core/extensions/context.dart';
import 'package:employees_directory_syed_umair/feature/add_edit_employee/view/screens/add_edit_employee_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class EmployeeList extends StatefulWidget {
  final List<Employee> employees;

  const EmployeeList({super.key, required this.employees});

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  late List<Employee> _currentEmployees;
  late List<Employee> _previousEmployees;

  @override
  void initState() {
    super.initState();
    _categorizeEmployees();
  }

  @override
  void didUpdateWidget(EmployeeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.employees != widget.employees) {
      _categorizeEmployees();
    }
  }

  void _categorizeEmployees() {
    //MARK: Categorize employees
    final now = DateUtils.dateOnly(DateTime.now());
    _currentEmployees =
        widget.employees.where((e) {
          final toDate = e.to;
          return toDate == null ||
              toDate.isAtSameMomentAs(now) ||
              toDate.isAfter(now);
        }).toList();
    _previousEmployees =
        widget.employees.where((e) {
          final toDate = e.to;
          return toDate != null && toDate.isBefore(now);
        }).toList();
  }

  void _handleDismiss(BuildContext context, Employee employee, bool isCurrent) {
    // Remove from local lists first, otherwise dismissable will not work. need to remove immediately
    setState(() {
      if (isCurrent) {
        _currentEmployees.removeWhere(
          (e) => e.internalId == employee.internalId,
        );
      } else {
        _previousEmployees.removeWhere(
          (e) => e.internalId == employee.internalId,
        );
      }
    });

    handleDelete(context, employee);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surfaceDim,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: CustomScrollView(
          slivers: [
            if (_currentEmployees.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(title: 'Current employees'),
              ),
              _EmployeeListSliver(
                list: _currentEmployees,
                onDismissed:
                    (employee) => _handleDismiss(context, employee, true),
              ),
            ],
            if (_previousEmployees.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(title: 'Previous employees'),
              ),
              _EmployeeListSliver(
                list: _previousEmployees,
                onDismissed:
                    (employee) => _handleDismiss(context, employee, false),
              ),
            ],
            if (_currentEmployees.isNotEmpty || _previousEmployees.isNotEmpty)
              const SliverToBoxAdapter(child: _SwipeHint()),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final shouldPaddStart = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        shouldPaddStart ? 16.0 : 0.0,
        8.0,
        16.0,
        8.0,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmployeeListSliver extends StatelessWidget {
  final List<Employee> list;
  final ValueChanged<Employee> onDismissed;

  const _EmployeeListSliver({required this.list, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final employee = list[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 300),
          child: ScaleAnimation(
            child: FadeInAnimation(
              child: _EmployeeListItem(
                employee: employee,
                onDismissed: () => onDismissed(employee),
              ),
            ),
          ),
        );
      },
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            thickness: 1.3,
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
    );
  }
}

// MARK: Employee List Item
class _EmployeeListItem extends StatelessWidget {
  final Employee employee;
  final VoidCallback onDismissed;

  const _EmployeeListItem({required this.employee, required this.onDismissed});

  String _formatDateRange(DateTime? from, DateTime? to) {
    final DateFormat formatter = DateFormat('d MMM, yyyy');
    final fromStr = from != null ? formatter.format(from) : 'N/A';

    if (to == null) {
      return 'From $fromStr';
    } else {
      final toStr = formatter.format(to);
      // Check if 'to' date is the same day or after 'from' date before showing range
      if (!to.isBefore(from ?? DateTime(0))) {
        return '$fromStr - $toStr';
      } else {
        return 'From $fromStr';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = _formatDateRange(employee.from, employee.to);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Dismissible(
          key: ValueKey(employee.internalId ?? UniqueKey()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => onDismissed(),
          background: Container(
            color: Colors.red[400],
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              title: Text(
                employee.name ?? 'No Name',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    employee.role?.roleTitle ?? 'No Role',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withAlpha(190),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withAlpha(150),
                    ),
                  ),
                ],
              ),
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditEmployeeView(employee: employee),
                  ),
                );
                if (result == 'deleted' && context.mounted) {
                  showSnackBarWithUndo(context, employee);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    final shouldPaddStart = MediaQuery.of(context).size.width < 600;
    return Container(
      margin: const EdgeInsets.only(bottom: 32.0),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: shouldPaddStart ? 16.0 : 0.0,
      ),
      child: Text(
        'Swipe left to delete',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        textAlign: TextAlign.center,
      ),
    );
  }
}

void handleDelete(BuildContext context, Employee employee) {
  context.read<EmployeeBloc>().add(EmployeeDelete(employee.internalId!));
  showSnackBarWithUndo(context, employee);
}

void showSnackBarWithUndo(BuildContext context, Employee employee) {
  if (employee.internalId == null) return; // Guard clause

  final bloc = context.read<EmployeeBloc>();
  final employeeId = employee.internalId!;
  Timer? permanentDeleteTimer;

  final messenger = ScaffoldMessenger.of(context);
  permanentDeleteTimer = Timer(const Duration(seconds: 5), () {
    bloc.add(EmployeePermanentlyDelete(employeeId));
  });

  context.showSnackBarMessage(
    "Employee data has been deleted",
    messenger: messenger,
    duration: 5000,
    actionLabel: "Undo",
    isDarkThemed: true,
    actionCallback: () {
      permanentDeleteTimer?.cancel();
      bloc.add(EmployeeUndoDelete(employeeId));
    },
  );
}
