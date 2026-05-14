import '../models/stock_model.dart';
import 'stock_repository.dart';

class MockStockRepository implements StockRepository {
  static final List<StockModel> _items = [
    StockModel(
      id: 's1',
      name: 'Microfiber Towels',
      category: 'Towels',
      brand: 'CleanPro',
      quantity: 45,
      minQuantity: 20,
      purchasePrice: 35,
      sellingPrice: 60,
      supplierName: 'Auto Supplies India',
      supplierPhone: '9876543210',
      notes: 'Premium 400 GSM microfiber',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockModel(
      id: 's2',
      name: 'Foam Shampoo',
      category: 'Liquids',
      brand: 'CarGloss',
      quantity: 8,
      minQuantity: 10,
      purchasePrice: 220,
      sellingPrice: 380,
      supplierName: 'Chemical Mart',
      supplierPhone: '9765432100',
      notes: '5L cans, high foam formula',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StockModel(
      id: 's3',
      name: 'Ceramic Spray',
      category: 'Liquids',
      brand: 'ShineMax',
      quantity: 0,
      minQuantity: 5,
      purchasePrice: 450,
      sellingPrice: 750,
      supplierName: 'Detail World',
      supplierPhone: '9654321009',
      notes: 'SiO2 based, 500ml bottles',
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
    ),
    StockModel(
      id: 's4',
      name: 'Wheel Cleaner',
      category: 'Liquids',
      brand: 'RimGuard',
      quantity: 12,
      minQuantity: 8,
      purchasePrice: 180,
      sellingPrice: 300,
      supplierName: 'Chemical Mart',
      supplierPhone: '9765432100',
      notes: 'Acid-free formula, 1L bottles',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockModel(
      id: 's5',
      name: 'Pressure Washer Nozzle',
      category: 'Machines',
      brand: 'JetFlow',
      quantity: 6,
      minQuantity: 3,
      purchasePrice: 850,
      sellingPrice: 1400,
      supplierName: 'Tools & More',
      supplierPhone: '9543210987',
      notes: '5-in-1 adjustable nozzle set',
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
    ),
    StockModel(
      id: 's6',
      name: 'Tyre Dressing',
      category: 'Liquids',
      brand: 'BlackShine',
      quantity: 3,
      minQuantity: 6,
      purchasePrice: 160,
      sellingPrice: 280,
      supplierName: 'Auto Supplies India',
      supplierPhone: '9876543210',
      notes: 'Water-based, 500ml spray',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    StockModel(
      id: 's7',
      name: 'Glass Cleaner',
      category: 'Liquids',
      brand: 'ClearView',
      quantity: 18,
      minQuantity: 10,
      purchasePrice: 95,
      sellingPrice: 160,
      supplierName: 'Chemical Mart',
      supplierPhone: '9765432100',
      notes: 'Streak-free formula, 1L',
      lastUpdated: DateTime.now().subtract(const Duration(days: 4)),
    ),
    StockModel(
      id: 's8',
      name: 'Clay Bar Kit',
      category: 'Accessories',
      brand: 'SmoothFinish',
      quantity: 9,
      minQuantity: 5,
      purchasePrice: 380,
      sellingPrice: 650,
      supplierName: 'Detail World',
      supplierPhone: '9654321009',
      notes: 'Fine grade, 200g bars',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StockModel(
      id: 's9',
      name: 'Foam Cannon',
      category: 'Machines',
      brand: 'SprayPro',
      quantity: 4,
      minQuantity: 2,
      purchasePrice: 1200,
      sellingPrice: 1900,
      supplierName: 'Tools & More',
      supplierPhone: '9543210987',
      notes: 'Compatible with all pressure washers',
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
    ),
    StockModel(
      id: 's10',
      name: 'Dashboard Polish',
      category: 'Liquids',
      brand: 'InteriorPro',
      quantity: 14,
      minQuantity: 8,
      purchasePrice: 130,
      sellingPrice: 220,
      supplierName: 'Auto Supplies India',
      supplierPhone: '9876543210',
      notes: 'UV protection, vanilla scent',
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
    ),
    StockModel(
      id: 's11',
      name: 'Detailing Brush Set',
      category: 'Accessories',
      brand: 'BrushMaster',
      quantity: 2,
      minQuantity: 5,
      purchasePrice: 290,
      sellingPrice: 500,
      supplierName: 'Detail World',
      supplierPhone: '9654321009',
      notes: '10-piece set, soft bristles',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StockModel(
      id: 's12',
      name: 'Wax Applicator Pads',
      category: 'Accessories',
      brand: 'ApplyRight',
      quantity: 60,
      minQuantity: 20,
      purchasePrice: 15,
      sellingPrice: 30,
      supplierName: 'Auto Supplies India',
      supplierPhone: '9876543210',
      notes: 'Pack of 10, foam pads',
      lastUpdated: DateTime.now().subtract(const Duration(days: 6)),
    ),
    StockModel(
      id: 's13',
      name: 'Engine Degreaser',
      category: 'Liquids',
      brand: 'PowerClean',
      quantity: 0,
      minQuantity: 4,
      purchasePrice: 250,
      sellingPrice: 420,
      supplierName: 'Chemical Mart',
      supplierPhone: '9765432100',
      notes: 'Heavy-duty formula, 2L',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StockModel(
      id: 's14',
      name: 'Orbital Polisher',
      category: 'Machines',
      brand: 'ProOrbit',
      quantity: 2,
      minQuantity: 1,
      purchasePrice: 4500,
      sellingPrice: 7500,
      supplierName: 'Tools & More',
      supplierPhone: '9543210987',
      notes: '15mm throw, 180W motor',
      lastUpdated: DateTime.now().subtract(const Duration(days: 10)),
    ),
    StockModel(
      id: 's15',
      name: 'Air Freshener',
      category: 'Accessories',
      brand: 'FreshCar',
      quantity: 30,
      minQuantity: 15,
      purchasePrice: 40,
      sellingPrice: 80,
      supplierName: 'Auto Supplies India',
      supplierPhone: '9876543210',
      notes: 'New car scent, hanging type',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static List<StockModel> get allItems => List.unmodifiable(_items);

  @override
  Future<List<StockModel>> fetchAll() async {
    await Future.microtask(() {});
    return List.from(_items);
  }

  @override
  Future<bool> addStock(StockModel stock) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _items.add(stock.copyWith(
      id: 's${DateTime.now().millisecondsSinceEpoch}',
      lastUpdated: DateTime.now(),
    ));
    return true;
  }

  @override
  Future<bool> updateStock(StockModel stock) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _items.indexWhere((i) => i.id == stock.id);
    if (idx == -1) return false;
    _items[idx] = stock.copyWith(lastUpdated: DateTime.now());
    return true;
  }

  @override
  Future<bool> deleteStock(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.removeWhere((i) => i.id == id);
    return true;
  }
}
