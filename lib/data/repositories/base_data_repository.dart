import 'package:flutter/foundation.dart';
import 'package:mvvm_plus/mvvm_plus.dart';

/// Shared consumer-controlled lifecycle for retained repository data.
///
/// [data] is `null` before the source has loaded, and is reset to `null` when
/// the final repository consumer unsubscribes. A successfully loaded empty
/// collection is therefore distinct from data that has not been loaded.
///
/// Consumers should use [addListener] and [removeListener]. Every registration
/// must have a matching removal. Direct listeners on [data] do not keep the
/// repository's source active.
abstract class BaseDataRepository<T> extends Model {
  final Map<VoidCallback, int> _consumerRegistrations =
      Map<VoidCallback, int>.identity();
  int _consumerRegistrationCount = 0;
  bool _debugLoggingEnabled = false;
  String _debugClassName = '';
  bool _disposed = false;

  /// Retained source data, or `null` while not loaded or inactive.
  late final ValueNotifier<T?> data = createProperty<T?>(null);

  /// Whether at least one consumer is registered through [addListener].
  @protected
  bool get hasDataConsumers => _consumerRegistrationCount != 0;

  /// Registers one repository consumer.
  ///
  /// Registering the same callback more than once creates distinct
  /// registrations. Each must be removed separately.
  @override
  void addListener(VoidCallback onData) {
    _addDataListener(onData);
  }

  void _addDataListener(VoidCallback onData) {
    if (_disposed) {
      throw StateError('Cannot subscribe to disposed $runtimeType.');
    }

    final isFirstConsumer = _consumerRegistrationCount == 0;
    var notifiedDuringStart = false;
    void markStartupNotification() => notifiedDuringStart = true;
    if (isFirstConsumer) {
      data.addListener(markStartupNotification);
    }
    data.addListener(onData);
    _consumerRegistrations.update(onData, (count) => count + 1,
        ifAbsent: () => 1);
    _consumerRegistrationCount++;

    try {
      if (isFirstConsumer) {
        startDataSource();
      }
    } catch (_) {
      _removeRegistration(onData);
      if (_consumerRegistrationCount == 0) {
        try {
          stopDataSource();
        } finally {
          data.value = null;
        }
      }
      rethrow;
    } finally {
      if (isFirstConsumer) {
        data.removeListener(markStartupNotification);
      }
    }

    debugRepositoryMessage('adding listener to data source.');
    // Existing retained data is delivered immediately. If a newly started
    // source emitted synchronously, the ValueNotifier already invoked this
    // listener, so do not invoke it a second time.
    if (data.value != null && !notifiedDuringStart) {
      onData();
    }
  }

  /// Removes one matching repository-consumer registration.
  ///
  /// An unknown callback has no effect.
  @override
  void removeListener(VoidCallback onData) {
    _removeDataListener(onData);
  }

  void _removeDataListener(VoidCallback onData) {
    if (!_consumerRegistrations.containsKey(onData)) {
      return;
    }

    debugRepositoryMessage('removing listener from data stream.');
    _removeRegistration(onData);
    if (_consumerRegistrationCount == 0) {
      try {
        stopDataSource();
      } finally {
        data.value = null;
      }
    }
  }

  void _removeRegistration(VoidCallback onData) {
    final count = _consumerRegistrations[onData];
    if (count == null) return;

    data.removeListener(onData);
    if (count == 1) {
      _consumerRegistrations.remove(onData);
    } else {
      _consumerRegistrations[onData] = count - 1;
    }
    _consumerRegistrationCount--;
  }

  /// Clears retained data and starts a fresh active source lifecycle.
  ///
  /// This is useful when a caller needs to discard a local or optimistic data
  /// change and reload the authoritative value. Calling it without consumers
  /// is a no-op because inactive repositories retain no source resources.
  void resetData() {
    if (!hasDataConsumers) {
      debugRepositoryMessage('Data source is inactive, no need to reset.');
      return;
    }

    stopDataSource();
    data.value = null;
    startDataSource();
  }

  /// Enables debug lifecycle logging for this repository.
  void enableDebugLogging(String className) {
    _debugLoggingEnabled = true;
    _debugClassName = className;
    debugRepositoryMessage('Debug logging enabled.');
  }

  /// Starts the concrete source on the zero-to-one consumer transition.
  @protected
  void startDataSource();

  /// Stops the concrete source on the one-to-zero consumer transition.
  @protected
  void stopDataSource();

  /// Prints a repository debug message when debug logging is enabled.
  @protected
  void debugRepositoryMessage(Object message) {
    if (_debugLoggingEnabled && kDebugMode) {
      // Preserve the stream repository's existing debug output behavior.
      // ignore: avoid_print
      print('$_debugClassName: $message');
    }
  }

  /// Disposes this repository when it has no registered consumers.
  @override
  void dispose() {
    if (_consumerRegistrationCount != 0) {
      throw StateError(
        'Cannot dispose of $runtimeType while it has listeners.',
      );
    }
    stopDataSource();
    data.value = null;
    _disposed = true;
    super.dispose();
  }

  /// Deprecated alias for [addListener].
  @Deprecated('Use addListener instead.')
  void subscribeToData(VoidCallback listener) {
    _addDataListener(listener);
  }

  /// Deprecated alias for [removeListener].
  @Deprecated('Use removeListener instead.')
  void unsubscribeFromData(VoidCallback listener) {
    _removeDataListener(listener);
  }
}
