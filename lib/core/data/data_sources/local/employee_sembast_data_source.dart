import 'dart:async';

import 'package:sembast/sembast.dart';

import 'package:employees_directory_syed_umair/core/services/database_service.dart';
import 'package:employees_directory_syed_umair/core/data/models/employee.dart';
import 'package:employees_directory_syed_umair/core/data/data_sources/employee_data_source.dart';

class EmployeeSembastDataSource implements EmployeeDataSource {
  final DatabaseService _dbService;
  late StoreRef<int, Map<String, dynamic>> _employeeStore;

  EmployeeSembastDataSource(this._dbService) {
    _employeeStore = _dbService.getEmployeeStore();
  }

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<List<Employee>> getEmployees() async {
    final finder = Finder(
      filter: Filter.equals('deleted', false),
      sortOrders: [SortOrder('from', false)],
    );
    final snapshots = await _employeeStore.find(await _db, finder: finder);
    return snapshots.map((snapshot) {
      return Employee.fromJson(snapshot.value, snapshot.key);
    }).toList();
  }

  @override
  Stream<List<Employee>> watchEmployees() async* {
    final finder = Finder(
      filter: Filter.equals('deleted', false),
      sortOrders: [SortOrder('from', false)],
    );
    final query = _employeeStore.query(finder: finder);
    final db = await _db;

    await for (final snapshots in query.onSnapshots(db)) {
      final employees =
          snapshots.map((snapshot) {
            return Employee.fromJson(snapshot.value, snapshot.key);
          }).toList();
      yield employees;
    }
  }

  @override
  Future<Employee> addEmployee(Employee employee) async {
    final key = await _employeeStore.add(await _db, employee.toJson());
    return employee.copyWith(internalId: key);
  }

  @override
  Future<void> updateEmployee(Employee employee) async {
    if (employee.internalId == null) {
      throw ArgumentError('Employee must have an internalId to be updated.');
    }
    await _employeeStore
        .record(employee.internalId!)
        .update(await _db, employee.toJson());
  }

  @override
  Future<void> deleteEmployee(int internalId) async {
    final finder = Finder(filter: Filter.byKey(internalId));
    await _employeeStore.update(await _db, {'deleted': true}, finder: finder);
  }

  @override
  Future<void> undoDeleteEmployee(int internalId) async {
    final finder = Finder(filter: Filter.byKey(internalId));
    await _employeeStore.update(await _db, {'deleted': false}, finder: finder);
  }

  @override
  Future<void> permanentlyDeleteEmployee(int internalId) async {
    await _employeeStore.record(internalId).delete(await _db);
  }

  @override
  Future<void> cleanUpDeletedEmployees() async {
    final finder = Finder(filter: Filter.equals('deleted', true));
    await _employeeStore.delete(await _db, finder: finder);
  }
}
