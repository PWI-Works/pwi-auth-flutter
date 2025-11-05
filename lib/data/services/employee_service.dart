// lib/data/services/employee_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pwi_auth/data/services/employee_service_interface.dart';
import 'package:pwi_auth/data/models/employee.dart';
import 'package:pwi_auth/data/services/firebase_paths.dart';

/// Service class for handling employee-related operations.
class EmployeeService implements EmployeeServiceInterface {
  EmployeeService._internal({FirebaseFirestore? firestore})
      : _employeeCollection = (firestore ?? FirebaseFirestore.instance)
            .collection(FirebasePaths.collectionEmployees);

  static EmployeeService? _instance;

  factory EmployeeService({FirebaseFirestore? firestore}) =>
      _instance ??= EmployeeService._internal(firestore: firestore);

  /// Provides the lazily initialized singleton instance.
  static EmployeeService get instance => EmployeeService();

  // Reference to the Firestore collection for employees
  final CollectionReference _employeeCollection;

  /// Streams real-time updates of employees, excluding those with employeeType "Shared Device"
  /// and filtering out employees whose preferredName contains "test".
  ///
  /// \return A [Stream] of lists of [Employee] objects.
  @override
  Stream<List<Employee>> getEmployeesStream() {
    return _employeeCollection
        // Apply server-side filter to exclude employees with employeeType "Shared Device"
        .where('employeeType', isNotEqualTo: 'Shared Device')
        // Listen to real-time snapshots of the filtered collection
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          // Convert each Firestore document to an [Employee] object
          .map((doc) => Employee.fromFirestore(doc))
          // Apply client-side filter to exclude employees whose preferredName contains "test"
          .where((employee) =>
              !employee.preferredName.toLowerCase().contains('test'))
          // Convert the filtered iterable to a list
          .toList();
    });
  }

  /// Retrieves a single employee by their unique [id].
  ///
  /// [id] - The unique identifier of the employee.
  ///
  /// \return A [Future] that resolves to an [Employee] object.
  @override
  Future<Employee> getEmployeeById(String id) async {
    // Fetch the document with the specified [id] from the employee collection
    final doc = await _employeeCollection.doc(id).get();
    // Convert the fetched document to an [Employee] object
    return Employee.fromFirestore(doc);
  }
}
