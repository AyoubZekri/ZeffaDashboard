class NotificationModel {
  int? id;
  String? uuid;
  int? userId;
  String? title;
  String? content;
  bool isRead;
  String? type;
  String? createdAt;
  String? updatedAt;

  NotificationModel({
    this.id,
    this.uuid,
    this.userId,
    this.title,
    this.content,
    this.isRead = false,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        uuid = json['uuid'],
        userId = json['user_id'],
        title = json['title'],
        content = json['content'],
        isRead = json['is_read'] == 1,
        type = json['type'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['user_id'] = userId;
    data['title'] = title;
    data['content'] = content;
    data['is_read'] = isRead ? 1 : 0;
    data['type'] = type;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
