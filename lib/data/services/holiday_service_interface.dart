import 'package:pwi_auth/data/models/holiday.dart';

/// Read access to company holidays.
abstract class HolidayServiceInterface {
  /// Streams all holidays whenever the shared collection changes.
  Stream<List<Holiday>> getHolidaysStream();
}
