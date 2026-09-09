import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts a Firestore document reference field to the referenced document ID.
class FirestoreDocumentReferenceIdConverter
    implements JsonConverter<String?, Object?> {
  const FirestoreDocumentReferenceIdConverter(this.collectionPath);

  final String collectionPath;

  @override
  String? fromJson(Object? json) {
    if (json == null) {
      return null;
    }

    if (json is DocumentReference<Object?>) {
      return json.id;
    }

    throw FormatException(
      'Field must be a Firestore document reference.',
      json,
    );
  }

  @override
  Object? toJson(String? object) {
    if (object == null) {
      return null;
    }

    return FirebaseFirestore.instance.collection(collectionPath).doc(object);
  }
}
