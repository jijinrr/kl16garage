import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import 'expense_repository.dart';

/// In-memory mock Expense repository.
class MockExpenseRepository implements ExpenseRepository {
  static const _uuid = Uuid();

  static final List<ExpenseModel> _store = _seed();
  static final _controller =
      StreamController<List<ExpenseModel>>.broadcast();

  /// Public read-only view used by MockAnalyticsRepository.
  static List<ExpenseModel> get allExpenses => List.unmodifiable(_store);

  static void _emit() => _controller.add(List.unmodifiable(_store));

  static List<ExpenseModel> _seed() {
    final now = DateTime.now();
    return [
      ExpenseModel(
        id: 'exp001',
        category: 'Supplies',
        title: 'Car Wash Shampoo',
        amount: 850,
        notes: 'Premium foam shampoo 5L',
        staffId: 'stf001',
        date: now,
      ),
      ExpenseModel(
        id: 'exp002',
        category: 'Supplies',
        title: 'Microfiber Cloths x10',
        amount: 450,
        notes: 'Replacement stock',
        staffId: 'stf002',
        date: now,
      ),
      ExpenseModel(
        id: 'exp003',
        category: 'Maintenance',
        title: 'Water Pump Repair',
        amount: 1200,
        notes: 'Fixed pressure pump',
        staffId: 'stf001',
        date: now.subtract(const Duration(days: 1)),
      ),
      ExpenseModel(
        id: 'exp004',
        category: 'Fuel',
        title: 'Generator Diesel',
        amount: 600,
        notes: '10L diesel',
        staffId: 'stf002',
        date: now.subtract(const Duration(days: 1)),
      ),
      ExpenseModel(
        id: 'exp005',
        category: 'Utilities',
        title: 'Electricity Bill',
        amount: 3200,
        notes: 'Monthly electricity',
        staffId: 'stf001',
        date: now.subtract(const Duration(days: 3)),
      ),
      ExpenseModel(
        id: 'exp006',
        category: 'Supplies',
        title: 'Ceramic Coating Kit',
        amount: 2800,
        notes: 'Professional grade kit',
        staffId: 'stf002',
        date: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  @override
  Stream<List<ExpenseModel>> watchTodayExpenses(String staffId) {
    final today = DateTime.now();
    bool isToday(ExpenseModel e) =>
        e.date != null &&
        e.date!.year == today.year &&
        e.date!.month == today.month &&
        e.date!.day == today.day;

    final todayList = _store.where(isToday).toList();

    return _controller.stream
        .map((all) => all.where(isToday).toList())
        .startWith(todayList);
  }

  @override
  Stream<List<ExpenseModel>> watchAllExpenses() {
    return _controller.stream.startWith(List.unmodifiable(_store));
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await Future.microtask(() {});
    final withId = expense.copyWith(id: _uuid.v4());
    _store.insert(0, withId);
    _emit();
  }

  @override
  Future<void> deleteExpense(String id) async {
    await Future.microtask(() {});
    _store.removeWhere((e) => e.id == id);
    _emit();
  }

  @override
  Future<List<ExpenseModel>> fetchByDateRange(
      DateTime from, DateTime to) async {
    await Future.microtask(() {});
    final start = from.subtract(const Duration(seconds: 1));
    final end = to.add(const Duration(days: 1));
    return _store
        .where((e) =>
            e.date != null &&
            e.date!.isAfter(start) &&
            e.date!.isBefore(end))
        .toList();
  }
}

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

