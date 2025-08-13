import 'package:flutter/material.dart';

/// A reusable card widget with a title and content.
class TitleCard extends StatelessWidget {
  /// The title to display at the top of the card.
  final String title;

  /// The content to display in the card.
  final Widget content;

  /// Optional widget to display in the trailing area of the title row.
  /// Perfect for adding toggle buttons, icons, or other interactive elements.
  final Widget? trailing;

  /// The padding to apply inside the card.
  final EdgeInsetsGeometry padding;

  /// Creates an instance of [TitleCard].
  const TitleCard({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.padding = const EdgeInsets.all(16.0),
  });

  /// [content] should not contain Expanded or Flexible unless TitleCard is wrapped in a flex widget.
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section with Wrap instead of Row
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            // Content area
            content,
          ],
        ),
      ),
    );
  }
}
