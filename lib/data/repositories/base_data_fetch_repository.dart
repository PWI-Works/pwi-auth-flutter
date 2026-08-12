import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pwi_auth/data/repositories/base_data_repository.dart';

/// Supported automatic refresh schedules for [BaseDataFetchRepository].
enum DataRefreshSchedule { daily, interval, never }

/// Base class for retained data loaded by one [Future] at a time.
///
/// The first consumer fetches immediately. Successful values—including empty
/// collections—are retained in [data]. `null` means not loaded or inactive.
/// Automatic refresh exists only while a repository consumer is registered.
/// Call [resetData] to discard local changes and immediately fetch the
/// authoritative value again. Any pending refresh timer is replaced. For an
/// interval schedule, the full interval starts after the replacement fetch
/// finishes; for a daily schedule, the next wall-clock occurrence is
/// recalculated after it finishes.
abstract class BaseDataFetchRepository<T> extends BaseDataRepository<T> {
  /// Creates a Future-backed repository.
  ///
  /// Daily repositories refresh at [timeOfDay], which defaults to local
  /// midnight. Interval repositories require a positive [numberOfMinutes].
  /// Never-refresh repositories only perform the initial fetch.
  BaseDataFetchRepository({
    DataRefreshSchedule refreshSchedule = DataRefreshSchedule.daily,
    TimeOfDay? timeOfDay,
    int? numberOfMinutes,
  })  : assert(
          refreshSchedule == DataRefreshSchedule.daily || timeOfDay == null,
          'timeOfDay is only used with DataRefreshSchedule.daily.',
        ),
        assert(
          refreshSchedule == DataRefreshSchedule.interval ||
              numberOfMinutes == null,
          'numberOfMinutes is only used with DataRefreshSchedule.interval.',
        ),
        assert(
          refreshSchedule != DataRefreshSchedule.interval ||
              (numberOfMinutes != null && numberOfMinutes > 0),
          'DataRefreshSchedule.interval requires numberOfMinutes greater than zero.',
        ),
        _refreshSchedule = refreshSchedule,
        _timeOfDay = timeOfDay ??
            (refreshSchedule == DataRefreshSchedule.daily
                ? const TimeOfDay(hour: 0, minute: 0)
                : null),
        _numberOfMinutes = numberOfMinutes {
    if (refreshSchedule != DataRefreshSchedule.daily && timeOfDay != null) {
      throw ArgumentError(
        'timeOfDay is only valid for daily refresh.',
      );
    }
    if (refreshSchedule == DataRefreshSchedule.interval &&
        (numberOfMinutes == null || numberOfMinutes <= 0)) {
      throw ArgumentError.value(
        numberOfMinutes,
        'numberOfMinutes',
        'must be greater than zero for interval refresh',
      );
    }
    if (refreshSchedule != DataRefreshSchedule.interval &&
        numberOfMinutes != null) {
      throw ArgumentError(
        'numberOfMinutes is only valid for interval refresh.',
      );
    }
    if (refreshSchedule == DataRefreshSchedule.daily) {
      final dailyTime = _timeOfDay!;
      RangeError.checkValueInInterval(
        dailyTime.hour,
        0,
        23,
        'timeOfDay.hour',
      );
      RangeError.checkValueInInterval(
        dailyTime.minute,
        0,
        59,
        'timeOfDay.minute',
      );
    }
  }

  final DataRefreshSchedule _refreshSchedule;
  final TimeOfDay? _timeOfDay;
  final int? _numberOfMinutes;

  Timer? _refreshTimer;
  Future<void>? _inFlightFetch;
  int _lifecycle = 0;

  /// Loads one non-null repository value.
  Future<T> fetchData();

  /// Handles a failed initial or automatic fetch.
  ///
  /// Override this to report repository failures to application logging or
  /// monitoring. The default intentionally does nothing. A failure retains the
  /// last successful [data] value and does not stop future refresh attempts.
  @protected
  void onFetchError(Object error, StackTrace stackTrace) {}

  @override
  void startDataSource() {
    final lifecycle = ++_lifecycle;
    unawaited(_attemptFetch(lifecycle));
  }

  @override
  void stopDataSource() {
    _lifecycle++;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    // Futures cannot be canceled. The lifecycle token prevents this result
    // from publishing or creating another timer after shutdown.
    _inFlightFetch = null;
  }

  Future<void> _attemptFetch(int lifecycle) {
    if (!hasDataConsumers || lifecycle != _lifecycle) {
      return Future<void>.value();
    }
    final existing = _inFlightFetch;
    if (existing != null) return existing;

    final attempt = _performFetch(lifecycle);
    _inFlightFetch = attempt;
    return attempt;
  }

  Future<void> _performFetch(int lifecycle) async {
    try {
      final value = await fetchData();
      if (hasDataConsumers && lifecycle == _lifecycle) {
        data.value = value;
      }
    } catch (error, stackTrace) {
      if (hasDataConsumers && lifecycle == _lifecycle) {
        onFetchError(error, stackTrace);
      }
    } finally {
      if (lifecycle == _lifecycle) {
        _inFlightFetch = null;
        if (hasDataConsumers) {
          _scheduleNextAttempt(lifecycle);
        }
      }
    }
  }

  void _scheduleNextAttempt(int lifecycle) {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    final Duration? delay;
    switch (_refreshSchedule) {
      case DataRefreshSchedule.daily:
        final now = DateTime.now();
        final dailyTime = _timeOfDay!;
        var next = DateTime(
          now.year,
          now.month,
          now.day,
          dailyTime.hour,
          dailyTime.minute,
        );
        if (!next.isAfter(now)) {
          next = DateTime(
            now.year,
            now.month,
            now.day + 1,
            dailyTime.hour,
            dailyTime.minute,
          );
        }
        delay = next.difference(now);
      case DataRefreshSchedule.interval:
        delay = Duration(minutes: _numberOfMinutes!);
      case DataRefreshSchedule.never:
        delay = null;
    }

    if (delay == null || !hasDataConsumers || lifecycle != _lifecycle) return;
    _refreshTimer = Timer(delay, () {
      _refreshTimer = null;
      if (hasDataConsumers && lifecycle == _lifecycle) {
        unawaited(_attemptFetch(lifecycle));
      }
    });
  }
}
