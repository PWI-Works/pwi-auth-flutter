// lib/data/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwi_auth/data/services/user_service_interface.dart';
import 'package:pwi_auth/data/models/firestore_user.dart';
import 'package:pwi_auth/data/services/firebase_paths.dart';

/// Service class for managing user-related operations.
class UserService implements UserServiceInterface {
  /// Instance of Firestore to interact with the database.
  final FirebaseFirestore _firestore;

  /// Flag to determine whether to use emulators for Firestore.
  final bool _useEmulators;

  /// Reference to the users collection in Firestore.
  late final CollectionReference _usersCollection;

  /// Reference to the employees collection in Firestore.
  late final CollectionReference _employeesCollection;

  /// Creates a new instance of [UserService].
  ///
  /// * [firestore] - An optional instance of [FirebaseFirestore]. If not provided, the default instance is used.
  /// * [useEmulators] - A flag to determine whether to use emulators for Firestore. Defaults to false.
  UserService._internal({
    FirebaseFirestore? firestore,
    bool useEmulators = false,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _useEmulators = useEmulators {
    _usersCollection = _firestore.collection(FirebasePaths.collectionUsers);
    _employeesCollection =
        _firestore.collection(FirebasePaths.collectionEmployees);
  }

  static UserService? _instance;

  /// Creates (if needed) and returns the singleton [UserService] instance.
  factory UserService({
    FirebaseFirestore? firestore,
    bool useEmulators = false,
  }) {
    final existing = _instance;
    if (existing != null) {
      if (firestore != null && !identical(existing._firestore, firestore)) {
        throw StateError(
          'UserService is already initialized with a different Firestore instance.',
        );
      }
      if (useEmulators != existing._useEmulators) {
        throw StateError(
          'UserService is already initialized with useEmulators=${existing._useEmulators}.',
        );
      }
      return existing;
    }

    final created = UserService._internal(
      firestore: firestore,
      useEmulators: useEmulators,
    );
    _instance = created;
    return created;
  }

  /// Provides the lazily initialized singleton instance.
  static UserService get instance => UserService();

  /// Retrieves the Firestore document for the given authenticated user.
  ///
  /// * [authUser] - The authenticated [User] object.
  ///
  /// Returns a [FirestoreUser] object if the document exists, otherwise returns null.
  Future<FirestoreUser?> _getUserDoc(User authUser) async {
    final doc = await _usersCollection.doc(authUser.uid).get();
    if (doc.exists) {
      return FirestoreUser.fromFirestore(doc);
    }
    return null;
  }

  /// Retrieves the employee ID associated with the given authenticated user.
  ///
  /// * [authUser] - The authenticated [User] object.
  ///
  /// Returns the employee ID as a [String] if found, otherwise returns null.
  @override
  Future<String?> getEmployeeIdFromUser(User authUser) async {
    if (_useEmulators) {
      final query = await _employeesCollection
          .where('primaryEmail', isEqualTo: authUser.email)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    }

    final user = await _getUserDoc(authUser);
    if (user != null) {
      final employeeDoc = await user.employeeRef.get();
      if (employeeDoc.exists) {
        return employeeDoc.id;
      }
    }
    return null;
  }
}
