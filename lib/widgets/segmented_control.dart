import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Segmented control for surface finish selection (Glossy / Matte / Brushed).
/// Matches advanced_config_forge_modern design.
class SegmentedControl extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedControl({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(kRadiusMD),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: kSpaceMD),
                decoration: BoxDecoration(
                  color: isSelected ? kSurfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(kRadiusDefault),
                  boxShadow: isSelected ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)] : null,
                ),
                child: Center(
                  child: Text(
                    items[i],
                    style: kLabelMd.copyWith(
                      color: isSelected ? kPrimary : kOnSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
