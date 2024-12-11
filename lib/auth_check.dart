import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'auth_check_view_model.dart';

import 'login_page.dart';

class AuthCheck extends ViewWidget<AuthCheckViewModel> {
  AuthCheck(
      {super.key,
      required String authenticatedRoute,
      required String appTitle})
      : super(
            builder: () => AuthCheckViewModel(
                authenticatedRoute: authenticatedRoute,
                appTitle: appTitle));

  void _waitCheckAuth() async {
    if (!viewModel.authChecked) {
      // wait for auth check to complete
      await Future.delayed(const Duration(milliseconds: 300), _waitCheckAuth);
      return;
    }

    switch (viewModel.isSignedIn) {
      case true:
        Navigator.of(context)
            .pushReplacementNamed(viewModel.authenticatedRoute);
        break;
      case false:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginPage(
              title: viewModel.appTitle,
              onSignInRoute: viewModel.authenticatedRoute,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
