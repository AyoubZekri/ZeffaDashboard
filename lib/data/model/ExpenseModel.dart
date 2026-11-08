class ExpenseModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? reservationUuid; // Linked reservation (wedding), optional
  // Workers expense by count: value = count × price per person
  final int? workersCount;
  final int? femaleWorkersCount;
  final double? workerPrice;
  final double? femaleWorkerPrice;
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
    this.reservationUuid,
    this.workersCount,
    this.femaleWorkersCount,
    this.workerPrice,
    this.femaleWorkerPrice,
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
      reservationUuid: json['reservation_uuid'],
      workersCount: (json['workers_count'] as num?)?.toInt(),
      femaleWorkersCount: (json['female_workers_count'] as num?)?.toInt(),
      workerPrice: json['worker_price'] != null ? (json['worker_price'] as num).toDouble() : null,
      femaleWorkerPrice: json['female_worker_price'] != null ? (json['female_worker_price'] as num).toDouble() : null,
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
      'reservation_uuid': reservationUuid,
      'workers_count': workersCount,
      'female_workers_count': femaleWorkersCount,
      'worker_price': workerPrice,
      'female_worker_price': femaleWorkerPrice,
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
    String? reservationUuid,
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
      reservationUuid: reservationUuid ?? this.reservationUuid,
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
