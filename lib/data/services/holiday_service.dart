import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pwi_auth/data/models/holiday.dart';
import 'package:pwi_auth/data/services/firebase_paths.dart';
import 'package:pwi_auth/data/services/holiday_service_interface.dart';

/// Provides read access to holidays stored in Firestore.
class HolidayService implements HolidayServiceInterface {
  /// Creates a holiday service using [firestore], or the default instance.
  HolidayService({FirebaseFirestore? firestore})
      : _holidaysCollection = (firestore ?? FirebaseFirestore.instance)
            .collection(FirebasePaths.collectionHolidays);

  final CollectionReference<Map<String, dynamic>> _holidaysCollection;

  @override
  Stream<List<Holiday>> getHolidaysStream() {
    return _holidaysCollection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map(Holiday.fromFirestore).toList(growable: false),
        );
  }
}
