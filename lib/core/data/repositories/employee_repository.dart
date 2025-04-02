import 'package:employees_directory_syed_umair/core/data/models/employee.dart';

abstract class EmployeeRepository {
  Stream<List<Employee>> watchEmployees();
  Future<List<Employee>> getEmployees();
  Future<void> addEmployee(Employee employee);
  Future<void> updateEmployee(Employee employee);
  Future<void> deleteEmployee(int id);
  Future<void> undoDeleteEmployee(int id);
  Future<void> permanentlyDeleteEmployee(int id);
}
