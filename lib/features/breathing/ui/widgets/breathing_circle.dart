import 'package:flutter/material.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';

class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.phase,
    required this.phaseProgress,
  });

  final BreathingPhase phase;
  final double phaseProgress;

  double _sizeForPhase() {
    if (phase == BreathingPhase.inhale) {
      return 100 + (120 * phaseProgress);
    }
    if (phase == BreathingPhase.hold) {
      return 220;
    }
    if (phase == BreathingPhase.exhale) {
      return 220 - (220 * phaseProgress);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double size = _sizeForPhase();
    final Color color = switch (phase) {
      BreathingPhase.inhale => const Color(0xFFD4DFCD),
      BreathingPhase.hold => const Color(0xFFB5C0AF),
      BreathingPhase.exhale => const Color(0xFF9BAB94),
      BreathingPhase.completed => Colors.transparent,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
