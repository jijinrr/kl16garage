import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import '../models/staff_model.dart';
import '../repositories/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  StaffProvider(this._repo);

  final StaffRepository _repo;

  List<StaffModel> _staff = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<StaffModel> get staff => _filtered;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<StaffModel> get _filtered {
    if (_searchQuery.isEmpty) return _staff;
    final q = _searchQuery.toLowerCase();
    return _staff
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.phone.contains(q))
        .toList();
  }

  int get activeCount => _staff.where((s) => s.isActive).length;
  int get inactiveCount => _staff.where((s) => !s.isActive).length;

  void startListening() {
    _repo.watchAllStaff().listen(
      (list) {
        _staff = list;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<bool> addStaff(StaffModel staff, {File? photo}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.addStaff(staff, photo: photo);
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } on StorageException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStaff(StaffModel staff, {File? photo}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.updateStaff(staff, photo: photo);
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } on StorageException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleStatus(String id, bool isActive) async {
    try {
      await _repo.toggleStatus(id, isActive);
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStaff(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deleteStaff(id);
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
