import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holiday.g.dart';

/// A company holiday stored in the shared `holidays` collection.
@JsonSerializable()
class Holiday {
  /// Creates a holiday.
  const Holiday({
    required this.id,
    required this.name,
    required this.date,
    required this.isPaid,
  });

  /// The Firestore document identifier.
  @JsonKey(includeToJson: false)
  final String id;

  /// The display name of the holiday.
  @JsonKey(defaultValue: 'Unnamed')
  final String name;

  /// The local calendar date on which the holiday occurs.
  ///
  /// Firestore stores this value as a `YYYY-MM-DD` string so converting it
  /// never introduces a time-zone offset.
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime date;

  /// Whether employees are paid for the holiday.
  @JsonKey(defaultValue: false)
  final bool isPaid;

  /// Whether the holiday is today or in the future.
  bool get canEdit {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final holidayDate = DateTime(date.year, date.month, date.day);
    return !holidayDate.isBefore(today);
  }

  /// Creates a holiday from a Firestore document.
  factory Holiday.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return Holiday.fromJson({
      ...?document.data(),
      'id': document.id,
    });
  }

  /// Creates a holiday from JSON-compatible data.
  factory Holiday.fromJson(Map<String, dynamic> json) =>
      _$HolidayFromJson(json);

  /// Converts this holiday to the format stored in Firestore.
  Map<String, dynamic> toJson() => _$HolidayToJson(this);
}

DateTime _dateFromJson(Object value) {
  if (value is DateTime) {
    return DateTime(value.year, value.month, value.day);
  }

  return DateTime.parse(value as String);
}

String _dateToJson(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
