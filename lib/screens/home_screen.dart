import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';

import '../widgets/search_bar_widget.dart';
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

  void _addFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File upload coming soon')),
    );
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? Center(
                key: const ValueKey('loading'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: kPrimary),
                    const SizedBox(height: kSpaceMD),
                    Text('Analyzing with Forge Intelligence...', style: kLabelMd.copyWith(color: kSecondary)),
                  ],
                ),
              )
            : Center(
                key: const ValueKey('content'),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: kSpaceMarginMobile, vertical: kSpaceXL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'How can I help you?',
                        style: kDisplayLg,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpaceXL),
                      // Search Section
                      Stack(
                        children: [
                          ForgeSearchBar(
                            controller: _queryController,
                            onSubmit: _submitText,
                            onMicTap: _toggleVoice,
                            onCameraTap: _takePhoto,
                            onAddTap: _addFile,
                          ),
                          if (_isListening)
                            Positioned(
                              right: 96, // Positioned near the mic button
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: kError, borderRadius: BorderRadius.circular(100)),
                                child: Text('Listening...', style: kDataXs.copyWith(color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: kSpaceXL),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _navigateToAdvanced,
                            icon: const Icon(Icons.tune),
                            label: const Text('Advanced Configuration Mode'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                              backgroundColor: kSurfaceContainerLowest,
                              foregroundColor: kPrimary,
                              elevation: 2,
                              side: const BorderSide(color: kOutlineVariant),
                              textStyle: kLabelMd.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
