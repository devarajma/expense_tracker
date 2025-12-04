class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' or 'expense'
  final int userId;

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'userId': userId,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      userId: map['userId'] as int,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    int? userId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      userId: userId ?? this.userId,
    );
  }
}
