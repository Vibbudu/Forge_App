import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/forge_response.dart';
import '../widgets/forge_app_bar.dart';

import '../widgets/standards_chip.dart';
import '../widgets/failure_warning_card.dart';
import '../widgets/property_bar.dart';
import '../widgets/cost_bar.dart';
import 'vendor_map_screen.dart';

class ResultScreen extends StatefulWidget {
  final ForgeResponse data;

  const ResultScreen({super.key, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (widget.data.ttsAudioBase64 == null) return;
    
    if (_isPlaying) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() => _isPlaying = false);
    } else {
      try {
        final bytes = base64Decode(widget.data.ttsAudioBase64!);
        await _audioPlayer.play(BytesSource(bytes));
        if (!mounted) return;
        setState(() => _isPlaying = true);
        
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _isPlaying = false);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to play audio summary.')),
        );
      }
    }
  }

  // Export PDF function goes here

  Future<void> _exportPdf() async {
    if (!mounted) return;
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF report...')),
    );

    try {
      final response = await http.post(
        Uri.parse('$kApiBaseUrl$kEndpointReport/generate'),
        headers: {'Content-Type': 'application/json'},
        // We have to recreate the raw response JSON since we don't store it exactly
        // But the document says "Paste the exact response object received from /api/full-analysis"
        // Let's serialize the current widget.data object back to JSON (we might need a toJson)
        // Wait! The document says "exact response object". I'll add toJson to ForgeResponse.
        body: jsonEncode(widget.data.toJson()),
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/forge_analysis_report.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.data.recommendation;
    final std = widget.data.standards;
    final fail = widget.data.failure;
    final cost = widget.data.cost;
    final conflict = widget.data.conflictWarning;

    return Scaffold(
      appBar: const ForgeAppBar(title: 'Analysis', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kSpaceMarginMobile, kSpaceLG, kSpaceMarginMobile, kSpaceXL * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conflict Warning
            if (conflict.detected) ...[
              Container(
                decoration: BoxDecoration(
                  color: kErrorContainer,
                  borderRadius: BorderRadius.circular(kRadiusMD),
                  border: const Border(left: BorderSide(color: kError, width: 4)),
                ),
                padding: const EdgeInsets.all(kSpaceMD),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: kOnErrorContainer),
                    const SizedBox(width: kSpaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Physics Conflict Detected', style: kTitleSm.copyWith(color: kOnErrorContainer)),
                          const SizedBox(height: 4),
                          ...conflict.conflicts.map((c) => Text('• $c', style: kDataXs.copyWith(color: kOnErrorContainer))),
                          if (conflict.resolution != null) ...[
                            const SizedBox(height: 8),
                            Text('Resolution: ${conflict.resolution}', style: kLabelMd.copyWith(color: kOnErrorContainer)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kSpaceLG),
            ],

            // Header
            Row(
              children: [
                Expanded(child: Text(rec.name, style: kDisplayLg)),
                if (widget.data.ttsAudioBase64 != null)
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle_fill),
                    color: kPrimary,
                    iconSize: 40,
                    onPressed: _playAudio,
                  ),
              ],
            ),
            const SizedBox(height: kSpaceSM),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: kSurfaceContainer, borderRadius: BorderRadius.circular(100)),
              child: Text(rec.grade, style: kLabelMd.copyWith(color: kSecondary)),
            ),
            const SizedBox(height: kSpaceMD),
            Text(rec.explanation, style: kBodyMd.copyWith(color: kSecondary)),
            const SizedBox(height: kSpaceLG),

            // Standards
            Wrap(
              spacing: kSpaceSM,
              runSpacing: kSpaceSM,
              children: std.details.map((d) {
                return StandardsChip(standard: d.standard, status: d.status);
              }).toList(),
            ),
            const SizedBox(height: kSpaceLG),

            // Failure Warning
            if (fail.failureModes.isNotEmpty) ...[
              FailureWarningCard(
                title: 'Failure Mode: ${fail.failureModes.first.type}',
                description: fail.failureModes.first.description,
              ),
              const SizedBox(height: kSpaceLG),
            ],

            // Properties
            Container(
              decoration: BoxDecoration(color: kSurfaceContainerLowest, borderRadius: BorderRadius.circular(kRadiusLG), boxShadow: kSoftShadow),
              padding: const EdgeInsets.all(kSpaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mechanical Profile', style: kHeadlineMd),
                  const SizedBox(height: kSpaceMD),
                  // Show numeric properties as bars
                  ...rec.properties.entries.where((e) => e.value is num).map((entry) {
                    final val = (entry.value as num).toDouble();
                    // Color code: red for ≤3, orange for 4-6, green for ≥7
                    Color barColor;
                    if (val >= 7) {
                      barColor = const Color(0xFF16A34A); // green
                    } else if (val >= 4) {
                      barColor = kPrimary; // forge orange
                    } else {
                      barColor = kError; // red
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: kSpaceMD),
                      child: PropertyBar(
                        label: entry.key.replaceAll('_', ' ').toUpperCase(),
                        value: '${val.toInt()}/10',
                        fraction: val / 10.0,
                        barColor: barColor,
                      ),
                    );
                  }),
                  // Show non-numeric properties (like surface_finish) as chips
                  ...rec.properties.entries.where((e) => e.value is! num).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: kSpaceSM),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key.replaceAll('_', ' ').toUpperCase(), style: kDataXs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: kSurfaceContainer,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('${entry.value}'.toUpperCase(), style: kDataXs.copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: kSpaceLG),

            // Cost Comparison
            Container(
              decoration: BoxDecoration(color: kSurfaceContainerLowest, borderRadius: BorderRadius.circular(kRadiusLG), boxShadow: kSoftShadow),
              padding: const EdgeInsets.all(kSpaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Market Cost Index', style: kHeadlineMd),
                  const SizedBox(height: kSpaceLG),
                  ...cost.comparison.map((tier) {
                    // Calculate fraction relative to the most expensive option
                    final maxPrice = cost.comparison.fold<double>(0, (prev, t) => t.pricePerKgMax > prev ? t.pricePerKgMax : prev);
                    final fraction = maxPrice > 0 ? tier.pricePerKgMax / maxPrice : 0.5;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: kSpaceMD),
                      child: CostBar(
                        label: tier.name.split('(').first.trim(),
                        price: tier.priceDisplay,
                        fraction: fraction,
                        isPrimary: tier.name == rec.name,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: kSpaceLG),

            // Actions
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => VendorMapScreen(vendors: widget.data.vendors.vendors)));
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Local Vendors'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: kSpaceMD)),
                  ),
                ),
                if (widget.data.reportAvailable) ...[
                  const SizedBox(width: kSpaceSM),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _exportPdf,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                        side: const BorderSide(color: kOutlineVariant),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: kSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
