import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import '../models/attendance_model.dart';
import '../models/staff_model.dart';
import '../repositories/attendance_repository.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider(this._repo);

  final AttendanceRepository _repo;

  List<AttendanceModel> _records = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  bool _saved = false;

  List<AttendanceModel> get records => _records;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get saved => _saved;

  int get presentCount =>
      _records.where((r) => r.status == 'present').length;
  int get absentCount =>
      _records.where((r) => r.status == 'absent').length;
  int get lateCount =>
      _records.where((r) => r.status == 'late').length;

  Future<void> fetchForDate(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _records = await _repo.fetchByDate(date);
    } on DatabaseException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialises attendance records for staff members not yet recorded.
  void initForStaff(List<StaffModel> staffList) {
    final existing = {for (final r in _records) r.staffId: r};
    final merged = staffList.map((s) {
      return existing[s.id] ??
          AttendanceModel(
            id: '',
            staffId: s.id,
            staffName: s.name,
            status: 'absent',
            date: _selectedDate,
          );
    }).toList();
    _records = merged;
    notifyListeners();
  }

  void updateStatus(String staffId, String status) {
    _records = _records
        .map((r) => r.staffId == staffId ? r.copyWith(status: status) : r)
        .toList();
    notifyListeners();
  }

  Future<bool> saveAll() async {
    _isLoading = true;
    _error = null;
    _saved = false;
    notifyListeners();
    try {
      await _repo.saveBatch(_records);
      _saved = true;
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
