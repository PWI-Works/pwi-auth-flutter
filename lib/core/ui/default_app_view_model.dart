import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/default_global_controller.dart';

/// AppViewModel is primarily responsible for managing the theme mode.
class DefaultAppViewModel extends ViewModel {
  DefaultGlobalController get controller => DefaultGlobalController.instance;

  ThemeMode get themeMode => DefaultGlobalController.instance.themeMode.value;

  String get appTitle => controller.appTitle;

  DefaultAppViewModel() {
    controller.themeMode.addListener(() => buildView());
  }

  @override
  dispose() {
    controller.themeMode.removeListener(() => buildView());
    super.dispose();
  }
}
