import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/ocr_processor.dart';
import '../../core/utils/plate_validator.dart';
import '../../data/models/scan_record.dart';
import '../../data/repositories/scan_repository.dart';

enum ScanStatus { idle, processing, done, failed }

class CameraViewModel extends ChangeNotifier {
  final ScanRepository _repo;

  CameraViewModel(this._repo);

  ScanStatus _status = ScanStatus.idle;
  String _errorMsg = '';

  ScanStatus get status => _status;
  String get errorMsg => _errorMsg;
  bool get isProcessing => _status == ScanStatus.processing;

  // ── OCR ────────────────────────────────────────────────────────────────────
  Future<OCRResult?> processImage(String imagePath) async {
    _status = ScanStatus.processing;
    _errorMsg = '';
    notifyListeners();

    try {
      final result = await OCRProcessor.processImage(imagePath);
      if (result == null) {
        _errorMsg = 'No text detected. Try better lighting.';
        _status = ScanStatus.failed;
        notifyListeners();
        return null;
      }
      _status = ScanStatus.done;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMsg = 'Processing failed: $e';
      _status = ScanStatus.failed;
      notifyListeners();
      return null;
    }
  }

  // ── Persist ────────────────────────────────────────────────────────────────
  Future<ScanRecord> saveScan({
    required String plateNumber,
    required String rawText,
    String? tempImagePath,
  }) async {
    final savedPath = tempImagePath != null ? await _persistImage(tempImagePath) : null;
    final record = ScanRecord(
      plateNumber: PlateValidator.normalize(plateNumber),
      imagePath: savedPath,
      scanDate: DateTime.now(),
      rawText: rawText,
      isValidPlate: PlateValidator.isValidPlate(plateNumber),
    );
    return _repo.save(record);
  }

  void reset() {
    _status = ScanStatus.idle;
    _errorMsg = '';
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Copies the temp camera file into the app documents directory so it persists.
  Future<String?> _persistImage(String tempPath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dest = '${dir.path}/plate_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(tempPath).copy(dest);
      return dest;
    } catch (e) {
      debugPrint('Image persist error: $e');
      return null;
    }
  }
}
