import 'package:employees_directory_syed_umair/core/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/services/database_service.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final databaseService = DatabaseService();
  await databaseService.database;
  getIt.registerSingleton<DatabaseService>(databaseService);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();

  runApp(const AppView());
}
