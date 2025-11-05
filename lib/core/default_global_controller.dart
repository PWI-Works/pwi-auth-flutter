import 'dart:async' show Future, StreamSubscription, unawaited;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/data/services/employee_service_interface.dart';
import 'package:pwi_auth/data/services/user_service_interface.dart';
import 'package:pwi_auth/core/user_initialization_type.dart';
import 'package:pwi_auth/data/services/services.dart';
import 'package:pwi_auth/pwi_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signature for creating a customized global controller instance.
///
/// This allows apps to inject a subclass while delegating the singleton
/// lifecycle managed by [DefaultGlobalController].
typedef GlobalControllerBuilder = DefaultGlobalController Function({
  required String appTitle,
  PwiAuthBase? auth,
});

/// Typed builder for subclasses so callers can retain their specific type.
typedef TypedGlobalControllerBuilder<T extends DefaultGlobalController> = T
    Function({
  required String appTitle,
  PwiAuthBase? auth,
});

/// Singleton that provides global application state that the UI listens to.
///
/// Highlights:
/// - Call [initialize] once at startup to configure the singleton. Subsequent
///   calls must supply the same [appTitle] and [auth] instance or a
///   [StateError] is thrown.
/// - Use [initializeSubclass] if you need a subclass while keeping the existing
///   singleton behavior and shared initialization.
/// - Extend the controller and override [onReady], [onSignIn], or [onSignOut]
///   to customize behavior. Subclasses should invoke [protected] in their
///   constructor so the shared initialization runs when the singleton is set up.
class DefaultGlobalController extends Model {
  DefaultGlobalController._create();

  /// Constructor intended for subclasses so they can invoke shared setup.
  @protected
  DefaultGlobalController.protected() : this._create();

  /// Singleton instance storage.
  static DefaultGlobalController? _instance;

  /// Returns the active singleton instance.
  ///
  /// Throws a [StateError] if the controller has not been initialized yet.
  static DefaultGlobalController get instance {
    final current = _instance;
    if (current == null) {
      throw StateError(
        'GlobalControllerInterface has not been initialized. Call initialize '
        'before accessing the instance.',
      );
    }
    return current;
  }

  /// Exposes the active instance when available, otherwise `null`.
  static DefaultGlobalController? get instanceOrNull => _instance;

  bool _isConfigured = false;
  bool _userServicesConfigured = false;
  UserInitializationType? _userInitializationType;
  EmployeeServiceInterface? _employeeService;
  UserServiceInterface? _userService;

  void _setup({required String appTitle, PwiAuthBase? auth}) {
    if (_isConfigured) {
      throw StateError('GlobalControllerInterface is already configured.');
    }
    _appTitle = appTitle;
    _isConfigured = true;
    _initializeCore(auth: auth);
  }

  /// Initializes the singleton controller with an optional custom subclass.
  ///
  /// Subsequent calls perform validation and return the existing instance.
  static DefaultGlobalController initialize({
    required String appTitle,
    PwiAuthBase? auth,
    GlobalControllerBuilder? builder,
    UserInitializationType userType = UserInitializationType.firestoreEmployee,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) =>
      initializeSubclass<DefaultGlobalController>(
        appTitle: appTitle,
        auth: auth,
        builder: builder ??
            ({required String appTitle, PwiAuthBase? auth}) =>
                DefaultGlobalController._create(),
        userType: userType,
        employeeService: employeeService,
        userService: userService,
      );

  /// Initializes the singleton with a custom subclass while keeping type safety.
  ///
  /// The provided [builder] must call [protected] within its constructor so
  /// shared setup executes. Most subclasses expose their own static
  /// `initialize` that forwards here so app code can remain unaware of the
  /// builder. This method throws if the singleton is already initialized with a
  /// different subclass.
  static T initializeSubclass<T extends DefaultGlobalController>({
    required String appTitle,
    PwiAuthBase? auth,
    required TypedGlobalControllerBuilder<T> builder,
    UserInitializationType userType = UserInitializationType.firestoreEmployee,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) {
    _validateUserInitialization(
      userType: userType,
      employeeService: employeeService,
      userService: userService,
    );

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
      if (existing is! T) {
        throw StateError(
          'GlobalControllerInterface already initialized with '
          '${existing.runtimeType}.',
        );
      }
      existing._configureUserInitialization(
        userType: userType,
        employeeService: employeeService,
        userService: userService,
      );
      return existing;
    }

    final controller = builder(
      appTitle: appTitle,
      auth: auth,
    );
    controller._configureUserInitialization(
      userType: userType,
      employeeService: employeeService,
      userService: userService,
    );
    controller._setup(appTitle: appTitle, auth: auth);
    _instance = controller;
    return controller;
  }

  void _configureUserInitialization({
    required UserInitializationType userType,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) {
    if (_userServicesConfigured) {
      if (_userInitializationType != userType) {
        throw StateError(
          'GlobalControllerInterface already initialized with userType '
          '$_userInitializationType.',
        );
      }
      if (employeeService != null && !identical(_employeeService, employeeService)) {
        throw StateError(
          'GlobalControllerInterface already initialized with an employeeService instance.',
        );
      }
      if (userService != null && !identical(_userService, userService)) {
        throw StateError(
          'GlobalControllerInterface already initialized with a userService instance.',
        );
      }
      return;
    }

    switch (userType) {
      case UserInitializationType.firebaseAuthUser:
        _employeeService = null;
        _userService = null;
        break;
      case UserInitializationType.firestoreEmployee:
        _employeeService = employeeService ?? EmployeeService();
        _userService = userService ?? UserService();
        break;
    }

    _userInitializationType = userType;
    _userServicesConfigured = true;
  }

  static void _validateUserInitialization({
    required UserInitializationType userType,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) {
    switch (userType) {
      case UserInitializationType.firebaseAuthUser:
        if (employeeService != null) {
          throw ArgumentError.value(
            employeeService,
            'employeeService',
            'must be null when userType is firebaseAuthUser.',
          );
        }
        if (userService != null) {
          throw ArgumentError.value(
            userService,
            'userService',
            'must be null when userType is firebaseAuthUser.',
          );
        }
        break;
      case UserInitializationType.firestoreEmployee:
        break;
    }
  }

  /// Returns the active singleton instance cast to [T].
  ///
  /// Throws when the singleton is uninitialized or does not match [T].
  static T instanceAs<T extends DefaultGlobalController>() {
    final controller = instance;
    if (controller is! T) {
      throw StateError(
        'GlobalControllerInterface is of type ${controller.runtimeType}, '
        'requested $T.',
      );
    }
    return controller;
  }

  /// Immutable application title exposed through [appTitle].
  late final String _appTitle;

  /// Firebase authentication wrapper the controller listens to.
  PwiAuthBase? _auth;

  /// getter for the active auth instance
  PwiAuthBase get auth {
    if (_auth == null) {
      throw StateError(
          'GlobalControllerInterface has not been initialized. Call initialize before accessing it.');
    }
    return _auth!;
  }

  /// Subscription that tracks authentication state changes.
  StreamSubscription<User?>? _authSubscription;

  /// Whether the user is currently signed in
  ///
  /// Throws a [StateError] until the controller has been initialized via
  /// [initialize] or [initializeSubclass].
  bool get isSignedIn {
    if (_auth == null) {
      throw StateError(
          'GlobalControllerInterface has not been initialized. Call initialize before accessing it.');
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
    _auth = null;
    _employeeService = null;
    _userService = null;
    _userInitializationType = null;
    _userServicesConfigured = false;
    _isConfigured = false;
    if (identical(_instance, this)) {
      _instance = null;
    }
    super.dispose();
  }
}
