class PartyTypeModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? name;
  final String? content;
  final double? basicPrice;
  final double? seasonalPrice;
  final String? icon;
  final String? createdAt;
  final String? updatedAt;

  PartyTypeModel({
    this.id,
    this.uuid,
    this.userId,
    this.name,
    this.content,
    this.basicPrice,
    this.seasonalPrice,
    this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory PartyTypeModel.fromJson(Map<String, dynamic> json) {
    return PartyTypeModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      name: json['name'],
      content: json['content'],
      basicPrice: json['basic_price'] != null ? (json['basic_price'] as num).toDouble() : null,
      seasonalPrice: json['seasonal_price'] != null ? (json['seasonal_price'] as num).toDouble() : null,
      icon: json['icon'],
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
      'content': content,
      'basic_price': basicPrice,
      'seasonal_price': seasonalPrice,
      'icon': icon,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<PartyTypeModel> fromList(List data) {
    return data
        .map((e) => PartyTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
