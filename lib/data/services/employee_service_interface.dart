import 'dart:async';

import 'package:pwi_auth/data/models/employee.dart';

/// Contract consumed by the global controller for employee lookups.
abstract class EmployeeServiceInterface {
  Stream<List<Employee>> getEmployeesStream();
  Future<Employee> getEmployeeById(String id);
}
