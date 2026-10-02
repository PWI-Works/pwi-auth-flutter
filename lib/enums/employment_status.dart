import 'package:json_annotation/json_annotation.dart';

part 'employment_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum EmploymentStatus {
  @JsonValue('Active')
  active,

  @JsonValue('Inactive')
  inactive;

  /// Returns the JSON string defined by this status's [JsonValue] annotation.
  String toJson() => _$EmploymentStatusEnumMap[this]!;
}
