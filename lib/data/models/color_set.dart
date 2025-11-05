// lib/models/color_set.dart

import 'package:flutter/material.dart';

/// A class that represents a set of colors.
///
/// The `ColorSet` class contains two `Color` properties: `foreground` and `background`.
/// These properties are used to define a set of colors that can be used together.
class ColorSet {
  /// The foreground color.
  final Color foreground;

  /// The background color.
  final Color background;

  /// Creates a `ColorSet` with the given foreground and background colors.
  ///
  /// Both `foreground` and `background` are required parameters.
  const ColorSet({required this.foreground, required this.background});
}
