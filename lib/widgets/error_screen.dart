import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'info_card.dart';

/// A stateless widget that displays an error message on the screen.
class ErrorScreen extends StatelessWidget {
  /// The error message to be displayed.
  final String message;

  /// Email address used by the support contact button.
  final String? supportEmailAddress;

  /// Subject line used by the support contact button.
  final String? supportEmailSubject;

  /// Body used by the support contact button.
  final String? supportEmailBody;

  /// Label shown on the support contact button.
  final String supportButtonLabel;

  /// Creates an [ErrorScreen] widget.
  ///
  /// The [message] parameter is required and must not be null.
  const ErrorScreen({
    super.key,
    required this.message,
    this.supportEmailAddress,
    this.supportEmailSubject,
    this.supportEmailBody,
    this.supportButtonLabel = 'Email Support',
  });

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
                bottomWidget: supportEmailAddress != null &&
                        supportEmailAddress!.isNotEmpty
                    ? FilledButton.icon(
                        onPressed: _emailSupport,
                        icon: const Icon(Icons.email_outlined),
                        label: Text(supportButtonLabel),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _emailSupport() async {
    if (supportEmailAddress?.isEmpty ?? true) {
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: supportEmailAddress!,
      queryParameters: {
        if (supportEmailSubject != null) 'subject': supportEmailSubject,
        if (supportEmailBody != null) 'body': supportEmailBody,
      },
    );

    await launchUrl(uri);
  }
}
