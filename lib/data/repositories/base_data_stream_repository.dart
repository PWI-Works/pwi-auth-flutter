// lib/data/repositories/base_data_stream_repository.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mvvm_plus/mvvm_plus.dart';

/// BaseDataStreamRepository is an abstract class that provides a template for
/// creating repositories with a data stream. It manages a data property and a
/// stream subscription, allowing subclasses to define the actual data stream.
///
/// This class provides methods to add and remove listeners to the data property
/// and reset the stream. Adding and removing listeners automatically initializes
/// and closes the data stream. It also ensures proper disposal of resources
/// when the class is no longer needed.
///
/// It is important to note that we should not use data.addListener() directly
/// in any implementations of this class. Instead, we should use the
/// subscribeToData() method. This ensures that the stream is properly
/// initialized and closed when listeners are added and removed.
/// ```dart
/// // do this
/// repository.subscribeToData(() {
///  localValue = repository.data.value;
/// });
///
/// // not this
/// repository.data.addListener(() {
///  localValue = repository.data.value;
/// });
/// ```
abstract class BaseDataStreamRepository<T> extends Model {
  /// a flag to enable debug logging
  bool _debugLoggingEnabled = false;

  /// a class name for debug logging
  String _debugClassName = '';

  /// A property that stores the data once it is loaded.
  /// View models can subscribe to this property using `*.data.addListener()`.
  late final data = createProperty<T?>(null);

  /// A subscription to the data stream.
  /// This is used to listen to the data source and update the `data` property.
  /// Subclasses must override the `createDataStream` method to provide the actual data stream.
  StreamSubscription<T>? _dataSubscription;

  /// Registers a listener to the `data` property.
  ///
  /// This method ensures the data stream is initialized if it is not already started
  /// and adds the provided callback as a listener to the `data` property.
  ///
  /// \param onData A callback function to be executed when the `data` property changes.
  void subscribeToData(VoidCallback onData) {
    // Start the stream if it is not already started
    _initStream();
    _debugPrint("adding listener to data stream.");
    data.addListener(onData);
    // If data is already available, trigger the callback immediately
    if (data.value != null) {
      onData();
    }
  }

  /// Unregisters a listener from the `data` property.
  ///
  /// This method removes the provided callback from the `data` property listeners.
  /// If there are no more listeners, it closes the data stream.
  ///
  /// \param onData A callback function to be removed from the `data` property listeners.
  void unsubscribeFromData(VoidCallback onData) {
    _debugPrint("removing listener from data stream.");
    data.removeListener(onData);

    // Close the stream if no more listeners
    if (!data.hasListeners) {
      _closeStream();
    }
  }

  /// Enables debug logging for the repository.
  void enableDebugLogging(String className) {
    _debugLoggingEnabled = true;
    _debugClassName = className;
    _debugPrint('Debug logging enabled.');
  }

  /// Creates a stream subscription to the data source.
  ///
  /// Subclasses must implement this method to define the actual data stream.
  /// The override must call `data.value = data` to update the `data` property
  /// when new data is received.
  StreamSubscription<T> createDataStream();

  /// Initializes the data stream subscription.
  ///
  /// This method ensures that the data stream subscription is started only once.
  /// It calls the `createDataStream` method to start the subscription.
  void _initStream() {
    if (_dataSubscription != null) return;
    _debugPrint('Initializing data stream.');
    _dataSubscription = createDataStream();
  }

  /// Closes the data stream subscription.
  ///
  /// This method cancels the data stream subscription, sets the `data` property to null,
  /// and cleans up the subscription reference.
  void _closeStream() {
    _debugPrint("Closing data stream.");
    _dataSubscription?.cancel();
    _dataSubscription = null;
    data.value = null; // reset data
  }

  /// Resets the data stream subscription.
  ///
  /// This method closes the current data stream subscription and reinitializes it.
  ///
  /// Can be called to roll back optimistic updates in case of errors.
  ///
  /// Otherwise, this should not be needed except in odd cases where the user is
  /// logged out and logged back in, as Firestore data subscriptions are
  /// automatically canceled when the user logs out. However, even then the user
  /// can just refresh the page to reinitialize the stream.
  void resetStream() {
    if (_dataSubscription == null) {
      _debugPrint("Data stream is already null, no need to reset.");
      return;
    }
    _closeStream();
    _initStream();
  }

  /// Prints debug messages if debug logging is enabled.
  void _debugPrint(Object message) {
    if (_debugLoggingEnabled) {
      if (kDebugMode) {
        print('$_debugClassName: $message');
      }
    }
  }

  /// Disposes of the class and its resources.
  ///
  /// This method ensures that the class is properly disposed of by closing the data stream
  /// subscription and throwing an error if there are still listeners on the `data` property.
  @override
  void dispose() {
    if (data.hasListeners) {
      throw StateError(
        'Cannot dispose of $runtimeType while it has listeners.',
      );
    }
    _closeStream();
    super.dispose();
  }

  /// Overrides the addListener method to throw an error.
  /// This is to prevent accidental direct use of `addListener` on repositories,
  /// which is often suggested by auto-completion.
  @override
  void addListener(VoidCallback listener) {
    throw UnsupportedError(
      'Do not use addListener directly on repositories. Use subscribeToData() instead.',
    );
  }

  /// Overrides the removeListener method to throw an error.
  /// This is to prevent accidental direct use of `removeListener` on repositories,
  /// which is often suggested by auto-completion.
  @override
  void removeListener(VoidCallback listener) {
    throw UnsupportedError(
      'Do not use removeListener directly on repositories. Use unsubscribeFromData() instead.',
    );
  }
}
