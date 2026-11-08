class HallModel {
  final int? id;
  final String? uuid; // null = the account's own hall (from profile)
  final int? userId;
  final String? name;
  final String? phone1; // Admin manager phone (empty → account phone)
  final String? phone2; // Field manager phone (empty → account phone)
  final String? address; // Location (empty → account address)
  final String? createdAt;
  final String? updatedAt;

  HallModel({
    this.id,
    this.uuid,
    this.userId,
    this.name,
    this.phone1,
    this.phone2,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAccountHall => uuid == null;

  factory HallModel.fromJson(Map<String, dynamic> json) {
    return HallModel(
      id: json['id'],
      uuid: json['uuid'],
      userId: json['user_id'],
      name: json['name'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      address: json['address'],
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
      'phone1': phone1,
      'phone2': phone2,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<HallModel> fromList(List data) {
    return data
        .map((e) => HallModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
