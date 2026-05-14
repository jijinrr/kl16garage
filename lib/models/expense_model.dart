import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String id,
    required String category,
    required String title,
    required double amount,
    @Default('') String notes,
    @Default('') String staffId,
    DateTime? date,
    DateTime? createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExpenseModel(
      id: doc.id,
      category: data['category'] as String? ?? '',
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] as String? ?? '',
      staffId: data['staffId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toFirestore(ExpenseModel model) => {
        'category': model.category,
        'title': model.title,
        'amount': model.amount,
        'notes': model.notes,
        'staffId': model.staffId,
        'date': model.date != null ? Timestamp.fromDate(model.date!) : null,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
