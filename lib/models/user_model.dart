import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String name,
    required String email,
    @Default('staff') String role, // 'admin' | 'staff'
    @Default('') String phone,
    @Default('') String photoUrl,
    @Default(0.0) double salary,
    @Default(true) bool isActive,
    DateTime? joinDate,
    @Default('') String emergencyContact,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Construct from a Firestore [DocumentSnapshot].
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'staff',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
      joinDate: (data['joinDate'] as Timestamp?)?.toDate(),
      emergencyContact: data['emergencyContact'] as String? ?? '',
    );
  }

  /// Convert to Firestore map (excludes uid — stored as doc ID).
  static Map<String, dynamic> toFirestore(UserModel model) => {
        'name': model.name,
        'email': model.email,
        'role': model.role,
        'phone': model.phone,
        'photoUrl': model.photoUrl,
        'salary': model.salary,
        'isActive': model.isActive,
        'joinDate': model.joinDate != null
            ? Timestamp.fromDate(model.joinDate!)
            : null,
        'emergencyContact': model.emergencyContact,
      };
}
