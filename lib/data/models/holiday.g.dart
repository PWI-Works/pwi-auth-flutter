// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Holiday _$HolidayFromJson(Map<String, dynamic> json) => Holiday(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unnamed',
      date: _dateFromJson(json['date'] as Object),
      isPaid: json['isPaid'] as bool? ?? false,
    );

Map<String, dynamic> _$HolidayToJson(Holiday instance) => <String, dynamic>{
      'name': instance.name,
      'date': _dateToJson(instance.date),
      'isPaid': instance.isPaid,
    };
