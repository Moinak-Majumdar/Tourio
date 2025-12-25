class ExpenseModel {
  final int? id;
  final int tourId;

  final String title;
  final double amount;

  final DateTime expenseDate; // logical date
  final String category;

  final bool isDeleted;

  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  ExpenseModel({
    this.id,
    required this.tourId,
    required this.title,
    required this.amount,
    required this.expenseDate,
    required this.category,
    this.isDeleted = false,
    this.createdAt,
    this.lastUpdatedAt,
  });

  // ---------------- From DB ----------------
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      tourId: map['tour_id'] as int,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date']),
      category: map['category'] as String,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastUpdatedAt: DateTime.parse(map['last_updated_at']),
    );
  }

  // ---------------- To DB ----------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tour_id': tourId,
      'title': title,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String(),
      'category': category,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }
}
