import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/service_model.dart';
import 'service_repository.dart';

/// In-memory mock implementation â€” no Firebase required.
/// Pre-loaded with realistic Kerala/India dummy data.
class MockServiceRepository implements ServiceRepository {
  static const _uuid = Uuid();

  // Single shared list so all parts of the app see the same data
  static final List<ServiceModel> _store = _seed();

  /// Public read-only view used by MockAnalyticsRepository.
  static List<ServiceModel> get allServices => List.unmodifiable(_store);

  static final _controller =
      StreamController<List<ServiceModel>>.broadcast();

  static void _emit() => _controller.add(List.unmodifiable(_store));

  // â”€â”€ Seeded dummy data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static List<ServiceModel> _seed() {
    final now = DateTime.now();
    return [
      _make(
        id: 'svc001',
        name: 'Arjun Menon',
        vehicle: 'KL16AB1234',
        phone: '9876543210',
        type: 'Sedan',
        services: ['Full Wash', 'Interior Cleaning', 'Wax Polish'],
        total: 1200,
        advance: 1200,
        method: 'UPI',
        status: 'Completed',
        staffName: 'Rajan',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      _make(
        id: 'svc002',
        name: 'Priya Nair',
        vehicle: 'KL07CD5678',
        phone: '8765432109',
        type: 'SUV',
        services: ['Ceramic Coating', 'Premium Detailing'],
        total: 4500,
        advance: 2000,
        method: 'Cash',
        status: 'Pending',
        staffName: 'Suresh',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      _make(
        id: 'svc003',
        name: 'Rajesh Kumar',
        vehicle: 'KL01EF9012',
        phone: '7654321098',
        type: 'Hatchback',
        services: ['Body Wash', 'Vacuum Cleaning'],
        total: 600,
        advance: 600,
        method: 'Cash',
        status: 'Completed',
        staffName: 'Rajan',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      _make(
        id: 'svc004',
        name: 'Meera Pillai',
        vehicle: 'KL04GH3456',
        phone: '6543210987',
        type: 'SUV',
        services: ['Foam Wash', 'Seat Shampoo', 'Engine Bay Cleaning'],
        total: 2800,
        advance: 1500,
        method: 'Both',
        status: 'Pending',
        staffName: 'Suresh',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      _make(
        id: 'svc005',
        name: 'Sunil Das',
        vehicle: 'KL16IJ7890',
        phone: '9988776655',
        type: 'Bike',
        services: ['Bike Detailing', 'Foam Wash'],
        total: 500,
        advance: 500,
        method: 'UPI',
        status: 'Completed',
        staffName: 'Rajan',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      _make(
        id: 'svc006',
        name: 'Anitha Krishnan',
        vehicle: 'KL08KL2345',
        phone: '8877665544',
        type: 'Sedan',
        services: ['Exterior Polishing', 'Headlight Restoration'],
        total: 1800,
        advance: 0,
        method: 'Cash',
        status: 'Pending',
        staffName: 'Suresh',
        createdAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      _make(
        id: 'svc007',
        name: 'Deepak Varma',
        vehicle: 'KL10MN6789',
        phone: '7766554433',
        type: 'Truck',
        services: ['Full Wash', 'Underbody Wash'],
        total: 1500,
        advance: 1500,
        method: 'Cash',
        status: 'Completed',
        staffName: 'Rajan',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      _make(
        id: 'svc008',
        name: 'Lakshmi Devi',
        vehicle: 'KL05OP0123',
        phone: '6655443322',
        type: 'Van',
        services: ['Interior Cleaning', 'Vacuum Cleaning', 'Seat Shampoo'],
        total: 2200,
        advance: 1000,
        method: 'UPI',
        status: 'Pending',
        staffName: 'Suresh',
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
      ),
    ];
  }

  static ServiceModel _make({
    required String id,
    required String name,
    required String vehicle,
    required String phone,
    required String type,
    required List<String> services,
    required double total,
    required double advance,
    required String method,
    required String status,
    required String staffName,
    required DateTime createdAt,
  }) {
    final balance = (total - advance).clamp(0, double.infinity).toDouble();
    final payStatus = advance <= 0
        ? 'Pending'
        : advance >= total
            ? 'Completed'
            : 'Partial';
    return ServiceModel(
      id: id,
      customerName: name,
      vehicleNumber: vehicle,
      phone: phone,
      vehicleType: type,
      services: services,
      totalAmount: total,
      advanceAmount: advance,
      balanceAmount: balance,
      paymentStatus: payStatus,
      paymentMethod: method,
      status: status,
      staffId: 'local_staff',
      staffName: staffName,
      createdAt: createdAt,
    );
  }

  // â”€â”€ Repository contract â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Stream<List<ServiceModel>> watchTodayServices() {
    final today = DateTime.now();
    final todayList = _store
        .where((s) =>
            s.createdAt != null &&
            s.createdAt!.year == today.year &&
            s.createdAt!.month == today.month &&
            s.createdAt!.day == today.day)
        .toList();

    // Emit current state + future changes
    return _controller.stream
        .map((all) => all
            .where((s) =>
                s.createdAt != null &&
                s.createdAt!.year == today.year &&
                s.createdAt!.month == today.month &&
                s.createdAt!.day == today.day)
            .toList())
        .startWith(todayList);
  }

  @override
  Stream<List<ServiceModel>> watchAllServices() {
    return _controller.stream.startWith(List.unmodifiable(_store));
  }

  @override
  Future<void> addService(ServiceModel service) async {
    await Future.microtask(() {});
    final withId = service.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    _store.insert(0, withId);
    _emit();
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    await Future.microtask(() {});
    final idx = _store.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _store[idx] = service;
      _emit();
    }
  }

  @override
  Future<void> deleteService(String id) async {
    await Future.microtask(() {});
    _store.removeWhere((s) => s.id == id);
    _emit();
  }

  @override
  Future<void> markCompleted(String id) async {
    await Future.microtask(() {});
    final idx = _store.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _store[idx] = _store[idx].copyWith(
        status: 'Completed',
        completedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<List<ServiceModel>> fetchHistory({
    dynamic lastDoc,
    int limit = 20,
    String? statusFilter,
  }) async {
    await Future.microtask(() {});
    var list = List<ServiceModel>.from(_store);
    list.sort((a, b) => (b.createdAt ?? DateTime(0))
        .compareTo(a.createdAt ?? DateTime(0)));
    if (statusFilter != null && statusFilter != 'All') {
      list = list.where((s) => s.status == statusFilter).toList();
    }
    return list.take(limit).toList();
  }

  @override
  Future<List<ServiceModel>> fetchByDateRange(
      DateTime from, DateTime to) async {
    await Future.microtask(() {});
    return _store
        .where((s) =>
            s.createdAt != null &&
            s.createdAt!.isAfter(from.subtract(const Duration(seconds: 1))) &&
            s.createdAt!.isBefore(to.add(const Duration(days: 1))))
        .toList();
  }
}

// â”€â”€ Stream helper extension â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

