import '../models/room.dart';

class MockRoomService {
  MockRoomService._internal();
  static final MockRoomService instance = MockRoomService._internal();

  final List<Room> _items = [];

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  void seed() {
    if (_items.isNotEmpty) return;

    add(
      Room(
        id: _generateId(),
        name: 'Ruang 101',
        building: 'Gedung A',
        floor: '1',
        capacity: 40,
        category: 'kelas',
        facilities: [],
        status: 'available',
      ),
    );

    add(
      Room(
        id: _generateId(),
        name: 'Ruang 102',
        building: 'Gedung A',
        floor: '1',
        capacity: 35,
        category: 'kelas',
        facilities: [],
        status: 'available',
      ),
    );

    add(
      Room(
        id: _generateId(),
        name: 'Lab Komputer A',
        building: 'Gedung B',
        floor: '2',
        capacity: 30,
        category: 'lab',
        facilities: [],
        status: 'booked',
      ),
    );

    add(
      Room(
        id: _generateId(),
        name: 'Ruang Seminar',
        building: 'Gedung C',
        floor: '3',
        capacity: 100,
        category: 'seminar',
        facilities: [],
        status: 'available',
      ),
    );
  }

  List<Room> getAll() => List.unmodifiable(_items);

  Room? getById(String id) {
    for (final r in _items) {
      if (r.id == id) return r;
    }
    return null;
  }

  Room add(Room r) {
    final item = Room(
      id: r.id.isNotEmpty ? r.id : _generateId(),
      name: r.name,
      building: r.building,
      floor: r.floor,
      capacity: r.capacity,
      category: r.category,
      facilities: r.facilities,
      status: r.status,
    );
    _items.add(item);
    return item;
  }

  bool update(String id, Room updated) {
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
}
