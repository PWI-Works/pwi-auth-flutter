/// The PwiAuth library provides authentication functionalities for the PWI application.
library pwi_auth;

import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/browser_client.dart';
import 'package:pwi_auth/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart';

/// A class that provides authentication functionalities, including sign-in, sign-up, and session management.
class PwiAuth {
  // #region Singleton Implementation

  /// Private constructor
  PwiAuth._({
    bool? useSessionCookie,
    this.enableLogs = false,
  }) : useSessionCookie = useSessionCookie ?? !kDebugMode {
    log('PwiAuth created with useSessionCookie = ${this.useSessionCookie}');
    _subscribeToAuthChanges();

    if (this.useSessionCookie) {
      _initAuthWatch();
    } else {
      // if not using session cookie, assume auth status is current
      _authStatusChecked = true;
    }
  }

  /// The singleton instance
  static PwiAuth? _instance;

  /// Gets the singleton instance of PwiAuth
  ///
  /// If the instance does not already exist, it creates a new one with the specified
  /// [useSessionCookie] and [loggingEnabled] parameters.
  ///
  /// \param useSessionCookie - Optional. Indicates whether to use session cookies for authentication.
  /// \param loggingEnabled - Optional. Indicates whether logging is enabled. Defaults to false.
  ///
  /// \returns The singleton instance of PwiAuth.
  factory PwiAuth({
    bool? useSessionCookie,
    bool loggingEnabled = false,
  }) {
    _instance ??= PwiAuth._(
      useSessionCookie: useSessionCookie,
      enableLogs: loggingEnabled,
    );
    return _instance!;
  }

  bool enableLogs;

  // #endregion
  static const String _notSignedInMessage = "not-signed-in";

  // Private variables
  /// The endpoint URL for the authentication service.
  final String _endPoint = 'auth.pwiworks.app';

  /// An instance of FirebaseAuth used for authentication operations.
  final _auth = FirebaseAuth.instance;

  /// A timer that periodically checks the authentication status.
  Timer? _authCheckTimer;

  /// A completer used to manage the sign-out process.
  Completer<void>? _signOutCompleter;

  /// A subscription to the authentication state changes.
  StreamSubscription<User?>? _authSub;

  /// The currently authenticated user, or null if no user is signed in.
  User? user;

  /// A stream that emits authentication state changes.
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  /// Returns a stream of authentication state changes.
  Stream<User?> get authStateChanges => _controller.stream;

  /// A stream that emits errors.
  final StreamController<String?> _errors =
      StreamController<String?>.broadcast();

  /// Returns a stream of errors.
  Stream<String?> get errors => _errors.stream;

  /// Indicates whether the user is currently signed in.
  bool get signedIn => user != null;

  /// Indicates whether to use session cookies for authentication.
  final bool useSessionCookie;

  /// A flag indicating whether the authentication status has been checked.
  static bool _authStatusChecked = false;

  /// Returns whether the authentication status has been checked.
  bool get authStatusChecked => _authStatusChecked;

