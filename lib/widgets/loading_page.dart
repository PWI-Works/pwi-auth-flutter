import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/widgets/loading_page_view_model.dart';

/// A loading page that cycles through different loading messages with fade transitions
class LoadingPage extends ViewWidget<LoadingPageViewModel> {
  /// Creates a loading view with an optional initial message and then with cycling messages.
  ///
  /// This widget cycles through predefined messages. This gives users better confidence that something is actually
  /// happening, and keeps the wait interesting.
  ///
  /// If during debugging you start to see the messages repeating, it could indicate that there
  /// is an error behind the scenes that needs to be addressed.
  LoadingPage({super.key, String? initialMessage})
      : super(builder: () => LoadingPageViewModel(initialMessage));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated text with fade in/out effect
          AnimatedOpacity(
            opacity: viewModel.isTransitioning.value ? 0.0 : 1.0,
            duration: viewModel.transitionDuration,
            child: Text(
              viewModel.currentMessage.value,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
