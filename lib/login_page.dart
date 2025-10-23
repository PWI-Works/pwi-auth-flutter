/// The PwiAuth library provides authentication functionalities for the PWI application.
library pwi_auth;

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
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

  Future<String?> _signInWithCredentials(LoginData data) async {
    try {
      await auth.signIn(email: data.name, password: data.password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signUp(SignupData data) async {
    if (data.name == null || data.password == null) {
      return Future.value('Invalid username or password');
    }

    try {
      await auth.signUp(
          email: data.name!,
          password: data.password!,
          firstName: data.additionalSignupData?["firstName"] ?? "Unknown",
          lastName: data.additionalSignupData?["lastName"] ?? "Unknown");
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signInWithGoogle() async {
    try {
      await auth.signInWithGoogle();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showGoogleLogin = Uri.base.host.contains('pwiworks.app') ||
        Uri.base.host.contains('localhost');

    return FlutterLogin(
      title: appTitle,
      logo: const AssetImage('packages/pwi_auth/assets/images/pwi_logo.png'),
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
      loginProviders: showGoogleLogin
          ? <LoginProvider>[
              LoginProvider(
                button: Buttons.google,
                label: 'Sign in with Google',
                callback: () async {
                  await _signInWithGoogle();
                  return;
                },
              ),
            ]
          : [],
      onSubmitAnimationCompleted: () => onAuthenticated(context),
      onRecoverPassword: _recoverPassword,
    );
  }
}
