class BudgetModel {
  final int? id;
  final int userId;
  final double monthlyBudget;
  final double spentAmount;
  final int month;
  final int year;

  BudgetModel({
    this.id,
    required this.userId,
    required this.monthlyBudget,
    required this.spentAmount,
    required this.month,
    required this.year,
  });

  double get remainingBudget => monthlyBudget - spentAmount;
  double get percentUsed => (spentAmount / monthlyBudget * 100).clamp(0, 100);
  bool get isOverBudget => spentAmount > monthlyBudget;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'monthlyBudget': monthlyBudget,
      'spentAmount': spentAmount,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      monthlyBudget: (map['monthlyBudget'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  BudgetModel copyWith({
    int? id,
    int? userId,
    double? monthlyBudget,
    double? spentAmount,
    int? month,
    int? year,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
