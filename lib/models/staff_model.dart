import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_model.freezed.dart';
part 'staff_model.g.dart';

@freezed
class StaffModel with _$StaffModel {
  const factory StaffModel({
    required String id,
    required String name,
    required String phone,
    @Default('') String email,
    @Default(0.0) double salary,
    @Default('staff') String role,
    @Default('') String photoUrl,
    @Default(true) bool isActive,
    DateTime? joinDate,
    @Default('') String emergencyContact,
  }) = _StaffModel;

  factory StaffModel.fromJson(Map<String, dynamic> json) =>
      _$StaffModelFromJson(json);

  factory StaffModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StaffModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
      role: data['role'] as String? ?? 'staff',
      photoUrl: data['photoUrl'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      joinDate: (data['joinDate'] as Timestamp?)?.toDate(),
      emergencyContact: data['emergencyContact'] as String? ?? '',
    );
  }

  static Map<String, dynamic> toFirestore(StaffModel model) => {
        'name': model.name,
        'phone': model.phone,
        'email': model.email,
        'salary': model.salary,
        'role': model.role,
        'photoUrl': model.photoUrl,
        'isActive': model.isActive,
        'joinDate': model.joinDate != null
            ? Timestamp.fromDate(model.joinDate!)
            : null,
        'emergencyContact': model.emergencyContact,
      };
}
