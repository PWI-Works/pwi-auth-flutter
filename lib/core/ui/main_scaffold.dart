// lib/ui/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/core/global_controller_interface.dart';
import 'package:pwi_auth/core/router/app_router.dart';
import 'main_scaffold_view_model.dart';

/// Persistent shell: left nav + right content.
/// Uses custom_adaptive_scaffold for adaptive navigation and delegates.
class MainScaffold extends ViewWidget<MainScaffoldViewModel> {
  final Widget? child;
  final int selectedIndex;

  MainScaffold({
    super.key,
    this.child,
    required this.selectedIndex,
  }) : super(builder: () => MainScaffoldViewModel());

  @override
  Widget build(BuildContext context) {
    if (!viewModel.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Column(
      children: [
        Expanded(
          child: AdaptiveScaffold(
            // Keep transitions instant for this shell.
            transitionDuration: Duration.zero,

            // Selected nav index and change handler live in the VM.
            selectedIndex: selectedIndex,
            onSelectedIndexChange: viewModel.onSelectedIndexChange,
  
              // Provide destinations with icons/titles from route definitions.
            destinations: AppRouter.instance.navigationRoutes
                .map(
                  (route) => CustomNavigationDestination(
                    icon: Icon(route.icon),
                    selectedIcon: Icon(route.selectedIcon ?? route.icon),
                    label: route.title,
                  ),
                )
                .toList(),

            // Show the child content (managed by go_router).
            body: (context) => child ?? const SizedBox.shrink(),
            smallBody: (context) => child ?? const SizedBox.shrink(),
            mediumLargeBody: (context) => child ?? const SizedBox.shrink(),
            largeBody: (context) => child ?? const SizedBox.shrink(),
            extraLargeBody: (context) => child ?? const SizedBox.shrink(),

            useDrawer: false,
          ),
        ),
      ],
    );
  }
}
