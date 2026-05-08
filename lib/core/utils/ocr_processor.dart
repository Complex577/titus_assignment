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
    final candidates = <String>[];

    for (final block in recognized.blocks) {
      // Full block on one logical line (e.g. "KA 01 AB 1234")
      final blockLine = block.text.replaceAll('\n', ' ').trim();
      if (_isCandidateLikely(blockLine)) candidates.add(blockLine);

      for (final line in block.lines) {
        final t = line.text.trim();
        if (_isCandidateLikely(t)) candidates.add(t);

        for (final element in line.elements) {
          final et = element.text.trim();
          if (_isCandidateLikely(et)) candidates.add(et);
        }
      }
    }

    return candidates;
  }

  static bool _isCandidateLikely(String text) {
    final alphanumOnly = text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return alphanumOnly.length >= 4 && alphanumOnly.length <= 14;
  }

  static Future<void> dispose() async {
    await _recognizer.close();
  }
}
