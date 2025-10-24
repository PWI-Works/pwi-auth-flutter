import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:pwi_auth/widgets/flexible_grid/grid_item.dart';

/// A widget that arranges [GridItem]s in a flexible grid layout.
///
/// The [FlexibleGridLayout] widget arranges its children in rows, ensuring that
/// the total number of grid units in each row does not exceed [preferredGridUnits].
/// Each [GridItem] specifies the number of grid units it occupies. The layout
/// can be customized with [itemGaps], [preferredGridUnits], and [minItemWidth].
class FlexibleGridLayout extends StatelessWidget {
  /// The list of [GridItem]s to display in the grid.
  final List<GridItem> items;

  /// The gap to apply between grid items.
  final double itemGaps;

  /// The preferred total number of grid units available per row.
  /// The value of minItemWidth will override this to ensure a minimum width.
  final int preferredGridUnits;

  /// The minimum width of each grid item.
  final double minItemWidth;

  /// Creates a [FlexibleGridLayout] widget.
  ///
  /// The [items] parameter is required. The [itemGaps] parameter defaults to 8.0,
  /// the [preferredGridUnits] parameter defaults to 3, and the [minItemWidth] parameter
  /// defaults to 100.
  const FlexibleGridLayout({
    super.key,
    required this.items,
    this.itemGaps = 8.0,
    this.preferredGridUnits = 3,
    this.minItemWidth = 100,
  });

  /// Calculates the optimal number of grid units based on the available width.
  ///
  /// The [availableWidth] parameter is the width available for the grid layout.
  /// This method accounts for item margins and ensures the optimal number of grid units
  /// does not exceed the preferred grid units or the maximum requested units by any item.
  int _calculateOptimalGridUnits(double availableWidth) {
    // Account for all margins and gaps
    final totalMargin = itemGaps * 2; // padding on each item
    final effectiveItemWidth = minItemWidth + totalMargin;

    // Calculate maximum possible units given the available width
    final possibleUnits = (availableWidth / effectiveItemWidth).floor();

    // Take the minimum between possible units and preferred grid units,
    // but ensure it's never less than 1
    final optimalUnits = possibleUnits.clamp(1, preferredGridUnits);

    return optimalUnits;
  }

  List<GridItem> _adjustItemGridUnits(
      List<GridItem> items, int effectiveGridUnits) {
    return items.map((item) {
      // If the item's grid units exceed the effective grid units,
      // create a new GridItem with adjusted grid units
      if (item.gridUnits > effectiveGridUnits) {
        return GridItem(
          title: item.title,
          bodyWidget: item.bodyWidget,
          bodyText: item.bodyText,
          gridUnits: effectiveGridUnits,
        );
      }
      return item;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final effectiveGridUnits = _calculateOptimalGridUnits(availableWidth);

        // Adjust items to fit within effective grid units
        final adjustedItems = _adjustItemGridUnits(items, effectiveGridUnits);

        // Group items into rows based on grid units
        final rows = <List<GridItem>>[];
        List<GridItem> currentRow = [];
        int currentRowUnits = 0;

        for (final item in adjustedItems) {
          if (currentRowUnits + item.gridUnits > effectiveGridUnits) {
            if (currentRow.isNotEmpty) {
              rows.add(currentRow);
            }
            currentRow = [item];
            currentRowUnits = item.gridUnits;
          } else {
            currentRow.add(item);
            currentRowUnits += item.gridUnits;
          }
        }

        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
        }

        return LayoutGrid(
          columnSizes: List.generate(effectiveGridUnits, (index) => 1.fr),
          rowSizes: List.generate(rows.length, (index) => auto),
          columnGap: itemGaps,
          rowGap: itemGaps,
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
              for (var itemIndex = 0;
                  itemIndex < rows[rowIndex].length;
                  itemIndex++)
                Padding(
                  padding: EdgeInsets.all(itemGaps),
                  child: rows[rowIndex][itemIndex].build(context),
                ).withGridPlacement(
                  columnStart: rows[rowIndex]
                      .take(itemIndex)
                      .fold<int>(0, (sum, prev) => sum + prev.gridUnits),
                  columnSpan: rows[rowIndex][itemIndex].gridUnits,
                  rowStart: rowIndex,
                  rowSpan: 1,
                ),
          ],
        );
      },
    );
  }
}
