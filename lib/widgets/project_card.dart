import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Horizontal scrollable project card for Active Projects section.
class ProjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? imageColor;

  const ProjectCard({super.key, required this.title, required this.subtitle, this.imageColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(kRadiusLG),
        boxShadow: kSoftShadow,
      ),
      padding: const EdgeInsets.all(kSpaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusDefault),
            child: Container(
              height: 128,
              width: double.infinity,
              color: imageColor ?? kSurfaceContainer,
              child: Center(
                child: Icon(Icons.construction, size: 48, color: kOutline.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: kSpaceSM),
          Text(title, style: kTitleSm),
          const SizedBox(height: kSpaceXS),
          Text(subtitle, style: kDataXs.copyWith(color: kSecondary)),
        ],
      ),
    );
  }
}
