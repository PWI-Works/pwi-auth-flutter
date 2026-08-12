import 'dart:async';

import 'package:pwi_auth/data/repositories/base_data_repository.dart';

/// Base class for repositories backed by one shared data stream.
///
/// Existing subclasses only need to implement [createDataStream], as before.
/// The first [addListener] call starts the stream and the matching final
/// [removeListener] call cancels it and resets [data] to `null`.
abstract class BaseDataStreamRepository<T> extends BaseDataRepository<T> {
  StreamSubscription<T>? _dataSubscription;
  int _streamLifecycle = 0;

  /// Creates the shared source subscription.
  ///
  /// Implementations publish values by assigning them to [data.value].
  StreamSubscription<T> createDataStream();

  @override
  void startDataSource() {
    if (_dataSubscription != null) return;
    debugRepositoryMessage('Initializing data stream.');
    final lifecycle = ++_streamLifecycle;
    final subscription = createDataStream();
    // A synchronous first event may cause the listener to unsubscribe (and
    // even resubscribe) before createDataStream returns. Do not let that older
    // start overwrite or outlive the resulting lifecycle.
    if (lifecycle != _streamLifecycle || !hasDataConsumers) {
      unawaited(subscription.cancel());
      return;
    }
    _dataSubscription = subscription;
  }

  @override
  void stopDataSource() {
    _streamLifecycle++;
    final subscription = _dataSubscription;
    if (subscription == null) return;

    debugRepositoryMessage('Closing data stream.');
    // Clear the field before cancellation so a rapid resubscription owns a
    // distinct lifecycle and completion of this cancellation cannot clear it.
    _dataSubscription = null;
    unawaited(subscription.cancel());
  }

  /// Cancels and recreates an active stream subscription.
  ///
  /// This retains the previous behavior: calling it while inactive is a no-op,
  /// while an active reset clears [data] and immediately creates a fresh source.
  void resetStream() {
    if (_dataSubscription == null) {
      debugRepositoryMessage('Data stream is already null, no need to reset.');
      return;
    }
    resetData();
  }
}
