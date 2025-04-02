import 'dart:async';

import 'package:employees_directory_syed_umair/core/logger/logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class DatabaseService {
  Database? _database;
  static const String _dbName = 'employees.db';

  final employeeStore = intMapStoreFactory.store('employees');

  Future<Database> get database async {
    if (_database == null) {
      await _initDb();
    }
    return _database!;
  }

  Future<void> _initDb() async {
    try {
      DatabaseFactory factory;
      String dbPath;

      if (kIsWeb) {
        factory = databaseFactoryWeb;
        dbPath = _dbName;
        logInfo('Using Sembast Web for path: \$dbPath');
      } else {
        factory = databaseFactoryIo;
        final dir = await getApplicationDocumentsDirectory();
        await dir.create(recursive: true);
        dbPath = join(dir.path, _dbName);
        logInfo('Using Sembast IO Factory for path: \$dbPath');
      }

      _database = await factory.openDatabase(dbPath);
      logInfo('Database opened successfully at: \$dbPath');
    } catch (e) {
      if (kDebugMode) {
        rethrow;
      }
      logError('Error opening database: $e');
      rethrow;
    }
  }

  Future<void> closeDb() async {
    try {
      await _database?.close();
      _database = null;
      logInfo('Database closed.');
    } catch (e) {
      if (kDebugMode) {
        rethrow;
      }
      logError('Error closing database: $e');
      rethrow;
    }
  }

  StoreRef<int, Map<String, dynamic>> getEmployeeStore() {
    return employeeStore;
  }
}
