import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight model for Firestore job title references.
class JobTitle {
  /// Firestore document id.
  final String id;

  JobTitle._({required this.id});

  static JobTitle fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? _,
  ) {
    return JobTitle._(id: snapshot.id);
  }
}
