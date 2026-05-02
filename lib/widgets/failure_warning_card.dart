import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Failure warning card — color-coded by severity.
/// GREEN for LOW, AMBER for MEDIUM, RED for HIGH/CRITICAL.
class FailureWarningCard extends StatelessWidget {
  final String title;
  final String description;
  final String severity;

  const FailureWarningCard({super.key, required this.title, required this.description, this.severity = 'MEDIUM'});

  @override
  Widget build(BuildContext context) {
    final isLow = severity.toUpperCase() == 'LOW';
    final isHigh = severity.toUpperCase() == 'HIGH' || severity.toUpperCase() == 'CRITICAL';

    final Color bgColor = isLow ? const Color(0xFFF0FDF4) : isHigh ? const Color(0xFFFEF2F2) : kWarningBg;
    final Color borderColor = isLow ? const Color(0xFF16A34A) : isHigh ? kError : kWarningBorder;
    final Color iconColor = isLow ? const Color(0xFF16A34A) : isHigh ? const Color(0xFFDC2626) : const Color(0xFFD97706);
    final Color titleColor = isLow ? const Color(0xFF14532D) : isHigh ? const Color(0xFF7F1D1D) : const Color(0xFF78350F);
    final Color descColor = isLow ? const Color(0xFF166534) : isHigh ? const Color(0xFF991B1B) : const Color(0xFF92400E);
    final IconData icon = isLow ? Icons.check_circle : isHigh ? Icons.error : Icons.warning;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: kSoftShadow,
      ),
      padding: const EdgeInsets.all(kSpaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: kSpaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kTitleSm.copyWith(color: titleColor),
                ),
                const SizedBox(height: kSpaceXS),
                Text(
                  description,
                  style: kLabelMd.copyWith(
                    color: descColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
