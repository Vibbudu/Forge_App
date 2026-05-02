import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Large search bar matching home_forge_modern design.
/// 64px height, embedded mic + camera buttons, high elevation shadow.
class ForgeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmit;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;

  const ForgeSearchBar({
    super.key,
    required this.controller,
    this.onSubmit,
    this.onMicTap,
    this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(kRadiusMD),
        boxShadow: kHighElevation,
      ),
      child: Row(
        children: [
          const SizedBox(width: kSpaceMD),
          Icon(Icons.search, color: kOutline, size: 24),
          const SizedBox(width: kSpaceSM),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSubmit?.call(),
              style: kTitleSm,
              decoration: InputDecoration(
                hintText: 'What do you need to build?',
                hintStyle: kTitleSm.copyWith(color: kOutline.withValues(alpha: 0.5)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
          _ActionIcon(icon: Icons.mic, onTap: onMicTap),
          _ActionIcon(icon: Icons.photo_camera, onTap: onCameraTap),
          const SizedBox(width: kSpaceSM),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ActionIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadiusXL),
        ),
        child: Icon(icon, color: kPrimary, size: 24),
      ),
    );
  }
}
