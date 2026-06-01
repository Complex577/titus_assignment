import 'dart:ui';

class PlateScanWindow {
  PlateScanWindow._();

  static const double centerY = 0.42;
  static const double widthFactor = 0.9;
  static const double heightFactor = 0.2;

  static Rect rectForSize(Size size) {
    final scanW = size.width * widthFactor;
    final scanH = size.height * heightFactor;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * centerY),
      width: scanW,
      height: scanH,
    );
  }
}
