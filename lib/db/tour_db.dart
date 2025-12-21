import 'package:sqflite/sqflite.dart';
import 'package:tourio/models/tour_model.dart';

import 'db_helper.dart';

class TourDb {
  static const String table = 'tours';

  // ---------------- UPSERT ----------------
  // Returns tourId (inserted or updated)
  static Future<int> upsertTour(TourModel model) async {
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

  // ---------------- GET BY ID ----------------
  static Future<TourModel?> getTourById(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [tourId],
      limit: 1,
    );

    if (res.isEmpty) return null;
    return TourModel.fromMap(res.first);
  }

  // ---------------- GET ALL TOURS ----------------
  // Used for Home screen
  static Future<List<TourModel>> getAllTours() async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      orderBy: 'last_updated_at DESC',
      where: 'is_deleted = 0',
    );

    return res.map(TourModel.fromMap).toList();
  }

  // All tour dropdown
  static Future<List<TourModel>> getAllToursDropdown() async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      orderBy: 'destination ASC, name ASC',
      where: 'is_deleted = 0',
    );

    return res.map(TourModel.fromMap).toList();
  }

  // ---------------- DELETE TOUR ----------------
  // Hard delete (child tables cascade automatically)
  static Future<void> deleteTour(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      table,
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [tourId],
    );
  }

  /// ---------------- TOUR COUNT ----------------
  /// Returns total number of tours created
  static Future<int> getTourCount() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(id) FROM $table WHERE is_deleted = 0',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
