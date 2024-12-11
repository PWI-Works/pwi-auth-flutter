import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/utils.dart';
import 'auth_check_view_model.dart';

import 'login_page.dart';

class AuthCheck extends ViewWidget<AuthCheckViewModel> {
  AuthCheck(
      {super.key,
      required String authenticatedRoute,
      required String appTitle, bool loggingEnabled = false})
      : super(
            builder: () => AuthCheckViewModel(
                authenticatedRoute: authenticatedRoute,
                appTitle: appTitle)){
    if (!enableLogs) {
      enableLogs = loggingEnabled;
    }
  }

  void _waitCheckAuth() async {
    if (!viewModel.authChecked) {
      // wait for auth check to complete
      await Future.delayed(const Duration(milliseconds: 300), _waitCheckAuth);
      return;
    }

    switch (viewModel.isSignedIn) {
      case true:
        log("User is signed in, redirecting to ${viewModel.authenticatedRoute}");
        Navigator.of(context)
            .pushReplacementNamed(viewModel.authenticatedRoute);
        break;
      case false:
        log("User is not signed in, redirecting to login page");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(
              appTitle: viewModel.appTitle,
              authenticatedRoute: viewModel.authenticatedRoute,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    log("building AuthCheck view, redirectLoopRunning: ${viewModel.redirectLoopRunning}, authChecked: ${viewModel.authChecked}, isSignedIn: ${viewModel.isSignedIn}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!viewModel.redirectLoopRunning) {
        viewModel.redirectLoopRunning = true;
        _waitCheckAuth();
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
