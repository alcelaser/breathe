import 'package:flutter/material.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';

class PhaseLabel extends StatelessWidget {
  const PhaseLabel({
    super.key,
    required this.phase,
  });

  final BreathingPhase phase;

  String get _label {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
      case BreathingPhase.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _label,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
