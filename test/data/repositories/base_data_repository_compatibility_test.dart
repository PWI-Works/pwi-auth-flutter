// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pwi_auth/data/repositories/base_data_fetch_repository.dart';
import 'package:pwi_auth/data/repositories/base_data_stream_repository.dart';

/// Uses the original stream subclass contract without any lifecycle overrides.
class _ExistingStreamRepository extends BaseDataStreamRepository<int> {
  final List<StreamController<int>> controllers = [];

  @override
  StreamSubscription<int> createDataStream() {
    final controller = StreamController<int>(sync: true);
    controllers.add(controller);
    return controller.stream.listen((value) => data.value = value);
  }
}

class _SynchronouslyEmittingRepository extends BaseDataStreamRepository<int> {
  @override
  StreamSubscription<int> createDataStream() {
    data.value = 2;
    return const Stream<int>.empty().listen((_) {});
  }
}

class _FetchRepository extends BaseDataFetchRepository<List<int>> {
  _FetchRepository.daily()
      : super(
          refreshSchedule: DataRefreshSchedule.daily,
          timeOfDay: const TimeOfDay(hour: 1, minute: 0),
        );

  _FetchRepository.interval()
      : super(
          refreshSchedule: DataRefreshSchedule.interval,
          numberOfMinutes: 30,
        );

  _FetchRepository.never() : super(refreshSchedule: DataRefreshSchedule.never);

  int fetchCount = 0;

  @override
  Future<List<int>> fetchData() async {
    fetchCount++;
    return <int>[fetchCount];
  }
}

void main() {
  test('existing stream API cancels after the final real consumer', () {
    final repository = _ExistingStreamRepository();
    void first() {}
    void second() {}

    repository.subscribeToData(first);
    repository.subscribeToData(second);
    expect(repository.controllers, hasLength(1));

    repository.unsubscribeFromData(first);
    expect(repository.controllers.single.hasListener, isTrue);

    repository.unsubscribeFromData(second);
    expect(repository.controllers.single.hasListener, isFalse);
    expect(repository.data.value, isNull);
    repository.dispose();
  });

  test('existing stream API can reset and start a fresh source', () {
    final repository = _ExistingStreamRepository();
    void listener() {}

    repository.subscribeToData(listener);
    repository.resetStream();

    expect(repository.controllers, hasLength(2));
    expect(repository.controllers.first.hasListener, isFalse);
    expect(repository.controllers.last.hasListener, isTrue);

    repository.unsubscribeFromData(listener);
    repository.dispose();
  });

  test('standard addListener API participates in source lifecycle', () {
    final repository = _ExistingStreamRepository();
    void listener() {}

    repository.addListener(listener);
    expect(repository.controllers.single.hasListener, isTrue);

    repository.removeListener(listener);
    expect(repository.controllers.single.hasListener, isFalse);
    repository.dispose();
  });

  test('a synchronous source emission notifies the first listener once', () {
    final repository = _SynchronouslyEmittingRepository();
    repository.data.value = 1;
    var calls = 0;
    void listener() => calls++;

    repository.addListener(listener);

    expect(repository.data.value, 2);
    expect(calls, 1);
    repository.removeListener(listener);
    repository.dispose();
  });

  test('fetch configuration and reset workflow remain usable', () async {
    final daily = _FetchRepository.daily();
    final interval = _FetchRepository.interval();
    final never = _FetchRepository.never();
    void listener() {}

    never.addListener(listener);
    await Future<void>.delayed(Duration.zero);
    expect(never.fetchCount, 1);
    expect(never.data.value, [1]);

    never.data.value = [99];
    never.resetData();
    expect(never.data.value, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(never.fetchCount, 2);
    expect(never.data.value, [2]);

    never.removeListener(listener);
    never.dispose();
    daily.dispose();
    interval.dispose();
  });
}
