import 'RoleModel.dart';

class SubUserModel {
  final int? id;
  final String? username;
  final String? email;
  final int? roleId;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;
  final RoleModel? roleDetails;

  SubUserModel({
    this.id,
    this.username,
    this.email,
    this.roleId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.roleDetails,
  });

  factory SubUserModel.fromJson(Map<String, dynamic> json) {
    return SubUserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      roleId: json['role_id'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      roleDetails: json['role_details'] != null
          ? RoleModel.fromJson(json['role_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role_id': roleId,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<SubUserModel> fromList(List data) {
    return data
        .map((e) => SubUserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
