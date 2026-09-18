import 'package:json_annotation/json_annotation.dart';

enum EmployeeType {
  @JsonValue('Full-Time')
  fullTime,

  @JsonValue('Part-Time')
  partTime,

  @JsonValue('Seasonal')
  seasonal,

  @JsonValue('Shared Device')
  sharedDevice,
}
