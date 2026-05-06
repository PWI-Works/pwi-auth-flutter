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

  Future<String?> _signInWithMicrosoft() async {
    try {
      await auth.signInWithMicrosoft();
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
                callback: () async {
                  await _signInWithGoogle();
                  return;
                },
              ),
              LoginProvider(
                icon: FontAwesomeIcons.microsoft,
                label: 'Microsoft',
                callback: () async {
                  await _signInWithMicrosoft();
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
