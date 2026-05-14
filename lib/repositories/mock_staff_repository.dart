import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/staff_model.dart';
import 'staff_repository.dart';

/// In-memory mock Staff repository.
class MockStaffRepository implements StaffRepository {
  static const _uuid = Uuid();

  static final List<StaffModel> _store = _seed();
  static final _controller =
      StreamController<List<StaffModel>>.broadcast();

  static void _emit() => _controller.add(List.unmodifiable(_store));

  static List<StaffModel> _seed() => [
        const StaffModel(
          id: 'stf001',
          name: 'Rajan Pillai',
          phone: '9876543210',
          email: 'rajan@kl16garage.com',
          salary: 18000,
          role: 'staff',
          isActive: true,
          photoUrl: '',
          emergencyContact: '9876501234',
        ),
        const StaffModel(
          id: 'stf002',
          name: 'Suresh Kumar',
          phone: '8765432109',
          email: 'suresh@kl16garage.com',
          salary: 16000,
          role: 'staff',
          isActive: true,
          photoUrl: '',
          emergencyContact: '8765401234',
        ),
        const StaffModel(
          id: 'stf003',
          name: 'Anand Nair',
          phone: '7654321098',
          email: 'anand@kl16garage.com',
          salary: 15000,
          role: 'staff',
          isActive: false,
          photoUrl: '',
          emergencyContact: '7654301234',
        ),
        const StaffModel(
          id: 'stf004',
          name: 'Deepa Menon',
          phone: '6543210987',
          email: 'deepa@kl16garage.com',
          salary: 17000,
          role: 'staff',
          isActive: true,
          photoUrl: '',
          emergencyContact: '6543201234',
        ),
      ];

  @override
  Stream<List<StaffModel>> watchAllStaff() {
    return _controller.stream.startWith(List.unmodifiable(_store));
  }

  @override
  Future<void> addStaff(StaffModel staff, {File? photo}) async {
    await Future.microtask(() {});
    // photo ignored in mock mode
    final withId = staff.copyWith(id: _uuid.v4());
    _store.add(withId);
    _emit();
  }

  @override
  Future<void> updateStaff(StaffModel staff, {File? photo}) async {
    await Future.microtask(() {});
    final idx = _store.indexWhere((s) => s.id == staff.id);
    if (idx != -1) {
      _store[idx] = staff;
      _emit();
    }
  }

  @override
  Future<void> toggleStatus(String id, bool isActive) async {
    await Future.microtask(() {});
    final idx = _store.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _store[idx] = _store[idx].copyWith(isActive: isActive);
      _emit();
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    await Future.microtask(() {});
    _store.removeWhere((s) => s.id == id);
    _emit();
  }
}

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

