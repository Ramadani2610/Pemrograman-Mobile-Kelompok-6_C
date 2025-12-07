class Facility {
  final String id;
  String name;
  String description;
  String category;
  int quantity;
  int available;
  String location;
  List<String> images;

  Facility({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.quantity,
    required this.available,
    required this.location,
    List<String>? images,
  }) : images = images ?? [];

  factory Facility.fromMap(Map<String, dynamic> m) => Facility(
    id: m['id'] as String,
    name: m['name'] as String,
    description: m['description'] as String? ?? '',
    category: m['category'] as String? ?? 'general',
    quantity: (m['quantity'] as num?)?.toInt() ?? 0,
    available: (m['available'] as num?)?.toInt() ?? 0,
    location: m['location'] as String? ?? '',
    images: (m['images'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'quantity': quantity,
    'available': available,
    'location': location,
    'images': images,
  };
}
