import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:pwi_auth/core/global_controller_interface.dart';
import 'package:pwi_auth/core/router/app_router.dart';

/// ViewModel for the main scaffold of the application.
class MainScaffoldViewModel extends ViewModel {
  final GlobalControllerInterface _global = GlobalControllerInterface.instance;

  // Default tab to show if path doesn't match any known route
  static const int _defaultTab = 1; // Categories tab

  MainScaffoldViewModel() {
    _global.addListener(notifyListeners);
  }

  /// DI: Router service to keep go_router calls out of Views.
  late final GoRouter _router = AppRouter.instance.router;

  /// Check if the app is loaded.
  bool get loaded => _global.isSignedIn;

  /// Called when the user selects a different destination in the nav.
  void onSelectedIndexChange(int index) {
    final routes = AppRouter.instance.navigationRoutes;
    if (index >= 0 && index < routes.length) {
      _router.goNamed(routes[index].name);
    } else {
      // Default to first route
      _router.goNamed(routes[0].name);
    }
  }

  /// Maps the current path to the selected tab index.
  static int indexForPath(String path) {
    final routes = AppRouter.instance.navigationRoutes;
    for (int i = 0; i < routes.length; i++) {
      if (path.startsWith(routes[i].route)) {
        return i;
      }
    }
    return _defaultTab;
  }

  @override
  void dispose() {
    _global.removeListener(notifyListeners);
    super.dispose();
  }
}
