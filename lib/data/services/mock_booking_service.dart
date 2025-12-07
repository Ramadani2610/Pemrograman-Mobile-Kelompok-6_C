import '../models/booking.dart';

class MockBookingService {
  MockBookingService._internal();
  static final MockBookingService instance = MockBookingService._internal();

  final List<Booking> _items = [];

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Booking add(Booking b) {
    final item = Booking(
      id: b.id.isNotEmpty ? b.id : _generateId(),
      userId: b.userId,
      facilityId: b.facilityId,
      roomId: b.roomId,
      startDate: b.startDate,
      endDate: b.endDate,
      status: b.status,
      approvedBy: b.approvedBy,
      approvedAt: b.approvedAt,
      purpose: b.purpose,
      quantity: b.quantity,
    );
    _items.add(item);
    return item;
  }

  void seed() {
    if (_items.isNotEmpty) return;

    final now = DateTime.now();

    add(
      Booking(
        id: _generateId(),
        userId: 'user001',
        facilityId: 'facility001',
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        status: 'pending',
        purpose: 'Presentasi Kelompok',
        quantity: 2,
      ),
    );

    add(
      Booking(
        id: _generateId(),
        userId: 'user002',
        facilityId: 'facility002',
        roomId: 'room001',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 2)),
        status: 'approved',
        approvedBy: 'admin001',
        approvedAt: now,
        purpose: 'Rapat Dosen',
        quantity: 1,
      ),
    );

    add(
      Booking(
        id: _generateId(),
        userId: 'user003',
        facilityId: 'facility003',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.subtract(const Duration(days: 1)),
        status: 'returned',
        purpose: 'Lab Sementara',
        quantity: 5,
      ),
    );
  }

  List<Booking> getAll() => List.unmodifiable(_items);

  Booking? getById(String id) {
    for (final b in _items) {
      if (b.id == id) return b;
    }
    return null;
  }

  List<Booking> getByUserId(String userId) {
    return _items.where((b) => b.userId == userId).toList();
  }

  List<Booking> getByStatus(String status) {
    return _items.where((b) => b.status == status).toList();
  }

  bool update(String id, Booking updated) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return false;
    _items[idx] = updated;
    return true;
  }

  bool delete(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return false;
    _items.removeAt(idx);
    return true;
  }

  bool approve(String id, String approvedBy) {
    final b = getById(id);
    if (b == null) return false;
    b.status = 'approved';
    b.approvedBy = approvedBy;
    b.approvedAt = DateTime.now();
    return update(id, b);
  }

  bool reject(String id) {
    final b = getById(id);
    if (b == null) return false;
    b.status = 'rejected';
    return update(id, b);
  }

  bool markReturned(String id) {
    final b = getById(id);
    if (b == null) return false;
    b.status = 'returned';
    return update(id, b);
  }
}
