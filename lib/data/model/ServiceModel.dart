class ServiceModel {
  int? id;
  String? uuid;
  int? userId;
  String? name;
  double? price;
  String? createdAt;
  String? updatedAt;

  ServiceModel({
    this.id,
    this.uuid,
    this.userId,
    this.name,
    this.price,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<ServiceModel> fromList(List data) {
    return data.map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
