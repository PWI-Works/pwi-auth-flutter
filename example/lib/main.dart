import 'package:flutter/material.dart';
import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/core/router/app_router.dart';
import 'package:pwi_auth/core/router/route_details.dart';
import 'package:pwi_auth/widgets/loading_page.dart';
import 'package:pwi_auth/core/ui/default_app.dart';
import 'package:pwi_auth/themes/themes.dart';
import 'package:pwi_auth/core/router/default_routes.dart';
import 'mock_pwi_auth.dart';

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
        contextBuilder: (context) => const MyHomePage(title: 'Loading Page'),
      ),
      DefaultRoutes.settings,
    ],
  );

  runApp(DefaultApp(selectedTheme: Themes.purple));
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: LoadingPage(initialMessage: 'Loading...'),
    );
  }
}
