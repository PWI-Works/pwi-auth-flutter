import 'package:json_annotation/json_annotation.dart';

enum EmploymentStatus {
  @JsonValue('Active')
  active,

  @JsonValue('Inactive')
  inactive,
}
