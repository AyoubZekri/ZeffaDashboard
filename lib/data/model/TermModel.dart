class TermModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? title;
  final String? type; // 'internal_rules','contract_terms','required_procedures','required_documents'
  final String? createdAt;
  final String? updatedAt;
  
  // List of contents from Terms_content
  final List<String> contents;

  // Getter to return concatenated content for backwards compatibility
  String get content => contents.join("\n");

  TermModel({
    this.id,
    this.uuid,
    this.userId,
    this.title,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.contents = const [],
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedContents = [];
    if (json['contents'] != null) {
      parsedContents = List<String>.from(json['contents']);
    } else if (json['content'] != null) {
      // Fallback if it's a single string
      parsedContents = [json['content']];
    }
    return TermModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      title: json['title'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      contents: parsedContents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'user_id': userId,
      'title': title,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'contents': contents,
    };
  }

  TermModel copyWith({
    int? id,
    String? uuid,
    int? userId,
    String? title,
    String? type,
    String? createdAt,
    String? updatedAt,
    List<String>? contents,
  }) {
    return TermModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contents: contents ?? this.contents,
    );
  }

  static List<TermModel> fromList(List data) {
    return data
        .map((e) => TermModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
