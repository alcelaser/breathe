import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';
import 'package:recovery_app/features/breathing/ui/widgets/breathing_circle.dart';
import 'package:recovery_app/features/breathing/ui/widgets/phase_label.dart';

// ============================================================================
// Data Models & Constants
// ============================================================================

enum _BreathingPattern {
  boxBreathing('Box Breathing', 4, 4, 4,
      'Goal: steady the nervous system and improve focus. Equal inhale/hold/exhale timing can reduce stress spikes.'),
  breathing47('4-7-8', 4, 7, 8,
      'Goal: down-regulate and prepare for rest. Long exhale is used to encourage calm and reduce racing thoughts.'),
  relaxed('Relaxed', 5, 0, 7,
      'Goal: gentle recovery breathing with no hold. Useful when you want calm breathing without strain.'),
  custom('Custom', 4, 4, 4,
      'Goal: tailor timing to comfort and symptoms. Keep breath smooth and avoid pushing into discomfort.');

  const _BreathingPattern(this.label, this.defaultInhale, this.defaultHold,
      this.defaultExhale, this.goal);

  final String label;
  final int defaultInhale;
  final int defaultHold;
  final int defaultExhale;
  final String goal;
}

extension on BreathingVibrationLevel {
  String get label {
    return switch (this) {
      BreathingVibrationLevel.off => 'Off',
      BreathingVibrationLevel.light => 'Light',
      BreathingVibrationLevel.medium => 'Medium',
      BreathingVibrationLevel.heavy => 'Heavy',
    };
  }
}

// ============================================================================
// Utilities
// ============================================================================

class _BreathingUtils {
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (minutes == 0) return '${remaining}s';
    return '${minutes}m ${remaining.toString().padLeft(2, '0')}s';
  }
}

// ============================================================================
// Breathing Screen Setup
// ============================================================================

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  static const String _howToBreathe =
      'How to breathe: sit upright with shoulders relaxed, inhale through your nose, keep the breath soft during holds, then exhale slowly through your mouth. Stop if you feel dizzy and restart with shorter timings.';

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> {
  late _BreathingPattern _pattern = _BreathingPattern.boxBreathing;
  late int _inhale = _pattern.defaultInhale;
  late int _hold = _pattern.defaultHold;
  late int _exhale = _pattern.defaultExhale;
  int _cycles = 5;
  BreathingVibrationLevel _vibrationLevel = BreathingVibrationLevel.light;

  int get _totalSessionSeconds => (_inhale + _hold + _exhale) * _cycles;

  void _setPattern(_BreathingPattern pattern) {
    setState(() {
      _pattern = pattern;
      _inhale = pattern.defaultInhale;
      _hold = pattern.defaultHold;
      _exhale = pattern.defaultExhale;
    });
  }

  Future<void> _startSession() async {
    await ref.read(breathingNotifierProvider.future);
    await ref.read(breathingNotifierProvider.notifier).startSession(
          patternName: _pattern.label,
          inhale: _inhale,
          hold: _hold,
          exhale: _exhale,
          cycles: _cycles,
          vibrationLevel: _vibrationLevel,
        );
    if (mounted) {
      context.push('/breathing/session');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PatternDropdown(
                selectedPattern: _pattern,
                onPatternSelected: _setPattern,
              ),
              const SizedBox(height: 32),
              _InformationPanel(
                howToBreathe: BreathingScreen._howToBreathe,
                patternGoal: _pattern.goal,
              ),
              const SizedBox(height: 48),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 32),
              _BreathingParameterSliders(
                inhale: _inhale,
                hold: _hold,
                exhale: _exhale,
                cycles: _cycles,
                onInhaleChanged: (v) => setState(() => _inhale = v),
                onHoldChanged: (v) => setState(() => _hold = v),
                onExhaleChanged: (v) => setState(() => _exhale = v),
                onCyclesChanged: (v) => setState(() => _cycles = v),
              ),
              const SizedBox(height: 12),
              _VibrationSelector(
                selectedLevel: _vibrationLevel,
                onLevelSelected: (v) =>
                    setState(() => _vibrationLevel = v),
              ),
              const SizedBox(height: 20),
              _SessionTimeCard(totalSeconds: _totalSessionSeconds),
              const SizedBox(height: 8),
              Center(
                child: FilledButton(
                  onPressed: _startSession,
                  child: const Text('Start Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BreathingScreen Widgets
// ============================================================================

class _PatternDropdown extends StatelessWidget {
  const _PatternDropdown({
    required this.selectedPattern,
    required this.onPatternSelected,
  });

  final _BreathingPattern selectedPattern;
  final ValueChanged<_BreathingPattern> onPatternSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_BreathingPattern>(
      value: selectedPattern,
      decoration: const InputDecoration(labelText: 'Pattern'),
      items: [
        for (final pattern in _BreathingPattern.values)
          DropdownMenuItem(
            value: pattern,
            child: Text(pattern.label),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onPatternSelected(value);
        }
      },
    );
  }
}

class _InformationPanel extends StatelessWidget {
  const _InformationPanel({
    required this.howToBreathe,
    required this.patternGoal,
  });

  final String howToBreathe;
  final String patternGoal;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            howToBreathe,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            patternGoal,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BreathingParameterSliders extends StatelessWidget {
  const _BreathingParameterSliders({
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.cycles,
    required this.onInhaleChanged,
    required this.onHoldChanged,
    required this.onExhaleChanged,
    required this.onCyclesChanged,
  });

  final int inhale;
  final int hold;
  final int exhale;
  final int cycles;
  final ValueChanged<int> onInhaleChanged;
  final ValueChanged<int> onHoldChanged;
  final ValueChanged<int> onExhaleChanged;
  final ValueChanged<int> onCyclesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SliderParameter(
          label: 'Inhale',
          value: inhale,
          min: 1,
          max: 15,
          onChanged: onInhaleChanged,
        ),
        _SliderParameter(
          label: 'Hold',
          value: hold,
          min: 0,
          max: 15,
          onChanged: onHoldChanged,
        ),
        _SliderParameter(
          label: 'Exhale',
          value: exhale,
          min: 1,
          max: 15,
          onChanged: onExhaleChanged,
        ),
        _SliderParameter(
          label: 'Cycles',
          value: cycles,
          min: 1,
          max: 20,
          onChanged: onCyclesChanged,
        ),
      ],
    );
  }
}

class _SliderParameter extends StatelessWidget {
  const _SliderParameter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final double min;
  final double max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text('$label: $value s')),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class _VibrationSelector extends StatelessWidget {
  const _VibrationSelector({
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  final BreathingVibrationLevel selectedLevel;
  final ValueChanged<BreathingVibrationLevel> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Vibration',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in BreathingVibrationLevel.values)
              ChoiceChip(
                label: Text(level.label),
                selected: selectedLevel == level,
                onSelected: (_) => onLevelSelected(level),
              ),
          ],
        ),
      ],
    );
  }
}

