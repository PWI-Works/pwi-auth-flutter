import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/default_global_controller.dart';

/// AppViewModel is primarily responsible for managing the theme mode.
class DefaultAppViewModel extends ViewModel {
  /// Provides a shortcut to the global controller shared across the app.
  DefaultGlobalController get controller => DefaultGlobalController.instance;

  /// Local view-model property that mirrors the controller's theme mode.
  /// It keeps the UI responsive to theme changes triggered elsewhere.
  late final themeMode = createProperty<ThemeMode>(controller.themeMode.value);

  /// Exposes the configured application title for UI widgets.
  String get appTitle => controller.appTitle;

  DefaultAppViewModel() {
    // Keep this view-model in sync whenever the global theme mode changes.
    controller.themeMode.addListener(_setThemeMode);
  }

  void _setThemeMode() {
    themeMode.value = controller.themeMode.value;
  }

  @override
  dispose() {
    // Avoid leaking listeners when the view-model is disposed.
    controller.themeMode.removeListener(_setThemeMode);
    super.dispose();
  }
}
