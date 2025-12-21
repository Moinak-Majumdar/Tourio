import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tourio.db');

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createToursTable);
    await db.execute(_createItineraryTable);
    await db.execute(_createExpensesTable);
    await db.execute(_createNotesTable);
    await db.execute(_createChecklistTable);
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tourio.db');
    await deleteDatabase(path);
  }

  // ---------------- TABLE DEFINITIONS ----------------

  static const String _createToursTable = '''
  CREATE TABLE tours (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    destination TEXT,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    budget REAL,
    total_days INTEGER NOT NULL,
    cover_image_path TEXT,
    created_at TEXT NOT NULL,
    last_updated_at TEXT NOT NULL,
    is_deleted INTEGER DEFAULT 0
  );
  ''';

  static const String _createItineraryTable = '''
  CREATE TABLE itinerary_days (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id INTEGER NOT NULL,
    day_number INTEGER NOT NULL,
    title TEXT,
    description TEXT,
    created_at TEXT NOT NULL,
    last_updated_at TEXT NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
  );
  ''';

  static const String _createExpensesTable = '''
  CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    category TEXT NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    last_updated_at TEXT NOT NULL,
    FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
  );
  ''';

  static const String _createNotesTable = '''
  CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    is_pinned INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    last_updated_at TEXT NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
  );
  ''';

  static const String _createChecklistTable = '''
  CREATE TABLE checklist_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    is_completed INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    last_updated_at TEXT NOT NULL,
    is_deleted INTEGER DEFAULT 0,
    FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
  );
  ''';
}
