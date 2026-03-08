import 'package:tourio/db/db_helper.dart';
import 'package:tourio/models/note_model.dart';

class NotesDb {
  static const _table = 'notes';

  // ---------------- Create / Update ----------------

  static Future<int> upsert(NoteModel note) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();

    if (note.id == null) {
      return db.insert(_table, {
        'tour_id': note.tourId,
        'content': note.content,
        'is_pinned': note.isPinned ? 1 : 0,
        'is_deleted': note.isDeleted ? 1 : 0,
        'created_at': now.toIso8601String(),
        'last_updated_at': now.toIso8601String(),
      });
    } else {
      return db.update(
        _table,
        {
          'tour_id': note.tourId,
          'content': note.content,
          'is_pinned': note.isPinned ? 1 : 0,
          'is_deleted': note.isDeleted ? 1 : 0,
          'last_updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [note.id],
      );
    }
  }

  // ---------------- Queries ----------------

  static Future<List<NoteModel>> getByTour(int tourId) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      _table,
      where: 'tour_id = ? AND is_deleted = 0',
      whereArgs: [tourId],
      orderBy: 'is_pinned DESC, last_updated_at DESC',
    );

    return rows.map(NoteModel.fromMap).toList();
  }

  static Future<NoteModel?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;

    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return NoteModel.fromMap(rows.first);
  }

  // ---------------- Pin / Unpin ----------------

  static Future<void> togglePin(int id, bool pinned) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      _table,
      {
        'is_pinned': pinned ? 1 : 0,
        'last_updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- Soft Delete ----------------

  static Future<void> softDelete(int id) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      _table,
      {'is_deleted': 1, 'last_updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- Hard Delete (optional) ----------------

  static Future<void> hardDelete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
