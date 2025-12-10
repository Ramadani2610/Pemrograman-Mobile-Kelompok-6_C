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
      userId: b.userId,
      name: b.name,
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
      rejectedBy: b.rejectedBy,
      rejectedReason: b.rejectedReason,
      actualReturnTime: b.actualReturnTime,
      returnedBy: b.returnedBy,
    );
    _items.add(item);
    return item;
  }

  Booking? getById(String id) {
    try {
      return _items.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  bool update(String id, Booking updated) {
    final index = _items.indexWhere((b) => b.id == id);
    if (index == -1) return false;
    _items[index] = updated;
    return true;
  }

  // ======= QUERY =======

  List<Booking> getAll() {
    final list = List<Booking>.from(_items);
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

  List<Booking> getByStatus(String status) {
    final list = _items.where((b) => b.status == status).toList();
    list.sort((a, b) => b.startDate.compareTo(a.startDate));
    return list;
  }

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

  bool approve(String id, [String? adminId]) => _updateStatus(id, 'approved');

  bool reject(String id, {String? reason, String? rejectedBy}) {
    final old = getById(id);
    if (old == null) return false;

    final updated = old.copyWith(
      status: 'rejected',
      rejectedBy: rejectedBy,
      rejectedReason: reason,
      updatedAt: DateTime.now(),
    );

    return update(id, updated);
  }

  /// Tandai sudah dikembalikan.
  /// - Jika [actualReturnTime] null → pakai DateTime.now()
  /// - Jika [returnedBy] null → boleh dibiarkan null
  bool markReturned(
    String id, {
    DateTime? actualReturnTime,
    String? returnedBy,
  }) {
    final old = getById(id);
    if (old == null) return false;

    final now = DateTime.now();
    final actual = actualReturnTime ?? now;

    final updated = old.copyWith(
      status: 'returned',
      updatedAt: now,
      actualReturnTime: actual,
      returnedBy: returnedBy,
    );

    return update(id, updated);
  }

  // ======= DUMMY DATA =======
  void seed() {
    if (_items.isNotEmpty) return;

    final now = DateTime.now();

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
        actualReturnTime: now.subtract(const Duration(days: 1, hours: -2)),
        returnedBy: 'admin001',
      ),
    );

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
        rejectedBy: 'admin001',
        rejectedReason: 'Tidak ada surat pengantar resmi.',
      ),
    );
  }
}
