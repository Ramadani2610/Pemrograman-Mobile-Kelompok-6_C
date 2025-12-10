// lib/data/models/booking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  // ====== IDENTITAS PEMINJAMAN ======
  final String id;
  final String? userId;
  final String? name;

  // ====== TARGET ======
  final String? facilityId;
  final String? roomId;

  // ====== WAKTU ======
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? actualReturnTime; // khusus fasilitas

  // ====== STATUS & META ======
  final String status;    // pending / approved / returned / rejected
  final String? purpose;  // "kelas_pengganti" / "agenda_organisasi" / "peminjaman_fasilitas"
  final int quantity;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ====== INFO AKADEMIK ======
  final String? className;
  final String? courseName;
  final String? department;

  // ====== AGENDA ORGANISASI ======
  final String? organizationName;
  final String? eventName;
  final String? attachmentPath;

  // ====== PENOLAKAN ======
  final String? rejectedBy;
  final String? rejectedReason;

  final String? returnedBy;

  const Booking({
    required this.id,
    this.userId,
    this.name,
    this.facilityId,
    this.roomId,
    required this.startDate,
    required this.endDate,
    this.actualReturnTime,
    this.status = 'pending',
    this.purpose,
    this.quantity = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.className,
    this.courseName,
    this.department,
    this.organizationName,
    this.eventName,
    this.attachmentPath,
    this.returnedBy,
    this.rejectedBy,
    this.rejectedReason,
  })  : createdAt = createdAt ?? startDate,
        updatedAt = updatedAt ?? (createdAt ?? startDate);

  // ====== HELPER PARSE TANGGAL FLEXIBLE (Timestamp / DateTime / String) ======
  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.parse(value as String);
  }

  static DateTime _parseRequiredDate(dynamic value, String fieldName) {
    final result = _parseNullableDate(value);
    if (result == null) {
      throw ArgumentError('Field "$fieldName" tidak boleh null');
    }
    return result;
  }

  // ====== FROM MAP (bisa dipakai untuk Firestore map) ======
  factory Booking.fromMap(Map<String, dynamic> map, {String? id}) {
    return Booking(
      id: id ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String?,
      name: map['name'] as String?,
      facilityId: map['facilityId'] as String?,
      roomId: map['roomId'] as String?,
      startDate: _parseRequiredDate(map['startDate'], 'startDate'),
      endDate: _parseRequiredDate(map['endDate'], 'endDate'),
      actualReturnTime: _parseNullableDate(map['actualReturnTime']),
      status: map['status'] as String? ?? 'pending',
      purpose: map['purpose'] as String?,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      createdAt:
          _parseNullableDate(map['createdAt']) ??
          _parseRequiredDate(map['startDate'], 'startDate'),
      updatedAt:
          _parseNullableDate(map['updatedAt']) ??
          _parseNullableDate(map['createdAt']) ??
          _parseRequiredDate(map['startDate'], 'startDate'),
      className: map['className'] as String?,
      courseName: map['courseName'] as String?,
      department: map['department'] as String?,
      organizationName: map['organizationName'] as String?,
      eventName: map['eventName'] as String?,
      attachmentPath: map['attachmentPath'] as String?,
      returnedBy: map['returnedBy'] as String?,
      rejectedBy: map['rejectedBy'] as String?,
      rejectedReason: map['rejectedReason'] as String?,
    );
  }

  // Opsional: langsung dari DocumentSnapshot
  factory Booking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Booking.fromMap(data, id: doc.id);
  }

  // ====== TO MAP (siap dikirim ke Firestore) ======
  Map<String, dynamic> toMap() {
    return {
      // `id` biasanya diambil dari doc.id, tapi tetap boleh disimpan
      'id': id,
      'userId': userId,
      'name': name,
      'facilityId': facilityId,
      'roomId': roomId,
      'startDate': startDate,              // DateTime → Timestamp oleh plugin
      'endDate': endDate,
      'actualReturnTime': actualReturnTime,
      'status': status,
      'purpose': purpose,
      'quantity': quantity,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'className': className,
      'courseName': courseName,
      'department': department,
      'organizationName': organizationName,
      'eventName': eventName,
      'attachmentPath': attachmentPath,
      'returnedBy': returnedBy,
      'rejectedBy': rejectedBy,
      'rejectedReason': rejectedReason,
    };
  }

  // ====== COPY WITH ======
  Booking copyWith({
    String? id,
    String? userId,
    String? name,
    String? facilityId,
    String? roomId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? actualReturnTime,
    String? status,
    String? purpose,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? className,
    String? courseName,
    String? department,
    String? organizationName,
    String? eventName,
    String? attachmentPath,
    String? returnedBy,
    String? rejectedBy,
    String? rejectedReason,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      facilityId: facilityId ?? this.facilityId,
      roomId: roomId ?? this.roomId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      actualReturnTime: actualReturnTime ?? this.actualReturnTime,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      className: className ?? this.className,
      courseName: courseName ?? this.courseName,
      department: department ?? this.department,
      organizationName: organizationName ?? this.organizationName,
      eventName: eventName ?? this.eventName,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      returnedBy: returnedBy ?? this.returnedBy,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectedReason: rejectedReason ?? this.rejectedReason,
    );
  }
}
