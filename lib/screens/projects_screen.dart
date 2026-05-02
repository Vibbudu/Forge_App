import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';


/// Placeholder screen for the Projects tab.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'Projects'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kSpaceMarginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPrimaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(kRadiusLG),
                ),
                child: const Icon(Icons.architecture, size: 40, color: kPrimary),
              ),
              const SizedBox(height: kSpaceLG),
              const Text('Active Projects', style: kHeadlineMd),
              const SizedBox(height: kSpaceSM),
              Text(
                'Your construction projects will appear here.\nSearch for materials to get started.',
                style: kBodyMd.copyWith(color: kSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
