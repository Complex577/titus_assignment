import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'plate_validator.dart';

class OCRResult {
  final String plateNumber;
  final String rawText;
  final bool isValidPlate;

  const OCRResult({
    required this.plateNumber,
    required this.rawText,
    required this.isValidPlate,
  });
}

class OCRProcessor {
  OCRProcessor._();

  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Runs ML Kit text recognition on [imagePath] and returns the best plate candidate.
  static Future<OCRResult?> processImage(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) return null;

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognized = await _recognizer.processImage(inputImage);

      final rawText = recognized.text.trim();
      if (rawText.isEmpty) return null;

      final candidates = _buildCandidates(recognized);
      final plate = PlateValidator.extractBest(candidates);
      final isValid = PlateValidator.isValidPlate(plate);

      return OCRResult(
        plateNumber: plate.isEmpty ? rawText.split('\n').first.trim().toUpperCase() : plate,
        rawText: rawText,
        isValidPlate: isValid,
      );
    } catch (e) {
      debugPrint('OCRProcessor error: $e');
      return null;
    }
  }

  /// Extracts individual line/element text as candidates.
  static List<String> _buildCandidates(RecognizedText recognized) {
    final candidates = <String>{};

    for (final block in recognized.blocks) {
      // Full block on one logical line (e.g. "KA 01 AB 1234")
      final blockLine = block.text.replaceAll('\n', ' ').trim();
      _addCandidate(candidates, blockLine);

      if (block.lines.length > 1) {
        final mergedBlockLines = block.lines.map((line) => line.text.trim()).join(' ');
        _addCandidate(candidates, mergedBlockLines);
      }

      for (final line in block.lines) {
        final t = line.text.trim();
        _addCandidate(candidates, t);

        final elements = line.elements.map((element) => element.text.trim()).toList();
        _addJoinedCandidates(candidates, elements);

        for (final element in line.elements) {
          final et = element.text.trim();
          _addCandidate(candidates, et);
        }
      }
    }

    return candidates.toList()
      ..sort(
        (a, b) => PlateValidator.scoreCandidate(b).compareTo(
          PlateValidator.scoreCandidate(a),
        ),
      );
  }

  static bool _isCandidateLikely(String text) {
    final alphanumOnly = text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return alphanumOnly.length >= 4 && alphanumOnly.length <= 14;
  }

  static void _addCandidate(Set<String> candidates, String text) {
    final value = text.trim();
    if (!_isCandidateLikely(value)) return;
    candidates.add(value);
  }

  static void _addJoinedCandidates(Set<String> candidates, List<String> parts) {
    if (parts.length < 2) return;

    for (var start = 0; start < parts.length; start++) {
      var joined = '';
      for (var end = start; end < parts.length && end < start + 3; end++) {
        final part = parts[end].trim();
        if (part.isEmpty) continue;

        joined = joined.isEmpty ? part : '$joined $part';
        _addCandidate(candidates, joined);
      }
    }
  }

  static Future<void> dispose() async {
    await _recognizer.close();
  }
}
