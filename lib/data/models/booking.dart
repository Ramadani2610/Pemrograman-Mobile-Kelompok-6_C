class Booking {
  final String id;
  String userId;
  String facilityId;
  String? roomId; // optional, if booking a room
  DateTime startDate;
  DateTime endDate;
  String status; // 'pending', 'approved', 'rejected', 'returned'
  String? approvedBy;
  DateTime? approvedAt;
  String purpose;
  int quantity;

  Booking({
    required this.id,
    required this.userId,
    required this.facilityId,
    this.roomId,
    required this.startDate,
    required this.endDate,
    String? status,
    this.approvedBy,
    this.approvedAt,
    String? purpose,
    int? quantity,
  }) : status = status ?? 'pending',
       purpose = purpose ?? '',
       quantity = quantity ?? 1;

  factory Booking.fromMap(Map<String, dynamic> m) => Booking(
    id: m['id'] as String,
    userId: m['userId'] as String,
    facilityId: m['facilityId'] as String,
    roomId: m['roomId'] as String?,
    startDate: DateTime.parse(m['startDate'] as String),
    endDate: DateTime.parse(m['endDate'] as String),
    status: m['status'] as String? ?? 'pending',
    approvedBy: m['approvedBy'] as String?,
    approvedAt: m['approvedAt'] != null
        ? DateTime.parse(m['approvedAt'] as String)
        : null,
    purpose: m['purpose'] as String? ?? '',
    quantity: (m['quantity'] as num?)?.toInt() ?? 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'facilityId': facilityId,
    'roomId': roomId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status,
    'approvedBy': approvedBy,
    'approvedAt': approvedAt?.toIso8601String(),
    'purpose': purpose,
    'quantity': quantity,
  };
}
