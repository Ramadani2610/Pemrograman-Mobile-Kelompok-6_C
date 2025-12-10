// facility_item_model.dart
class FacilityItem {
  final String code;
  final String status;
  final String entryDate;
  final String? lastBorrowed;
  final String? description;

  FacilityItem({
    required this.code,
    required this.status,
    required this.entryDate,
    this.lastBorrowed,
    this.description,
  });
}