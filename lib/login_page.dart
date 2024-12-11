import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:pwi_auth/pwi_auth.dart';

class LoginPage extends StatelessWidget {
  final PwiAuth _auth = PwiAuth(useSessionCookie: !kDebugMode);

  final String title;
  final String onSignInRoute;

  LoginPage({super.key, required this.title, required this.onSignInRoute});

  Future<String?> _signInWithCredentials(LoginData data) async {
    try {
      await _auth.signIn(email: data.name, password: data.password);
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
      await _auth.signUp(
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
      await _auth.signInWithGoogle();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: title,
      logo: const AssetImage('assets/images/pwi_logo.png'),
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
      loginProviders: <LoginProvider>[
        LoginProvider(
          button: Buttons.google,
          label: 'Sign in with Google',
          callback: () async {
            await _signInWithGoogle();
            return;
          },
        ),
      ],
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(onSignInRoute);
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}