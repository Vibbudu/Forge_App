import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Advanced slider card — white card with label, description, floating tooltip.
/// Matches advanced_config_forge_modern: 44px thumb, tooltip bubble, card shadow.
class AdvancedSliderCard extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) formatValue;
  final ValueChanged<double> onChanged;

  const AdvancedSliderCard({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.formatValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (value - min) / (max - min);
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(kRadiusMD),
        boxShadow: kSoftShadow,
      ),
      padding: const EdgeInsets.fromLTRB(kSpaceMD, kSpaceLG, kSpaceMD, kSpaceSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: kLabelMd.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(description, style: kDataXs.copyWith(color: kOnSurfaceVariant)),
          const SizedBox(height: kSpaceLG),
          // Tooltip positioned above slider
          LayoutBuilder(
            builder: (context, constraints) {
              final tooltipLeft = fraction * (constraints.maxWidth - 44) + 22 - 30;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Tooltip bubble
                  Positioned(
                    left: tooltipLeft.clamp(0.0, constraints.maxWidth - 60),
                    top: -32,
                    child: _TooltipBubble(text: formatValue(value)),
                  ),
                  // Slider
                  SizedBox(
                    width: constraints.maxWidth,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: kSurfaceContainer,
                        inactiveTrackColor: kSurfaceContainer,
                        thumbColor: kPrimary,
                        thumbShape: _ForgeThumbShape(),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                        overlayColor: kPrimary.withValues(alpha: 0.08),
                      ),
                      child: Slider(
                        value: value,
                        min: min,
                        max: max,
                        divisions: divisions,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final String text;
  const _TooltipBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(kRadiusSM),
            boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Text(text, style: kDataXs.copyWith(color: Colors.white)),
        ),
        // Triangle pointer
        CustomPaint(
          size: const Size(12, 6),
          painter: _TrianglePainter(color: kPrimary),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ForgeThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(44, 44);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    // White border
    canvas.drawCircle(center, 22, Paint()..color = Colors.white);
    // Shadow
    canvas.drawCircle(center, 22, Paint()
      ..color = const Color(0x18000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Primary fill
    canvas.drawCircle(center, 18, Paint()..color = kPrimary);
  }
}
