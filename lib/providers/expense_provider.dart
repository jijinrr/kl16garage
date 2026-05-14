import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import '../core/services/session.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._repo);

  final ExpenseRepository _repo;

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get todayTotal =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  void startListening() {
    final uid = Session.uid;
    _repo.watchTodayExpenses(uid).listen(
      (list) {
        _expenses = list;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> addExpense({
    required String category,
    required String title,
    required double amount,
    String notes = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final uid = Session.uid;
      final expense = ExpenseModel(
        id: '',
        category: category,
        title: title,
        amount: amount,
        notes: notes,
        staffId: uid,
        date: DateTime.now(),
      );
      await _repo.addExpense(expense);
      return true;
    } on DatabaseException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExpense(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.deleteExpense(id);
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
