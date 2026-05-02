import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/forge_app_bar.dart';
import '../widgets/segmented_control.dart';
import '../widgets/advanced_slider_card.dart';
import 'result_screen.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class AdvancedConfigScreen extends StatefulWidget {
  const AdvancedConfigScreen({super.key});

  @override
  State<AdvancedConfigScreen> createState() => _AdvancedConfigScreenState();
}

class _AdvancedConfigScreenState extends State<AdvancedConfigScreen> {
  int _finishIndex = 0;
  final List<String> _finishes = ['Glossy', 'Matte', 'Brushed'];
  bool _isLoading = false;

  // Sliders strictly on 1-10 scale as per documentation
  double _tensile = 5;
  double _ductility = 5;
  double _corrosion = 5;
  double _malleability = 5;
  double _thermal = 5;
  double _density = 5;

  Future<void> _findMaterial() async {
    setState(() => _isLoading = true);
    try {
      final advancedParams = {
        'tensile_strength': _tensile.toInt(),
        'ductility': _ductility.toInt(),
        'corrosion_resistance': _corrosion.toInt(),
        'malleability': _malleability.toInt(),
        'thermal_resistance': _thermal.toInt(),
        'density': _density.toInt(),
        'surface_finish': _finishes[_finishIndex].toLowerCase(),
      };

      final loc = await LocationService().getCurrentLocation();
      final response = await ApiService().analyzeQuery(
        inputType: 'advanced',
        advancedParams: advancedParams,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ForgeAppBar(title: 'Advanced Configuration', showBackButton: true),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: kPrimary),
                  const SizedBox(height: kSpaceMD),
                  Text('Processing configuration...', style: kLabelMd.copyWith(color: kSecondary)),
                ],
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFFFFF5F0), kBackground],
                  center: Alignment(0, -0.8),
                  radius: 1.5,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  kSpaceMarginMobile, kSpaceLG, kSpaceMarginMobile, 120, // space for bottom button
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Material Card
                    Container(
                      decoration: BoxDecoration(
                        color: kSurfaceContainerLowest,
                        borderRadius: BorderRadius.circular(kRadiusLG),
                        boxShadow: kSoftShadow,
                      ),
                      padding: const EdgeInsets.all(kSpaceMD),
                      child: Row(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(color: kSurfaceContainer, borderRadius: BorderRadius.circular(kRadiusMD)),
                            child: Icon(Icons.memory, size: 32, color: kOutline.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(width: kSpaceMD),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: kPrimaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(kRadiusSM)),
                                  child: Text('CUSTOM BUILD', style: kDataXs.copyWith(color: kPrimary)),
                                ),
                                const SizedBox(height: 4),
                                const Text('Parameter Specification', style: kTitleSm),
                                const SizedBox(height: 2),
                                Text('Set exact physics properties (1-10)', style: kDataXs.copyWith(color: kSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSpaceXL),

                    const Text('SURFACE FINISH', style: kDataXs),
                    const SizedBox(height: kSpaceSM),
                    SegmentedControl(
                      items: _finishes,
                      selectedIndex: _finishIndex,
                      onChanged: (i) => setState(() => _finishIndex = i),
                    ),
                    const SizedBox(height: kSpaceXL),

                    const Text('SUBSTRATE PARAMETERS (1-10)', style: kDataXs),
                    const SizedBox(height: kSpaceSM),

                    AdvancedSliderCard(
                      label: 'Tensile Strength',
                      description: 'Resistance to breaking under tension',
                      value: _tensile,
                      min: 1, max: 10, divisions: 9,
                      formatValue: (v) => v.toInt().toString(),
                      onChanged: (v) => setState(() => _tensile = v),
                    ),
                    const SizedBox(height: kSpaceMD),

                    AdvancedSliderCard(
                      label: 'Ductility',
                      description: 'Ability to deform under tensile stress',
                      value: _ductility,
                      min: 1, max: 10, divisions: 9,
                      formatValue: (v) => v.toInt().toString(),
                      onChanged: (v) => setState(() => _ductility = v),
                    ),
                    const SizedBox(height: kSpaceMD),

                    AdvancedSliderCard(
                      label: 'Corrosion Resistance',
                      description: 'Resistance to oxidation and chemical attack',
                      value: _corrosion,
                      min: 1, max: 10, divisions: 9,
                      formatValue: (v) => v.toInt().toString(),
                      onChanged: (v) => setState(() => _corrosion = v),
                    ),
                    const SizedBox(height: kSpaceMD),

                    AdvancedSliderCard(
                      label: 'Malleability',
                      description: 'Ability to deform under compressive stress',
                      value: _malleability,
                      min: 1, max: 10, divisions: 9,
                      formatValue: (v) => v.toInt().toString(),
                      onChanged: (v) => setState(() => _malleability = v),
                    ),
                    const SizedBox(height: kSpaceMD),

                    AdvancedSliderCard(
                      label: 'Thermal Resistance',
                      description: 'Ability to resist heat flow',
                      value: _thermal,
                      min: 1, max: 10, divisions: 9,
                      formatValue: (v) => v.toInt().toString(),
                      onChanged: (v) => setState(() => _thermal = v),
                    ),
                    const SizedBox(height: kSpaceMD),

                    AdvancedSliderCard(
                      label: 'Density',
                      description: 'Mass per unit volume ratio',
                      value: _density,
                      min: 1, max: 10, divisions: 9,
                      formatValue: (v) => v.toInt().toString(),
                      onChanged: (v) => setState(() => _density = v),
                    ),
                  ],
                ),
              ),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(kSpaceMarginMobile, kSpaceSM, kSpaceMarginMobile, kSpaceLG),
        decoration: const BoxDecoration(
          color: kSurfaceContainerLowest,
          boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, -8))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _findMaterial,
              icon: const Icon(Icons.search),
              label: const Text('Find Material'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: kSpaceMD),
                elevation: 4,
                shadowColor: kPrimary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
