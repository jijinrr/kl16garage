// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceModelImpl _$$AttendanceModelImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceModelImpl(
  id: json['id'] as String,
  staffId: json['staffId'] as String,
  staffName: json['staffName'] as String,
  status: json['status'] as String,
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  checkIn: json['checkIn'] == null
      ? null
      : DateTime.parse(json['checkIn'] as String),
  checkOut: json['checkOut'] == null
      ? null
      : DateTime.parse(json['checkOut'] as String),
);

Map<String, dynamic> _$$AttendanceModelImplToJson(
  _$AttendanceModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'staffId': instance.staffId,
  'staffName': instance.staffName,
  'status': instance.status,
  'date': instance.date?.toIso8601String(),
  'checkIn': instance.checkIn?.toIso8601String(),
  'checkOut': instance.checkOut?.toIso8601String(),
};
