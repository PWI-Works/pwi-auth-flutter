/// The PwiAuth library provides authentication functionalities for the PWI application.
library pwi_auth;

import 'dart:async';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/pwi_auth.dart';

class AuthCheckViewModel extends ViewModel {
  late final PwiAuth _auth;
  final String authenticatedRoute;
  final String appTitle;
  final bool useGoRouter;

  late final StreamSubscription _authSubscription;
  late final StreamSubscription _errorSubscription;

  bool _redirectLoopRunning = false;

  bool get redirectLoopRunning => _redirectLoopRunning;

  set redirectLoopRunning(bool value) {
    _redirectLoopRunning = value;
    buildView();
  }

  bool get isSignedIn => _auth.signedIn;

  bool get authChecked => _auth.authStatusChecked;

  String? _error;

  String? get error => _error;

  set error(String? value) {
    _error = value;
    buildView();
  }

  int _waitAuthCheckLoops = 0;

  int get waitAuthCheckLoops => _waitAuthCheckLoops;

  set waitAuthCheckLoops(int value) {
    _waitAuthCheckLoops = value;
    if (_waitAuthCheckLoops % 3 == 0 && !authChecked) {
      _auth.forceCheckAuth();
    }
    buildView();
  }

  AuthCheckViewModel({
    required this.authenticatedRoute,
    required this.appTitle,
    required this.useGoRouter,
  }) {
    try {
      _auth = get<PwiAuth>();
    } catch (e) {
      throw ("PwiAuth service not initialized with Bilocators.");
    }

    _authSubscription = _auth.authStateChanges.listen((_) => buildView());
    _errorSubscription =
        _auth.errors.listen((errorMessage) => error = errorMessage);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _errorSubscription.cancel();
    super.dispose();
  }
}
