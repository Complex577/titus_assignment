import '../database/database_helper.dart';
import '../models/scan_record.dart';

class ScanRepository {
  final DatabaseHelper _db;

  ScanRepository(this._db);

  Future<ScanRecord> save(ScanRecord record) async {
    final id = await _db.insert(record);
    return record.copyWith(id: id);
  }

  Future<List<ScanRecord>> getAll() => _db.getAll();

  Future<List<ScanRecord>> search(String query) => _db.search(query);

  Future<List<ScanRecord>> getRecent(int limit) => _db.getRecent(limit);

  Future<bool> delete(int id) async => (await _db.delete(id)) > 0;

  Future<void> deleteAll() => _db.deleteAll();

  Future<int> totalCount() => _db.count();

  Future<int> todayCount() => _db.countToday();
}
