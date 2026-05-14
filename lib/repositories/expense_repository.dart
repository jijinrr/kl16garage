import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/date_helpers.dart';
import '../models/expense_model.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseModel>> watchTodayExpenses(String staffId);
  Stream<List<ExpenseModel>> watchAllExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<List<ExpenseModel>> fetchByDateRange(DateTime from, DateTime to);
}

class FirestoreExpenseRepository implements ExpenseRepository {
  @override
  Stream<List<ExpenseModel>> watchTodayExpenses(String staffId) {
    final start = DateHelpers.startOfDay(DateTime.now());
    final end = DateHelpers.endOfDay(DateTime.now());
    return FirebaseService.expenses
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ExpenseModel.fromFirestore).toList());
  }

  @override
  Stream<List<ExpenseModel>> watchAllExpenses() {
    return FirebaseService.expenses
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ExpenseModel.fromFirestore).toList());
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await FirebaseService.expenses
          .add(ExpenseModel.toFirestore(expense));
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to add expense.');
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await FirebaseService.expenses.doc(id).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to delete expense.');
    }
  }

  @override
  Future<List<ExpenseModel>> fetchByDateRange(
      DateTime from, DateTime to) async {
    try {
      final snap = await FirebaseService.expenses
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(ExpenseModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch expenses.');
    }
  }
}
