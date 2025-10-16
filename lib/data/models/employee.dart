// lib/models/employee.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pwi_auth/data/models/color_set.dart';
import 'package:pwi_auth/semantic_colors.dart';

/// Represents an employee with various attributes.
class Employee {
  final String id; // Unique identifier for the employee
  final String firstName; // Employee's first name
  final String lastName; // Employee's last name
  final String preferredName; // Employee's preferred name
  final String fullNameByLastName; // Employee's full name by last name
  final String supervisorId; // ID of the employee's supervisor
  final DocumentReference?
      supervisor; // Firestore reference to the supervisor's document
  final String
      seniorityString; // String representing the employee's seniority level
  final String jobTitle; // String representing the employee's job title
  final String department; // String representing the employee's department
  final String? employeeType; // Type of employee (e.g., full-time, part-time)
  final DateTime? startDate; // Date when the employee started
  final DateTime? lastDayAtPWI; // Date when the employee ended (if applicable)
  final bool isActive; // Indicates if the employee is currently active

  String get preferredFirstName => preferredName.split(' ')[0];

  /// Constructs an [Employee] instance with the given attributes.
  Employee({
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
  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>; // Retrieve data from the document

    /// Helper function to safely extract string values with a default fallback.
    ///
    /// \param key The key to look up in the data map.
    /// \param defaultValue The default value to return if the key is not found or the value is not a string.
    /// \return The string value associated with the key, or the default value.
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
    DocumentReference? supervisor;
    if (data['supervisor'] is List) {
      final supervisorList = data['supervisor'] as List;
      if (supervisorList.isNotEmpty &&
          supervisorList.first is DocumentReference) {
        supervisor = supervisorList.first as DocumentReference;
      }
    }

    return Employee(
      id: doc.id,
      // Set employee ID from document ID
      firstName: getString('firstName'),
      // Extract first name
      lastName: getString('lastName'),
      // Extract last name
      preferredName: getString('preferredName'),
      // Extract preferred name
      fullNameByLastName: getString('fullNameByLastname'),
      // full name
      supervisorId: supervisor?.id ?? '',
      // Extract supervisor ID or set to empty string
      supervisor: supervisor,
      // Set supervisor reference
      seniorityString: getString('seniorityString'),
      // Extract seniority level string
      jobTitle: getString('jobTitleString', '-'),
      // Extract job title string
      department: getString('departmentString', '-'),
      // Extract department string
      employeeType: getString('employeeType'),
      // Extract employee type
      startDate: (() {
        try {
          return DateTime.parse(
              getString('startDate')); // Parse start date string to DateTime
        } catch (e) {
          return null; // Return null if parsing fails
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
      // Determine if employee is active
    );
  }

  /// Getter to retrieve the initials from the preferred name.
  ///
  /// This method splits the `preferredName` by spaces and returns a string
  /// containing the first letter of the first word and the first letter of the last word.
  ///
  /// \return A string representing the initials.
  String get initials {
    List<String> names =
        preferredName.split(' '); // Split preferred name into words
    return '${names.first[0]}${names.last[0]}'; // Concatenate first letters of first and last words
  }

  /// Checks if the employee is an admin based on the department string.
  ///
  /// Determines if the employee belongs to departments typically associated with admin roles.
  ///
  /// \return `true` if the employee is an admin, `false` otherwise.
  bool get isAdmin =>
      department.toLowerCase().contains('hr') &&
      (seniorityString.toLowerCase().contains("red") ||
          seniorityString.toLowerCase().contains("green"));

  /// Checks if the employee is a supervisor based on the seniority string.
  ///
  /// Determines if the employee holds a supervisory position by analyzing seniority indicators.
  ///
  /// \return `true` if the employee is a supervisor, `false` otherwise.
  bool get isSupervisor =>
      !seniorityString.toLowerCase().contains('orange') &&
      !seniorityString.toLowerCase().contains('yellow') &&
      seniorityString.isNotEmpty;

  /// Checks if the employee holds an executive position.
  ///
  /// This getter determines if the employee is an executive by checking if the
  /// `seniorityString` contains the word 'red'.
  ///
  /// \return `true` if the employee is an executive, `false` otherwise.
  bool get isExecutive => seniorityString.toLowerCase().contains('red');

  /// Checks if the employee is a developer based on the job title.
  bool get isDeveloper => department.toLowerCase().contains("software");

  /// Returns the color associated with the employee's seniority level.
  ///
  /// This method checks the `seniorityString` to determine the appropriate color.
  /// If the `seniorityString` contains specific keywords, it returns the corresponding color.
  /// If no keywords match, it returns grey.
  ///
  /// \return A `Color` representing the seniority level.
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
