// lib/app.dart

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/router/app_router.dart';
import 'package:pwi_auth/core/ui/app_view_model.dart';
import 'package:pwi_auth/themes/blue_theme.dart';
import 'package:pwi_auth/themes/green_theme.dart';
import 'package:pwi_auth/themes/purple_theme.dart';
import 'package:pwi_auth/themes/red_theme.dart';
import 'package:pwi_auth/themes/themes.dart';

/// The main application widget that sets up the router and theme.
class App extends ViewWidget<AppViewModel> {
  final Themes selectedTheme;

  /// Constructor for the App widget.
  App({super.key, required this.selectedTheme})
      : super(builder: () => AppViewModel());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: viewModel.appTitle,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: viewModel.themeMode,
      routerConfig: AppRouter.instance.router,
    );
  }

  ThemeData get _lightTheme => switch (selectedTheme) {
        Themes.purple => PurpleTheme.light,
        Themes.blue => BlueTheme.light,
        Themes.green => GreenTheme.light,
        Themes.red => RedTheme.light,
      };

  ThemeData get _darkTheme => switch (selectedTheme) {
        Themes.purple => PurpleTheme.dark,
        Themes.blue => BlueTheme.dark,
        Themes.green => GreenTheme.dark,
        Themes.red => RedTheme.dark,
      };
}
