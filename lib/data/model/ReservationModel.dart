import 'package:get/get.dart';

class ReservationModel {
  final int? id;
  final String uuid;
  final int? userId;
  final String? numperReservation;
  final String customerName;
  final String phoneNumber;
  final String bookingDate;
  final int? bookingPeriod;
  final String typeOfPartyUuid;
  final double price;
  final String? notes;
  final double deposit;
  final double remainingAmount;
  final int numberOfMen;
  final int numberOfWomen;
  final String? createdAt;
  final String? updatedAt;
  final String? addedByName;

  // Joined fields from party_types
  final String? partyTypeName;
  final double? partyBasicPrice;
  final double? partySeasonalPrice;
  final String? partyIcon;

  // Joined fields from dishes (comma-separated)
  final String? dishesNames;
  final String? dishesUuids;

  // Joined fields from services (comma-separated)
  final String? servicesNames;
  final String? servicesUuids;

  // Computed properties for UI
  final String? customerType;
  final String time;
  final String avatarInitials;

  const ReservationModel({
    this.id,
    required this.uuid,
    this.userId,
    this.numperReservation,
    required this.customerName,
    required this.phoneNumber,
    required this.bookingDate,
    this.bookingPeriod,
    required this.typeOfPartyUuid,
    required this.price,
    this.notes,
    required this.deposit,
    required this.remainingAmount,
    required this.numberOfMen,
    required this.numberOfWomen,
    this.createdAt,
    this.updatedAt,
    this.addedByName,
    this.partyTypeName,
    this.partyBasicPrice,
    this.partySeasonalPrice,
    this.partyIcon,
    this.dishesNames,
    this.dishesUuids,
    this.servicesNames,
    this.servicesUuids,
    this.customerType,
    this.time = '',
    this.avatarInitials = '',
  });

  // Dynamic Status Key Computation
  String get statusKey {
    if (deposit >= price || remainingAmount <= 0) {
      return 'fully_paid';
    } else if (deposit > 0 && remainingAmount > 0) {
      return 'partially_paid';
    } else {
      return 'unpaid';
    }
  }

  // Get dishes as a list of UUIDs
  List<String> get dishesUuidList {
    if (dishesUuids == null || dishesUuids!.isEmpty) return [];
    return dishesUuids!.split(',').where((s) => s.isNotEmpty).toList();
  }

  // Get dishes as a list of names
  List<String> get dishesNameList {
    if (dishesNames == null || dishesNames!.isEmpty) return [];
    return dishesNameList_helper();
  }

  List<String> dishesNameList_helper() {
    if (dishesNames == null || dishesNames!.isEmpty) return [];
    return dishesNames!.split(',').where((s) => s.isNotEmpty).toList();
  }

  // Get services as a list of UUIDs
  List<String> get servicesUuidList {
    if (servicesUuids == null || servicesUuids!.isEmpty) return [];
    return servicesUuids!.split(',').where((s) => s.isNotEmpty).toList();
  }

  // Get services as a list of names
  List<String> get servicesNameList {
    if (servicesNames == null || servicesNames!.isEmpty) return [];
    return servicesNames!.split(',').where((s) => s.isNotEmpty).toList();
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      uuid: json['uuid'] ?? '',
      userId: json['user_id'],
      numperReservation: json['numperReservation'],
      customerName: json['username'] ?? '',
      phoneNumber: json['phone_numper'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingPeriod: json['booking_period'],
      typeOfPartyUuid: json['type_of_party_uuid'] ?? '',
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : 0.0,
      notes: json['notes'],
      deposit: json['deposit'] != null
          ? double.parse(json['deposit'].toString())
          : 0.0,
      remainingAmount: json['remaining_amount'] != null
          ? double.parse(json['remaining_amount'].toString())
          : 0.0,
      numberOfMen: json['number_of_men'] ?? 0,
      numberOfWomen: json['number_of_women'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      addedByName: json['added_by_name'],
      // Joined fields
      partyTypeName: json['party_type_name'],
      partyBasicPrice: json['basic_price'] != null
          ? (json['basic_price'] as num).toDouble()
          : null,
      partySeasonalPrice: json['seasonal_price'] != null
          ? (json['seasonal_price'] as num).toDouble()
          : null,
      partyIcon: json['party_icon'],
      dishesNames: json['dishes_names'],
      dishesUuids: json['dishes_uuids'],
      servicesNames: json['services_names'],
      servicesUuids: json['services_uuids'],
      time: '10:00 AM - 02:00 PM', // Placeholder
      // Generated
      avatarInitials:
          json['username'] != null && json['username'].toString().isNotEmpty
          ? json['username'].toString()[0]
          : '?',
    );
  }

  static List<ReservationModel> fromList(List data) {
    return data
        .map((e) => ReservationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
