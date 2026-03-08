import 'package:tourio/db/db_helper.dart';
import 'package:tourio/db/traveler_db.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/taveler_model.dart';

class ExpenseDb {
  static const table = 'expenses';

  // ---------------- UPSERT ----------------
  static Future<int> upsert(ExpenseModel expense, TavelerModel traveler) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    int expenseId = 0;
    int travelerId = 0;

    if (traveler.id == null) {
      travelerId = await TravelerDb.upsertTraveler(traveler);
    } else {
      travelerId = traveler.id!;
    }

    if (expense.id == null) {
      expenseId = await db.insert(table, {
        ...expense.toMap(),
        'paid_by': travelerId,
        'created_at': now.toIso8601String(),
        'last_updated_at': now.toIso8601String(),
      });
    } else {
      await db.update(
        table,
        {
          ...expense.toMap(),
          'paid_by': travelerId,
          'last_updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      expenseId = expense.id!;
    }
    return expenseId;
  }

  // ---------------- GET BY TOUR ----------------
  static Future<List<ExpenseModel>> getByTour(
    int tourId, {
    bool includeDeleted = false,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final res = await db.query(
      table,
      where: includeDeleted ? 'tour_id = ?' : 'tour_id = ? AND is_deleted = 0',
      whereArgs: [tourId],
      orderBy: 'expense_date DESC, created_at DESC',
    );

    return res.map(ExpenseModel.fromMap).toList();
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

  // ---------------- RESTORE ----------------
  static Future<void> restore(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      table,
      {'is_deleted': 0, 'last_updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- HARD DELETE (OPTIONAL) ----------------
  static Future<void> hardDelete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
