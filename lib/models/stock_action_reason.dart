enum StockActionType {
  add,
  use;

  String get displayName {
    switch (this) {
      case StockActionType.add:
        return 'Add Stock';
      case StockActionType.use:
        return 'Use Stock';
    }
  }

  static StockActionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'add':
        return StockActionType.add;
      case 'use':
        return StockActionType.use;
      default:
        return StockActionType.add;
    }
  }
}

enum AddStockReason {
  purchased,
  returned,
  adjusted;

  String get displayName {
    switch (this) {
      case AddStockReason.purchased:
        return 'Purchased';
      case AddStockReason.returned:
        return 'Returned';
      case AddStockReason.adjusted:
        return 'Adjusted';
    }
  }

  static AddStockReason fromString(String value) {
    switch (value.toLowerCase()) {
      case 'purchased':
        return AddStockReason.purchased;
      case 'returned':
        return AddStockReason.returned;
      case 'adjusted':
        return AddStockReason.adjusted;
      default:
        return AddStockReason.purchased;
    }
  }
}

enum UseStockReason {
  order,
  damage,
  lost,
  adjusted;

  String get displayName {
    switch (this) {
      case UseStockReason.order:
        return 'Used for Order';
      case UseStockReason.damage:
        return 'Damaged';
      case UseStockReason.lost:
        return 'Lost';
      case UseStockReason.adjusted:
        return 'Adjusted';
    }
  }

  static UseStockReason fromString(String value) {
    switch (value.toLowerCase()) {
      case 'order':
        return UseStockReason.order;
      case 'damage':
        return UseStockReason.damage;
      case 'lost':
        return UseStockReason.lost;
      case 'adjusted':
        return UseStockReason.adjusted;
      default:
        return UseStockReason.order;
    }
  }
}

enum StockLevel {
  safe,
  low,
  critical;

  String get displayName {
    switch (this) {
      case StockLevel.safe:
        return 'Safe';
      case StockLevel.low:
        return 'Low Stock';
      case StockLevel.critical:
        return 'Critical';
    }
  }
}
