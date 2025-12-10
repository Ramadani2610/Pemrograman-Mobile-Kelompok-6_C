class Booking {
  final String id;
  final String? userId;
  final String? name;
  final String? facilityId;
  final String? roomId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? purpose;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // --- Info akademik tambahan ---
  // Kelas yang MEMINJAM (bukan jadwal rutin)
  final String? className;      // contoh: "TI 2023 A"
  final String? courseName;     // contoh: "Pemrograman Mobile C"
  final String? department;     // contoh: "Teknik Informatika"

  // --- Info penolakan (untuk tab Ditolak) ---
  final String? rejectedBy;      // id admin yang menolak
  final String? rejectedReason;  // alasan ditolak

  const Booking({
    required this.id,
    this.userId,
    this.name,
    this.facilityId,
    this.roomId,
    required this.startDate,
    required this.endDate,
    this.status = 'pending',
    this.purpose,
    this.quantity = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.className,
    this.courseName,
    this.department,
    this.rejectedBy,
    this.rejectedReason,
  })  : createdAt = createdAt ?? startDate,
        updatedAt = updatedAt ?? (createdAt ?? startDate);

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String?,
      name: map['name'] as String?,
      facilityId: map['facilityId'] as String?,
      roomId: map['roomId'] as String?,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      status: map['status'] as String? ?? 'pending',
      purpose: map['purpose'] as String?,
      quantity: map['quantity'] as int? ?? 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      className: map['className'] as String?,
      courseName: map['courseName'] as String?,
      department: map['department'] as String?,
      rejectedBy: map['rejectedBy'] as String?,
      rejectedReason: map['rejectedReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'facilityId': facilityId,
      'roomId': roomId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'purpose': purpose,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'className': className,
      'courseName': courseName,
      'department': department,
      'rejectedBy': rejectedBy,
      'rejectedReason': rejectedReason,
    };
  }

  Booking copyWith({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? purpose,
    int? quantity,
    String? className,
    String? courseName,
    String? department,
    String? rejectedBy,
    String? rejectedReason,
  }) {
    return Booking(
      id: id,
      userId: userId,
      name: name,
      facilityId: facilityId,
      roomId: roomId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      className: className ?? this.className,
      courseName: courseName ?? this.courseName,
      department: department ?? this.department,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedReason: rejectedReason ?? this.rejectedReason,
    );
  }
}
