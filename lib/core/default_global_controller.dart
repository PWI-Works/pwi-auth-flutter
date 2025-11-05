import 'dart:async' show Future, StreamSubscription, unawaited;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/data/models/employee.dart';
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

  /// Tracks the singleton instance once [initialize] locks it in place.
  ///
  /// We purposely avoid exposing setters so the lifecycle is owned entirely by
  /// the controller and misconfiguration is caught by explicit guards.
  static DefaultGlobalController? _instance;

  /// Returns the active singleton instance.
  ///
  /// Throws a [StateError] if the controller has not been initialized yet.
  static DefaultGlobalController get instance {
    final current = _instance;
    if (current == null) {
      throw StateError(
        'DefaultGlobalController has not been initialized. Call initialize '
        'before accessing the instance.',
      );
    }
    return current;
  }

  /// Exposes the active instance when available, otherwise `null`.
  static DefaultGlobalController? get instanceOrNull => _instance;

  /// Guards against double configuration of [_setup].
  bool _isConfigured = false;

  /// Ensures we only wire up employee/user services once.
  bool _userServicesConfigured = false;

  /// Determines whether we resolve employees from Firestore or rely solely on
  /// the Firebase auth user.
  UserInitializationType? _userInitializationType;

  /// Lazy-initialized employee service based on [_userInitializationType].
  EmployeeServiceInterface? _employeeService;

  /// Lazy-initialized user service used to translate Firebase users to employee
  /// IDs.
  UserServiceInterface? _userService;

  /// Cache of the currently signed-in employee record (if any).
  Employee? _loggedInEmployee;

  /// Latest Firebase auth user that triggered [_configureAuth]'s listener.
  User? _firebaseAuthUser;

  /// Most recently fetched employee, or `null` when unavailable.
  Employee? get loggedInEmployee => _loggedInEmployee;

  /// Mirror of Firebase user state so UI can access auth metadata.
  User? get firebaseAuthUser => _firebaseAuthUser;

  /// Convenience getter for the Firebase user's email.
  String? get firebaseUserEmail => _firebaseAuthUser?.email;

  /// Convenience getter for the Firebase display name.
  String? get firebaseUserDisplayName => _firebaseAuthUser?.displayName;

  /// Convenience getter for the Firebase UID.
  String? get firebaseUserUid => _firebaseAuthUser?.uid;

  /// Internal one-time setup invoked by the static [initialize] helpers.
  ///
  /// Wrapped so subclasses can opt-in to the shared lifecycle without exposing
  /// configuration hooks publicly.
  void _setup({required String appTitle, PwiAuthBase? auth}) {
    if (_isConfigured) {
      throw StateError('DefaultGlobalController is already configured.');
    }
    // Persist the caller-supplied metadata before we fan out to async work.
    _appTitle = appTitle;
    // Mark configured before invoking helper methods so re-entrant calls fail
    // fast instead of partially reconfiguring the singleton.
    _isConfigured = true;
    _initializeCore(auth: auth);
  }

  /// Initializes the singleton controller with an optional custom subclass.
  ///
  /// This is the entry point most apps hit during bootstrapping. On the first
  /// call we eagerly build the controller, wire up authentication listeners and
  /// optionally resolve domain services depending on [userType]. Subsequent
  /// calls become assertions that the caller is not accidentally trying to
  /// reconfigure global state with a different app title, auth instance, or
  /// service dependencies.
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
        // Default to constructing a vanilla controller when the caller does
        // not provide a custom builder.
        builder: builder ??
            ({required String appTitle, PwiAuthBase? auth}) =>
                DefaultGlobalController._create(),
        userType: userType,
        employeeService: employeeService,
        userService: userService,
      );

  /// Initializes the singleton with a custom subclass while keeping type safety.
  ///
  /// Subclasses typically expose their own static `initialize` helper that
  /// simply forwards into this method with a strongly typed [builder]. We
  /// enforce that every subclass constructor calls [DefaultGlobalController.protected]
  /// so the shared setup path runs and lifecycle invariants stay intact. The
  /// extra type parameter [T] lets callers regain their subtype without relying
  /// on casts at call-sites.
  static T initializeSubclass<T extends DefaultGlobalController>({
    required String appTitle,
    PwiAuthBase? auth,
    required TypedGlobalControllerBuilder<T> builder,
    UserInitializationType userType = UserInitializationType.firestoreEmployee,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) {
    // Validate arguments early so callers receive fast feedback before any
    // stateful work happens.
    _validateUserInitialization(
      userType: userType,
      employeeService: employeeService,
      userService: userService,
    );

    final existing = _instance;
    if (existing != null) {
      // When the singleton already exists we treat this call as a sanity check
      // that the configuration matches what we have on record.
      if (existing.appTitle != appTitle) {
        throw StateError(
          'DefaultGlobalController already initialized with appTitle '
          '"${existing.appTitle}".',
        );
      }
      if (auth != null && !identical(existing._auth, auth)) {
        throw StateError(
          'DefaultGlobalController already initialized with an auth '
          'instance. Dispose the current instance before supplying a new one.',
        );
      }
      if (existing is! T) {
        throw StateError(
          'DefaultGlobalController already initialized with '
          '${existing.runtimeType}.',
        );
      }
      existing._configureUserInitialization(
        userType: userType,
        employeeService: employeeService,
        userService: userService,
      );
      // Return the already-initialized controller rather than rebuilding.
      return existing;
    }

    // No instance yet – build one using the caller-supplied factory.
    final controller = builder(
      appTitle: appTitle,
      auth: auth,
    );
    // Configure dependencies before running the rest of the setup so any
    // thrown assertions stop initialization early.
    controller._configureUserInitialization(
      userType: userType,
      employeeService: employeeService,
      userService: userService,
    );
    controller._setup(appTitle: appTitle, auth: auth);
    // Publish the instance last so partially initialized controllers are never
    // visible to other parts of the app.
    _instance = controller;
    return controller;
  }

  /// Applies the configuration for how the controller should retrieve user data.
  ///
  /// This routine executes on both the first initialization and on subsequent
  /// validation calls. When invoked after the singleton already exists we
  /// ensure the requested dependencies match the original configuration so we
  /// can catch subtle bugs where setup code drifts across hot reloads or
  /// parallel integration tests.
  void _configureUserInitialization({
    required UserInitializationType userType,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) {
    if (_userServicesConfigured) {
      // If we already wired up services, treat the new inputs as assertions
      // that nothing has changed rather than attempting to reconfigure.
      if (_userInitializationType != userType) {
        throw StateError(
          'DefaultGlobalController already initialized with userType '
          '$_userInitializationType.',
        );
      }
      if (employeeService != null &&
          !identical(_employeeService, employeeService)) {
        throw StateError(
          'DefaultGlobalController already initialized with an employeeService instance.',
        );
      }
      if (userService != null && !identical(_userService, userService)) {
        throw StateError(
          'DefaultGlobalController already initialized with a userService instance.',
        );
      }
      return;
    }

    switch (userType) {
      case UserInitializationType.firebaseAuthUser:
        // Rely purely on Firebase auth; nothing extra to cache.
        _employeeService = null;
        _userService = null;
        break;
      case UserInitializationType.firestoreEmployee:
        // Fall back to default service implementations when the caller does not
        // pass mocks or overrides. This keeps the controller functional in
        // production builds with zero additional wiring.
        _employeeService = employeeService ?? EmployeeService();
        _userService = userService ?? UserService();
        break;
    }

    // The order here matters; we set the enum last so, in the event of a thrown
    // exception above, a retry can attempt configuration again.
    _userInitializationType = userType;
    _userServicesConfigured = true;
  }

  /// Sanity-checks combinations of user initialization parameters.
  ///
  /// Doing validation up front keeps the rest of the setup logic simpler and
  /// makes configuration failures easier to diagnose because we can point to
  /// exactly which argument violated the contract.
  static void _validateUserInitialization({
    required UserInitializationType userType,
    EmployeeServiceInterface? employeeService,
    UserServiceInterface? userService,
  }) {
    switch (userType) {
      case UserInitializationType.firebaseAuthUser:
        // Firebase auth-only mode should not receive service overrides because
        // they would never be invoked. Flag them early so the caller can
        // migrate to `firestoreEmployee` if they actually needed them.
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
        // No validation required – all arguments are optional and default to
        // concrete implementations in [_configureUserInitialization].
        break;
    }
  }

  /// Returns the active singleton instance cast to [T].
  ///
  /// Useful in module code that knows a more specific subtype should be
  /// available. The runtime check keeps debugging straightforward by throwing a
  /// descriptive error when the assumption fails.
  static T instanceAs<T extends DefaultGlobalController>() {
    final controller = instance;
    if (controller is! T) {
      throw StateError(
        'DefaultGlobalController is of type ${controller.runtimeType}, '
        'requested $T.',
      );
    }
    // The cast is now guaranteed to succeed because of the guard above.
    return controller;
  }

  /// Immutable application title exposed through [appTitle].
  ///
  /// Set when [_setup] runs so the value remains stable across the lifetime of
  /// the singleton.
  late final String _appTitle;

  /// Firebase authentication wrapper the controller listens to.
  PwiAuthBase? _auth;

  /// Returns the active auth instance, guaranteeing initialization first.
  PwiAuthBase get auth {
    if (_auth == null) {
      throw StateError(
          'DefaultGlobalController has not been initialized. Call initialize before accessing it.');
    }
    // `_auth` should only ever be null during teardown; exposing the helpful
    // error keeps misuse from silently succeeding in tests.
    return _auth!;
  }

  /// Subscription that tracks authentication state changes.
  StreamSubscription<User?>? _authSubscription;

  /// Whether the user is currently signed in according to [_auth].
  ///
  /// Throws a [StateError] until the controller has been initialized via
  /// [initialize] or [initializeSubclass].
  bool get isSignedIn {
    if (_auth == null) {
      throw StateError(
          'DefaultGlobalController has not been initialized. Call initialize before accessing it.');
    }
    // The value is read directly off the auth wrapper so this getter always
    // reflects real-time state.
    return _auth!.signedIn;
  }

  /// The title of the application.
  ///
  /// Exposed as a simple getter because the value never changes after initial
  /// setup.
  String get appTitle => _appTitle;

  /// The current theme mode of the application.
  ///
  /// Uses `mvvm_plus`'s [createProperty] helper so the UI can bind directly to
  /// changes without re-implementing boilerplate state management.
  late final themeMode = createProperty<ThemeMode>(ThemeMode.system);

  /// Sets up auth subscription and loads persisted theme preferences.
  ///
  /// This method centralizes first-run configuration so both the base class
  /// and subclasses follow the same lifecycle order: configure auth, attach
  /// listeners, hydrate persistent state, then invoke [onReady].
  void _initializeCore({PwiAuthBase? auth}) {
    // Wire up authentication first because it will drive most of the reactive
    // state within the controller.
    _configureAuth(auth);
    // Persist theme changes as they happen.
    themeMode.addListener(_saveTheme);
    // Fire-and-forget theme loading. Caller can override [onReady] if they
    // need to react after the async work completes.
    unawaited(_loadTheme());
    onReady();
  }

  /// Configures the [PwiAuthBase] instance and reacts to auth state changes.
  ///
  /// We subscribe exactly once and fan all updates through this controller so
  /// downstream widgets only need to listen in a single place.
  void _configureAuth(PwiAuthBase? auth) {
    // Allow callers to inject a custom auth implementation (for testing or
    // white-label builds) while defaulting to the standard [PwiAuth].
    final resolvedAuth = auth ?? PwiAuth();
    // Make sure we are not leaking subscriptions when initialization runs more
    // than once (e.g., during hot restart in development).
    _authSubscription?.cancel();
    _auth = resolvedAuth;
    // The `listen` callback is the heart of the controller: it updates caches
    // and delegates to lifecycle hooks in response to authentication changes.
    _authSubscription = _auth!.authStateChanges.listen((user) async {
      // Cache the raw Firebase user so the UI can inspect metadata.
      _firebaseAuthUser = user;
      if (user != null) {
        try {
          if (_userInitializationType ==
              UserInitializationType.firestoreEmployee) {
            if (_employeeService == null || _userService == null) {
              throw StateError(
                'DefaultGlobalController implementation is not configured with employee or user services.',
              );
            }
            // Translate the Firebase user into a domain-specific employee
            // record. This provides richer context for the rest of the app.
            final employeeId = await _userService!.getEmployeeIdFromUser(user);
            _loggedInEmployee = employeeId != null
                ? await _employeeService!.getEmployeeById(employeeId)
                : null;
          } else {
            _loggedInEmployee = null;
          }
        } catch (_) {
          // Swallow errors so a bad network call does not crash the listener;
          // the UI can observe the missing employee and handle accordingly.
          _loggedInEmployee = null;
        }
        // Give subclasses a chance to perform additional, higher-level work.
        await onSignIn(user);
      } else {
        _loggedInEmployee = null;
        // Subclasses can clean up derived state here.
        await onSignOut();
      }
      // Notify observers regardless of success so they can reconcile with the
      // latest known state.
      notifyListeners();
    });
  }

  /// Loads the persisted theme selection from shared preferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('themeMode');
    // The integer maps directly to the [ThemeMode] enum index; default to
    // system if nothing was previously saved (first run or cleared storage).
    themeMode.value =
        saved != null ? ThemeMode.values[saved] : ThemeMode.system;
  }

  /// Saves the current theme selection to shared preferences.
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Persist the enum index so `_loadTheme` can restore without extra mapping.
    await prefs.setInt('themeMode', themeMode.value.index);
  }

  /// Lifecycle hook invoked after the core initialization completes.
  ///
  /// By default it does nothing, but subclasses can trigger additional async
  /// work (for example, fetching feature flags) knowing that theme listeners
  /// and auth subscriptions are already wired up.
  @protected
  @mustCallSuper
  void onReady() {}

  /// Lifecycle hook when a Firebase [user] signs in.
  ///
  /// Subclasses typically override this to pre-load downstream data (such as
  /// user settings) after the base class has finished hydrating core caches.
  Future<void> onSignIn(User user) async {
    // Override in implementation if needed
  }

  /// Lifecycle hook when the user signs out.
  ///
  /// Override to tear down module-specific resources that were initialized in
  /// [onSignIn] or elsewhere.
  Future<void> onSignOut() async {
    // Override in implementation if needed
  }

  /// Tears down the singleton when no longer needed.
  ///
  /// This is mainly exercised by tests. We aggressively null out references so
  /// a fresh call to [initialize] starts from a clean slate.
  @override
  void dispose() {
    // Cancel subscriptions first so no callbacks fire after teardown.
    _authSubscription?.cancel();
    themeMode.removeListener(_saveTheme);
    // Reset dependencies and cached state.
    _auth = null;
    _employeeService = null;
    _userService = null;
    _userInitializationType = null;
    _userServicesConfigured = false;
    _loggedInEmployee = null;
    _firebaseAuthUser = null;
    _isConfigured = false;
    if (identical(_instance, this)) {
      // Only clear the static singleton if the disposed instance is the active
      // one. This plays nicely with subclasses that may dispose independently.
      _instance = null;
    }
    super.dispose();
  }
}
