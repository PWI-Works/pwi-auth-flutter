import 'package:flutter/material.dart';

/// A reusable card widget with a title and content.
class TitleCard extends StatelessWidget {
  /// The padding to apply inside the card.
  final EdgeInsetsGeometry padding;

  /// The title to display at the top of the card.
  final String title;

  /// The content to display in the card.
  final Widget content;

  /// Optional widget to display in the trailing area of the title row.
  /// Perfect for adding toggle buttons, icons, or other interactive elements.
  final Widget? trailing;

  /// The minimum width for showing the title and trailing in a row.
  /// If the size is smaller, it becomes a column.
  final double trailingWidgetRowMinSize;

  /// Creates an instance of [TitleCard].
  const TitleCard({
    super.key,
    required this.title,
    required this.content,
    this.trailing,
    this.padding = const EdgeInsets.all(16.0),
    this.trailingWidgetRowMinSize = 450,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < trailingWidgetRowMinSize;
        return Card(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with title and trailing
                if (isSmallScreen)
                  // For small screens - title and trailing in separate rows
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with centered text for small screens
                      Center(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          // Allow up to 2 lines for very long titles
                          maxLines: 2,
                          // Use ellipsis if it's too long
                          overflow: TextOverflow.ellipsis,
                          // Center-align the text
                          textAlign: TextAlign.center, 
                        ),
                      ),
                      // Space between title and trailing
                      if (trailing != null) const SizedBox(height: 12.0),
                      // Trailing widget (segmented control) centered
                      if (trailing != null)
                        SizedBox(
                          width: double.infinity,
                          child: Center(child: trailing!),
                        ),
                      // Bottom padding
                      const SizedBox(height: 16.0),
                    ],
                  )
                else
                  // For larger screens - title and trailing side by side
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title with flexible width
                        Flexible(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        // Add trailing widget if provided
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ),
                // Expanded content area
                Expanded(child: content),
              ],
            ),
          ),
        );
      },
    );
  }
}
