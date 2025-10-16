// lib\ui\settings\settings_drawer_view_model.dart

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/pwi_auth.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class SettingsPageViewModel extends ViewModel {
  DefaultGlobalController get global => DefaultGlobalController.instance;
  final signOutButtonController = RoundedLoadingButtonController();

  bool _loaded = false;

  bool get loaded => _loaded;

  set loaded(bool value) {
    _loaded = value;
    buildView();
  }

  SettingsPageViewModel() {
    global.themeMode.addListener(() => buildView());
  }

  ThemeMode get currentTheme => global.themeMode.value;

  set currentTheme(ThemeMode value) {
    global.themeMode.value = value;
    buildView();
  }

  Future<void> signOut() async {
    signOutButtonController.start();
    try {
      await PwiAuth().signOut();
      signOutButtonController.success();
    } catch (e) {
      signOutButtonController.error();
      return;
    }
  }

  @override
  void dispose() {
    global.themeMode.removeListener(() => buildView());
    super.dispose();
  }
}
