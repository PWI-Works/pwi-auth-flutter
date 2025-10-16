import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwi_auth/pwi_auth.dart';

/// Lightweight mock implementation of [PwiAuthBase] for local testing examples.
class MockPwiAuth extends PwiAuthBase {
  MockPwiAuth({
    bool signedIn = true,
    User? initialUser,
    User? Function()? mockUserFactory,
  })  : _userFactory = mockUserFactory,
        _signedIn = signedIn,
        _user = signedIn ? (initialUser ?? mockUserFactory?.call()) : null;


  final User? Function()? _userFactory;

  User? _user;
  bool _signedIn;

  final _authStateController = StreamController<User?>.broadcast();
  final _errorsController = StreamController<String?>.broadcast();


  @override
  User? get user => _user;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Stream<String?> get errors => _errorsController.stream;

  @override
  bool get signedIn => _signedIn;

  @override
  bool get authStatusChecked => true;

  /// Updates the mock authentication state and notifies listeners.
  void setSignedIn({required bool value, User? user}) {
    _signedIn = value;
    if (value) {
      _user = user ?? _user ?? _userFactory?.call();
    } else {
      _user = null;
    }
    _authStateController.add(_user);
  }

  /// Emits an error message to any listeners observing [errors].
  void emitError(String? error) => _errorsController.add(error);

  @override
  Future<void> forceCheckAuth() async {}

  @override
  Future<void> signOut() async => setSignedIn(value: false);

  @override
  Future<void> signIn({required String email, required String password}) async =>
      setSignedIn(value: true);

  @override
  Future<void> signInWithGoogle() async => setSignedIn(value: true);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async =>
      setSignedIn(value: true);

  @override
  Future<void> goToSignUp() async {}

  @override
  Future<void> goToSignIn() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  void dispose() {
    _authStateController.close();
    _errorsController.close();
  }
}
