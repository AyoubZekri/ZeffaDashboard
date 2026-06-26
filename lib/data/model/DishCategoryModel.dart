class DishCategoryModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? name;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DishCategoryModel({
    this.id,
    this.uuid,
    this.userId,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory DishCategoryModel.fromJson(Map<String, dynamic> json) {
    return DishCategoryModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
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
      'name': name,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  DishCategoryModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    String? name,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DishCategoryModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<DishCategoryModel> fromList(List data) {
    return data
        .map((e) => DishCategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}