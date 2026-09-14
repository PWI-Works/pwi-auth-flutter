// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee._(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      preferredName: json['preferredName'] as String,
      workEmail: json['workEmail'] as String,
      mobile: json['mobile'] as String,
      fullNameByLastName: json['fullNameByLastname'] as String,
      supervisor: _documentReferenceFromJson(json['supervisor']),
      seniority: json['seniorityString'] as String,
      jobTitle: json['jobTitleString'] as String,
      department: json['departmentString'] as String,
      employeeType: json['employeeType'] as String?,
      startDate: _dateFromJson(json['startDate']),
      lastDayAtPWI: _dateFromJson(json['lastDayAtPWI']),
      isActive: _isActiveFromJson(json['employmentStatus']),
      activeDirectoryProcessingStatus:
          json['activeDirectoryProcessingStatus'] as String?,
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'activeDirectoryProcessingStatus':
          instance.activeDirectoryProcessingStatus,
    };
