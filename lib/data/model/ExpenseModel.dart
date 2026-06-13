class ExpenseModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final int? type; // 1: maintenance workers, 2: cleaning materials, 3: other expenses
  final String? description; // Expense name
  final double? value; // Amount
  final String? datePerry; // Date of the expense
  final String? createdAt;
  final String? updatedAt;

  ExpenseModel({
    this.id,
    this.uuid,
    this.userId,
    this.type,
    this.description,
    this.value,
    this.datePerry,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      type: json['type'],
      description: json['description'],
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      datePerry: json['date_perry'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'type': type,
      'description': description,
      'value': value,
      'date_perry': datePerry,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ExpenseModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    int? type,
    String? description,
    double? value,
    String? datePerry,
    String? createdAt,
    String? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      value: value ?? this.value,
      datePerry: datePerry ?? this.datePerry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<ExpenseModel> fromList(List data) {
    return data
        .map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
