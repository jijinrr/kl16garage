import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import '../models/service_model.dart';
import '../repositories/analytics_repository.dart';

enum AnalyticsPeriod { today, weekly, monthly }

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider(this._repo);

  final AnalyticsRepository _repo;

  Map<String, dynamic> _summary = {};
  List<ServiceModel> _recentActivity = [];
  AnalyticsPeriod _period = AnalyticsPeriod.today;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get summary => _summary;
  List<ServiceModel> get recentActivity => _recentActivity;
  AnalyticsPeriod get period => _period;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Derived getters ───────────────────────────────────────────────────────
  double get totalRevenue =>
      (_summary['totalRevenue'] as double?) ?? 0.0;
  double get totalExpenses =>
      (_summary['totalExpenses'] as double?) ?? 0.0;
  double get profit =>
      (_summary['profit'] as double?) ?? 0.0;
  int get totalVehicles =>
      (_summary['totalVehicles'] as int?) ?? 0;
  int get paymentCompleted =>
      (_summary['paymentCompleted'] as int?) ?? 0;
  int get paymentPartial =>
      (_summary['paymentPartial'] as int?) ?? 0;
  int get paymentPending =>
      (_summary['paymentPending'] as int?) ?? 0;

  // ── Vehicle closing analytics ─────────────────────────────────────────────
  int get closedVehicles =>
      (_summary['closedVehicles'] as int?) ?? 0;
  double get closingRate =>
      (_summary['closingRate'] as double?) ?? 0.0;
  String get peakClosingTime =>
      (_summary['peakClosingTime'] as String?) ?? '4 PM – 7 PM';
  String get bestClosingDay =>
      (_summary['bestClosingDay'] as String?) ?? 'Saturday';
  List<double> get closingTrend =>
      (_summary['closingTrend'] as List<double>?) ??
      [12, 18, 20, 15, 22, 24, 30];

  Future<void> fetchSummary([AnalyticsPeriod? period]) async {
    if (period != null) _period = period;
    _isLoading = true;
    _error = null;
    notifyListeners(); // show spinner
    try {
      switch (_period) {
        case AnalyticsPeriod.today:
          _summary = await _repo.fetchTodaySummary();
        case AnalyticsPeriod.weekly:
          _summary = await _repo.fetchWeeklySummary();
        case AnalyticsPeriod.monthly:
          _summary = await _repo.fetchMonthlySummary();
      }
    } on DatabaseException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners(); // hide spinner + paint data in one frame
    }
  }

  Future<void> fetchRecentActivity() async {
    try {
      _recentActivity = await _repo.fetchRecentActivity(10);
      notifyListeners();
    } on DatabaseException catch (_) {
      // Silent fail for activity feed
    }
  }

  void setPeriod(AnalyticsPeriod p) {
    _period = p;
    fetchSummary();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
