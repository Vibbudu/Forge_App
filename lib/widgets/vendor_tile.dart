import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/forge_response.dart';

/// Vendor detail bottom sheet content matching suppliers_forge_modern design.
class VendorDetailSheet extends StatelessWidget {
  final VendorInfo vendor;
  final VoidCallback? onGetDirections;

  const VendorDetailSheet({super.key, required this.vendor, this.onGetDirections});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32), bottom: Radius.circular(kRadiusLG)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, -8))],
      ),
      padding: const EdgeInsets.all(kSpaceLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 48, height: 6,
            decoration: BoxDecoration(color: kSurfaceContainerHigh, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: kSpaceLG),
          // Name & distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name, style: kTitleSm),
                    const SizedBox(height: kSpaceXS),
                    Row(children: [
                      Icon(Icons.star, color: kPrimary, size: 18),
                      const SizedBox(width: 4),
                      Text('${vendor.rating}', style: kDataXs),
                      const SizedBox(width: 4),
                      Text('(${vendor.totalRatings} ratings)', style: kDataXs.copyWith(color: kSecondary)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('${vendor.distanceKm} km away', style: kLabelMd.copyWith(color: kPrimaryContainer)),
              ),
            ],
          ),
          const SizedBox(height: kSpaceMD),
          // Hours & status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurfaceContainerLow,
              borderRadius: BorderRadius.circular(kRadiusMD),
            ),
            child: Row(children: [
              Icon(Icons.schedule, color: kSecondary, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor.openNow ? 'Open Now' : 'Closed', style: kDataXs.copyWith(color: kSecondary)),
                  Text(vendor.phone, style: kLabelMd),
                ],
              ),
            ]),
          ),
          const SizedBox(height: kSpaceMD),
          // Get Directions button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGetDirections,
              icon: const Icon(Icons.directions, size: 20),
              label: const Text('Get Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryContainer,
                foregroundColor: kOnPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMD)),
                elevation: 4,
                shadowColor: kPrimary.withValues(alpha: 0.25),
                textStyle: kTitleSm.copyWith(color: kOnPrimaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
