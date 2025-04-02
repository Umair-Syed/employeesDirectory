part of 'employee_bloc.dart';

enum EmployeeStatus { initial, loading, loaded, error }

final class EmployeeState extends Equatable {
  final EmployeeStatus status;
  final List<Employee> employees;
  final String? error;

  const EmployeeState({
    this.status = EmployeeStatus.initial,
    this.employees = const [],
    this.error,
  });

  EmployeeState copyWith({
    EmployeeStatus? status,
    List<Employee>? employees,
    String? error,
  }) {
    return EmployeeState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, employees, error];
}
