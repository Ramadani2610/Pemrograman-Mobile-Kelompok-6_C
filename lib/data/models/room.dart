class Room {
  final String id;
  String name;
  String building;
  String floor;
  int capacity;
  String category; // 'kelas', 'lab', 'seminar', etc
  List<String> facilities; // list of facility IDs
  String status; // 'available', 'booked', 'maintenance'

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.category,
    List<String>? facilities,
    String? status,
  }) : facilities = facilities ?? [],
       status = status ?? 'available';

  factory Room.fromMap(Map<String, dynamic> m) => Room(
    id: m['id'] as String,
    name: m['name'] as String,
    building: m['building'] as String? ?? '',
    floor: m['floor'] as String? ?? '',
    capacity: (m['capacity'] as num?)?.toInt() ?? 0,
    category: m['category'] as String? ?? 'kelas',
    facilities: (m['facilities'] as List<dynamic>?)?.cast<String>() ?? [],
    status: m['status'] as String? ?? 'available',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'building': building,
    'floor': floor,
    'capacity': capacity,
    'category': category,
    'facilities': facilities,
    'status': status,
  };
}
