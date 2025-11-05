// lib/models/firestore_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a user in Firestore.
class FirestoreUser {
  /// The unique identifier of the user.
  final String id;

  /// Reference to the employee document in Firestore.
  final DocumentReference employeeRef;

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
      employeeRef: data['employeeRef'] as DocumentReference,
    );
  }
}
