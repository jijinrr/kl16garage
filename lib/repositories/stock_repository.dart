import '../models/stock_model.dart';

abstract class StockRepository {
  Future<List<StockModel>> fetchAll();
  Future<bool> addStock(StockModel stock);
  Future<bool> updateStock(StockModel stock);
  Future<bool> deleteStock(String id);
}
