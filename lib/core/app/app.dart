import 'package:employees_directory_syed_umair/core/app/di.dart';
import 'package:employees_directory_syed_umair/core/theme/app_theme.dart';
import 'package:employees_directory_syed_umair/feature/employee_list/view/screens/employee_list_screen.dart';
import 'package:flutter/material.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return DI(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employees Directory',
        theme: getTheme(Brightness.light),
        darkTheme: getTheme(Brightness.dark),
        themeMode: ThemeMode.light,
        home: const EmployeeListScreen(),
      ),
    );
  }
}
