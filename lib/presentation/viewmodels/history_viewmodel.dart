import 'package:flutter/foundation.dart';
import '../../data/models/scan_record.dart';
import '../../data/repositories/scan_repository.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryViewModel extends ChangeNotifier {
  final ScanRepository _repo;

  HistoryViewModel(this._repo);

  List<ScanRecord> _all = [];
  List<ScanRecord> _filtered = [];
  HistoryStatus _status = HistoryStatus.initial;
  String _errorMsg = '';
  String _query = '';
  int _total = 0;
  int _today = 0;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<ScanRecord> get scans => _filtered;
  HistoryStatus get status => _status;
  String get errorMsg => _errorMsg;
  String get query => _query;
  int get total => _total;
  int get today => _today;
  bool get isEmpty => _filtered.isEmpty;
  bool get isLoading => _status == HistoryStatus.loading;

  // ── Public API ─────────────────────────────────────────────────────────────
  Future<void> load() async {
    _status = HistoryStatus.loading;
    notifyListeners();
    try {
      _all = await _repo.getAll();
      _applyFilter();
      _total = await _repo.totalCount();
      _today = await _repo.todayCount();
      _status = HistoryStatus.loaded;
    } catch (e) {
      _errorMsg = e.toString();
      _status = HistoryStatus.error;
    }
    notifyListeners();
  }

  Future<List<ScanRecord>> getRecent(int n) => _repo.getRecent(n);

  void search(String q) {
    _query = q;
    _applyFilter();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    _all.removeWhere((s) => s.id == id);
    _applyFilter();
    _total = await _repo.totalCount();
    _today = await _repo.todayCount();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repo.deleteAll();
    _all = [];
    _filtered = [];
    _total = 0;
    _today = 0;
    notifyListeners();
  }

  // ── Private ────────────────────────────────────────────────────────────────
  void _applyFilter() {
    if (_query.isEmpty) {
      _filtered = List.from(_all);
    } else {
      final lower = _query.toLowerCase();
      _filtered = _all.where((s) => s.plateNumber.toLowerCase().contains(lower)).toList();
    }
  }
}
