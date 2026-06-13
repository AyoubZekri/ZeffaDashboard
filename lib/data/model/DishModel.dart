class DishModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? catUuid;
  final String? name;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DishModel({
    this.id,
    this.uuid,
    this.userId,
    this.catUuid,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      catUuid: json['cat_uuid'],
      name: json['name'],
      image: json['image'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'cat_uuid': catUuid,
      'name': name,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DishModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    String? catUuid,
    String? name,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DishModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      catUuid: catUuid ?? this.catUuid,
      name: name ?? this.name,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<DishModel> fromList(List data) {
    return data
        .map((e) => DishModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}