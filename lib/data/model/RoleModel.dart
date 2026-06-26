import 'dart:convert';

class RoleModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? name;
  final String? type; // 'full' or 'partial'
  final String? permissions; // JSON string of list of permissions
  final String? createdAt;
  final String? updatedAt;

  RoleModel({
    this.id,
    this.uuid,
    this.userId,
    this.name,
    this.type,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  List<String> get permissionsList {
    if (permissions == null || permissions!.isEmpty) return [];
    try {
      final decoded = jsonDecode(permissions!);
      return List<String>.from(decoded);
    } catch (e) {
      return [];
    }
  }

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      permissions: json['permissions'],
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
      'type': type,
      'permissions': permissions,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<RoleModel> fromList(List data) {
    return data
        .map((e) => RoleModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
