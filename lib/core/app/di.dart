import 'package:employees_directory_syed_umair/core/blocs/employee_bloc/employee_bloc.dart';
import 'package:employees_directory_syed_umair/core/data/data_sources/employee_data_source.dart';
import 'package:employees_directory_syed_umair/core/data/data_sources/local/employee_sembast_data_source.dart';
import 'package:employees_directory_syed_umair/core/data/repositories/employee_repository.dart';
import 'package:employees_directory_syed_umair/core/data/repositories/employee_repository_impl.dart';
import 'package:employees_directory_syed_umair/core/services/database_service.dart';
import 'package:employees_directory_syed_umair/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DI extends StatelessWidget {
  const DI({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<EmployeeDataSource>(
          create:
              (context) => EmployeeSembastDataSource(
                getIt<DatabaseService>(),
              ), // DatabaseService is injected here
        ),
        RepositoryProvider<EmployeeRepository>(
          create:
              (context) =>
                  EmployeeRepositoryImpl(context.read<EmployeeDataSource>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<EmployeeBloc>(
            create:
                (context) => EmployeeBloc(
                  employeeRepository: context.read<EmployeeRepository>(),
                ),
          ),
        ],
        child: child,
      ),
    );
  }
}
