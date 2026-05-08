import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../widgets/loading_overlay.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _ctrl;
  bool _ready = false;
  bool _capturing = false;
  FlashMode _flash = FlashMode.off;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _ctrl?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }

  Future<void> _init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _error = AppStrings.cameraPermDenied);
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) setState(() => _error = AppStrings.cameraError);
      return;
    }

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {
          _ctrl = controller;
          _ready = true;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera error: $e');
    }
  }

  Future<void> _capture() async {
    if (!_ready || _capturing || _ctrl == null) return;
    setState(() => _capturing = true);

    try {
      final file = await _ctrl!.takePicture();
      if (!mounted) return;

      final vm = context.read<CameraViewModel>();
      final result = await vm.processImage(file.path);

      if (!mounted) return;
      if (result != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(imagePath: file.path, ocrResult: result),
          ),
        );
        vm.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMsg.isNotEmpty ? vm.errorMsg : AppStrings.ocrFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_ctrl == null) return;
    final next = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _ctrl!.setFlashMode(next);
    setState(() => _flash = next);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = context.watch<CameraViewModel>().isProcessing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LoadingOverlay(
        isLoading: isProcessing,
        message: AppStrings.processing,
        child: _error != null
            ? _errorBody()
            : !_ready
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _cameraBody(),
      ),
    );
  }

  Widget _cameraBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_ctrl!),
        CustomPaint(painter: _ScannerOverlay()),
        SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _flash == FlashMode.torch ? Icons.flashlight_on : Icons.flashlight_off,
                  color: Colors.white,
                ),
                onPressed: _toggleFlash,
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.58,
          left: 0,
          right: 0,
          child: const Text(
            AppStrings.positionPlate,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CaptureButton(
                isCapturing: _capturing,
                onPressed: _capture,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white54),
            const SizedBox(height: 20),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: openAppSettings,
              child: const Text(AppStrings.openSettings),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppStrings.cancel, style: TextStyle(color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanW = size.width * 0.9;
    final scanH = size.height * 0.2;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.42),
      width: scanW,
      height: scanH,
    );

    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.60);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    const len = 28.0;
    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset tl, double dx, double dy) {
      canvas.drawLine(tl, tl + Offset(dx * len, 0), corner);
      canvas.drawLine(tl, tl + Offset(0, dy * len), corner);
    }

    drawCorner(rect.topLeft, 1, 1);
    drawCorner(rect.topRight, -1, 1);
    drawCorner(rect.bottomLeft, 1, -1);
    drawCorner(rect.bottomRight, -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CaptureButton extends StatelessWidget {
  final bool isCapturing;
  final VoidCallback onPressed;

  const _CaptureButton({required this.isCapturing, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: isCapturing
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.9),
        ),
        child: isCapturing
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black54),
              )
            : const Icon(Icons.camera_alt, color: Colors.black87, size: 32),
      ),
    );
  }
}
