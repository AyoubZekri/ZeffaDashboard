class ServiceModel {
  int? id;
  String? uuid;
  int? userId;
  String? name;
  double? price;
  int? priceType; // 0 = fixed price, 1 = per person (price × guests)
  String? createdAt;
  String? updatedAt;

  ServiceModel({
    this.id,
    this.uuid,
    this.userId,
    this.name,
    this.price,
    this.priceType,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      name: json['name'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      priceType: (json['price_type'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'name': name,
      'price': price,
      'price_type': priceType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isPerPerson => priceType == 1;

  /// Cost in a reservation: per-person services are multiplied by the guests
  /// (no guests yet → 0)
  double costFor(int guests) =>
      isPerPerson ? (price ?? 0.0) * guests : (price ?? 0.0);

  static List<ServiceModel> fromList(List data) {
    return data.map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
