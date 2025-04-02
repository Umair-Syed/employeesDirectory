import 'package:employees_directory_syed_umair/core/blocs/employee_bloc/employee_bloc.dart';
import 'package:employees_directory_syed_umair/feature/employee_list/view/screens/employee_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // clean up the deleted employees, permanent delete them
      // Incase the app is killed before the undo timer is up
      context.read<EmployeeBloc>().add(EmployeeCleanUpDeletedEmployees());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const EmployeeListView();
  }
}
