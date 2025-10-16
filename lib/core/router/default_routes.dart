import 'package:flutter/material.dart' show Icons;
import 'package:pwi_auth/core/router/route_details.dart';

class DefaultRoutes {
  
  static const String settingsRouteName = "settings";

  static RouteDetails settings = RouteDetails(
    name: settingsRouteName,
    title: 'Settings',
    icon: Icons.settings,
    route: '/settings',
    contextBuilder: (context) => SettingsPage(),
  );
}
