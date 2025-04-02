part of 'employee_bloc.dart';

sealed class EmployeeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class EmployeeFetchList extends EmployeeEvent {}

final class EmployeeAdd extends EmployeeEvent {
  final Employee employee;

  EmployeeAdd(this.employee);

  @override
  List<Object> get props => [employee];
}

final class EmployeeUpdate extends EmployeeEvent {
  final Employee employee;

  EmployeeUpdate(this.employee);

  @override
  List<Object> get props => [employee];
}

final class EmployeeDelete extends EmployeeEvent {
  final int id;

  EmployeeDelete(this.id);

  @override
  List<Object> get props => [id];
}

final class EmployeeUndoDelete extends EmployeeEvent {
  final int id;

  EmployeeUndoDelete(this.id);

  @override
  List<Object> get props => [id];
}

final class EmployeePermanentlyDelete extends EmployeeEvent {
  final int id;

  EmployeePermanentlyDelete(this.id);

  @override
  List<Object> get props => [id];
}

final class EmployeeCleanUpDeletedEmployees extends EmployeeEvent {}

class EmployeeListUpdated extends EmployeeEvent {
  final List<Employee> employees;
  EmployeeListUpdated(this.employees);

  @override
  List<Object> get props => [employees];
}

final class EmployeeError extends EmployeeEvent {
  final String message;

  EmployeeError(this.message);

  @override
  List<Object> get props => [message];
}
