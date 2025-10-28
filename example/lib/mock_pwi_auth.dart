import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pwi_auth/pwi_auth.dart';

/// Lightweight mock implementation of [PwiAuthBase] for local testing examples.
class MockPwiAuth extends PwiAuthBase {
  MockPwiAuth({
    bool signedIn = true,
    User? initialUser,
    User? Function()? mockUserFactory,
  }) : _userFactory = (() =>
           _resolveUser(initialUser: null, mockUserFactory: mockUserFactory)),
       _signedIn = signedIn,
       _user = signedIn
           ? _resolveUser(
               initialUser: initialUser,
               mockUserFactory: mockUserFactory,
             )
           : null;

  static User _resolveUser({
    required User? initialUser,
    required User? Function()? mockUserFactory,
  }) {
    if (initialUser != null) {
      return initialUser;
    }
    final provided = mockUserFactory?.call();
    return provided ?? _MockFirebaseUser.generate();
  }

  final User Function() _userFactory;

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
  ///
  /// When switching to a signed-in state without a provided [user], this method
  /// generates a lightweight mock [User] instance so downstream listeners never
  /// observe a `null` user while `signedIn` is `true`.
  void setSignedIn({required bool value, User? user}) {
    try {
      _signedIn = value;
      if (value) {
        _user = user ?? _user ?? _userFactory();
      } else {
        _user = null;
      }
      _authStateController.add(_user);
    } catch (e) {
      emitError(e.toString());
      debugPrint('Error in setSignedIn: $e');
    }
  }

  /// Emits an error message to any listeners observing [errors].
  void emitError(String? error) => _errorsController.add(error);

  @override
  Future<void> forceCheckAuth() async {}

  @override
  Future<void> signOut() async => setSignedIn(value: false);

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async => setSignedIn(value: true);

  @override
  Future<void> signInWithGoogle() async => setSignedIn(value: true);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async => setSignedIn(value: true);

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

class _MockFirebaseUser implements User {
  _MockFirebaseUser({
    required this.uid,
    String? email,
    String? displayName,
    bool emailVerified = false,
    bool isAnonymous = false,
    String? phoneNumber,
    String? photoURL,
  }) : _email = email,
       _displayName = displayName,
       _emailVerified = emailVerified,
       _isAnonymous = isAnonymous,
       _phoneNumber = phoneNumber,
       _photoURL = photoURL,
       _metadata = UserMetadata(
         DateTime.now().millisecondsSinceEpoch,
         DateTime.now().millisecondsSinceEpoch,
       );

  factory _MockFirebaseUser.generate() {
    final seed = DateTime.now().millisecondsSinceEpoch;
    return _MockFirebaseUser(
      uid: 'mock-user-$seed',
      email: 'mock$seed@example.com',
      displayName: 'Mock User $seed',
    );
  }

  @override
  final String uid;
  String? _email;
  String? _displayName;
  bool _emailVerified;
  final bool _isAnonymous;
  final String? _phoneNumber;
  String? _photoURL;
  final UserMetadata _metadata;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;

  @override
  bool get emailVerified => _emailVerified;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  UserMetadata get metadata => _metadata;

  @override
  String? get phoneNumber => _phoneNumber;

  @override
  String? get photoURL => _photoURL;

  @override
  List<UserInfo> get providerData => const [];

  @override
  String? get refreshToken => null;

  @override
  String? get tenantId => null;

  @override
  MultiFactor get multiFactor =>
      throw UnimplementedError('MultiFactor is not supported in MockPwiAuth.');

  @override
  Future<void> delete() async {}

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => 'mock-token';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) =>
      Future.error(
        UnimplementedError('IdTokenResult is not supported in MockPwiAuth.'),
      );

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) =>
      Future.error(
        UnimplementedError('linkWithCredential not supported in MockPwiAuth.'),
      );

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) =>
      Future.error(
        UnimplementedError('linkWithProvider not supported in MockPwiAuth.'),
      );

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) => Future.error(
    UnimplementedError('linkWithPopup not supported in MockPwiAuth.'),
  );

  @override
  Future<void> linkWithRedirect(AuthProvider provider) => Future.error(
    UnimplementedError('linkWithRedirect not supported in MockPwiAuth.'),
  );

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) => Future.error(
    UnimplementedError('linkWithPhoneNumber not supported in MockPwiAuth.'),
  );

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) => Future.error(
    UnimplementedError(
      'reauthenticateWithCredential not supported in MockPwiAuth.',
    ),
  );

  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) =>
      Future.error(
        UnimplementedError(
          'reauthenticateWithProvider not supported in MockPwiAuth.',
        ),
      );

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) =>
      Future.error(
        UnimplementedError(
          'reauthenticateWithPopup not supported in MockPwiAuth.',
        ),
      );

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) =>
      Future.error(
        UnimplementedError(
          'reauthenticateWithRedirect not supported in MockPwiAuth.',
        ),
      );

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) async {}

  @override
  Future<User> unlink(String providerId) async => this;

  @override
  Future<void> updateDisplayName(String? displayName) async {
    _displayName = displayName;
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    _email = newEmail;
  }

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) =>
      Future.error(
        UnimplementedError('updatePhoneNumber not supported in MockPwiAuth.'),
      );

  @override
  Future<void> updatePhotoURL(String? photoURL) async {
    _photoURL = photoURL;
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    _displayName = displayName ?? _displayName;
    _photoURL = photoURL ?? _photoURL;
  }

  @override
  Future<void> verifyBeforeUpdateEmail(
    String newEmail, [
    ActionCodeSettings? actionCodeSettings,
  ]) async {
    _email = newEmail;
    _emailVerified = true;
  }

  @override
  String toString() => '_MockFirebaseUser(uid: $uid, email: $_email)';
}
