import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Failure warning card — amber bg with left border, warning icon.
/// Matches analysis_forge_modern: #FFF8E1 bg, amber-500 left border.
class FailureWarningCard extends StatelessWidget {
  final String title;
  final String description;

  const FailureWarningCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWarningBg,
        borderRadius: BorderRadius.circular(kRadiusMD),
        border: const Border(left: BorderSide(color: kWarningBorder, width: 4)),
        boxShadow: kSoftShadow,
      ),
      padding: const EdgeInsets.all(kSpaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning, color: Color(0xFFD97706), size: 24),
          const SizedBox(width: kSpaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kTitleSm.copyWith(color: const Color(0xFF78350F)),
                ),
                const SizedBox(height: kSpaceXS),
                Text(
                  description,
                  style: kLabelMd.copyWith(
                    color: const Color(0xFF92400E).withValues(alpha: 0.9),
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
