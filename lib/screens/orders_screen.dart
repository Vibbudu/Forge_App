import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';

/// Placeholder screen for the Orders tab.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'Orders'),
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
                child: const Icon(Icons.shopping_cart, size: 40, color: kPrimary),
              ),
              const SizedBox(height: kSpaceLG),
              const Text('Material Orders', style: kHeadlineMd),
              const SizedBox(height: kSpaceSM),
              Text(
                'Your material orders and purchase history\nwill appear here.',
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
