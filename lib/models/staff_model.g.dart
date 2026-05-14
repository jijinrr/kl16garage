// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StaffModelImpl _$$StaffModelImplFromJson(Map<String, dynamic> json) =>
    _$StaffModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      role: json['role'] as String? ?? 'staff',
      photoUrl: json['photoUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      joinDate: json['joinDate'] == null
          ? null
          : DateTime.parse(json['joinDate'] as String),
      emergencyContact: json['emergencyContact'] as String? ?? '',
    );

Map<String, dynamic> _$$StaffModelImplToJson(_$StaffModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'salary': instance.salary,
      'role': instance.role,
      'photoUrl': instance.photoUrl,
      'isActive': instance.isActive,
      'joinDate': instance.joinDate?.toIso8601String(),
      'emergencyContact': instance.emergencyContact,
    };
