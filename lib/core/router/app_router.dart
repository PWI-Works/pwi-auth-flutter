import 'package:pwi_auth/core/default_global_controller.dart';
import 'package:pwi_auth/core/router/route_details.dart';
import 'package:pwi_auth/core/ui/main_scaffold.dart';
import 'package:pwi_auth/login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:pwi_auth/core/ui/fade_transition_page.dart';

//// Singleton class to manage router configuration
class AppRouter {
  // Private constructor for singleton pattern
  AppRouter._();

  /// Singleton instance of AppRouter
  static final AppRouter instance = AppRouter._();

  // Constant for the login route path
  static const String loginRoutePath = '/login';
  static const String _redirectQueryParameter = 'from';

  // Late initialization of the GoRouter instance
  late final GoRouter router = _createRouter();

  // Holds the global controller instance
  static DefaultGlobalController? _global;

  /// A list of routes that are displayed in the navigation bar and rail
  static List<RouteDetails>? _navigationRoutes;
  static bool _useNavigation = true;

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

  /// Initialize the global controller and configure how routes are displayed.
  ///
  /// When [useNavigation] is `true`, each route is rendered inside the shared
  /// [MainScaffold]. Setting it to `false` returns the route widgets directly.
  static void initialize({
    required DefaultGlobalController globalController,
    required List<RouteDetails> navigationRoutes,
    bool useNavigation = true,
  }) {
    assert(
      !useNavigation || navigationRoutes.length >= 2,
      'You must supply at least two routes when useNavigation is true.',
    );
    _global = globalController;
    _navigationRoutes = navigationRoutes;
    _useNavigation = useNavigation;
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
          final redirectUri = Uri(
            path: loginRoutePath,
            queryParameters: {
              _redirectQueryParameter: state.uri.toString(),
            },
          );
          return redirectUri.toString();
        }

        if (isSignedIn && isLoginRoute) {
          final redirectLocation =
              state.uri.queryParameters[_redirectQueryParameter];
          if (redirectLocation != null && redirectLocation.isNotEmpty) {
            final parsedRedirect = Uri.tryParse(redirectLocation);
            if (parsedRedirect != null &&
                parsedRedirect.path != loginRoutePath) {
              return redirectLocation;
            }
          }
          return defaultRoute;
        }

        return null;
      },
      // Initial location for the router
      initialLocation: _global!.isSignedIn ? defaultRoute : loginRoutePath,
      // List of routes for the router
      routes: [
        if (_useNavigation)
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
        if (!_useNavigation) ..._buildRoutesAndChildRoutes(navigationRoutes),
        GoRoute(
          // Path for the login route
          path: loginRoutePath,
          // Builder for the login route
          pageBuilder: (context, state) => FadeTransitionPage<dynamic>(
            key: state.pageKey,
            child: LoginPage(
              appTitle: global.appTitle,
              onAuthenticated: (context) {
                final redirectLocation =
                    state.uri.queryParameters[_redirectQueryParameter];
                if (redirectLocation != null &&
                    redirectLocation.isNotEmpty &&
                    Uri.tryParse(redirectLocation)?.path != loginRoutePath) {
                  context.go(redirectLocation);
                  return;
                }
                context.go(defaultRoute);
              },
              auth: _global!.auth,
            ),
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
          child: routeDetail.contextBuilder(context, state),
        ),
        // Recursively builds child routes if they exist
        routes: routeDetail.childRoutes != null
            ? _buildRoutesAndChildRoutes(routeDetail.childRoutes!)
            : [],
      );
    }).toList();
  }
}
