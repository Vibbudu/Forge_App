import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Standards compliance chip — green pill for PASS, red pill for FAIL.
/// Matches analysis_forge_modern design with check_circle/cancel icons.
class StandardsChip extends StatelessWidget {
  final String standard;
  final String status;

  const StandardsChip({super.key, required this.standard, required this.status});

  @override
  Widget build(BuildContext context) {
    final isPass = status.toUpperCase() == 'PASS';
    final bgColor = isPass ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final fgColor = isPass ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final icon = isPass ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fgColor),
          const SizedBox(width: kSpaceSM),
          Text(
            standard,
            style: kDataXs.copyWith(color: fgColor),
          ),
        ],
      ),
    );
  }
}
