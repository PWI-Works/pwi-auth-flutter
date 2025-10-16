import 'package:flutter/material.dart';

/// A class that holds the details for a navigation button.
class RouteDetails {
  /// The name of the route for using GoRouter's named routes.
  final String name;

  /// The title of the navigation button.
  final String title;

  /// The icon of the navigation button.
  final IconData icon;

  /// The selected icon of the navigation button.
  final IconData? selectedIcon;

  /// The route of the navigation button.
  final String route;

  /// The widget builder for the route.
  final Widget Function(BuildContext) contextBuilder;

  /// The child routes of the specific page
  final List<RouteDetails>? childRoutes;

  /// Creates a new instance of [RouteDetails].
  ///
  /// * [title]: The title of the navigation button.
  /// * [icon]: The icon of the navigation button.
  const RouteDetails({
    required this.name,
    required this.title,
    required this.icon,
    required this.route,
    required this.contextBuilder,
    this.childRoutes,
    this.selectedIcon,
  });
}
