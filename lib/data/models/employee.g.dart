// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee._(
      id: json['id'] as String,
      firstName: _stringFromJson(json['firstName']),
      lastName: _stringFromJson(json['lastName']),
      preferredName: _stringFromJson(json['preferredName']),
      workEmail: _stringFromJson(json['workEmail']),
      mobile: _stringFromJson(json['mobile']),
      fullNameByLastName: _stringFromJson(json['fullNameByLastname']),
      supervisor: _documentReferenceFromJson(json['supervisor']),
      seniority: _stringFromJson(json['seniorityString']),
      jobTitle: _jobTitleFromJson(json['jobTitleString']),
      department: _departmentFromJson(json['departmentString']),
      employeeType: _employeeTypeFromJson(json['employeeType']),
      startDate: _dateFromJson(json['startDate']),
      lastDayAtPWI: _lastDayAtPwiFromJson(json['lastDayAtPWI']),
      isActive: _isActiveFromJson(json['employmentStatus']),
      activeDirectoryProcessingStatus:
          json['activeDirectoryProcessingStatus'] as String?,
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      'activeDirectoryProcessingStatus':
          instance.activeDirectoryProcessingStatus,
    };
