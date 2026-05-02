import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';

/// Placeholder screen for the Profile tab.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'Profile'),
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 40, color: kPrimary),
              ),
              const SizedBox(height: kSpaceLG),
              const Text('Your Profile', style: kHeadlineMd),
              const SizedBox(height: kSpaceSM),
              Text(
                'Account settings and preferences\nwill appear here.',
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
