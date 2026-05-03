import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';

import '../widgets/search_bar_widget.dart';
import 'result_screen.dart';
import 'advanced_config_screen.dart';
import 'materials_screen.dart';
import 'history_screen.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _queryController = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isLoading = false;
  bool _isListening = false;
  String _selectedLanguage = 'en-IN';
  String? _recordingPath;

  final List<Map<String, String>> _languages = [
    {'code': 'en-IN', 'name': 'English'},
    {'code': 'hi-IN', 'name': 'Hindi'},
    {'code': 'kn-IN', 'name': 'Kannada'},
  ];

  @override
  void dispose() {
    _queryController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _submitText() async {
    if (_queryController.text.trim().isEmpty) return;
    await _analyze(
      inputType: 'text',
      text: _queryController.text.trim(),
      language: _selectedLanguage,
    );
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      final path = await _audioRecorder.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _recordingPath = path;
      });

      if (_recordingPath != null) {
        await _processVoiceTranscription(_recordingPath!);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/forge_record_${DateTime.now().millisecondsSinceEpoch}.wav';

        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
          numChannels: 1,
        );

        await _audioRecorder.start(config, path: path);
        if (!mounted) return;
        setState(() {
          _isListening = true;
          _queryController.text = 'Listening...';
        });
      }
    }
  }

  Future<void> _processVoiceTranscription(String path) async {
    setState(() => _isLoading = true);
    try {
      final bytes = await File(path).readAsBytes();
      final base64Audio = base64Encode(bytes);

      final result = await ApiService().transcribeAudio(
        audioBase64: base64Audio,
        languageCode: _selectedLanguage,
        audioFormat: 'wav',
      );

      final transcript = result['transcript'] ?? '';
      final readyForAnalysis = result['ready_for_analysis'] ?? false;

      if (!mounted) return;
      setState(() {
        _queryController.text = transcript;
        _isLoading = false;
      });

      if (readyForAnalysis && transcript.isNotEmpty) {
        await _analyze(inputType: 'voice_transcript', text: transcript, language: _selectedLanguage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transcription error: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      final base64Image = base64Encode(bytes);
      await _analyze(inputType: 'photo', photoBase64: base64Image, language: _selectedLanguage);
    }
  }

  Future<void> _addFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      await _analyze(inputType: 'photo', photoBase64: base64Image, language: _selectedLanguage);
    }
  }

  Future<void> _analyze({
    required String inputType,
    String? text,
    String? photoBase64,
    String language = 'en-IN',
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
        language: language,
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

  void _navigateToMaterials() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MaterialsScreen()),
    );
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
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
                      // Language Selector
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _languages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: kSpaceSM),
                          itemBuilder: (context, index) {
                            final lang = _languages[index];
                            final isSelected = _selectedLanguage == lang['code'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedLanguage = lang['code']!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? kPrimary : kSurfaceContainer,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  lang['name']!,
                                  style: kDataXs.copyWith(
                                    color: isSelected ? Colors.white : kSecondary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: kSpaceMD),
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
                      const SizedBox(height: kSpaceMD),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _navigateToMaterials,
                            icon: const Icon(Icons.inventory_2_outlined),
                            label: const Text('Browse Materials Database'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                              foregroundColor: kSecondary,
                              side: const BorderSide(color: kOutlineVariant),
                              textStyle: kLabelMd,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpaceMD),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _navigateToHistory,
                            icon: const Icon(Icons.history),
                            label: const Text('Saved Analyses'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                              foregroundColor: kSecondary,
                              side: const BorderSide(color: kOutlineVariant),
                              textStyle: kLabelMd,
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
