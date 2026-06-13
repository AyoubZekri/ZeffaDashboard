class NoteModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? title;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  NoteModel({
    this.id,
    this.uuid,
    this.userId,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  NoteModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    String? title,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<NoteModel> fromList(List data) {
    return data
        .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
