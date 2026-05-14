// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceModelImpl _$$ServiceModelImplFromJson(Map<String, dynamic> json) =>
    _$ServiceModelImpl(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      phone: json['phone'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? 'Sedan',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (json['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (json['balanceAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      status: json['status'] as String? ?? 'Pending',
      staffId: json['staffId'] as String? ?? '',
      staffName: json['staffName'] as String? ?? '',
      beforePhotos:
          (json['beforePhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      afterPhotos:
          (json['afterPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      comments: json['comments'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$ServiceModelImplToJson(_$ServiceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'vehicleNumber': instance.vehicleNumber,
      'phone': instance.phone,
      'vehicleType': instance.vehicleType,
      'services': instance.services,
      'totalAmount': instance.totalAmount,
      'advanceAmount': instance.advanceAmount,
      'balanceAmount': instance.balanceAmount,
      'paymentStatus': instance.paymentStatus,
      'paymentMethod': instance.paymentMethod,
      'status': instance.status,
      'staffId': instance.staffId,
      'staffName': instance.staffName,
      'beforePhotos': instance.beforePhotos,
      'afterPhotos': instance.afterPhotos,
      'comments': instance.comments,
      'createdAt': instance.createdAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
