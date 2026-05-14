import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_model.freezed.dart';
part 'service_model.g.dart';

@freezed
class ServiceModel with _$ServiceModel {
  const factory ServiceModel({
    required String id,
    required String customerName,
    required String vehicleNumber,
    @Default('') String phone,
    @Default('Sedan') String vehicleType,
    @Default([]) List<String> services,
    @Default(0.0) double totalAmount,
    @Default(0.0) double advanceAmount,
    @Default(0.0) double balanceAmount,
    @Default('Pending') String paymentStatus, // 'Completed' | 'Partial' | 'Pending'
    @Default('Cash') String paymentMethod,    // 'Cash' | 'UPI' | 'Both'
    @Default('Pending') String status,        // 'Pending' | 'Completed'
    @Default('') String staffId,
    @Default('') String staffName,
    @Default([]) List<String> beforePhotos,
    @Default([]) List<String> afterPhotos,
    @Default('') String comments,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _ServiceModel;

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ServiceModel(
      id: doc.id,
      customerName: data['customerName'] as String? ?? '',
      vehicleNumber: data['vehicleNumber'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      vehicleType: data['vehicleType'] as String? ?? 'Sedan',
      services: List<String>.from(data['services'] as List? ?? []),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      advanceAmount: (data['advanceAmount'] as num?)?.toDouble() ?? 0.0,
      balanceAmount: (data['balanceAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: data['paymentStatus'] as String? ?? 'Pending',
      paymentMethod: data['paymentMethod'] as String? ?? 'Cash',
      status: data['status'] as String? ?? 'Pending',
      staffId: data['staffId'] as String? ?? '',
      staffName: data['staffName'] as String? ?? '',
      beforePhotos: List<String>.from(data['beforePhotos'] as List? ?? []),
      afterPhotos: List<String>.from(data['afterPhotos'] as List? ?? []),
      comments: data['comments'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toFirestore(ServiceModel model) => {
        'customerName': model.customerName,
        'vehicleNumber': model.vehicleNumber,
        'phone': model.phone,
        'vehicleType': model.vehicleType,
        'services': model.services,
        'totalAmount': model.totalAmount,
        'advanceAmount': model.advanceAmount,
        'balanceAmount': model.balanceAmount,
        'paymentStatus': model.paymentStatus,
        'paymentMethod': model.paymentMethod,
        'status': model.status,
        'staffId': model.staffId,
        'staffName': model.staffName,
        'beforePhotos': model.beforePhotos,
        'afterPhotos': model.afterPhotos,
        'comments': model.comments,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': model.completedAt != null
            ? Timestamp.fromDate(model.completedAt!)
            : null,
      };
}
