class ReservationModel {
  final int? id;
  final String uuid;
  final int? userId;
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

  // Joined fields from party_type
  final String? partyTypeName;
  final double? partyBasicPrice;
  final double? partySeasonalPrice;
  final String? partyIcon;

  // Joined fields from dishes (comma-separated)
  final String? dishesNames;
  final String? dishesUuids;

  // Computed properties for UI
  final String customerType;
  final String time;
  final String avatarInitials;

  const ReservationModel({
    this.id,
    required this.uuid,
    this.userId,
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
    this.partyTypeName,
    this.partyBasicPrice,
    this.partySeasonalPrice,
    this.partyIcon,
    this.dishesNames,
    this.dishesUuids,
    this.customerType = 'عميل',
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
    return dishesNames!.split(', ').where((s) => s.isNotEmpty).toList();
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      uuid: json['uuid'] ?? '',
      userId: json['user_id'],
      customerName: json['username'] ?? '',
      phoneNumber: json['phone_numper'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingPeriod: json['booking_period'],
      typeOfPartyUuid: json['type_of_party_uuid'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      notes: json['notes'],
      deposit: json['deposit'] != null ? double.parse(json['deposit'].toString()) : 0.0,
      remainingAmount: json['remaining_amount'] != null ? double.parse(json['remaining_amount'].toString()) : 0.0,
      numberOfMen: json['number_of_men'] ?? 0,
      numberOfWomen: json['number_of_women'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      // Joined fields
      partyTypeName: json['party_type_name'],
      partyBasicPrice: json['party_basic_price'] != null ? double.tryParse(json['party_basic_price'].toString()) : null,
      partySeasonalPrice: json['party_seasonal_price'] != null ? double.tryParse(json['party_seasonal_price'].toString()) : null,
      partyIcon: json['party_icon'],
      dishesNames: json['dishes_names'],
      dishesUuids: json['dishes_uuids'],
      // Generated
      avatarInitials: json['username'] != null && json['username'].toString().isNotEmpty 
          ? json['username'].toString()[0] 
          : '?',
    );
  }
}
