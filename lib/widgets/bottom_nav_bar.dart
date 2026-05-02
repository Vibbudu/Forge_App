import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Bottom navigation bar matching the mobile_app design.
/// 5 tabs: Materials, Projects, Map, Orders, Profile.
/// Active tab: orange text + filled icon + orange-50 bg pill.
/// Frosted glass: white/95 opacity, blur, rounded-top-2xl.
class ForgeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ForgeBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.category_outlined, activeIcon: Icons.category, label: 'Materials'),
    _NavItem(icon: Icons.architecture_outlined, activeIcon: Icons.architecture, label: 'Projects'),
    _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Map'),
    _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Orders'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLG)),
        boxShadow: kNavShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpaceMD, vertical: kSpaceSM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? kForgeOrange.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(kRadiusMD),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? kForgeOrange : Colors.grey.shade400,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: kFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isActive ? kForgeOrange : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
