import 'dart:async' show Future, StreamSubscription, unawaited;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/pwi_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signature for creating a customized global controller instance.
///
/// This allows apps to inject a subclass while delegating the singleton
/// lifecycle managed by [DefaultGlobalController].
typedef GlobalControllerBuilder = DefaultGlobalController Function(
    String appTitle, PwiAuthBase? auth);

/// Singleton that provides global application state that the UI listens to.
///
/// Highlights:
/// - Use the factory constructor to obtain the singleton. The first call must
///   supply the application title and can optionally provide a [PwiAuthBase]
///   instance. Repeated calls return the same instance and validate arguments.
/// - Use [GlobalControllerBuilder] if you need a subclass while keeping the
///   existing singleton behavior and shared initialization.
/// - Extend the controller and override [onReady], [onSignIn], or [onSignOut]
///   to customize behavior. Subclasses should call [protected] in their
///   constructor to ensure the shared initialization runs.
class DefaultGlobalController extends Model {
  /// Obtains the singleton controller.
  ///
  /// Subsequent calls return the same instance, so the provided [appTitle] and
  /// [auth] must match or a [StateError] is thrown. When [builder] is supplied
  /// the created instance must call [protected] or otherwise ensure the core
  /// initialization executes.
  factory DefaultGlobalController({
    required String appTitle,
    PwiAuthBase? auth,
    GlobalControllerBuilder? builder,
  }) {
    final existing = _instance;
    if (existing != null) {
      if (existing.appTitle != appTitle) {
        throw StateError(
          'GlobalControllerInterface already initialized with appTitle '
          '"${existing.appTitle}".',
        );
      }
      if (auth != null && !identical(existing._auth, auth)) {
        throw StateError(
          'GlobalControllerInterface already initialized with an auth '
          'instance. Dispose the current instance before supplying a new one.',
        );
      }
      return existing;
    }

    final controller = builder?.call(appTitle, auth) ??
        DefaultGlobalController._internal(
          appTitle: appTitle,
          auth: auth,
        );
    _instance = controller;
    return controller;
  }

  /// Core constructor that performs shared initialization.
  DefaultGlobalController._internal({
    required String appTitle,
    PwiAuthBase? auth,
  }) : _appTitle = appTitle {
    _initializeCore(auth: auth);
  }

  /// Constructor intended for subclasses so they can invoke shared setup.
  @protected
  DefaultGlobalController.protected({
    required String appTitle,
    PwiAuthBase? auth,
  }) : this._internal(appTitle: appTitle, auth: auth);

  /// Singleton instance storage.
  static DefaultGlobalController? _instance;

  /// Returns the active singleton instance.
  ///
  /// Throws a [StateError] if the controller has not been initialized yet.
  static DefaultGlobalController get instance {
    final current = _instance;
    if (current == null) {
      throw StateError(
        'GlobalControllerInterface has not been initialized. Call the factory '
        'constructor before accessing the instance.',
      );
    }
    return current;
  }

  /// Exposes the active instance when available, otherwise `null`.
  static DefaultGlobalController? get instanceOrNull => _instance;

  /// Immutable application title exposed through [appTitle].
  final String _appTitle;

  /// Firebase authentication wrapper the controller listens to.
  PwiAuthBase? _auth;

  /// Subscription that tracks authentication state changes.
  StreamSubscription<User?>? _authSubscription;

  /// Whether the user is currently signed in
  ///
  /// Throws a [StateError] until the controller has been initialized via the
  /// factory constructor.
  bool get isSignedIn {
    if (_auth == null) {
      throw StateError(
          'GlobalControllerInterface has not been initialized. Call the factory constructor before accessing it.');
    }
    return _auth!.signedIn;
  }

  /// The title of the application
  String get appTitle => _appTitle;

  /// The current theme mode of the application
  ///
  /// UI widgets can listen to this property to respond to theme changes.
  late final themeMode = createProperty<ThemeMode>(ThemeMode.system);

  /// Sets up auth subscription and loads persisted theme preferences.
  void _initializeCore({PwiAuthBase? auth}) {
    _configureAuth(auth);
    themeMode.addListener(_saveTheme);
    // Fire-and-forget theme loading. Caller can override [onReady] if they
    // need to react after the async work completes.
    unawaited(_loadTheme());
    onReady();
  }

  /// Configures the [PwiAuthBase] instance and reacts to auth state changes.
  void _configureAuth(PwiAuthBase? auth) {
    final resolvedAuth = auth ?? PwiAuth();
    _authSubscription?.cancel();
    _auth = resolvedAuth;
    _authSubscription = _auth!.authStateChanges.listen((user) async {
      if (user != null) {
        await onSignIn(user);
      } else {
        await onSignOut();
      }

      notifyListeners();
    });
  }

  /// Loads the persisted theme selection from shared preferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('themeMode');
    themeMode.value =
        saved != null ? ThemeMode.values[saved] : ThemeMode.system;
  }

  /// Saves the current theme selection to shared preferences.
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', themeMode.value.index);
  }

  /// Lifecycle hook invoked after the core initialization completes.
  @protected
  @mustCallSuper
  void onReady() {}

  /// Lifecycle hook when a Firebase [user] signs in.
  Future<void> onSignIn(User user) async {
    // Override in implementation if needed
  }

  /// Lifecycle hook when the user signs out.
  Future<void> onSignOut() async {
    // Override in implementation if needed
  }

  /// Tears down the singleton when no longer needed.
  @override
  void dispose() {
    _authSubscription?.cancel();
    themeMode.removeListener(_saveTheme);
    if (identical(_instance, this)) {
      _instance = null;
    }
    super.dispose();
  }
}
