import '../models/facility.dart';

class MockFacilityService {
  MockFacilityService._internal();
  static final MockFacilityService instance = MockFacilityService._internal();

  final List<Facility> _items = [];

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  // Seed some sample data
  void seed() {
    if (_items.isNotEmpty) return;
    add(
      Facility(
        id: _generateId(),
        name: 'Proyektor Epson X123',
        description: 'Proyektor untuk presentasi',
        category: 'audio-visual',
        quantity: 3,
        available: 2,
        location: 'Gudang A',
      ),
    );

    add(
      Facility(
        id: _generateId(),
        name: 'Kabel HDMI 2m',
        description: 'Kabel HDMI untuk koneksi laptop',
        category: 'elektronik',
        quantity: 10,
        available: 10,
        location: 'Gudang B',
      ),
    );

    add(
      Facility(
        id: _generateId(),
        name: 'Remote TV',
        description: 'Remote untuk TV ruang 101',
        category: 'audio-visual',
        quantity: 5,
        available: 4,
        location: 'Ruang 101',
      ),
    );
  }

  List<Facility> getAll() => List.unmodifiable(_items);

  Facility? getById(String id) {
    for (final f in _items) {
      if (f.id == id) return f;
    }
    return null;
  }

  Facility add(Facility f) {
    final item = Facility(
      id: f.id.isNotEmpty ? f.id : _generateId(),
      name: f.name,
      description: f.description,
      category: f.category,
      quantity: f.quantity,
      available: f.available,
      location: f.location,
      images: f.images,
    );
    _items.add(item);
    return item;
  }

  bool update(String id, Facility updated) {
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
