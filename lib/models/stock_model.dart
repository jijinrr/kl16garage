class StockModel {
  const StockModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.quantity,
    required this.minQuantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.supplierName,
    required this.supplierPhone,
    required this.notes,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final String category;
  final String brand;
  final int quantity;
  final int minQuantity;
  final double purchasePrice;
  final double sellingPrice;
  final String supplierName;
  final String supplierPhone;
  final String notes;
  final DateTime lastUpdated;

  bool get isOutOfStock => quantity == 0;
  bool get isLowStock => quantity > 0 && quantity <= minQuantity;
  String get stockStatus =>
      isOutOfStock ? 'Out of Stock' : isLowStock ? 'Low Stock' : 'In Stock';

  StockModel copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    int? quantity,
    int? minQuantity,
    double? purchasePrice,
    double? sellingPrice,
    String? supplierName,
    String? supplierPhone,
    String? notes,
    DateTime? lastUpdated,
  }) {
    return StockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
