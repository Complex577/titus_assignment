import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../constants/plate_scan_window.dart';

class PlateImageCropper {
  PlateImageCropper._();

  static Future<String?> cropToScanWindow(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!source.existsSync()) return null;

      final bytes = await source.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final oriented = img.bakeOrientation(decoded);
      final rect = PlateScanWindow.rectForSize(
        Size(oriented.width.toDouble(), oriented.height.toDouble()),
      );

      final x = rect.left.clamp(0.0, oriented.width - 1).round();
      final y = rect.top.clamp(0.0, oriented.height - 1).round();
      final width = math.min(rect.width.round(), oriented.width - x);
      final height = math.min(rect.height.round(), oriented.height - y);

      if (width < 1 || height < 1) return null;

      final cropped = img.copyCrop(
        oriented,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      final dir = await getTemporaryDirectory();
      final dest =
          '${dir.path}/plate_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(dest).writeAsBytes(img.encodeJpg(cropped, quality: 95));
      return dest;
    } catch (e) {
      debugPrint('Plate crop error: $e');
      return null;
    }
  }
}
