import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';

import '../widgets/search_bar_widget.dart';
import '../widgets/logistics_card.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/project_card.dart';
import 'result_screen.dart';
import 'advanced_config_screen.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _queryController = TextEditingController();

  bool _isLoading = false;

  // Speech to Text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _submitText() async {
    if (_queryController.text.trim().isEmpty) return;
    await _analyze(inputType: 'text', text: _queryController.text.trim());
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      if (_queryController.text.isNotEmpty) {
        await _submitText();
      }
    } else {
      bool available = await _speech.initialize();
      if (available) {
        if (!mounted) return;
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _queryController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              // Wait a bit before auto-submitting
            }
          }),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);
      await _analyze(inputType: 'photo', photoBase64: base64Image);
    }
  }

  Future<void> _analyze({
    required String inputType,
    String? text,
    String? photoBase64,
  }) async {
    setState(() => _isLoading = true);
    try {
      final loc = await LocationService().getCurrentLocation();
      final response = await ApiService().analyzeQuery(
        inputType: inputType,
        text: text,
        photoBase64: photoBase64,
        lat: loc.lat,
        lng: loc.lng,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(data: response)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToAdvanced() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdvancedConfigScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: kPrimary),
                  const SizedBox(height: kSpaceMD),
                  Text('Analyzing with Forge Intelligence...', style: kLabelMd.copyWith(color: kSecondary)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: kSpaceLG, bottom: kSpaceXL * 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMarginMobile),
                    child: Stack(
                      children: [
                        ForgeSearchBar(
                          controller: _queryController,
                          onSubmit: _submitText,
                          onMicTap: _toggleVoice,
                          onCameraTap: _takePhoto,
                        ),
                        if (_isListening)
                          Positioned(
                            right: 64, // Positioned near the mic button
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: kError, borderRadius: BorderRadius.circular(100)),
                              child: Text('Listening...', style: kDataXs.copyWith(color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSpaceSM),
                  Center(
                    child: TextButton(
                      onPressed: _navigateToAdvanced,
                      style: TextButton.styleFrom(
                        foregroundColor: kPrimary,
                        textStyle: kLabelMd.copyWith(decoration: TextDecoration.underline, decorationThickness: 2),
                      ),
                      child: const Text('Advanced Mode'),
                    ),
                  ),
                  const SizedBox(height: kSpaceMD),

                  // Bento Layout: Insights
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMarginMobile),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 600) {
                          return const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: LogisticsCard()),
                              SizedBox(width: kSpaceLG),
                              Expanded(child: MarketPulseCard()),
                            ],
                          );
                        }
                        return const Column(
                          children: [
                            LogisticsCard(),
                            SizedBox(height: kSpaceLG),
                            MarketPulseCard(),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: kSpaceLG),

                  // Recent Projects Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpaceMarginMobile),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Active Projects', style: kHeadlineMd),
                        Text('View All', style: kLabelMd.copyWith(color: kPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: kSpaceMD),
                  SizedBox(
                    height: 220,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: kSpaceMarginMobile),
                      children: const [
                        ProjectCard(title: 'Skyline Residency', subtitle: '64% Completion • On Track', imageColor: Color(0xFFE2E8F0)),
                        SizedBox(width: kSpaceMD),
                        ProjectCard(title: 'Metro Bridge Retrofit', subtitle: '22% Completion • 3 Alerts', imageColor: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
