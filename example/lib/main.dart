import 'package:flutter/material.dart';
import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/core/router/app_router.dart';
import 'package:pwi_auth/core/router/route_details.dart';
import 'package:pwi_auth/widgets/error_screen.dart';
import 'package:pwi_auth/widgets/loading_page.dart';
import 'package:pwi_auth/core/ui/default_app.dart';
import 'package:pwi_auth/themes/themes.dart';
import 'package:pwi_auth/core/router/default_routes.dart';
import 'package:pwi_auth/widgets/page_scaffold.dart';
import 'mock_pwi_auth.dart';

// todo fix the background color for the navigation bar

void main() {
  // Initialize the global controller before running the app
  DefaultGlobalController(appTitle: 'Flutter Demo', auth: MockPwiAuth());

  AppRouter.initialize(
    globalController: DefaultGlobalController.instance,
    navigationRoutes: [
      RouteDetails(
        name: "loading",
        title: 'Loading',
        icon: Icons.hourglass_empty,
        route: '/loading',
        contextBuilder: (context) => const LoadingPageScreen(),
      ),
      RouteDetails(
        name: "error",
        title: 'Error',
        icon: Icons.error,
        route: '/error',
        contextBuilder: (context) => const ErrorPageScreen(),
      ),
      DefaultRoutes.settings,
    ],
  );

  runApp(DefaultApp(selectedTheme: Themes.purple));
}

class LoadingPageScreen extends StatelessWidget {
  const LoadingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Loading Page",
      body: LoadingPage(initialMessage: 'Loading...'),
    );
  }
}

class ErrorPageScreen extends StatelessWidget {
  const ErrorPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Error Page",
      body: ErrorScreen(message: "An error has occurred."),
    );
  }
}