  /// Initializes the authentication watch process.
  ///
  /// This method attempts to sign in the user using a session cookie. If the session cookie is not present,
  /// it periodically checks every 2 seconds and signs out the user if the session cookie is missing.
  ///
  /// The method performs the following steps:
  /// 1. Calls `_attemptSignInWithCookie` to try signing in the user with a session cookie.
  /// 2. Sets up a periodic timer that runs every 2 seconds to check the presence of the session cookie.
  /// 3. If the session cookie is not present and the user is signed in, it logs a message and signs out the user.
  ///
  /// The timer is canceled after signing out the user.
  void _initAuthWatch() async {
    if (useSessionCookie) {
      await _attemptSignInWithCookie();
    }

    log('Initializing auth watch');
    _authCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if ((!_sessionCookieIsPresent()) && (user != null)) {
        log('Session cookie not present, signing out');
        _authCheckTimer?.cancel();
        try {
          await _auth.signOut();
        } catch (e) {
          log(e);
        }
      }
    });
  }

  /// Indicates whether a manual check of the authentication status is currently in progress.
  static bool _forceCheckingAuth = false;

  /// Forces a check of the authentication status by attempting to sign in with a session cookie.
  ///
  /// This method calls `_attemptSignInWithCookie` to try signing in the user using a session cookie.
  /// It is useful for manually triggering an authentication check when needed.
  Future<void> forceCheckAuth() async {
    log('Forcing auth check');
    if (!useSessionCookie) {
      log('Session cookie not used, skipping auth check force check as it is not needed.');
      _authStatusChecked = true;
      return;
    }

    if (_forceCheckingAuth) {
      log('Auth check already in progress, skipping force check.');
      return;
    }

    _forceCheckingAuth = true;
    await _attemptSignInWithCookie();
    _forceCheckingAuth = false;
  }

  // Add a flag to track sign in state
  bool _isSigningIn = false;

  /// Subscribes to authentication state changes and updates the user accordingly.
  void _subscribeToAuthChanges() {
    _authSub = _auth.authStateChanges().listen((user) async {
      log("PwiAuth user has changed: $user");
      if (user == null) {
        if (_signOutCompleter != null) {
          _signOutCompleter!.complete();
          _signOutCompleter = null;
        }
        // Only attempt cookie sign in if we're not in the middle of a regular sign in
        if (useSessionCookie && !_isSigningIn) {
          await _attemptSignInWithCookie();
        } else {
          this.user = null;
          _controller.add(null);
        }
      } else {
        // Signed in
        this.user = user;
        _controller.add(user);
      }
    });
  }

  /// Attempts to automatically sign in the user using the session cookie.
  ///
  /// This method checks the authentication status by calling `_checkAuthStatus`.
  /// If the authentication status has not been checked before, it sets `_authStatusChecked` to true.
  /// It then attempts to sign in the user with the custom token obtained from `_checkAuthStatus`.
  /// If an error occurs during the process, it logs the error, sets the `user` to null, and adds null to the `_controller` stream.
  Future<void> _attemptSignInWithCookie() async {
    if (!useSessionCookie) {
      log('_attemptSignInWithCookie called when useSessionCookie == false!');
      return;
    }
    log('Attempting to sign in with cookie (useSessionCookie = $useSessionCookie)');
    try {
      final token = await _checkAuthStatus();
      _auth.signInWithCustomToken(token);
    } catch (e) {
      // Signed out
      log(e);

      if (e.toString().contains(_notSignedInMessage)) {
        // do nothing
      } else {
        _errors.add(e.toString());
      }

      user = null;
      _controller.add(null);
    } finally {
      if (_authStatusChecked == false) {
        _authStatusChecked = true;
      }
    }
  }

  /// Checks the authentication status and returns a custom token if signed in.
  ///
  /// Throws an [Exception] if not signed in.
  Future<String> _checkAuthStatus() async {
    log('Checking auth status from API.');
    if (!_sessionCookieIsPresent()) {
      throw Exception(_notSignedInMessage);
    }

    final client = BrowserClient()..withCredentials = true;
    final uri = Uri.parse('https://$_endPoint/api/auth-status');
    final response = await client.get(uri);

    log(response.body);
    log(response.headers);
    for (var key in response.headers.keys) {
      log('$key: ${response.headers[key]}');
    }

    if (response.statusCode != 200) {
      throw Exception(_notSignedInMessage);
    }

    return response.body;
  }

  /// Checks if the session cookie is present in the browser.
  bool _sessionCookieIsPresent() {
    final sessionCookie = document.cookie.split(';').firstWhere(
        (cookie) => cookie.trim().startsWith('__session='),
        orElse: () => '');
    return sessionCookie.isNotEmpty;
  }

  /// Clears the session cookie.
  Future<void> _clearSessionCookie() async {
    final url = Uri.parse('https://$_endPoint/api/clear-session-cookie');
    final client = BrowserClient()..withCredentials = true;
    await client.post(url);
  }

  /// Signs out the current user and clears the session cookie.
  Future<void> signOut() async {
    try {
      if (useSessionCookie) {
        _signOutCompleter = Completer<void>();
        await _clearSessionCookie();

        if (_signOutCompleter != null) {
          await _signOutCompleter!.future.timeout(const Duration(seconds: 5));
        }
      } else {
        await _auth.signOut();
      }
    } catch (e) {
      log(e);
      _signOutCompleter = null;
    }
  }

  /// Sets the session cookie using the provided [idToken].
  ///
  /// Throws an [Exception] if setting the session cookie fails.
  Future<void> _setSessionCookie(String idToken) async {
    final client = BrowserClient()..withCredentials = true;

    final url = Uri.parse('https://$_endPoint/api/set-session-cookie');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'idToken': idToken});

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('set-session-cookie-failed');
    }
  }

  /// Signs in a user with the given [email] and [password].
  ///
  /// Throws an [Exception] if sign-in fails.
  Future<void> signIn({required String email, required String password}) async {
    _isSigningIn = true;
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (useSessionCookie) {
        final idToken = await userCredential.user?.getIdToken(true);
        await _setSessionCookie(idToken!);
      }
    } catch (e) {
      final error = e.toString();
      log(error);

      if (error.contains("invalid-email") ||
          error.contains("wrong-password") ||
          error.contains("invalid-credential")) {
        throw "Invalid email or password";
      } else if (error.contains("user-disabled")) {
        throw "User has been disabled";
      } else if (error.contains("user-not-found")) {
        throw "This user does not exist";
      }

      throw "Error signing in. Try again later";
    } finally {
      _isSigningIn = false;
    }
  }

  /// Signs in a user using Google authentication.
  ///
  /// Throws an [Exception] if sign-in fails.
  Future<void> signInWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(provider);

      if (useSessionCookie) {
        final idToken = await userCredential.user?.getIdToken(true);
        await _setSessionCookie(idToken!);
      }
    } catch (e) {
      log(e.toString());
      throw "Error signing in with Google. Try again later";
    }
  }

  /// Creates a new user account with the given [email], [password], [firstName], and [lastName].
  ///
  /// Throws an [Exception] if sign-up fails.
  Future<void> signUp(
      {required String email,
      required String password,
      required String firstName,
      required String lastName}) async {
    try {
      // Save the user data first so it's available when the stream gets called
      _authSub?.cancel();

      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (credential.user == null) {
        throw "error-creating-user";
      }

      await credential.user!.updateDisplayName("$firstName $lastName");

      if (useSessionCookie) {
        final idToken = await credential.user?.getIdToken(true);
        await _setSessionCookie(idToken!);
      }
    } catch (e) {
      log(e.toString());

      final error = e.toString();
      if (error.contains("invalid-email")) {
        throw "Invalid email address";
      } else if (error.contains("email-already-in-use")) {
        throw "An account with this email already exists";
      } else if (error.contains("weak-password")) {
        throw "Password is too weak. Must be at least 6 characters";
      } else if (error.toLowerCase().contains("permission_denied")) {
        throw "Permission denied. Contact the system administrator";
      }

      throw "Error creating account. Try again later";
    }
  }

  /// Navigates the user to the sign-up page.
  Future<void> goToSignUp() async {
    final url = Uri.parse('https://$_endPoint/sign-up?redirect=${Uri.base}');
    launchUrl(url, webOnlyWindowName: '_self');
  }

  /// Navigates the user to the sign-in page.
  Future<void> goToSignIn() async {
    final url = Uri.parse('https://$_endPoint/sign-in?redirect=${Uri.base}');
    launchUrl(url, webOnlyWindowName: '_self');
  }

  /// Sends a password reset email to the given [email].
  ///
  /// Throws an [Exception] if the email is invalid or sending fails.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log("Password reset email sent to $email");
    } catch (e) {
      log("Error sending password reset email: ${e.toString()}");
      final error = e.toString();
      if (error.contains("invalid-email")) {
        throw "Invalid email address";
      } else if (error.contains("user-not-found")) {
        throw "No user found with this email";
      }
      throw "Error sending password reset email. Try again later";
    }
  }

  /// Disposes of resources used by this instance.
  void dispose() {
    _controller.close();
    _authSub?.cancel();
    _authCheckTimer?.cancel();
  }
}
