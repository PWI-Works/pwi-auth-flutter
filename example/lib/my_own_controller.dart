import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwi_auth/core/default_global_controller.dart';

class MyOwnController extends DefaultGlobalController {
  //MyOwnController({super.appTitle});

  late final email = createProperty<String?>(null);

  @override
  Future<void> onSignIn(User user) async {
    email.value = user.email;
  }
}
