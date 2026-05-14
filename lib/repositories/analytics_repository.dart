import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../core/services/firebase_service.dart';
import '../models/expense_model.dart';
import '../models/service_model.dart';

/// Provides aggregated data for analytics charts.
abstract class AnalyticsRepository {
  Future<Map<String, dynamic>> fetchTodaySummary();
  Future<Map<String, dynamic>> fetchWeeklySummary();
  Future<Map<String, dynamic>> fetchMonthlySummary();
  Future<List<ServiceModel>> fetchRecentActivity(int limit);
}

class FirestoreAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<Map<String, dynamic>> fetchTodaySummary() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final serviceSnap = await FirebaseService.services
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final expenseSnap = await FirebaseService.expenses
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final services =
          serviceSnap.docs.map(ServiceModel.fromFirestore).toList();
      final expenses =
          expenseSnap.docs.map(ExpenseModel.fromFirestore).toList();

      final totalRevenue =
          services.fold(0.0, (sum, s) => sum + s.totalAmount);
      final totalExpenses =
          expenses.fold(0.0, (sum, e) => sum + e.amount);
      final completed =
          services.where((s) => s.status == 'Completed').length;
      final pending =
          services.where((s) => s.status == 'Pending').length;

      return {
        'totalVehicles': services.length,
        'totalRevenue': totalRevenue,
        'totalExpenses': totalExpenses,
        'profit': totalRevenue - totalExpenses,
        'completed': completed,
        'pending': pending,
      };
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch today summary.');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchWeeklySummary() async {
    try {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(monday.year, monday.month, monday.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return await _fetchRangeSummary(start, end);
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch weekly summary.');
    }
  }

  @override
  Future<Map<String, dynamic>> fetchMonthlySummary() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return await _fetchRangeSummary(start, end);
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch monthly summary.');
    }
  }

  Future<Map<String, dynamic>> _fetchRangeSummary(
      DateTime from, DateTime to) async {
    final serviceSnap = await FirebaseService.services
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    final expenseSnap = await FirebaseService.expenses
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    final services =
        serviceSnap.docs.map(ServiceModel.fromFirestore).toList();
    final expenses =
        expenseSnap.docs.map(ExpenseModel.fromFirestore).toList();

    final totalRevenue =
        services.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalExpenses =
        expenses.fold(0.0, (sum, e) => sum + e.amount);

    // Payment status breakdown
    final paymentCompleted =
        services.where((s) => s.paymentStatus == 'Completed').length;
    final paymentPartial =
        services.where((s) => s.paymentStatus == 'Partial').length;
    final paymentPending =
        services.where((s) => s.paymentStatus == 'Pending').length;

    return {
      'totalVehicles': services.length,
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'profit': totalRevenue - totalExpenses,
      'paymentCompleted': paymentCompleted,
      'paymentPartial': paymentPartial,
      'paymentPending': paymentPending,
      'services': services,
      'expenses': expenses,
    };
  }

  @override
  Future<List<ServiceModel>> fetchRecentActivity(int limit) async {
    try {
      final snap = await FirebaseService.services
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(ServiceModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch activity.');
    }
  }
}
