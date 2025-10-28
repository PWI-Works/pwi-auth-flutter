/// Employee model

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pwi_auth/data/models/color_set.dart';
import 'package:pwi_auth/semantic_colors.dart';

/// Represents an employee with various attributes.
///
/// See `default_employee_extensions.dart` for convenience role helpers built on
/// top of this model. Additional getter properties and methods should be added
/// via extensions instead of modifying or extending this core model.
class Employee {
  /// Unique identifier for the employee
  final String id;

  /// Employee's first name
  final String firstName;

  /// Employee's last name
  final String lastName;

  /// Employee's preferred name
  final String preferredName;

  /// Employee's full name by last name
  final String fullNameByLastName;

  /// ID of the employee's supervisor
  final String supervisorId;

  /// Firestore reference to the supervisor's document
  final DocumentReference? supervisor;

  /// String representing the employee's seniority level
  final String seniorityString;

  /// String representing the employee's job title
  final String jobTitle;

  /// String representing the employee's department
  final String department;

  /// Type of employee (e.g., full-time, part-time)
  final String? employeeType;

  /// Date when the employee started
  final DateTime? startDate;

  /// Date when the employee ended (if applicable)
  final DateTime? lastDayAtPWI;

  /// Indicates if the employee is currently active
  final bool isActive;

  /// Gets the preferred first name from the preferred name string.
  String get preferredFirstName => preferredName.split(' ')[0];

  /// Private constructor for Employee, as we don't want our apps to create new Employees
  /// at this time. Use [Employee.fromFirestore] to instantiate.
  Employee._({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.preferredName,
    required this.fullNameByLastName,
    required this.supervisorId,
    this.supervisor,
    required this.seniorityString,
    required this.jobTitle,
    required this.department,
    this.employeeType,
    required this.startDate,
    required this.lastDayAtPWI,
    required this.isActive,
  });

  /// Factory constructor to create an [Employee] instance from a Firestore document.
  ///
  /// Parses the Firestore document snapshot and initializes an [Employee] object.
  ///
  /// \param doc The Firestore document snapshot containing employee data.
  /// \return An [Employee] instance populated with data from the document.
  /// Factory constructor to create an [Employee] instance from a Firestore document.
  /// Parses the Firestore document snapshot and initializes an [Employee] object.
  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>; // Retrieve data from the document

    /// Helper function to safely extract string values with a default fallback.
    ///
    /// \param key The key to look up in the data map.
    /// \param defaultValue The default value to return if the key is not found or the value is not a string.
    /// \return The string value associated with the key, or the default value.
    /// Helper function to safely extract string values with a default fallback.
    String getString(String key, [String defaultValue = 'Unknown']) {
      if (data.containsKey(key)) {
        final value = data[key];
        if (value is String) {
          return value.trim(); // Return trimmed string if the value is a string
        } else if (value != null) {
          // Optionally convert non-string values to string
          return value.toString();
        }
      }
      return defaultValue; // Return default value if key is missing or value is null
    }

    // Initialize supervisor reference if available
    // Initialize supervisor reference if available
    DocumentReference? supervisor;
    if (data['supervisor'] is List) {
      final supervisorList = data['supervisor'] as List;
      if (supervisorList.isNotEmpty &&
          supervisorList.first is DocumentReference) {
        supervisor = supervisorList.first as DocumentReference;
      }
    }

    return Employee._(
      id: doc.id,
      firstName: getString('firstName'),
      lastName: getString('lastName'),
      preferredName: getString('preferredName'),
      fullNameByLastName: getString('fullNameByLastname'),
      supervisorId: supervisor?.id ?? '',
      supervisor: supervisor,
      seniorityString: getString('seniorityString'),
      jobTitle: getString('jobTitleString', '-'),
      department: getString('departmentString', '-'),
      employeeType: getString('employeeType'),
      startDate: (() {
        try {
          return DateTime.parse(getString('startDate'));
        } catch (e) {
          return null;
        }
      })(),
      lastDayAtPWI: (() {
        try {
          return getString('lastDayAtPWI') != 'Unknown'
              ? DateTime.parse(getString('lastDayAtPWI'))
              : null;
        } catch (e) {
          return null;
        }
      })(),
      isActive: getString('employmentStatus').toLowerCase() == 'active',
    );
  }

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
    final s = seniorityString.toLowerCase();
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
