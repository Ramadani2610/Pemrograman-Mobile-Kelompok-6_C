import '../models/booking.dart';

class MockBookingService {
  MockBookingService._internal();
  static final MockBookingService instance = MockBookingService._internal();

  final List<Booking> _items = [];

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  void clear() => _items.clear();

  Booking add(Booking b) {
    final item = Booking(
      id: b.id.isNotEmpty ? b.id : _generateId(),
      name: b.name,
      userId: b.userId,
      facilityId: b.facilityId,
      roomId: b.roomId,
      startDate: b.startDate,
      endDate: b.endDate,
      status: b.status,
      purpose: b.purpose,
      quantity: b.quantity,
      createdAt: b.createdAt,
      updatedAt: b.updatedAt,
      className: b.className,
      courseName: b.courseName,
      department: b.department,
    );
    _items.add(item);
    return item;
  }

  // ======= QUERY =======

  List<Booking> getAll() {
    final list = List<Booking>.from(_items);
    list.sort((a, b) => b.startDate.compareTo(a.startDate)); // terbaru di atas
    return list;
  }

  List<Booking> getByStatus(String status) {
    final list = _items.where((b) => b.status == status).toList();
    list.sort((a, b) => b.startDate.compareTo(a.startDate)); // terbaru di atas
    return list;
  }

  // (opsional) kalau mau filter tambahan
  List<Booking> getByType(String type) {
    if (type == 'class') {
      return _items
          .where((b) => (b.roomId ?? '').isNotEmpty)
          .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    }
    if (type == 'facility') {
      return _items
          .where((b) => (b.facilityId ?? '').isNotEmpty)
          .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
    }
    return getAll();
  }

  // ======= UPDATE STATUS =======

  bool _updateStatus(String id, String newStatus) {
    final index = _items.indexWhere((b) => b.id == id);
    if (index == -1) return false;

    final old = _items[index];
    _items[index] = old.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  // adminId tidak dipakai di mock, tapi disiapkan untuk backend
  bool approve(String id, [String? adminId]) => _updateStatus(id, 'approved');

  bool reject(String id, String adminId, {String? reason}) {
    final index = _items.indexWhere((b) => b.id == id);
    if (index == -1) return false;

  final old = _items[index];
  _items[index] = old.copyWith(
    status: 'rejected',
    rejectedReason: reason,
    updatedAt: DateTime.now(),
  );
  return true;
}


  bool markReturned(String id, [String? adminId]) =>
      _updateStatus(id, 'returned');

  // ======= DUMMY DATA =======

  void seed() {
    if (_items.isNotEmpty) return;

    final now = DateTime.now();

    // 1. Peminjaman KELAS - pending
    add(
      Booking(
        id: _generateId(),
        name: 'Nadia Rauf',
        userId: 'user001',
        roomId: 'CR101',
        startDate: now.add(const Duration(hours: 1)),
        endDate: now.add(const Duration(hours: 3)),
        status: 'pending',
        purpose: 'Kelas pengganti Pemrograman Mobile.',
        quantity: 1,
        className: 'TI 2023 A',
        courseName: 'Pemrograman Mobile C',
        department: 'Teknik Informatika',
      ),
    );

    // 2. Peminjaman FASILITAS - approved (sedang digunakan)
    add(
      Booking(
        id: _generateId(),
        name: 'Park Gaeul',
        userId: 'user002',
        facilityId: 'facility001',
        startDate: now.subtract(const Duration(hours: 1)),
        endDate: now.add(const Duration(hours: 1)),
        status: 'approved',
        purpose: 'Presentasi Kelompok',
        quantity: 2,
        className: 'TI 2022 B',
        courseName: 'Sistem Basis Data',
        department: 'Teknik Informatika',
      ),
    );

    // 3. Peminjaman FASILITAS - selesai (returned)
    add(
      Booking(
        id: _generateId(),
        name: 'Baek Ahjin',
        userId: 'user003',
        facilityId: 'facility003',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.subtract(const Duration(days: 1)),
        status: 'returned',
        purpose: 'Lab Sementara',
        quantity: 5,
        className: 'TM 2021 A',
        courseName: 'Praktikum Mekanika',
        department: 'Teknik Mesin',
      ),
    );

    // 4. Contoh peminjaman DITOLAK (rejected)
    add(
      Booking(
        id: _generateId(),
        name: 'Kim Minji',
        userId: 'user004',
        roomId: 'CR201',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1, hours: 2)),
        status: 'rejected',
        purpose: 'Acara organisasi tanpa surat resmi',
        quantity: 1,
        className: 'TI 2022 C',
        courseName: 'Metode Penelitian',
        department: 'Teknik Informatika',
      ),
    );
  }
}
