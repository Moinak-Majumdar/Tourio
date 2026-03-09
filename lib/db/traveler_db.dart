import 'package:tourio/db/db_helper.dart';
import 'package:tourio/models/taveler_model.dart';

class TravelerDb {
  static const table = 'travelers';

  // ----------------- upsert --------------------
  static Future<int> upsertTraveler(TavelerModel traveler) async {
    final db = await DatabaseHelper.instance.database;

    final now = DateTime.now().toIso8601String();

    if (traveler.id == null) {
      final data = {
        ...traveler.toMap(),
        'created_at': now,
        'last_updated_at': now,
      };
      return await db.insert(table, data);
    } else {
      final data = {...traveler.toMap(), 'last_updated_at': now};
      data.remove('created_at');
      await db.update(table, data, where: 'id = ?', whereArgs: [traveler.id]);
      return traveler.id!;
    }
  }

  static Future<List<TavelerModel>> getAllByTour(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        t.*,
        COALESCE(SUM(e.amount),0.0) AS total_spend
      FROM $table t
      LEFT JOIN expenses e 
        ON e.paid_by = t.id 
        AND e.tour_id = t.tour_id 
        AND e.is_deleted = 0
      WHERE t.tour_id = ?
        AND t.is_deleted = 0
      GROUP BY t.id
      ORDER BY t.is_self DESC, t.name ASC
    ''',
      [tourId],
    );

    return result.map((e) => TavelerModel.fromMap(e)).toList();
  }

  static Future<void> deleteTraveler(int travelerId) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      table,
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [travelerId],
    );
  }
}
