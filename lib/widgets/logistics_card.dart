import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Live Logistics card matching home_forge_modern design.
/// White card with headline, placeholder map image, "Active" pill, delivery ETAs.
class LogisticsCard extends StatelessWidget {
  const LogisticsCard({super.key});

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Logistics', style: kHeadlineMd),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('Active', style: kDataXs.copyWith(color: kPrimary)),
              ),
            ],
          ),
          const SizedBox(height: kSpaceMD),
          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusDefault),
            child: Container(
              height: 192,
              width: double.infinity,
              color: kSurfaceContainer,
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.map, size: 64, color: kOutline.withValues(alpha: 0.3)),
                  ),
                  Positioned(
                    top: kSpaceSM,
                    right: kSpaceSM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kSurfaceContainerLowest.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(kRadiusSM),
                        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: kSuccessColor, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('4 On Route', style: kDataXs),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: kSpaceMD),
          // Delivery items
          _DeliveryRow(name: 'Gravel Mix 4A', eta: '12 mins'),
          Divider(color: kSurfaceContainer, height: 1),
          _DeliveryRow(name: 'Ready-Mix Concrete', eta: '24 mins'),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  final String name;
  final String eta;
  const _DeliveryRow({required this.name, required this.eta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: kOutline, size: 18),
              const SizedBox(width: kSpaceSM),
              Text(name, style: kLabelMd),
            ],
          ),
          Text(eta, style: kLabelMd.copyWith(color: kPrimary)),
        ],
      ),
    );
  }
}
