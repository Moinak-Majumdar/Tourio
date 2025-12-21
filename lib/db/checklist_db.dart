import 'package:tourio/db/db_helper.dart';
import 'package:tourio/models/checklist_item_model.dart';

class ChecklistDb {
  static const String table = 'checklist_items';

  // ---------------- UPSERT ----------------
  static Future<int> upsert(ChecklistItemModel item) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    if (item.id == null) {
      final data = {...item.toMap(), 'created_at': now, 'last_updated_at': now};
      return await db.insert(table, data);
    } else {
      final data = {...item.toMap(), 'last_updated_at': now};
      await db.update(table, data, where: 'id = ?', whereArgs: [item.id]);
      return item.id!;
    }
  }

  // ---------------- GET ACTIVE ITEMS ----------------
  static Future<List<ChecklistItemModel>> getAllNonDeleted(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      where: 'tour_id = ? AND is_deleted = 0',
      whereArgs: [tourId],
      orderBy: 'created_at ASC',
    );

    return res.map(ChecklistItemModel.fromMap).toList();
  }

  // ---------------- GET DELETED ITEMS ----------------
  static Future<List<ChecklistItemModel>> getAllDeleted(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      where: 'tour_id = ? AND is_deleted = 1',
      whereArgs: [tourId],
      orderBy: 'last_updated_at DESC',
    );

    return res.map(ChecklistItemModel.fromMap).toList();
  }

  // ---------------- TOGGLE COMPLETE ----------------
  static Future<void> toggleCompleted(int id, bool completed) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      table,
      {
        'is_completed': completed ? 1 : 0,
        'last_updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
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

  // ---------------- HARD DELETE ----------------
  static Future<void> hardDelete(int id) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- RESTORE ----------------
  static Future<bool> restore(int id) async {
    final db = await DatabaseHelper.instance.database;

    final rowCount = await db.update(
      table,
      {'is_deleted': 0, 'last_updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    return rowCount > 0;
  }
}
