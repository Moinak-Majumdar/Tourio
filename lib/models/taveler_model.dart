class TavelerModel {
  final int? id;
  final int tourId;
  final bool isSelf;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  TavelerModel({
    this.id,
    required this.tourId,
    required this.isSelf,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  // ---------------- From DB ----------------
  factory TavelerModel.fromMap(Map<String, dynamic> map) {
    return TavelerModel(
      id: map['id'] as int?,
      tourId: map['tour_id'] as int,
      isSelf: (map['is_self'] ?? 0) == 1,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['last_updated_at']),
      isDeleted: (map['is_deleted'] ?? 0) == 1,
    );
  }

  // ---------------- To DB ----------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tour_id': tourId,
      'is_self': isSelf ? 1 : 0,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'last_updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}
