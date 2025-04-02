import 'package:employees_directory_syed_umair/core/blocs/employee_bloc/employee_bloc.dart';
import 'package:employees_directory_syed_umair/feature/add_edit_employee/view/screens/add_edit_employee_screen.dart';
import 'package:employees_directory_syed_umair/feature/employee_list/view/widgets/employee_list.dart';
import 'package:employees_directory_syed_umair/feature/employee_list/view/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeListView extends StatelessWidget {
  const EmployeeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee List')),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          switch (state.status) {
            case EmployeeStatus.initial:
            case EmployeeStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case EmployeeStatus.error:
              return Center(
                child: Text('Error: ${state.error ?? "Unknown error"}'),
              );
            case EmployeeStatus.loaded:
              if (state.employees.isEmpty) {
                return const EmptyState();
              } else {
                return EmployeeList(employees: state.employees);
              }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditEmployeeView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
