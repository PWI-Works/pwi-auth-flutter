/// The PwiAuth library provides authentication functionalities for the PWI application.
library pwi_auth;

import 'package:flutter/foundation.dart';
import 'package:pwi_auth/pwi_auth.dart';

/// Logs a [message] if logging is enabled.
void log(Object? message) {
  if (PwiAuth().enableLogs) {
    if (kDebugMode) {
      print(message);
    }
  }
}
