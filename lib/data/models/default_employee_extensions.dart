import 'package:pwi_auth/data/models/employee.dart';

/// Default extensions that add convenience role helpers to [Employee].
///
/// ```dart
/// import 'package:pwi_auth/data/models/employee.dart';
/// import 'package:pwi_auth/data/models/default_employee_extensions.dart';
///
/// void describe(Employee employee) {
///   if (employee.isExecutive) {
///     // Handle executives
///   }
/// }
/// ```
///
/// Applications can copy or augment this extension to tailor role detection to
/// their own business rules without modifying the core [Employee] model.
extension DefaultEmployeeExtensions on Employee {
  /// True when the employee's seniority indicates a supervisory position.
  bool get isSupervisor =>
      !seniorityString.toLowerCase().contains('orange') &&
      !seniorityString.toLowerCase().contains('yellow') &&
      seniorityString.isNotEmpty;

  /// True when the employee holds an executive-level role.
  bool get isExecutive =>
      seniorityString.toLowerCase().contains('red') ||
      jobTitle.toLowerCase().contains('chief');

  /// True when the employee belongs to the software department.
  bool get isDeveloper => department.toLowerCase().contains('software');
}
