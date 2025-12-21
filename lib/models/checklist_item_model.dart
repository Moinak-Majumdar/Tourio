class ChecklistItemModel {
  final int? id;
  final int tourId;
  final String title;
  final bool isCompleted;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  ChecklistItemModel({
    this.id,
    required this.tourId,
    required this.title,
    this.isCompleted = false,
    this.isDeleted = false,
    this.createdAt,
    this.lastUpdatedAt,
  });

  // ---------------- FROM MAP ----------------

  factory ChecklistItemModel.fromMap(Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: map['id'] as int?,
      tourId: map['tour_id'] as int,
      title: map['title'] as String,
      isCompleted: map['is_completed'] == 1,
      isDeleted: map['is_deleted'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastUpdatedAt: DateTime.parse(map['last_updated_at']),
    );
  }

  // ---------------- TO MAP ----------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tour_id': tourId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}
