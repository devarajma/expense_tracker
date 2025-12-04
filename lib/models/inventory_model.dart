class InventoryModel {
  final int? id;
  final int userId;
  final String name;
  final int quantity;
  final int lowStockThreshold;
  final DateTime lastUpdated;

  InventoryModel({
    this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.lowStockThreshold,
    required this.lastUpdated,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'quantity': quantity,
      'lowStockThreshold': lowStockThreshold,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      lowStockThreshold: map['lowStockThreshold'] as int,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  InventoryModel copyWith({
    int? id,
    int? userId,
    String? name,
    int? quantity,
    int? lowStockThreshold,
    DateTime? lastUpdated,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