class _SessionTimeCard extends StatelessWidget {
  const _SessionTimeCard({required this.totalSeconds});

  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Estimated Session Time',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _BreathingUtils.formatDuration(totalSeconds),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Active Session Screen
// ============================================================================

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  static const Duration _autoCloseDelay = Duration(seconds: 3);

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  bool _stopRequested = false;

  Future<void> _attemptStop({bool wait = true}) async {
    if (_stopRequested) return;

    final state = ref.read(breathingNotifierProvider).valueOrNull;
    if (state == null || !state.isRunning || state.didFinish) return;

    _stopRequested = true;

    if (wait) {
      await ref.read(breathingNotifierProvider.notifier).stopEarly();
    } else {
      unawaited(ref.read(breathingNotifierProvider.notifier).stopEarly());
    }
  }

  @override
  void dispose() {
    _attemptStop(wait: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathingNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          _attemptStop(wait: false);
          context.go('/breathing');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Active Session'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Exit Session',
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _attemptStop();
                if (mounted) {
                  context.go('/breathing');
                }
              },
            ),
          ],
        ),
        body: state.when(
          data: (breathingState) {
            if (breathingState.didFinish) {
              Future<void>.delayed(ActiveSessionScreen._autoCloseDelay, () {
                if (context.mounted) {
                  context.go('/breathing');
                }
              });
            }

            return _SessionContent(
              state: breathingState,
              onStopEarly: () async {
                await ref.read(breathingNotifierProvider.notifier).stopEarly();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Session ended early � ${breathingState.completedCycles} cycles completed',
                      ),
                    ),
                  );
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Unable to start breathing session.'),
          ),
        ),
      ),
    );
  }
}

class _SessionContent extends ConsumerWidget {
  const _SessionContent({
    required this.state,
    required this.onStopEarly,
  });

  final BreathingState state;
  final VoidCallback onStopEarly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BreathingCircle(
            phase: state.phase,
            phaseProgress:
                ((state.phaseDuration - state.secondsRemaining) /
                        state.phaseDuration)
                    .clamp(0.0, 1.0),
          ),
          const SizedBox(height: 12),
          PhaseLabel(phase: state.phase),
          Text('${state.secondsRemaining}s'),
          Text('Cycle ${state.completedCycles} of ${state.targetCycles}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: state.isPaused
                    ? ref.read(breathingNotifierProvider.notifier).resume
                    : ref.read(breathingNotifierProvider.notifier).pause,
                child: Text(state.isPaused ? 'Resume' : 'Pause'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onStopEarly,
                child: const Text('Stop'),
              ),
            ],
          ),
          if (state.didFinish)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _SessionSummaryCard(state: state),
            ),
        ],
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({required this.state});

  final BreathingState state;

  @override
  Widget build(BuildContext context) {
    final totalDuration =
        (state.inhaleSeconds + state.holdSeconds + state.exhaleSeconds) *
            state.completedCycles;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Pattern: ${state.patternName}'),
            Text('Cycles: ${state.completedCycles}'),
            Text('Total duration: ${totalDuration}s'),
          ],
        ),
      ),
    );
  }
}
