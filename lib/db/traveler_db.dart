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
      await db.update(table, data, where: 'id = ?', whereArgs: [traveler.id]);
      return traveler.id!;
    }
  }

  static Future<List<TavelerModel>> getAllByTour(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      table,
      where: 'tour_id = ? AND is_deleted = 0',
      whereArgs: [tourId],
      orderBy: 'is_self DESC, name ASC',
    );

    return result.map((e) => TavelerModel.fromMap(e)).toList();
  }
}
