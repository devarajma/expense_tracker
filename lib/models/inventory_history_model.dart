import 'package:expense_tracker/models/stock_action_reason.dart';

class InventoryHistoryModel {
  final int? id;
  final int inventoryId;
  final int userId;
  final StockActionType actionType;
  final int quantity;
  final String reason;
  final DateTime date;

  InventoryHistoryModel({
    this.id,
    required this.inventoryId,
    required this.userId,
    required this.actionType,
    required this.quantity,
    required this.reason,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'user_id': userId,
      'action_type': actionType.name.toUpperCase(),
      'quantity': quantity,
      'reason': reason,
      'date': date.toIso8601String(),
    };
  }

  factory InventoryHistoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryHistoryModel(
      id: map['id'] as int?,
      inventoryId: map['inventory_id'] as int,
      userId: map['user_id'] as int,
      actionType: StockActionType.fromString(map['action_type'] as String),
      quantity: map['quantity'] as int,
      reason: map['reason'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  InventoryHistoryModel copyWith({
    int? id,
    int? inventoryId,
    int? userId,
    StockActionType? actionType,
    int? quantity,
    String? reason,
    DateTime? date,
  }) {
    return InventoryHistoryModel(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      userId: userId ?? this.userId,
      actionType: actionType ?? this.actionType,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      date: date ?? this.date,
    );
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedDateTime {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
