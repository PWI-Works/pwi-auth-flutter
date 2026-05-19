/// The PwiAuth library provides authentication functionalities for the PWI application.
library pwi_auth;

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pwi_auth/pwi_auth.dart';

class LoginPage extends StatelessWidget {
  final PwiAuthBase auth;

  final String appTitle;
  final void Function(BuildContext context) onAuthenticated;

  const LoginPage({
    super.key,
    required this.appTitle,
    required this.onAuthenticated,
    required this.auth,
  });

  Future<String?> _runAuthAction(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signInWithCredentials(LoginData data) async {
    return _runAuthAction(
      () => auth.signIn(email: data.name, password: data.password),
    );
  }

  Future<String?> _signUp(SignupData data) async {
    if (data.name == null || data.password == null) {
      return Future.value('Invalid username or password');
    }

    return _runAuthAction(
      () => auth.signUp(
          email: data.name!,
          password: data.password!,
          firstName: data.additionalSignupData?["firstName"] ?? "Unknown",
          lastName: data.additionalSignupData?["lastName"] ?? "Unknown"),
    );
  }

  Future<String?> _signInWithGoogle() async {
    return _runAuthAction(auth.signInWithGoogle);
  }

  Future<String?> _signInWithMicrosoft() async {
    return _runAuthAction(auth.signInWithMicrosoft);
  }

  Future<String?> _recoverPassword(String email) async {
    return _runAuthAction(() => auth.sendPasswordResetEmail(email));
  }

  @override
  Widget build(BuildContext context) {
    final showSocialLogin = Uri.base.host.contains('pwiworks.app') ||
        Uri.base.host.contains('localhost');

    return FlutterLogin(
      title: appTitle,
      logo: const AssetImage(
          'packages/pwi_auth/assets/images/pwi-shield-white-space.png'),
      onLogin: _signInWithCredentials,
      onSignup: _signUp,
      additionalSignupFields: const [
        UserFormField(keyName: "firstName", displayName: "First Name"),
        UserFormField(keyName: "lastName", displayName: "Last Name"),
      ],
      messages: LoginMessages(
        passwordHint: "PWI Apps Password",
        recoverPasswordButton: "Reset Password",
        recoverPasswordIntro: "Enter your email to reset your password.",
        recoverPasswordDescription:
            'If you already have an account with us, we\'ll send you an email to reset your password.',
        providersTitleFirst: "or",
      ),
      theme: LoginTheme(
        providerButtonPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      loginProviders: showSocialLogin
          ? <LoginProvider>[
              LoginProvider(
                icon: FontAwesomeIcons.google,
                label: 'Google',
                callback: () => _signInWithGoogle(),
              ),
              LoginProvider(
                icon: FontAwesomeIcons.microsoft,
                label: 'Microsoft',
                callback: () => _signInWithMicrosoft(),
              ),
            ]
          : [],
      onSubmitAnimationCompleted: () => onAuthenticated(context),
      onRecoverPassword: _recoverPassword,
    );
  }
}
