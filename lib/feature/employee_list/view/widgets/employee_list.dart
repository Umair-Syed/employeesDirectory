import 'dart:async';

import 'package:employees_directory_syed_umair/core/blocs/employee_bloc/employee_bloc.dart';
import 'package:employees_directory_syed_umair/core/data/models/employee.dart';
import 'package:employees_directory_syed_umair/core/extensions/context.dart';
import 'package:employees_directory_syed_umair/feature/add_edit_employee/view/screens/add_edit_employee_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeList extends StatelessWidget {
  final List<Employee> employees;

  const EmployeeList({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return ListTile(
          title: Text(employee.name ?? 'No Name'),
          subtitle: Text(employee.role?.roleTitle ?? 'No Role'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              _showDeleteConfirmation(context, employee);
            },
          ),
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditEmployeeView(employee: employee),
              ),
            );
            if (result == 'deleted' && context.mounted) {
              _handleUndoDelete(context, employee);
            }
          },
        );
      },
    );
  }

  void _handleUndoDelete(BuildContext context, Employee employee) {
    if (employee.internalId == null) return; // Guard clause

    final bloc = context.read<EmployeeBloc>();
    final employeeId = employee.internalId!;
    Timer? permanentDeleteTimer;

    final messenger = ScaffoldMessenger.of(context);
    // TODO: App can be killed before the timer is up, so we need to handle this
    permanentDeleteTimer = Timer(const Duration(seconds: 5), () {
      bloc.add(EmployeePermanentlyDelete(employeeId));
    });

    context.showSnackBarMessage(
      "Employee data has been deleted",
      messenger: messenger,
      duration: 5000,
      actionLabel: "Undo",
      actionCallback: () {
        permanentDeleteTimer?.cancel();
        bloc.add(EmployeeUndoDelete(employeeId));
      },
    );
  }

  //TODO: Change to swipe to delete
  void _showDeleteConfirmation(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Employee?'),
          content: Text(
            'Are you sure you want to delete ${employee.name ?? "this employee"}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                if (employee.internalId != null) {
                  context.read<EmployeeBloc>().add(
                    EmployeeDelete(employee.internalId!),
                  );
                  _handleUndoDelete(context, employee);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error: Cannot delete employee without ID.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
