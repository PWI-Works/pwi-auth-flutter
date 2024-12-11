import 'package:flutter/foundation.dart';

bool enableLogs = false;

/// Logs a [message] if logging is enabled.
void log(Object? message) {
  if (enableLogs) {
    if (kDebugMode) {
      print(message);
    }
  }
}