enum WishlistPriority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case WishlistPriority.low:
        return 'Low';
      case WishlistPriority.medium:
        return 'Medium';
      case WishlistPriority.high:
        return 'High';
    }
  }

  static WishlistPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return WishlistPriority.low;
      case 'medium':
        return WishlistPriority.medium;
      case 'high':
        return WishlistPriority.high;
      default:
        return WishlistPriority.medium;
    }
  }
}

class WishlistModel {
  final int? id;
  final int userId;
  final String itemName;
  final int quantity;
  final WishlistPriority priority;
  final String expectedMonth; // Format: YYYY-MM
  final String? notes;
  final bool isPurchased;
  final DateTime? purchasedDate;
  final DateTime createdAt;

  WishlistModel({
    this.id,
    required this.userId,
    required this.itemName,
    this.quantity = 1,
    required this.priority,
    required this.expectedMonth,
    this.notes,
    this.isPurchased = false,
    this.purchasedDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_name': itemName,
      'quantity': quantity,
      'priority': priority.name,
      'expected_month': expectedMonth,
      'notes': notes,
      'is_purchased': isPurchased ? 1 : 0,
      'purchased_date': purchasedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as int? ?? 1,
      priority: WishlistPriority.fromString(map['priority'] as String),
      expectedMonth: map['expected_month'] as String,
      notes: map['notes'] as String?,
      isPurchased: (map['is_purchased'] as int) == 1,
      purchasedDate: map['purchased_date'] != null
          ? DateTime.parse(map['purchased_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // CopyWith for immutability
  WishlistModel copyWith({
    int? id,
    int? userId,
    String? itemName,
    int? quantity,
    WishlistPriority? priority,
    String? expectedMonth,
    String? notes,
    bool? isPurchased,
    DateTime? purchasedDate,
    DateTime? createdAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
      expectedMonth: expectedMonth ?? this.expectedMonth,
      notes: notes ?? this.notes,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get formatted month name (e.g., "January 2024")
  String get formattedMonth {
    try {
      final parts = expectedMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${monthNames[month - 1]} $year';
    } catch (e) {
      return expectedMonth;
    }
  }

  // Check if expected month is current or future
  bool get isCurrentOrFuture {
    try {
      final parts = expectedMonth.split('-');
      final expectedDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      return expectedDate.isAfter(currentMonth) ||
          (expectedDate.year == currentMonth.year && 
           expectedDate.month == currentMonth.month);
    } catch (e) {
      return true;
    }
  }
}
