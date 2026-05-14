import '../models/service_model.dart';
import 'analytics_repository.dart';
import 'mock_expense_repository.dart';
import 'mock_service_repository.dart';

/// Derives analytics directly from the shared in-memory stores.
/// Uses the public static getters exposed by MockServiceRepository
/// and MockExpenseRepository so private data is not accessed cross-file.
class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<Map<String, dynamic>> fetchTodaySummary() async {
    await Future.microtask(() {});
    final today = DateTime.now();
    final services = MockServiceRepository.allServices
        .where((s) =>
            s.createdAt != null &&
            s.createdAt!.year == today.year &&
            s.createdAt!.month == today.month &&
            s.createdAt!.day == today.day)
        .toList();
    final expenses = MockExpenseRepository.allExpenses
        .where((e) =>
            e.date != null &&
            e.date!.year == today.year &&
            e.date!.month == today.month &&
            e.date!.day == today.day)
        .toList();
    return _buildSummary(services, expenses, period: 'today');
  }

  @override
  Future<Map<String, dynamic>> fetchWeeklySummary() async {
    await Future.microtask(() {});
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    return _rangeQuery(start, now, period: 'weekly');
  }

  @override
  Future<Map<String, dynamic>> fetchMonthlySummary() async {
    await Future.microtask(() {});
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return _rangeQuery(start, now, period: 'monthly');
  }

  Map<String, dynamic> _rangeQuery(DateTime from, DateTime to,
      {required String period}) {
    final start = from.subtract(const Duration(seconds: 1));
    final end = to.add(const Duration(days: 1));
    final services = MockServiceRepository.allServices
        .where((s) =>
            s.createdAt != null &&
            s.createdAt!.isAfter(start) &&
            s.createdAt!.isBefore(end))
        .toList();
    final expenses = MockExpenseRepository.allExpenses
        .where((e) =>
            e.date != null &&
            e.date!.isAfter(start) &&
            e.date!.isBefore(end))
        .toList();
    return _buildSummary(services, expenses, period: period);
  }

  Map<String, dynamic> _buildSummary(
      List<ServiceModel> services, List<dynamic> expenses,
      {required String period}) {
    final totalRevenue =
        services.fold(0.0, (acc, v) => acc + v.totalAmount);
    final totalExpenses =
        expenses.fold(0.0, (acc, e) => acc + (e.amount as double));
    final closed =
        services.where((s) => s.status == 'Completed').length;
    final total = services.length;
    final closingRate = total == 0 ? 0.0 : (closed / total) * 100;

    // Dummy weekly trend — scales with period
    final trend = period == 'today'
        ? [3.0, 5.0, 4.0, 6.0, 8.0, 7.0, closed.toDouble()]
        : period == 'weekly'
            ? [12.0, 18.0, 20.0, 15.0, 22.0, 24.0, 30.0]
            : [45.0, 52.0, 48.0, 60.0, 58.0, 72.0, 80.0];

    return {
      'totalVehicles': total,
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'profit': totalRevenue - totalExpenses,
      'completed': closed,
      'pending': services.where((s) => s.status == 'Pending').length,
      'paymentCompleted':
          services.where((s) => s.paymentStatus == 'Completed').length,
      'paymentPartial':
          services.where((s) => s.paymentStatus == 'Partial').length,
      'paymentPending':
          services.where((s) => s.paymentStatus == 'Pending').length,
      'services': services,
      'expenses': expenses,
      // Vehicle closing analytics
      'closedVehicles': closed,
      'closingRate': closingRate,
      'peakClosingTime': '4 PM – 7 PM',
      'bestClosingDay': 'Saturday',
      'closingTrend': trend,
    };
  }

  @override
  Future<List<ServiceModel>> fetchRecentActivity(int limit) async {
    await Future.microtask(() {});
    final sorted = List<ServiceModel>.from(MockServiceRepository.allServices)
      ..sort((a, b) => (b.createdAt ?? DateTime(0))
          .compareTo(a.createdAt ?? DateTime(0)));
    return sorted.take(limit).toList();
  }
}
