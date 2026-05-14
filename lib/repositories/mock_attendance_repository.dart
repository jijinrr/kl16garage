import 'package:uuid/uuid.dart';
import '../models/attendance_model.dart';
import 'attendance_repository.dart';

/// In-memory mock Attendance repository.
/// Dates are stored as DateTime? and compared by year/month/day.
class MockAttendanceRepository implements AttendanceRepository {
  static const _uuid = Uuid();
  static final List<AttendanceModel> _store = [];

  @override
  Future<List<AttendanceModel>> fetchByDate(DateTime date) async {
    await Future.microtask(() {});
    return _store
        .where((a) =>
            a.date != null &&
            a.date!.year == date.year &&
            a.date!.month == date.month &&
            a.date!.day == date.day)
        .toList();
  }

  @override
  Future<void> saveAttendance(AttendanceModel attendance) async {
    await Future.microtask(() {});
    final idx = _store.indexWhere((a) =>
        a.staffId == attendance.staffId &&
        a.date != null &&
        attendance.date != null &&
        a.date!.year == attendance.date!.year &&
        a.date!.month == attendance.date!.month &&
        a.date!.day == attendance.date!.day);
    if (idx != -1) {
      _store[idx] = attendance;
    } else {
      _store.add(attendance.id.isEmpty
          ? attendance.copyWith(id: _uuid.v4())
          : attendance);
    }
  }

  @override
  Future<void> saveBatch(List<AttendanceModel> records) async {
    await Future.microtask(() {});
    for (final r in records) {
      await saveAttendance(r);
    }
  }

  @override
  Future<List<AttendanceModel>> fetchByMonth(int year, int month) async {
    await Future.microtask(() {});
    return _store
        .where((a) =>
            a.date != null &&
            a.date!.year == year &&
            a.date!.month == month)
        .toList();
  }
}

