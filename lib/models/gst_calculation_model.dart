class GSTCalculationModel {
  final int? id;
  final int userId;
  final double amount;
  final double gstPercent;
  final double cgst;
  final double sgst;
  final double total;
  final DateTime date;

  GSTCalculationModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.gstPercent,
    required this.cgst,
    required this.sgst,
    required this.total,
    required this.date,
  });

  // Factory method to calculate GST
  factory GSTCalculationModel.calculate({
    int? id,
    required int userId,
    required double amount,
    required double gstPercent,
    DateTime? date,
  }) {
    final gstAmount = amount * (gstPercent / 100);
    final cgst = gstAmount / 2;
    final sgst = gstAmount / 2;
    final total = amount + gstAmount;

    return GSTCalculationModel(
      id: id,
      userId: userId,
      amount: amount,
      gstPercent: gstPercent,
      cgst: cgst,
      sgst: sgst,
      total: total,
      date: date ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'gstPercent': gstPercent,
      'cgst': cgst,
      'sgst': sgst,
      'total': total,
      'date': date.toIso8601String(),
    };
  }

  factory GSTCalculationModel.fromMap(Map<String, dynamic> map) {
    return GSTCalculationModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      amount: (map['amount'] as num).toDouble(),
      gstPercent: (map['gstPercent'] as num).toDouble(),
      cgst: (map['cgst'] as num).toDouble(),
      sgst: (map['sgst'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}
