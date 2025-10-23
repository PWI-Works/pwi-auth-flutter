import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/pwi_auth.dart';

/// Example customization of [DefaultGlobalController] that adds extra state.
class MyOwnController extends DefaultGlobalController {
  MyOwnController._() : super.protected();

  /// Initializes the singleton with [MyOwnController]'s custom behavior.
  ///
  /// Apps call this instead of [DefaultGlobalController.initializeSubclass]
  /// so the wiring stays inside the subclass.
  static MyOwnController initialize({
    required String appTitle,
    PwiAuthBase? auth,
  }) => DefaultGlobalController.initializeSubclass<MyOwnController>(
    appTitle: appTitle,
    auth: auth,
    builder: ({required String appTitle, PwiAuthBase? auth}) =>
        MyOwnController._(),
  );

  /// Convenient typed accessor for the singleton instance.
  static MyOwnController get instance =>
      DefaultGlobalController.instanceAs<MyOwnController>();

  late final email = createProperty<String?>(null);

  @override
  Future<void> onSignIn(User user) async {
    email.value = user.email;
  }

  @override
  Future<void> onSignOut() async {
    print('MyOwnController signing out');
    email.value = null;
  }
}
