import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pwi_auth/data/models/holiday.dart';
import 'package:pwi_auth/data/services/firebase_paths.dart';

/// Provides read access to holidays stored in Firestore.
class HolidayService {
  /// Creates a holiday service using [firestore], or the default instance.
  HolidayService({FirebaseFirestore? firestore})
      : _holidaysCollection = (firestore ?? FirebaseFirestore.instance)
            .collection(FirebasePaths.collectionHolidays);

  final CollectionReference<Map<String, dynamic>> _holidaysCollection;

  Stream<List<Holiday>> getHolidaysStream() {
    return _holidaysCollection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map(Holiday.fromFirestore).toList(growable: false),
        );
  }

  /// Creates or updates [holiday] and records who made the change.
  Future<void> upsertHoliday(Holiday holiday, String firebaseUserId) {
    return _holidaysCollection.doc(holiday.id).set(
      {
        ...holiday.toJson(),
        'lastModifiedBy': {
          'id': firebaseUserId,
          'time': Timestamp.now(),
        },
      },
      SetOptions(merge: true),
    );
  }
}
