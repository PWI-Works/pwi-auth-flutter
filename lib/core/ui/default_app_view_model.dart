import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/default_global_controller.dart';

/// AppViewModel is primarily responsible for managing the theme mode.
class DefaultAppViewModel extends ViewModel {
  DefaultGlobalController get controller => DefaultGlobalController.instance;

  late final themeMode = createProperty<ThemeMode>(controller.themeMode.value);

  String get appTitle => controller.appTitle;

  DefaultAppViewModel() {
    controller.themeMode.addListener(_setThemeMode);
  }

  void _setThemeMode() {
    themeMode.value = controller.themeMode.value;
  }

  @override
  dispose() {
    controller.themeMode.removeListener(_setThemeMode);
    super.dispose();
  }
}
