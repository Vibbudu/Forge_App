import 'package:flutter/material.dart';
import 'home_screen.dart';

/// Root screen — Materials only (single screen, no bottom nav).
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
