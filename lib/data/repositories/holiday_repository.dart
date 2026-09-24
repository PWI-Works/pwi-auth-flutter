import 'dart:async';

import 'package:pwi_auth/data/models/holiday.dart';
import 'package:pwi_auth/data/repositories/base_data_stream_repository.dart';
import 'package:pwi_auth/data/services/holiday_service.dart';

/// Retains shared holiday data while it has active consumers.
class HolidayRepository extends BaseDataStreamRepository<List<Holiday>> {
  /// Creates a holiday repository.
  HolidayRepository({HolidayService? service})
      : _holidayService = service ?? HolidayService();

  final HolidayService _holidayService;

  @override
  StreamSubscription<List<Holiday>> createDataStream() {
    return _holidayService.getHolidaysStream().listen(
          (holidays) => data.value = holidays,
        );
  }

  /// Optimistically creates or replaces [holiday], then persists it.
  Future<void> upsertHoliday(
    Holiday holiday,
    String firebaseUserId,
  ) async {
    final currentHolidays = data.value;

    if (currentHolidays != null) {
      final holidayExists = currentHolidays.any(
        (currentHoliday) => currentHoliday.id == holiday.id,
      );

      data.value = holidayExists
          ? currentHolidays
              .map(
                (currentHoliday) =>
                    currentHoliday.id == holiday.id ? holiday : currentHoliday,
              )
              .toList()
          : [...currentHolidays, holiday];
    }

    try {
      await _holidayService.upsertHoliday(holiday, firebaseUserId);
    } catch (_) {
      resetStream();
      rethrow;
    }
  }
}
