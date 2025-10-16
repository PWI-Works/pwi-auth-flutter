import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/core/ui/main_scaffold.dart';
import 'package:pwi_auth/login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:pwi_auth/core/ui/fade_transition_page.dart';
import 'package:pwi_auth/data/models/route_details.dart';

//// Singleton class to manage router configuration
class AppRouter {
  // Private constructor for singleton pattern
  AppRouter._();

  /// Singleton instance of AppRouter
  static final AppRouter instance = AppRouter._();

  // Constant for the login route path
  static const String loginRoutePath = '/login';

  // Late initialization of the GoRouter instance
  late final GoRouter router = _createRouter();

  // Holds the global controller instance
  static DefaultGlobalController? _global;

  /// A list of routes that are displayed in the navigation bar and rail
  static List<RouteDetails>? _navigationRoutes;

  /// The global controller instance, used internally to force initialization
  DefaultGlobalController get global {
    final g = _global;
    if (g == null) {
      throw StateError(
          'AppRouter has not been initialized with a GlobalControllerInterface. Call AppRouter.initialize() first.');
    }
    return g;
  }

  /// The navigation routes, used internally to force initialization
  List<RouteDetails> get navigationRoutes {
    final routes = _navigationRoutes;
    if (routes == null) {
      throw StateError(
          'AppRouter has not been initialized with navigation routes. Call AppRouter.initialize() first.');
    }
    if (routes.isEmpty) {
      throw StateError(
          'AppRouter navigation routes cannot be empty. Please provide at least one route.');
    }
    return routes;
  }

  /// Initialize the global controller. Should be called at app startup.
  static void initialize({
    required DefaultGlobalController globalController,
    required List<RouteDetails> navigationRoutes,
  }) {
    _global = globalController;
    _navigationRoutes = navigationRoutes;
  }

  /// Creates and configures the GoRouter instance
  GoRouter _createRouter() {
    final defaultRoute = navigationRoutes.first.route;

    return GoRouter(
      refreshListenable: global,
      redirect: (context, state) {
        final isSignedIn = global.isSignedIn;
        final isLoginRoute = state.uri.path == loginRoutePath;

        if (!isSignedIn && !isLoginRoute) {
          return loginRoutePath;
        }

        if (isSignedIn && isLoginRoute) {
          return defaultRoute;
        }

        return null;
      },
      // Initial location for the router
      initialLocation: _global!.isSignedIn ? defaultRoute : loginRoutePath,
      // List of routes for the router
      routes: [
        ShellRoute(
          // Page builder for the shell route
          pageBuilder: (context, state, child) => FadeTransitionPage<dynamic>(
            key: state.pageKey,
            child: MainScaffold(
              // Determines the selected index based on the current path
              selectedIndex: navigationRoutes.indexWhere((routeDetail) =>
                  state.uri.path.startsWith(routeDetail.route)),
              child: child,
            ),
          ),
          // Builds the routes and their child routes
          routes: _buildRoutesAndChildRoutes(navigationRoutes),
        ),
        GoRoute(
          // Path for the login route
          path: loginRoutePath,
          // Builder for the login route
          pageBuilder: (context, state) => FadeTransitionPage<dynamic>(
            key: state.pageKey,
            child: LoginPage(
                appTitle: global.appTitle,
                onAuthenticated: (context) => context.go(defaultRoute)),
          ),
        )
      ],
    );
  }

  /// Builds the routes and their child routes recursively
  List<GoRoute> _buildRoutesAndChildRoutes(List<RouteDetails> routes) {
    return routes.map((routeDetail) {
      return GoRoute(
        // name for the route
        name: routeDetail.name,
        // Path for the route
        path: routeDetail.route,
        // Page builder for the route
        pageBuilder: (context, state) => FadeTransitionPage<dynamic>(
          key: state.pageKey,
          child: routeDetail.contextBuilder(context),
        ),
        // Recursively builds child routes if they exist
        routes: routeDetail.childRoutes != null
            ? _buildRoutesAndChildRoutes(routeDetail.childRoutes!)
            : [],
      );
    }).toList();
  }
}
