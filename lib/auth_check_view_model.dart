import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/pwi_auth.dart';

class AuthCheckViewModel extends ViewModel {
  late final PwiAuth _auth;
  final String authenticatedRoute;
  final String appTitle;

  bool redirectLoopRunning = false;

  bool get isSignedIn => _auth.signedIn;
  bool get authChecked => _auth.authStatusChecked;

  AuthCheckViewModel({required this.authenticatedRoute, required this.appTitle}) {
    try {
      _auth = get<PwiAuth>();
    } catch (e) {
      throw ("PwiAuth service not initialized with Bilocators.");
    }
  }
}
