import 'package:flutter/material.dart' show Icons;
import 'package:pwi_auth/core/router/route_details.dart';
import 'package:pwi_auth/widgets/settings/settings_page.dart';

class DefaultRoutes {
  // name of the settings route
  static String get settingsRouteName => settings.name;

  // default routes for the settings page
  static RouteDetails settings = RouteDetails(
    name: "settings",
    title: 'Settings',
    icon: Icons.settings,
    route: '/settings',
    contextBuilder: (context) => SettingsPage(),
  );
}
