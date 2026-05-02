import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'config/theme.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Unlock highest available refresh rate (120Hz / 90Hz)
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {}

  // Auto-login to get auth token
  await AuthService().login();

  runApp(const ForgeApp());
}

class ForgeApp extends StatelessWidget {
  const ForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Apply Google Fonts Inter to the entire theme
    final baseTheme = ForgeTheme.lightTheme;
    return MaterialApp(
      title: 'FORGE Intelligence',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainScreen(),
    );
  }
}

