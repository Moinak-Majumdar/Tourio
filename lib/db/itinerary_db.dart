import '../models/itinerary_model.dart';
import 'db_helper.dart';

class ItineraryDb {
  static const String table = 'itinerary_days';

  // ---------------- GET BY TOUR ----------------

  static Future<List<ItineraryModel>> getByTour(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      where: 'tour_id = ? AND is_deleted = 0',
      whereArgs: [tourId],
      orderBy: 'day_number ASC',
    );

    return res.map(ItineraryModel.fromMap).toList();
  }

  // ---------------- UPSERT ----------------
  /// DB controls created_at & last_updated_at
  static Future<int> upsert(ItineraryModel model) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    if (model.id == null) {
      final data = {
        ...model.toMap(),
        'created_at': now,
        'last_updated_at': now,
      };

      return await db.insert(table, data);
    } else {
      final data = {...model.toMap(), 'last_updated_at': now};

      await db.update(table, data, where: 'id = ?', whereArgs: [model.id]);

      return model.id!;
    }
  }

  // ---------------- SOFT DELETE ----------------

  static Future<void> softDelete(int id) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      table,
      {'is_deleted': 1, 'last_updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
