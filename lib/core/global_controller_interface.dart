import 'dart:async' show StreamSubscription;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/pwi_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An interface that provides global application state properties
 class GlobalControllerInterface extends Model {
  PwiAuth? _auth;

  StreamSubscription? _authSubscription;

  /// Whether the user is currently signed in
  bool get isSignedIn {
    if (_auth == null) {
      throw StateError(
          'AppControllerInterface has not been initialized. Call initialize() first.');
    }
    return _auth!.signedIn;
  }

  /// The title of the application
  String get appTitle;

  /// The current theme mode of the application
  late final themeMode = createProperty<ThemeMode>(ThemeMode.system);

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('themeMode');
    themeMode.value =
        saved != null ? ThemeMode.values[saved] : ThemeMode.system;
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.value.index);
  }

  @mustCallSuper
  Future<void> initialize({PwiAuth? auth}) async {
    _auth = auth ?? PwiAuth();

    _authSubscription = _auth!.authStateChanges.listen((user) async {
      if (user != null) {
        await onSignIn(user);
      } else {
        await onSignOut();
      }

      notifyListeners();
    });

    await _loadTheme();
    themeMode.addListener(_saveTheme);
  }

  Future<void> onSignIn(User user) async {
    // Override in implementation if needed
  }

  Future<void> onSignOut() async {
    // Override in implementation if needed
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    themeMode.removeListener(_saveTheme);
    super.dispose();
  }
}
