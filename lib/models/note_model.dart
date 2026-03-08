class NoteModel {
  final int? id;
  final int tourId;

  /// Quill Delta JSON string
  final String content;

  final bool isPinned;
  final bool isDeleted;

  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const NoteModel({
    this.id,
    required this.tourId,
    required this.content,
    this.isPinned = false,
    this.isDeleted = false,
    this.createdAt,
    this.lastUpdatedAt,
  });

  // ---------------- DB Mapping ----------------

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      tourId: map['tour_id'] as int,
      content: map['content'] as String,
      isPinned: map['is_pinned'] == 1,
      isDeleted: map['is_deleted'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastUpdatedAt: DateTime.parse(map['last_updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tour_id': tourId,
      'content': content,
      'is_pinned': isPinned ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}
