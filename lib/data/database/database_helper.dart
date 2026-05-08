import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scan_record.dart';

class DatabaseHelper {
  static const _dbName = 'plate_scanner.db';
  static const _dbVersion = 1;
  static const _table = 'scans';

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, _dbName),
      version: _dbVersion,
      onCreate: _create,
    );
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_table (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        plate_number    TEXT    NOT NULL,
        image_path      TEXT,
        scan_date       INTEGER NOT NULL,
        raw_text        TEXT    DEFAULT '',
        is_valid_plate  INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insert(ScanRecord record) async {
    final database = await db;
    final map = record.toMap()..remove('id');
    return database.insert(_table, map);
  }

  Future<List<ScanRecord>> getAll() async {
    final database = await db;
    final rows = await database.query(_table, orderBy: 'scan_date DESC');
    return rows.map(ScanRecord.fromMap).toList();
  }

  Future<List<ScanRecord>> search(String query) async {
    final database = await db;
    final rows = await database.query(
      _table,
      where: 'plate_number LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'scan_date DESC',
    );
    return rows.map(ScanRecord.fromMap).toList();
  }

  Future<List<ScanRecord>> getRecent(int limit) async {
    final database = await db;
    final rows = await database.query(_table, orderBy: 'scan_date DESC', limit: limit);
    return rows.map(ScanRecord.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final database = await db;
    return database.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    final database = await db;
    return database.delete(_table);
  }

  Future<int> count() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) FROM $_table');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> countToday() async {
    final database = await db;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final result = await database.rawQuery(
      'SELECT COUNT(*) FROM $_table WHERE scan_date >= ?',
      [start],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
