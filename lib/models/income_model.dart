class IncomeModel {
  final int? id;
  final int userId;
  final double amount;
  final String category;
  final String notes;
  final DateTime date;

  IncomeModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      notes: map['notes'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  IncomeModel copyWith({
    int? id,
    int? userId,
    double? amount,
    String? category,
    String? notes,
    DateTime? date,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      date: date ?? this.date,
    );
  }
}
