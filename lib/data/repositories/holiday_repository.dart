import 'dart:async';

import 'package:pwi_auth/data/models/holiday.dart';
import 'package:pwi_auth/data/repositories/base_data_stream_repository.dart';
import 'package:pwi_auth/data/services/holiday_service.dart';
import 'package:pwi_auth/data/services/holiday_service_interface.dart';

/// Retains shared holiday data while it has active consumers.
class HolidayRepository extends BaseDataStreamRepository<List<Holiday>> {
  /// Creates a holiday repository.
  HolidayRepository({HolidayServiceInterface? service})
      : _holidayService = service ?? HolidayService();

  final HolidayServiceInterface _holidayService;

  @override
  StreamSubscription<List<Holiday>> createDataStream() {
    return _holidayService.getHolidaysStream().listen(
          (holidays) => data.value = holidays,
        );
  }
}
