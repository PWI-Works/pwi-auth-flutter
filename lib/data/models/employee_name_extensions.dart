part of 'employee.dart';

/// Derived name helpers based on [Employee.preferredName].
extension EmployeeNameExtensions on Employee {
  /// All name parts between the first and last parts, excluding any suffix.
  /// Returns an empty string when fewer than three name parts exist.
  String get middleName {
    final names = _preferredNameParts.names;
    return names.length < 3 ? '' : names.sublist(1, names.length - 1).join(' ');
  }

  /// The trimmed text after the first comma, or an empty string if absent.
  String get suffix => _preferredNameParts.suffix;

  _PreferredNameParts get _preferredNameParts =>
      _PreferredNameParts.parse(preferredName);
}

class _PreferredNameParts {
  final List<String> names;
  final String suffix;

  _PreferredNameParts.parse(String preferredName)
      : this._(preferredName, preferredName.indexOf(','));

  _PreferredNameParts._(String preferredName, int comma)
      : names = (comma < 0 ? preferredName : preferredName.substring(0, comma))
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList(),
        suffix = comma < 0 ? '' : preferredName.substring(comma + 1).trim();

  String get firstName => names.isEmpty ? '' : names.first;
}
