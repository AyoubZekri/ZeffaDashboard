class SpecialDateModel {
  final int? id;
  final String? uuid;
  final String? reservationUuid;
  final int? userId;
  final String? title;
  final String? type; // 'special_day', 'friday', 'reserved', 'special_period'
  final String? startDate; // For periods
  final String? endDate; // For periods
  final String? date; // For single days
  final String? createdAt;
  final String? updatedAt;

  // Joined fields from reservations and party_types
  final String? customerName;
  final String? customerPhone;
  final int? bookingId;
  final String? eventType;

  SpecialDateModel({
    this.id,
    this.uuid,
    this.reservationUuid,
    this.userId,
    this.title,
    this.type,
    this.startDate,
    this.endDate,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerPhone,
    this.bookingId,
    this.eventType,
  });

  factory SpecialDateModel.fromJson(Map<String, dynamic> json) {
    return SpecialDateModel(
      id: json['id'],
      uuid: json['uuid'],
      reservationUuid: json['reservation_uuid'],
      userId: json['user_id'],
      title: json['title'],
      type: json['type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      date: json['date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      bookingId: json['booking_id'],
      eventType: json['event_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'reservation_uuid': reservationUuid,
      'user_id': userId,
      'title': title,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'booking_id': bookingId,
      'event_type': eventType,
    };
  }

  static List<SpecialDateModel> fromList(List<Map<String, dynamic>> list) {
    return list.map((e) => SpecialDateModel.fromJson(e)).toList();
  }
}
