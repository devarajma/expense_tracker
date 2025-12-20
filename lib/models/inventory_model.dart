import 'package:expense_tracker/models/stock_action_reason.dart';

class InventoryModel {
  final int? id;
  final int userId;
  final String name;
  final String? category;
  final int quantity;
  final int lowStockThreshold;
  final String unit;
  final String? notes;
  final DateTime lastUpdated;

  InventoryModel({
    this.id,
    required this.userId,
    required this.name,
    this.category,
    required this.quantity,
    required this.lowStockThreshold,
    this.unit = 'pcs',
    this.notes,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  bool get isLowStock => quantity <= lowStockThreshold;
  bool get isCritical => quantity < lowStockThreshold;

  StockLevel get stockLevel {
    if (quantity >= lowStockThreshold * 2) {
      return StockLevel.safe;
    } else if (quantity >= lowStockThreshold) {
      return StockLevel.low;
    } else {
      return StockLevel.critical;
    }
  }

  double get stockPercentage {
    if (lowStockThreshold == 0) return 1.0;
    final safeLevel = lowStockThreshold * 2;
    return (quantity / safeLevel).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'unit': unit,
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      name: map['name'] as String,
      category: map['category'] as String?,
      quantity: map['quantity'] as int,
      lowStockThreshold: map['lowStockThreshold'] as int,
      unit: map['unit'] as String? ?? 'pcs',
      notes: map['notes'] as String?,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  InventoryModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? category,
    int? quantity,
    int? lowStockThreshold,
    String? unit,
    String? notes,
    DateTime? lastUpdated,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
