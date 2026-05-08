import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PlateDisplayWidget extends StatelessWidget {
  final String plateText;
  final bool isValid;
  final double fontSize;

  const PlateDisplayWidget({
    super.key,
    required this.plateText,
    required this.isValid,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Plate body
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.plateYellow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.plateBorder, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blue strip (UK / Indian style)
              Container(
                width: 8,
                height: fontSize + 14,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                plateText.isEmpty ? '  ------  ' : plateText,
                style: TextStyle(
                  color: AppColors.plateText,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Validity badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: isValid ? AppColors.validLight : AppColors.partialLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isValid ? AppColors.valid : AppColors.partial,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isValid ? Icons.check_circle_outline : Icons.info_outline,
                size: 14,
                color: isValid ? AppColors.valid : AppColors.partial,
              ),
              const SizedBox(width: 6),
              Text(
                isValid ? 'Recognised format' : 'Partial / unrecognised',
                style: TextStyle(
                  color: isValid ? AppColors.valid : AppColors.partial,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
