import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/date_helpers.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceModel>> fetchByDate(DateTime date);
  Future<void> saveAttendance(AttendanceModel attendance);
  Future<void> saveBatch(List<AttendanceModel> records);
  Future<List<AttendanceModel>> fetchByMonth(int year, int month);
}

class FirestoreAttendanceRepository implements AttendanceRepository {
  @override
  Future<List<AttendanceModel>> fetchByDate(DateTime date) async {
    final key = DateHelpers.toFirestoreKey(date); // "2026-05-13"
    try {
      final snap = await FirebaseService.attendance
          .where('dateKey', isEqualTo: key)
          .get();
      return snap.docs.map(AttendanceModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch attendance.');
    }
  }

  @override
  Future<void> saveAttendance(AttendanceModel attendance) async {
    try {
      final data = AttendanceModel.toFirestore(attendance);
      data['dateKey'] = DateHelpers.toFirestoreKey(
          attendance.date ?? DateTime.now());

      if (attendance.id.isEmpty) {
        await FirebaseService.attendance.add(data);
      } else {
        await FirebaseService.attendance.doc(attendance.id).set(data);
      }
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to save attendance.');
    }
  }

  @override
  Future<void> saveBatch(List<AttendanceModel> records) async {
    try {
      final batch = FirebaseService.db.batch();
      for (final rec in records) {
        final data = AttendanceModel.toFirestore(rec);
        data['dateKey'] =
            DateHelpers.toFirestoreKey(rec.date ?? DateTime.now());
        if (rec.id.isEmpty) {
          final ref = FirebaseService.attendance.doc();
          batch.set(ref, data);
        } else {
          batch.set(FirebaseService.attendance.doc(rec.id), data);
        }
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Batch attendance save failed.');
    }
  }

  @override
  Future<List<AttendanceModel>> fetchByMonth(int year, int month) async {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0, 23, 59, 59);
    try {
      final snap = await FirebaseService.attendance
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .get();
      return snap.docs.map(AttendanceModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch monthly attendance.');
    }
  }
}
