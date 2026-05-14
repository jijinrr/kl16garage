import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/constants/app_config.dart';
import '../core/errors/exceptions.dart';
import '../core/services/session.dart';
import '../core/services/storage_service.dart';
import '../core/utils/currency_helpers.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  ServiceProvider(this._repo);

  final ServiceRepository _repo;

  StreamSubscription<List<ServiceModel>>? _subscription;
  List<ServiceModel> _todayServices = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<ServiceModel> get todayServices => _filteredServices;
  List<ServiceModel> get allTodayServices => _todayServices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  // ── Derived stats ─────────────────────────────────────────────────────────
  int get totalVehicles => _todayServices.length;
  int get completedCount =>
      _todayServices.where((s) => s.status == 'Completed').length;
  int get pendingCount =>
      _todayServices.where((s) => s.status == 'Pending').length;
  double get todayRevenue =>
      _todayServices.fold(0.0, (sum, s) => sum + s.totalAmount);

  List<ServiceModel> get _filteredServices {
    var list = _todayServices;
    if (_statusFilter != 'All') {
      list = list.where((s) => s.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((s) =>
              s.vehicleNumber.toLowerCase().contains(q) ||
              s.customerName.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  // ── Stream listener ───────────────────────────────────────────────────────
  void startListening() {
    _subscription?.cancel();
    _subscription = _repo.watchTodayServices().listen(
      (services) {
        _todayServices = services;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<bool> addService({
    required ServiceModel service,
    List<File>? beforePhotos,
    List<File>? afterPhotos,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final uid = Session.uid;

      // Upload photos if provided (skipped in mock mode — Firebase Storage not configured)
      List<String> beforeUrls = [];
      List<String> afterUrls = [];
      if (!kUseMockData) {
        if (beforePhotos != null && beforePhotos.isNotEmpty) {
          beforeUrls = await StorageService.uploadMultiple(
              files: beforePhotos, folder: 'service_photos/before');
        }
        if (afterPhotos != null && afterPhotos.isNotEmpty) {
          afterUrls = await StorageService.uploadMultiple(
              files: afterPhotos, folder: 'service_photos/after');
        }
      }

      final balance = CurrencyHelpers.balance(
          service.totalAmount, service.advanceAmount);
      final status = CurrencyHelpers.paymentStatus(
          service.totalAmount, service.advanceAmount);

      final finalService = service.copyWith(
        staffId: uid,
        balanceAmount: balance,
        paymentStatus: status,
        beforePhotos: beforeUrls,
        afterPhotos: afterUrls,
      );

      await _repo.addService(finalService);
      return true;
    } on StorageException catch (e) {
      _error = e.message;
      return false;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final balance = CurrencyHelpers.balance(
          service.totalAmount, service.advanceAmount);
      final status = CurrencyHelpers.paymentStatus(
          service.totalAmount, service.advanceAmount);
      await _repo.updateService(
          service.copyWith(balanceAmount: balance, paymentStatus: status));
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deleteService(id);
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markCompleted(String id) async {
    try {
      await _repo.markCompleted(id);
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
