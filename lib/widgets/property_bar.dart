import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Property bar — thin 4px progress bar with label and value.
/// Used in the analysis screen property breakdown cards.
class PropertyBar extends StatelessWidget {
  final String label;
  final String value;
  final double fraction;
  final Color? barColor;

  const PropertyBar({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: kDataXs),
            Text(value, style: kDataXs.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: kSpaceXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 4,
            width: double.infinity,
            color: kSurfaceContainer,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: barColor ?? kPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
