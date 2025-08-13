import 'package:flutter/material.dart';

/// A widget representing an item in a grid.
///
/// The [GridItem] widget can display a title, a body widget, or body text.
/// It requires the number of grid units it occupies to be specified.
class GridItem extends StatelessWidget {
  /// The title of the grid item.
  final String? title;

  /// The style to apply to the title text.
  /// Defaults to Theme.of(context).textTheme.labelMedium.
  final TextStyle? titleStyle;

  /// The widget to display as the body of the grid item.
  final Widget? bodyWidget;

  /// The text to display as the body of the grid item.
  final String? bodyText;

  /// The style to apply to the body text.
  /// Defaults to Theme.of(context).textTheme.bodyLarge.
  final TextStyle? bodyTextStyle;

  /// The number of grid units the item occupies.
  ///
  /// Must be at least 1.
  final int gridUnits;

  /// Creates a [GridItem] widget.
  ///
  /// The [gridUnits] parameter is required and must be at least 1.
  /// Either [bodyWidget] or [bodyText] must be provided.
  GridItem({
    super.key,
    this.title,
    this.titleStyle,
    this.bodyWidget,
    this.bodyText,
    this.bodyTextStyle,
    required this.gridUnits,
  })  : assert(gridUnits > 0, 'gridUnits must be at least 1'),
        assert(bodyWidget != null || bodyText != null,
            'bodyWidget or bodyText must be provided') {
    if (bodyWidget != null && bodyText != null) {
      debugPrint(
          'GridItem WARNING: You provided bodyWidget and bodyText, bodyText ($bodyText) will be ignored.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return bodyWidget ??
          Text(
            bodyText!,
            style: bodyTextStyle ?? Theme.of(context).textTheme.bodyLarge,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title!,
          style: titleStyle ?? Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        if (bodyWidget != null) bodyWidget!,
        if (bodyWidget == null && bodyText != null)
          Text(
            bodyText!,
            style: bodyTextStyle ?? Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}
