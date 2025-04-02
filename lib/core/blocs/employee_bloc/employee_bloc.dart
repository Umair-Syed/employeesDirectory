import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:employees_directory_syed_umair/core/data/models/employee.dart';
import 'package:employees_directory_syed_umair/core/data/repositories/employee_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository _employeeRepository;
  StreamSubscription<List<Employee>>? _employeeSubscription;

  EmployeeBloc({required EmployeeRepository employeeRepository})
    : _employeeRepository = employeeRepository,
      super(const EmployeeState()) {
    on<EmployeeFetchList>(_onEmployeeFetchList);
    on<EmployeeAdd>(_onEmployeeAdd);
    on<EmployeeUpdate>(_onEmployeeUpdate);
    on<EmployeeDelete>(_onEmployeeDelete);
    on<EmployeeUndoDelete>(_onEmployeeUndoDelete);
    on<EmployeePermanentlyDelete>(_onEmployeePermanentlyDelete);
    on<EmployeeCleanUpDeletedEmployees>(_onEmployeeCleanUpDeletedEmployees);
    on<EmployeeListUpdated>(_onEmployeeListUpdated);
    on<EmployeeError>(_onEmployeeError);
    _listenToEmployeeUpdates();

    add(EmployeeFetchList());
  }

  void _listenToEmployeeUpdates() {
    _employeeSubscription?.cancel();
    _employeeSubscription = _employeeRepository.watchEmployees().listen(
      (employees) {
        add(EmployeeListUpdated(employees));
      },
      onError: (error) {
        add(EmployeeError(error.toString()));
      },
    );
  }

  void _onEmployeeListUpdated(
    EmployeeListUpdated event,
    Emitter<EmployeeState> emit,
  ) {
    emit(
      state.copyWith(status: EmployeeStatus.loaded, employees: event.employees),
    );
  }

  Future<void> _onEmployeeFetchList(
    EmployeeFetchList event,
    Emitter<EmployeeState> emit,
  ) async {
    if (state.status != EmployeeStatus.loaded) {
      emit(state.copyWith(status: EmployeeStatus.loading));
    }
    try {
      final employees = await _employeeRepository.getEmployees();
      emit(state.copyWith(status: EmployeeStatus.loaded, employees: employees));
    } catch (e) {
      emit(state.copyWith(status: EmployeeStatus.error, error: e.toString()));
    }
  }

  Future<void> _onEmployeeAdd(
    EmployeeAdd event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await _employeeRepository.addEmployee(event.employee);
    } catch (e) {
      emit(state.copyWith(status: EmployeeStatus.error, error: e.toString()));
    }
  }

  Future<void> _onEmployeeUpdate(
    EmployeeUpdate event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await _employeeRepository.updateEmployee(event.employee);
    } catch (e) {
      emit(state.copyWith(status: EmployeeStatus.error, error: e.toString()));
    }
  }

  Future<void> _onEmployeeDelete(
    EmployeeDelete event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await _employeeRepository.deleteEmployee(event.id);
    } catch (e) {
      emit(state.copyWith(status: EmployeeStatus.error, error: e.toString()));
    }
  }

  Future<void> _onEmployeeUndoDelete(
    EmployeeUndoDelete event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await _employeeRepository.undoDeleteEmployee(event.id);
    } catch (e) {
      if (kDebugMode) {
        rethrow;
      }
      emit(state.copyWith(status: EmployeeStatus.error, error: e.toString()));
    }
  }

  Future<void> _onEmployeePermanentlyDelete(
    EmployeePermanentlyDelete event,
    Emitter<EmployeeState> emit,
  ) async {
    await _employeeRepository.permanentlyDeleteEmployee(event.id);
  }

  void _onEmployeeError(EmployeeError event, Emitter<EmployeeState> emit) {
    emit(state.copyWith(status: EmployeeStatus.error, error: event.message));
  }

  Future<void> _onEmployeeCleanUpDeletedEmployees(
    EmployeeCleanUpDeletedEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    await _employeeRepository.cleanUpDeletedEmployees();
  }

  @override
  Future<void> close() {
    _employeeSubscription?.cancel();
    return super.close();
  }
}
