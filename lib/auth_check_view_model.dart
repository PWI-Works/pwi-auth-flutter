import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/pwi_auth.dart';

class AuthCheckViewModel extends ViewModel {
  late final PwiAuth _auth;
  final String authenticatedRoute;
  final String appTitle;

  bool? _isSignedIn;
  bool? get isSignedIn => _isSignedIn;

  bool skipAuthCheck = false;

  AuthCheckViewModel({required this.authenticatedRoute, required this.appTitle}) {
    try {
      _auth = get<PwiAuth>();
    } catch (e) {
      throw ("PwiAuth service not initialized with Bilocators.");
    }
    _isSignedIn = _auth.signedIn;
  }
}
