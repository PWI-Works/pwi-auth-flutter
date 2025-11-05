// lib/data/repositories/employee_repository.dart

import 'dart:async';

import 'package:pwi_auth/data/models/employee.dart';
import 'package:pwi_auth/data/repositories/base_data_stream_repository.dart';
import 'package:pwi_auth/data/services/employee_service.dart';

/// Repository for managing employee data
///
/// Provides reactive access to employee data through a stream.
/// The stream is only active when there are active listeners,
/// conserving resources when the data isn't being observed.
class EmployeeRepository extends BaseDataStreamRepository<List<Employee>> {
  final EmployeeService _employeeService;

  /// Minimum number of employees we expect to receive
  /// Used to filter out incomplete data that might be initially returned
  static const int _minimumExpectedEmployees = 10;

  /// Creates a new EmployeeRepository
  ///
  /// Optionally accepts a custom [service]. If not provided,
  /// a default EmployeeService will be created.
  EmployeeRepository({EmployeeService? service})
      : _employeeService = service ?? EmployeeService();

  /// Sets up the data stream for employee data
  @override
  StreamSubscription<List<Employee>> createDataStream() {
    return _employeeService.getEmployeesStream().listen((employees) {
      if (employees.length > _minimumExpectedEmployees) {
        data.value = employees;
      }
    });
  }

  /// Returns the [Employee] with the given [id].
  ///
  /// If the employee is not found in the local data, attempts to fetch it from the service.
  /// Returns `null` if the employee does not exist.
  ///
  /// Example:
  /// ```dart
  /// final employee = await employeeRepository.getEmployeeById('123');
  /// ```
  Future<Employee?> getEmployeeById(String id) async {
    // Try to find employee in local data
    final localEmployee =
        data.value?.where((employee) => employee.id == id).toList();
    if (localEmployee != null && localEmployee.isNotEmpty) {
      return localEmployee.first;
    }

    // If not found, fetch from service
    try {
      return await _employeeService.getEmployeeById(id);
    } catch (e) {
      return null;
    }
  }
}
