import 'package:flutter/foundation.dart';
import '../models/stock_model.dart';
import '../repositories/stock_repository.dart';

class StockProvider extends ChangeNotifier {
  StockProvider(this._repo);

  final StockRepository _repo;

  List<StockModel> _items = [];
  String _search = '';
  String _categoryFilter = 'All';
  bool _isLoading = false;
  String? _error;

  List<StockModel> get items => _filtered;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get search => _search;
  String get categoryFilter => _categoryFilter;

  int get totalItems => _items.length;
  int get lowStockCount => _items.where((i) => i.isLowStock).length;
  int get outOfStockCount => _items.where((i) => i.isOutOfStock).length;
  int get recentlyAdded => _items
      .where((i) => i.lastUpdated
          .isAfter(DateTime.now().subtract(const Duration(days: 7))))
      .length;

  List<StockModel> get lowStockItems =>
      _items.where((i) => i.isLowStock || i.isOutOfStock).toList();

  List<StockModel> get _filtered {
    var list = List<StockModel>.from(_items);
    if (_categoryFilter == 'Low Stock') {
      list = list.where((i) => i.isLowStock || i.isOutOfStock).toList();
    } else if (_categoryFilter != 'All') {
      list = list.where((i) => i.category == _categoryFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              i.brand.toLowerCase().contains(q) ||
              i.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStock(StockModel stock) async {
    _isLoading = true;
    notifyListeners();
    final ok = await _repo.addStock(stock);
    if (ok) await fetchAll();
    _isLoading = false;
    notifyListeners();
    return ok;
  }

  Future<bool> updateStock(StockModel stock) async {
    _isLoading = true;
    notifyListeners();
    final ok = await _repo.updateStock(stock);
    if (ok) await fetchAll();
    _isLoading = false;
    notifyListeners();
    return ok;
  }

  Future<bool> deleteStock(String id) async {
    final ok = await _repo.deleteStock(id);
    if (ok) _items.removeWhere((i) => i.id == id);
    notifyListeners();
    return ok;
  }

  void setSearch(String v) {
    _search = v;
    notifyListeners();
  }

  void setCategoryFilter(String v) {
    _categoryFilter = v;
    notifyListeners();
  }
}
