import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/ocr_processor.dart';
import '../../core/utils/plate_validator.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import '../widgets/plate_display_widget.dart';

class ResultScreen extends StatefulWidget {
  final String? imagePath;
  final OCRResult ocrResult;

  const ResultScreen({
    super.key,
    required this.ocrResult,
    this.imagePath,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _plateCtrl;
  bool _isSaved = false;
  bool _isSaving = false;
  bool _showRaw = false;

  @override
  void initState() {
    super.initState();
    _plateCtrl = TextEditingController(text: widget.ocrResult.plateNumber);
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaved || _isSaving) return;
    final plate = _plateCtrl.text.trim().toUpperCase();
    if (plate.isEmpty) return;

    final cameraViewModel = context.read<CameraViewModel>();
    final historyViewModel = context.read<HistoryViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);
    try {
      await cameraViewModel.saveScan(
            plateNumber: plate,
            rawText: widget.ocrResult.rawText,
            tempImagePath: widget.imagePath,
          );
      await historyViewModel.load();
      if (mounted) {
        setState(() => _isSaved = true);
        messenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.savedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _copy() {
    final text = _plateCtrl.text.trim().toUpperCase();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.copiedToClipboard)),
    );
  }

  void _share() {
    final text = _plateCtrl.text.trim().toUpperCase();
    Share.share('Vehicle plate number: $text');
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanResult),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: AppStrings.shareText,
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image preview ───────────────────────────────────────────────
            if (widget.imagePath != null) _imagePreview(),
            const SizedBox(height: 24),

            // ── Plate display ───────────────────────────────────────────────
            Center(
              child: PlateDisplayWidget(
                plateText: _plateCtrl.text.isEmpty
                    ? widget.ocrResult.plateNumber
                    : _plateCtrl.text.trim().toUpperCase(),
                isValid: PlateValidator.isValidPlate(_plateCtrl.text.trim()),
              ),
            ),
            const SizedBox(height: 28),

            // ── Editable plate field ─────────────────────────────────────────
            Text(AppStrings.plateNumber,
                style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _plateCtrl,
              textCapitalization: TextCapitalization.characters,
              maxLength: 14,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'e.g. KA01AB1234',
                helperText: 'Edit if the recognition is incorrect',
                counterText: '',
              ),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),

            // ── Action buttons ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text(AppStrings.copy),
                    onPressed: _copy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_isSaved ? Icons.check : Icons.save_outlined, size: 18),
                    label: Text(_isSaved ? 'Saved' : AppStrings.saveToHistory),
                    onPressed: _isSaved ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Raw OCR text (collapsible) ───────────────────────────────────
            if (widget.ocrResult.rawText.isNotEmpty) ...[
              GestureDetector(
                onTap: () => setState(() => _showRaw = !_showRaw),
                child: Row(
                  children: [
                    Text(
                      AppStrings.rawOcrText,
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Icon(_showRaw ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
              if (_showRaw) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.ocrResult.rawText,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  ),
                ),
              ],
            ],

            const SizedBox(height: 20),
            // ── Scan again ───────────────────────────────────────────────────
            TextButton.icon(
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text(AppStrings.scanAgain),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(widget.imagePath!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 120,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}
