import 'package:employees_directory_syed_umair/core/data/data_sources/employee_data_source.dart';
import 'package:employees_directory_syed_umair/core/data/repositories/employee_repository.dart';
import 'package:employees_directory_syed_umair/core/data/models/employee.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeDataSource dataSource;

  EmployeeRepositoryImpl(this.dataSource);

  @override
  Future<void> addEmployee(Employee employee) {
    return dataSource.addEmployee(employee);
  }

  @override
  Future<void> deleteEmployee(int id) {
    return dataSource.deleteEmployee(id);
  }

  @override
  Future<void> undoDeleteEmployee(int id) {
    return dataSource.undoDeleteEmployee(id);
  }

  @override
  Future<void> permanentlyDeleteEmployee(int id) {
    return dataSource.permanentlyDeleteEmployee(id);
  }

  @override
  Future<List<Employee>> getEmployees() {
    return dataSource.getEmployees();
  }

  @override
  Stream<List<Employee>> watchEmployees() {
    return dataSource.watchEmployees();
  }

  @override
  Future<void> updateEmployee(Employee employee) {
    return dataSource.updateEmployee(employee);
  }

  @override
  Future<void> cleanUpDeletedEmployees() {
    return dataSource.cleanUpDeletedEmployees();
  }
}
