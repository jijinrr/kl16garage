import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
class AttendanceModel with _$AttendanceModel {
  const factory AttendanceModel({
    required String id,
    required String staffId,
    required String staffName,
    required String status, // 'present' | 'absent' | 'late'
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AttendanceModel(
      id: doc.id,
      staffId: data['staffId'] as String? ?? '',
      staffName: data['staffName'] as String? ?? '',
      status: data['status'] as String? ?? 'absent',
      date: (data['date'] as Timestamp?)?.toDate(),
      checkIn: (data['checkIn'] as Timestamp?)?.toDate(),
      checkOut: (data['checkOut'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toFirestore(AttendanceModel model) => {
        'staffId': model.staffId,
        'staffName': model.staffName,
        'status': model.status,
        'date':
            model.date != null ? Timestamp.fromDate(model.date!) : null,
        'checkIn': model.checkIn != null
            ? Timestamp.fromDate(model.checkIn!)
            : null,
        'checkOut': model.checkOut != null
            ? Timestamp.fromDate(model.checkOut!)
            : null,
      };
}
