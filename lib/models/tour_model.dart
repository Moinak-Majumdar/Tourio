class TourModel {
  final int? id;
  final String? name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  double? budget;
  final String? coverImagePath;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  TourModel({
    this.id,
    this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.budget,
    this.coverImagePath,
    this.createdAt,
    this.lastUpdatedAt,
  });

  String get tourName => name?.isNotEmpty == true ? name! : destination;

  factory TourModel.fromMap(Map<String, dynamic> map) {
    return TourModel(
      id: map['id'],
      name: map['name'] ?? '',
      destination: map['destination'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      totalDays: map['total_days'],
      coverImagePath: map['cover_image_path'],
      createdAt: DateTime.parse(map['created_at']),
      lastUpdatedAt: DateTime.parse(map['last_updated_at']),
      budget: map['budget'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'budget': budget,
      'cover_image_path': coverImagePath,
    };
  }
}
