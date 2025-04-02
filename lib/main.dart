import 'package:employees_directory_syed_umair/core/app/app.dart';
import 'package:employees_directory_syed_umair/core/app/app_bloc_observer.dart';
import 'package:employees_directory_syed_umair/core/logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/services/database_service.dart';
import 'package:loggy/loggy.dart' as log;

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  try {
    final databaseService = DatabaseService();
    await databaseService.database;
    getIt.registerSingleton<DatabaseService>(databaseService);
  } catch (e) {
    if (kDebugMode) {
      rethrow;
    }
    logError('Error setting up locator: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  _initLoggy();
  await setupLocator();

  runApp(const AppView());
}

void _initLoggy() {
  log.Loggy.initLoggy(
    logOptions: const log.LogOptions(
      log.LogLevel.all,
      stackTraceLevel: log.LogLevel.warning,
    ),
    logPrinter: ColorfulLogPrinter(),
  );
}
