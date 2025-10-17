import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwi_auth/core/default_global_controller.dart';

class MyOwnController extends DefaultGlobalController {
  //TODO fix this so that it works with the singleton pattern and either reuses the default factory contsructor or allows overrides


  late final email = createProperty<String?>(null);

  @override
  Future<void> onSignIn(User user) async {
    email.value = user.email;
  }
}
