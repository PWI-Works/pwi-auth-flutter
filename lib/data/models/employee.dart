/// Employee model

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pwi_auth/data/converters/firestore_document_reference_id_converter.dart';
import 'package:pwi_auth/data/models/color_set.dart';
import 'package:pwi_auth/enums/employee_type.dart';
import 'package:pwi_auth/enums/employment_status.dart';
import 'package:pwi_auth/semantic_colors.dart';

part 'employee.g.dart';

/// Represents an employee with various attributes.
///
/// See `default_employee_extensions.dart` for convenience role helpers built on
/// top of this model. Additional getter properties and methods should be added
/// via extensions instead of modifying or extending this core model.
@JsonSerializable(constructor: '_')
class Employee {
  static const Object _unset = Object();

  /// Unique identifier for the employee
  @JsonKey(includeToJson: false)
  final String id;

  /// Employee's first name
  @JsonKey(includeToJson: false)
  final String firstName;

  /// Employee's last name
  @JsonKey(includeToJson: false)
  final String lastName;

  /// Employee's preferred name
  @JsonKey(includeToJson: false)
  final String preferredName;

  /// Employee's work email address
  @JsonKey(includeToJson: false)
  final String workEmail;

  /// Employee's mobile phone number
  @JsonKey(includeToJson: false)
  final String mobile;

  /// Active Directory automation processing status.
  final String? activeDirectoryProcessingStatus;

  /// Employee's full name by last name
  @JsonKey(
    name: 'fullNameByLastname',
    includeToJson: false,
  )
  final String fullNameByLastName;

  /// ID of the employee's supervisor
  @JsonKey(
    name: 'supervisor',
    fromJson: _supervisorIdFromJson,
    includeToJson: false,
  )
  final String? supervisorId;

  /// String representing the employee's seniority level
  @JsonKey(
    name: 'seniorityString',
    includeToJson: false,
  )
  final String seniority;

  /// String representing the employee's job title
  @JsonKey(
    name: 'jobTitleString',
    includeToJson: false,
  )
  final String jobTitle;

  /// String representing the employee's department
  @JsonKey(
    name: 'departmentString',
    includeToJson: false,
  )
  final String department;

  /// Type of employee (e.g., full-time, part-time)
  @JsonKey(includeToJson: false)
  final EmployeeType? employeeType;

  /// Date when the employee started
  @JsonKey(fromJson: _dateFromJson, includeToJson: false)
  final DateTime? startDate;

  /// Date when the employee ended (if applicable)
  @JsonKey(fromJson: _dateFromJson, includeToJson: false)
  final DateTime? lastDayAtPWI;

  /// Employee's current employment status.
  @JsonKey(
    includeToJson: false,
  )
  final EmploymentStatus employmentStatus;

  /// Indicates if the employee is currently active.
  bool get isActive => employmentStatus == EmploymentStatus.active;

  /// Gets the preferred first name from the preferred name string.
  String get preferredFirstName => preferredName.split(' ')[0];

  /// Creates a copy with updated modifiable fields.
  Employee copyWith({
    Object? activeDirectoryProcessingStatus = _unset,
  }) {
    return Employee._(
      id: id,
      firstName: firstName,
      lastName: lastName,
      preferredName: preferredName,
      workEmail: workEmail,
      mobile: mobile,
      activeDirectoryProcessingStatus:
          identical(activeDirectoryProcessingStatus, _unset)
              ? this.activeDirectoryProcessingStatus
              : activeDirectoryProcessingStatus as String?,
      fullNameByLastName: fullNameByLastName,
      supervisorId: supervisorId,
      seniority: seniority,
      jobTitle: jobTitle,
      department: department,
      employeeType: employeeType,
      startDate: startDate,
      lastDayAtPWI: lastDayAtPWI,
      employmentStatus: employmentStatus,
    );
  }

  /// Private constructor for Employee, as we don't want our apps to create new Employees
  /// at this time. Use [Employee.fromFirestore] to instantiate.
  Employee._({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.preferredName,
    required this.workEmail,
    required this.mobile,
    required this.fullNameByLastName,
    this.supervisorId,
    required this.seniority,
    required this.jobTitle,
    required this.department,
    this.employeeType,
    required this.startDate,
    required this.lastDayAtPWI,
    required this.employmentStatus,
    required this.activeDirectoryProcessingStatus,
  });

  /// Factory constructor to create an [Employee] instance from a Firestore document.
  ///
  /// Parses the Firestore document snapshot and initializes an [Employee] object.
  ///
  /// \param doc The Firestore document snapshot containing employee data.
  /// \return An [Employee] instance populated with data from the document.
  /// Factory constructor to create an [Employee] instance from a Firestore document.
  /// Parses the Firestore document snapshot and initializes an [Employee] object.
  factory Employee.fromFirestore(DocumentSnapshot doc) => Employee.fromJson({
        ...(doc.data() as Map<String, dynamic>),
        'id': doc.id,
      });

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this);

  /// Gets the initials from the preferred name.
  /// This method splits the preferredName by spaces and returns a string containing the first letter of the first word and the first letter of the last word.
  String get initials {
    List<String> names =
        preferredName.split(' '); // Split preferred name into words
    return '${names.first[0]}${names.last[0]}'; // Concatenate first letters of first and last words
  }

  /// Returns the color associated with the employee's seniority level.
  /// This method checks the seniorityString to determine the appropriate color. If the seniorityString contains specific keywords, it returns the corresponding color. If no keywords match, it returns grey.
  ColorSet get seniorityColor {
    final s = seniority.toLowerCase();
    if (s.contains('yellow')) {
      return SemanticColors.yellowSeniority;
    }
    if (s.contains('green')) {
      return SemanticColors.greenSeniority;
    }
    if (s.contains('blue')) {
      return SemanticColors.blueSeniority;
    }
    if (s.contains('red')) {
      return SemanticColors.redSeniority;
    }
    if (s.contains('orange')) {
      return SemanticColors.orangeSeniority;
    }
    // Default color if no matches found
    return const ColorSet(background: Colors.grey, foreground: Colors.black);
  }
}

DateTime? _dateFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  return DateTime.parse((value as String).trim());
}

String? _supervisorIdFromJson(Object? value) {
  return const FirestoreDocumentReferenceIdConverter('employees')
      .fromJson(value);
}
