import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Market Pulse card — price trend bars for construction materials.
class MarketPulseCard extends StatelessWidget {
  const MarketPulseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(kRadiusLG),
        boxShadow: kSoftShadow,
      ),
      padding: const EdgeInsets.all(kSpaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Market Pulse', style: kHeadlineMd),
              Icon(Icons.trending_up, color: kOutline),
            ],
          ),
          const SizedBox(height: kSpaceLG),
          _TrendRow(name: 'Steel Rebar', change: '+4.2%', fraction: 0.85, isNegative: false, color: kPrimary),
          const SizedBox(height: kSpaceLG),
          _TrendRow(name: 'Structural Lumber', change: '-1.5%', fraction: 0.40, isNegative: true, color: kSuccessColor),
          const SizedBox(height: kSpaceLG),
          _TrendRow(name: 'Sheetrock Panels', change: 'Stable', fraction: 0.10, isNegative: false, color: kOutline),
          const SizedBox(height: kSpaceLG),
          Divider(color: kSurfaceContainer),
          const SizedBox(height: kSpaceSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Last updated: 14:32', style: kDataXs.copyWith(color: kOutline)),
              Text('Full Market Report', style: kDataXs.copyWith(color: kPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final String name;
  final String change;
  final double fraction;
  final bool isNegative;
  final Color color;
  const _TrendRow({required this.name, required this.change, required this.fraction, required this.isNegative, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(name, style: kLabelMd.copyWith(color: kSecondary)),
            Text(change, style: kTitleSm.copyWith(color: isNegative ? kSuccessColor : kOnSurface, fontSize: 16)),
          ],
        ),
        const SizedBox(height: kSpaceSM),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 4,
            width: double.infinity,
            color: kSurfaceContainer,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(color: color),
            ),
          ),
        ),
      ],
    );
  }
}
