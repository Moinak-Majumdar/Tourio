class ItineraryModel {
  final int? id;
  final int tourId;
  final int dayNumber;
  final String title;
  final String? description;

  const ItineraryModel({
    this.id,
    required this.tourId,
    required this.dayNumber,
    required this.title,
    this.description,
  });

  // ---------------- FROM MAP ----------------

  factory ItineraryModel.fromMap(Map<String, dynamic> map) {
    return ItineraryModel(
      id: map['id'] as int?,
      tourId: map['tour_id'] as int,
      dayNumber: map['day_number'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
    );
  }

  // ---------------- TO MAP ----------------

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tour_id': tourId,
      'day_number': dayNumber,
      'title': title,
      'description': description,
    };
  }
}
