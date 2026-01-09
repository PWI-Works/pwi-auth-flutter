import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pwi_auth/semantic_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum representing the different display types for the [InfoCard].
enum InfoCardDisplayType {
  /// Error display type.
  /// Uses error color.
  error,

  /// Warning display type.
  /// Uses warning color from semantic palette.
  warning,

  /// Normal display type.
  /// Uses tertiary color.
  normal,

  /// Themed low display type.
  /// Uses secondary container color.
  themedLow,

  /// Low display type.
  /// Uses surface container highest color.
  low,

  /// Success display type.
  /// Uses success color from semantic palette.
  success,
}

/// A widget that displays an informational card with a message.
///
/// The [InfoCard] widget displays a card with a message and an icon. The appearance
/// of the card can be customized using the [useStandardCardMargin] and [displayType] properties.
class InfoCard extends StatelessWidget {
  /// The message to display inside the card.
  final String message;

  /// Whether to use the standard margin for the card.
  ///
  /// If set to false, the card will have zero margin.
  final bool useStandardCardMargin;

  /// The display type of the card, which affects its background and text colors.
  /// Defaults to [InfoCardDisplayType.normal].
  /// See [InfoCardDisplayType] for more information.
  final InfoCardDisplayType displayType;

  /// Optional override for icon to display alongside the message.
  final Icon? icon;

  /// Optional link text to display after the message.
  final String? link;

  /// Creates an [InfoCard] widget.
  ///
  /// The [message] parameter is required. The [useStandardCardMargin] parameter defaults
  /// to false, and the [displayType] parameter defaults to [InfoCardDisplayType.normal].
  /// The [icon] parameter is optional and can be used to override the default icon. If not provided,
  /// the icon will be determined based on the [displayType].
  /// If [link] is provided, it is appended to the message as a clickable hyperlink.
  const InfoCard({
    super.key,
    required this.message,
    this.useStandardCardMargin = false,
    this.displayType = InfoCardDisplayType.normal,
    this.icon,
    this.link,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedLink = link?.trim();
    final hasLink = trimmedLink != null && trimmedLink.isNotEmpty;
    final textColor = _getTextColor(context);

    return Card(
      margin: useStandardCardMargin ? null : EdgeInsets.zero,
      elevation: 0,
      color: _getBackgroundColor(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: _getTextColor(context),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: hasLink
                  ? RichText(
                      text: TextSpan(
                        style: TextStyle(color: textColor),
                        children: [
                          TextSpan(text: message),
                          TextSpan(
                            text: ' $trimmedLink',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(Uri.parse(trimmedLink)),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      message,
                      style: TextStyle(color: textColor),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    // If an icon override is provided, use it
    if (icon != null) {
      return icon!.icon!;
    }

    // Otherwise, select icon based on display type
    switch (displayType) {
      case InfoCardDisplayType.error:
        return Icons.error_outline;
      case InfoCardDisplayType.warning:
        return Icons.warning_amber_outlined;
      case InfoCardDisplayType.success:
        return Icons.check_circle_outline;
      default:
        return Icons.info_outlined;
    }
  }

  /// Gets the background color for the card based on the [displayType].
  ///
  /// - Parameter context: The build context.
  /// - Returns: The background color for the card.
  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (displayType) {
      case InfoCardDisplayType.error:
        return colorScheme.error;
      case InfoCardDisplayType.warning:
        return SemanticColors.warning.background;
      case InfoCardDisplayType.normal:
        return colorScheme.tertiary;
      case InfoCardDisplayType.themedLow:
        return colorScheme.secondaryContainer;
      case InfoCardDisplayType.low:
        return colorScheme.surfaceContainerHighest;
      case InfoCardDisplayType.success:
        return SemanticColors.greenSeniority.background;
    }
  }

  /// Gets the text color for the card based on the [displayType].
  ///
  /// - Parameter context: The build context.
  /// - Returns: The text color for the card.
  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (displayType) {
      case InfoCardDisplayType.error:
        return colorScheme.onError;
      case InfoCardDisplayType.warning:
        return SemanticColors.warning.foreground;
      case InfoCardDisplayType.normal:
        return colorScheme.onTertiary;
      case InfoCardDisplayType.themedLow:
        return colorScheme.onSecondaryContainer;
      case InfoCardDisplayType.low:
        return colorScheme.onSurface;
      case InfoCardDisplayType.success:
        return SemanticColors.greenSeniority.foreground;
    }
  }
}
