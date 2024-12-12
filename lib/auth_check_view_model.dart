import 'dart:async';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/pwi_auth.dart';

class AuthCheckViewModel extends ViewModel {
  late final PwiAuth _auth;
  final String authenticatedRoute;
  final String appTitle;

  late final StreamSubscription _authSubscription;
  late final StreamSubscription _errorSubscription;

  bool redirectLoopRunning = false;

  bool get isSignedIn => _auth.signedIn;

  bool get authChecked => _auth.authStatusChecked;

  String? _error;
  String? get error => _error;
  set error(String? value) {
      _error = value;
      buildView();
  }

  int _loops = 0;
  int get loops => _loops;
  set loops(int value) {
      _loops = value;
      if (_loops == 3 && !authChecked) {
      }
      buildView();
  }

  AuthCheckViewModel(
      {required this.authenticatedRoute, required this.appTitle}) {
    try {
      _auth = get<PwiAuth>();
    } catch (e) {
      throw ("PwiAuth service not initialized with Bilocators.");
    }

    _authSubscription = _auth.authStateChanges.listen((_) => buildView());
    _errorSubscription = _auth.errors.listen((errorMessage) => error = errorMessage);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _errorSubscription.cancel();
    super.dispose();
  }
}
