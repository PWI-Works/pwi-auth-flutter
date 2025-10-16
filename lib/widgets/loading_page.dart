import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:pwi_auth/widgets/loading_page_view_model.dart';

/// A loading page that cycles through different loading messages with fade transitions
class LoadingPage extends ViewWidget<LoadingPageViewModel> {
  /// Initial message to display (optional)
  final String text;

  /// Creates a loading view with cycling messages
  LoadingPage({super.key, required this.text})
      : super(builder: () => LoadingPageViewModel(text));

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
          const SizedBox(height: 8),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
