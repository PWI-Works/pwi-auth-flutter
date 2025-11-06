import 'package:flutter/material.dart';
import 'package:pwi_auth/core/router/app_router.dart';
import 'package:pwi_auth/core/router/route_details.dart';
import 'package:pwi_auth/widgets/error_screen.dart';
import 'package:pwi_auth/widgets/info_card.dart';
import 'package:pwi_auth/widgets/loading_page.dart';
import 'package:pwi_auth/core/ui/default_app.dart';
import 'package:pwi_auth/themes/themes.dart';
import 'package:pwi_auth/core/router/default_routes.dart';
import 'package:pwi_auth/widgets/page_scaffold.dart';
import 'my_own_controller.dart';
import 'mock_pwi_auth.dart';

void main() {
  // Initialize the global controller before running the app
  MyOwnController.initialize(
    appTitle: 'Flutter Demo',
    auth: MockPwiAuth(signedIn: false),
  );

  AppRouter.initialize(
    globalController: MyOwnController.instance,
    navigationRoutes: [
      RouteDetails(
        name: "loading",
        title: 'Loading',
        icon: Icons.hourglass_empty,
        route: '/loading',
        contextBuilder: (context, _) => const LoadingPageScreen(),
      ),
      RouteDetails(
        name: "error",
        title: 'Error',
        icon: Icons.error_outline,
        route: '/error',
        contextBuilder: (context, _) => const ErrorPageScreen(),
      ),
      RouteDetails(
        name: "info",
        title: 'Info Widgets',
        icon: Icons.info_outline,
        route: '/info',
        contextBuilder: (context, _) => const InfoWidgets(),
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
      title: "Loading Widget Demo",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 24.0,
            ),
            child: Text(
              'The Loading Page shows an optional initial message and then cycles through a series of '
              'predefined messages. This gives users better confidence that something is actually '
              'happening, and keeps the wait interesting.\n\n'
              'If during debugging you start to see the messages repeating, it could indicate that there '
              'is an error behind the scenes that needs to be addressed.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: LoadingPage(initialMessage: 'Loading...')),
        ],
      ),
    );
  }
}

class ErrorPageScreen extends StatelessWidget {
  const ErrorPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Error Widget Demo",
      body: ErrorScreen(
        message:
            "This is an error screen. It uses animations to draw attention.",
      ),
    );
  }
}

class InfoWidgets extends StatelessWidget {
  const InfoWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Info Widgets Demo",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            InfoCard(
              message:
                  "This is a normal info card. This is the default display type. Use this in most scenarios.",
              useStandardCardMargin: true,
            ),
            InfoCard(
              message:
                  "This is a low info card. Use this for information of lesser importance.",
              displayType: InfoCardDisplayType.low,
              useStandardCardMargin: true,
            ),
            InfoCard(
              message:
                  "This is a themed low info card. Use this for information of medium importance.",
              displayType: InfoCardDisplayType.themedLow,
              useStandardCardMargin: true,
            ),
            InfoCard(
              message:
                  "This is a warning info card. Use this for situations that require attention.",
              displayType: InfoCardDisplayType.warning,
              useStandardCardMargin: true,
            ),
            InfoCard(
              message:
                  "This is an error info card. Use this for displaying errors.",
              displayType: InfoCardDisplayType.error,
              useStandardCardMargin: true,
            ),
          ],
        ),
      ),
    );
  }
}
