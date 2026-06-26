import 'dart:convert';

class PartyTypeModel {
  final int? id;
  final String? uuid;
  final int? userId;
  final String? name;
  final String? content;
  final double? basicPrice;
  final double? seasonalPrice;
  final List<Map<String, dynamic>>? guestPricingTiers;
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
    this.guestPricingTiers,
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
      guestPricingTiers: _parseTiers(json['guest_pricing_tiers']),
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
      'guest_pricing_tiers': guestPricingTiers != null ? jsonEncode(guestPricingTiers) : null,
      'icon': icon,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static List<Map<String, dynamic>>? _parseTiers(dynamic tiersJson) {
    if (tiersJson == null) return null;
    if (tiersJson is List) {
      return tiersJson.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (tiersJson is Map) {
      return [Map<String, dynamic>.from(tiersJson)];
    }
    if (tiersJson is String) {
      if (tiersJson.isEmpty) return null;
      try {
        final dynamic decoded = jsonDecode(tiersJson);
        if (decoded is List) {
          return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } else if (decoded is Map) {
          return [Map<String, dynamic>.from(decoded)];
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<PartyTypeModel> fromList(List data) {
    return data
        .map((e) => PartyTypeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
