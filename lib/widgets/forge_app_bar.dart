import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Forge app bar — construction icon + "Forge" brand text + trailing action.
/// Matches the mobile_app design: white bg, soft shadow, orange brand.
class ForgeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBack;

  const ForgeAppBar({super.key, this.title, this.showBackButton = false, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurfaceContainerLowest,
        boxShadow: kSoftShadow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpaceMarginMobile, vertical: 12),
          child: Row(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: kSpaceMD),
                  child: GestureDetector(
                    onTap: onBack ?? () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: kOnSurface),
                  ),
                ),
              const Icon(Icons.construction, color: kForgeOrange, size: 24),
              const SizedBox(width: kSpaceSM),
              Text(
                title ?? 'Forge',
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: title != null ? 20 : 24,
                  fontWeight: title != null ? FontWeight.w600 : FontWeight.w900,
                  letterSpacing: title != null ? -0.3 : -1.0,
                  color: title != null ? kOnSurface : kForgeOrange,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kRadiusXL),
                  ),
                  child: Icon(Icons.language, color: Colors.grey.shade400, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
