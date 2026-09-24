/// Converts a JSON date value into a [DateTime].
///
/// Firestore-backed models may receive an ISO-8601 string or an already
/// decoded [DateTime].
DateTime dateTimeFromJson(Object value) {
  if (value is DateTime) {
    return value;
  }

  return DateTime.parse((value as String).trim());
}

/// Converts a nullable JSON date value into a nullable [DateTime].
DateTime? nullableDateTimeFromJson(Object? value) {
  return value == null ? null : dateTimeFromJson(value);
}

/// Converts a JSON date value into a date without a time component.
DateTime dateOnlyFromJson(Object value) {
  final date = dateTimeFromJson(value);
  return DateTime(date.year, date.month, date.day);
}

/// Serializes [value] as a `YYYY-MM-DD` string.
String dateOnlyToJson(DateTime value) {
  return DateTime(value.year, value.month, value.day)
      .toIso8601String()
      .split('T')
      .first;
}
