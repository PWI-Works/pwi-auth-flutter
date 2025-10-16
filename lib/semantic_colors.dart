import 'package:flutter/material.dart';
import 'package:pwi_auth/data/models/color_set.dart';

/// A class that defines a set of semantic colors used in the application.
class SemanticColors {
  /// ColorSets for each seniority color pairing
  static const ColorSet redSeniority = ColorSet(
    background: _redSeniority,
    foreground: _onRedSeniority,
  );

  static const ColorSet greenSeniority = ColorSet(
    background: _greenSeniority,
    foreground: _onGreenSeniority,
  );

  static const ColorSet blueSeniority = ColorSet(
    background: _blueSeniority,
    foreground: _onBlueSeniority,
  );

  static const ColorSet orangeSeniority = ColorSet(
    background: _orangeSeniority,
    foreground: onOrangeSeniority,
  );

  static const ColorSet yellowSeniority = ColorSet(
    background: _yellowSeniority,
    foreground: _onYellowSeniority,
  );

  static const ColorSet warning = ColorSet(
    background: _warning,
    foreground: _onWarning,
  );

  /// The color used for warnings.
  static const Color _warning = Color(0xFFFFC800);

  /// The color used for text/icons on warning backgrounds.
  static const Color _onWarning = Color(0xFF000000);

  /// The color used for red seniority levels.
  static const Color _redSeniority = Color(0xFFF59689);

  /// The color used for text/icons on red seniority backgrounds.
  static const Color _onRedSeniority = Color(0xFF2C2221);

  /// The color used for green seniority levels.
  static const Color _greenSeniority = Color(0xFF86CC66);

  /// The color used for text/icons on green seniority backgrounds.
  static const Color _onGreenSeniority = Color(0xFF242C21);

  /// The color used for blue seniority levels.
  static const Color _blueSeniority = Color(0xFF89CAF5);

  /// The color used for text/icons on blue seniority backgrounds.
  static const Color _onBlueSeniority = Color(0xFF21272C);

  /// The color used for orange seniority levels.
  static const Color _orangeSeniority = Color(0xFFF2AD5A);

  /// The color used for text/icons on orange seniority backgrounds.
  static const Color onOrangeSeniority = Color(0xFF2C2721);

  /// The color used for yellow seniority levels.
  static const Color _yellowSeniority = Color(0xFFE5D51A);

  /// The color used for text/icons on yellow seniority backgrounds.
  static const Color _onYellowSeniority = Color(0xFF2C2B21);
}
