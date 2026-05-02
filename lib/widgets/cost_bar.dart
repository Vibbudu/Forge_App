import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Cost comparison bar — horizontal bar for cost tier visualization.
/// Matches analysis_forge_modern design.
class CostBar extends StatelessWidget {
  final String label;
  final String price;
  final double fraction;
  final bool isPrimary;
  final bool isHighlighted;

  const CostBar({
    super.key,
    required this.label,
    required this.price,
    required this.fraction,
    this.isPrimary = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: kDataXs.copyWith(
              fontWeight: FontWeight.w700,
              color: isPrimary ? kPrimary : kOnSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: kSpaceMD),
        Expanded(
          child: Container(
            height: isPrimary ? 40 : 32,
            decoration: BoxDecoration(
              color: kSurfaceContainer,
              borderRadius: BorderRadius.circular(kRadiusDefault),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isPrimary ? kPrimaryContainer : kSecondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(kRadiusDefault),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: kSpaceMD),
        SizedBox(
          width: 48,
          child: Text(
            price,
            style: kDataXs.copyWith(
              fontWeight: FontWeight.w700,
              color: isPrimary ? kPrimary : kOnSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
