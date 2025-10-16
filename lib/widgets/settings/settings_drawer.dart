// lib\ui\settings\settings_drawer.dart

import 'package:flutter/material.dart';
import 'package:pwi_auth/widgets/settings/settings_page.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 350,
      child: SettingsPage(),
    );
  }
}
