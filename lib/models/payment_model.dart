import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String serviceId,
    required double amount,
    required String method, // 'Cash' | 'UPI' | 'Both'
    DateTime? createdAt,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PaymentModel(
      id: doc.id,
      serviceId: data['serviceId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      method: data['method'] as String? ?? 'Cash',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toFirestore(PaymentModel model) => {
        'serviceId': model.serviceId,
        'amount': model.amount,
        'method': model.method,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
