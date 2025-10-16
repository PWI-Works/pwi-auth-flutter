// app_view_model.dart

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/global_controller_interface.dart';

/// AppViewModel is primarily responsible for managing the theme mode.
class AppViewModel extends ViewModel {
  DefaultGlobalController get controller => DefaultGlobalController.instance;

  ThemeMode get themeMode => DefaultGlobalController.instance.themeMode.value;

  String get appTitle => controller.appTitle;

  AppViewModel() {
    controller.themeMode.addListener(() => buildView());
  }

  @override
  dispose() {
    controller.themeMode.removeListener(() => buildView());
    super.dispose();
  }
}
