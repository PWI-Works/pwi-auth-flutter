/// The PwiAuth library provides authentication functionalities for the PWI application.
library pwi_auth;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/browser_client.dart';
import 'package:pwi_auth/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart';

/// A class that provides authentication functionalities, including sign-in, sign-up, and session management.
class PwiAuth {
  // Private variables
  final String _endPoint = 'auth.pwiworks.app';
  User? user;
  final _auth = FirebaseAuth.instance;
  Timer? _authCheckTimer;
  Completer<void>? _signOutCompleter;
  StreamSubscription<User?>? _authSub;

  /// A stream that emits authentication state changes.
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();

  /// Returns a stream of authentication state changes.
  Stream<User?> get authStateChanges => _controller.stream;

  /// Indicates whether the user is currently signed in.
  bool get signedIn => user != null;

  final bool useSessionCookie;


  static bool _authStatusChecked = false;

  bool get authStatusChecked => _authStatusChecked;

  /// Creates an instance of [PwiAuth] with the given endpoint.
  ///
  /// The [loggingEnabled] parameter controls whether logging is enabled.
  /// The [useSessionCookie] parameter controls whether a session cookie is required for authentication.
  /// Use this parameter to disable session cookie checks when testing from a domain that is blocked via CORS.
  PwiAuth({this.useSessionCookie = true, bool loggingEnabled = false}) {
    _subscribeToAuthChanges();

    enableLogs = loggingEnabled;
    
    if (useSessionCookie) {
      _attemptSignInWithCookie();
      _authCheckTimer =
          Timer.periodic(const Duration(seconds: 2), (timer) async {
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
    } else {
      // if not using session cookie, assume auth status is current
      _authStatusChecked = true;
    }
  }

  /// Subscribes to authentication state changes and updates the user accordingly.
  void _subscribeToAuthChanges() {
    _authSub = _auth.authStateChanges().listen((user) async {
      log(user);
      if (user == null) {
        if (_signOutCompleter != null) {
          _signOutCompleter!.complete();
          _signOutCompleter = null;
        }
        if (useSessionCookie) {
          _attemptSignInWithCookie();
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
    try {
      final token = await _checkAuthStatus();
      if (_authStatusChecked == false) {
        _authStatusChecked = true;
      }
      _auth.signInWithCustomToken(token);
    } catch (e) {
      // Signed out
      log(e);
      user = null;
      _controller.add(null);
    }
  }

  /// Checks the authentication status and returns a custom token if signed in.
  ///
  /// Throws an [Exception] if not signed in.
  Future<String> _checkAuthStatus() async {
    if (!_sessionCookieIsPresent()) {
      throw Exception('not-signed-in');
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
      throw Exception('not-signed-in');
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
