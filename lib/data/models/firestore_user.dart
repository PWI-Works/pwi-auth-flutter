// lib/models/firestore_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pwi_auth/data/models/employee.dart';

/// Model class representing a user in Firestore.
class FirestoreUser {
  /// The unique identifier of the user.
  final String id;

  /// Reference to the employee document in Firestore.
  final DocumentReference<Employee> employeeRef;

  /// Constructs a [FirestoreUser] instance.
  ///
  /// \param id The unique identifier of the user.
  /// \param employeeRef Reference to the employee document in Firestore.
  FirestoreUser({
    required this.id,
    required this.employeeRef,
  });

  /// Factory constructor to create a [FirestoreUser] instance from a Firestore document.
  ///
  /// \param doc The Firestore document snapshot.
  /// \return A new [FirestoreUser] instance.
  factory FirestoreUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirestoreUser(
      id: doc.id,
      employeeRef: _employeeReferenceFrom(data['employeeRef']),
    );
  }

  static DocumentReference<Employee> _employeeReferenceFrom(Object? value) {
    if (value is DocumentReference<Employee>) {
      return value;
    }

    if (value is DocumentReference) {
      return value.withConverter<Employee>(
        fromFirestore: (snapshot, _) => Employee.fromFirestore(snapshot),
        toFirestore: (_, __) => throw UnsupportedError(
          'Employee model does not support Firestore writes.',
        ),
      );
    }

    throw StateError('Firestore user is missing a valid employeeRef.');
  }
}
