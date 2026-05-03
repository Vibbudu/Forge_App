import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';
import '../services/api_service.dart';
import '../models/forge_response.dart';
import '../services/location_service.dart';
import 'result_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? initialImageBase64;
  final String initialLanguage;

  const ChatScreen({
    super.key,
    this.initialImageBase64,
    required this.initialLanguage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  String? _currentImageBase64;
  String _responseMode = 'CHAT';

  @override
  void initState() {
    super.initState();
    _currentImageBase64 = widget.initialImageBase64;
    if (_currentImageBase64 != null) {
      _messages.add({
        'role': 'user',
        'type': 'image',
        'content': 'Image uploaded',
        'image': _currentImageBase64,
      });
    }
    // Add welcome message
    _messages.add({
      'role': 'assistant',
      'type': 'text',
      'content': _getWelcomeMessage(),
    });
  }

  String _getWelcomeMessage() {
    switch (widget.initialLanguage) {
      case 'hi-IN': return 'नमस्ते! मैं आपकी कैसे मदद कर सकता हूँ?';
      case 'kn-IN': return 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?';
      default: return 'Hello! How can I help you today?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? textOverride}) async {
    final text = textOverride ?? _controller.text.trim();
    if (text.isEmpty && _currentImageBase64 == null) return;

    setState(() {
      if (text.isNotEmpty) {
        _messages.add({'role': 'user', 'type': 'text', 'content': text});
      }
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await ApiService().multimodalChat(
        text: text.isEmpty ? "What's in this image?" : text,
        imageBase64: _currentImageBase64,
        language: widget.initialLanguage,
        responseMode: _responseMode,
      );

      if (_responseMode == 'BREAKDOWN' && response['recommendation'] != null) {
        final forgeResponse = ForgeResponse.fromJson(response, language: widget.initialLanguage);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(data: forgeResponse)),
        );
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _messages.add({
          'role': 'assistant',
          'type': 'text',
          'content': response['chat_text'] ?? 'No response received.',
        });
        _currentImageBase64 = null; // Clear image context after first use
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat error: $e')),
      );
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      final path = await _audioRecorder.stop();
      setState(() => _isListening = false);
      if (path != null) {
        _processVoice(path);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/chat_voice_${DateTime.now().millisecondsSinceEpoch}.wav';
        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        );
        await _audioRecorder.start(config, path: path);
        setState(() => _isListening = true);
      }
    }
  }

  Future<void> _processVoice(String path) async {
    setState(() => _isLoading = true);
    try {
      final bytes = await File(path).readAsBytes();
      final base64Audio = base64Encode(bytes);
      final response = await ApiService().transcribeAudio(
        audioBase64: base64Audio,
        languageCode: widget.initialLanguage,
      );
      
      final transcript = response['transcript'] ?? '';
      if (transcript.isNotEmpty) {
        _sendMessage(textOverride: transcript);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'Expert Chat', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(kSpaceMD),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildChatBubble(msg, isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: kSpaceMD),
        padding: const EdgeInsets.all(kSpaceMD),
        decoration: BoxDecoration(
          color: isUser ? kPrimary : kSurfaceContainer,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: msg['type'] == 'image'
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(base64Decode(msg['image'])),
                  ),
                  const SizedBox(height: 4),
                  Text(msg['content'], style: kLabelMd.copyWith(color: Colors.white70)),
                ],
              )
            : Text(
                msg['content'],
                style: kBodyMd.copyWith(color: isUser ? Colors.white : kSecondary),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(kSpaceMD),
      decoration: const BoxDecoration(
        color: kSurfaceContainerLowest,
        boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ActionChip(
                  label: Text(_responseMode == 'CHAT' ? 'Chat Mode' : 'Report Mode'),
                  avatar: Icon(_responseMode == 'CHAT' ? Icons.chat : Icons.assignment, size: 16),
                  onPressed: () {
                    setState(() {
                      _responseMode = _responseMode == 'CHAT' ? 'BREAKDOWN' : 'CHAT';
                    });
                  },
                  backgroundColor: _responseMode == 'CHAT' ? kPrimary.withValues(alpha: 0.1) : kSuccess.withValues(alpha: 0.1),
                  labelStyle: kDataXs.copyWith(color: _responseMode == 'CHAT' ? kPrimary : kSuccess),
                ),
                const Spacer(),
                if (_currentImageBase64 != null)
                  Chip(
                    label: const Text('Image Attached'),
                    onDeleted: () => setState(() => _currentImageBase64 = null),
                    deleteIconColor: kError,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? kError : kPrimary),
                  onPressed: _toggleListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _responseMode == 'CHAT' ? 'Ask a question...' : 'Describe for report...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: kSurfaceContainer,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: kPrimary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
