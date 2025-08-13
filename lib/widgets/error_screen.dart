import 'package:flutter/material.dart';
import 'info_card.dart';

/// A stateless widget that displays an error message on the screen.
class ErrorScreen extends StatelessWidget {
  /// The error message to be displayed.
  final String message;

  /// Creates an [ErrorScreen] widget.
  ///
  /// The [message] parameter is required and must not be null.
  const ErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: SizedBox(
              width: 300,
              child: InfoCard(
                message: message,
                displayType: InfoCardDisplayType.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
