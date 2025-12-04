class ExpenseModel {
  final int? id;
  final int userId;
  final double amount;
  final String category;
  final String notes;
  final String? billPath;
  final DateTime date;

  ExpenseModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.notes,
    this.billPath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      'notes': notes,
      'billPath': billPath,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      notes: map['notes'] as String,
      billPath: map['billPath'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  ExpenseModel copyWith({
    int? id,
    int? userId,
    double? amount,
    String? category,
    String? notes,
    String? billPath,
    DateTime? date,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      billPath: billPath ?? this.billPath,
      date: date ?? this.date,
    );
  }
}
