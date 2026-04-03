import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';
import 'package:recovery_app/features/breathing/ui/widgets/breathing_circle.dart';
import 'package:recovery_app/features/breathing/ui/widgets/phase_label.dart';

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen> {
  String _pattern = 'Box Breathing';
  int _inhale = 4;
  int _hold = 4;
  int _exhale = 4;
  int _cycles = 5;
  BreathingVibrationLevel _vibrationLevel = BreathingVibrationLevel.light;

  static const Map<String, String> _patternGoals = <String, String>{
    'Box Breathing':
        'Goal: steady the nervous system and improve focus. Equal inhale/hold/exhale timing can reduce stress spikes.',
    '4-7-8':
        'Goal: down-regulate and prepare for rest. Long exhale is used to encourage calm and reduce racing thoughts.',
    'Relaxed':
        'Goal: gentle recovery breathing with no hold. Useful when you want calm breathing without strain.',
    'Custom':
        'Goal: tailor timing to comfort and symptoms. Keep breath smooth and avoid pushing into discomfort.',
  };

  static const String _howToBreathe =
      'How to breathe: sit upright with shoulders relaxed, inhale through your nose, keep the breath soft during holds, then exhale slowly through your mouth. Stop if you feel dizzy and restart with shorter timings.';

  int get _totalSessionSeconds => (_inhale + _hold + _exhale) * _cycles;

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    if (minutes == 0) {
      return '${remainingSeconds}s';
    }
    return '${minutes}m ${remainingSeconds.toString().padLeft(2, '0')}s';
  }

  String _vibrationLabel(BreathingVibrationLevel level) {
    if (level == BreathingVibrationLevel.off) {
      return 'Off';
    }
    if (level == BreathingVibrationLevel.light) {
      return 'Light';
    }
    if (level == BreathingVibrationLevel.medium) {
      return 'Medium';
    }
    return 'Strong';
  }

  void _applyPreset(String value) {
    setState(() {
      _pattern = value;
      if (value == 'Box Breathing') {
        _inhale = 4;
        _hold = 4;
        _exhale = 4;
      } else if (value == '4-7-8') {
        _inhale = 4;
        _hold = 7;
        _exhale = 8;
      } else if (value == 'Relaxed') {
        _inhale = 5;
        _hold = 0;
        _exhale = 7;
      }
    });
  }

  Future<void> _startSession() async {
    await ref.read(breathingNotifierProvider.future);
    await ref.read(breathingNotifierProvider.notifier).startSession(
          patternName: _pattern,
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
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _pattern,
                decoration: const InputDecoration(labelText: 'Pattern'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                      value: 'Box Breathing', child: Text('Box Breathing')),
                  DropdownMenuItem(value: '4-7-8', child: Text('4-7-8')),
                  DropdownMenuItem(value: 'Relaxed', child: Text('Relaxed')),
                  DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    _applyPreset(value);
                  }
                },
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _howToBreathe,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _patternGoals[_pattern] ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 32),
              Center(child: Text('Inhale: $_inhale s')),
              Slider(
                value: _inhale.toDouble(),
                min: 1,
                max: 15,
                divisions: 14,
                onChanged: (double value) =>
                    setState(() => _inhale = value.round()),
              ),
              Center(child: Text('Hold: $_hold s')),
              Slider(
                value: _hold.toDouble(),
                min: 0,
                max: 15,
                divisions: 15,
                onChanged: (double value) =>
                    setState(() => _hold = value.round()),
              ),
              Center(child: Text('Exhale: $_exhale s')),
              Slider(
                value: _exhale.toDouble(),
                min: 1,
                max: 15,
                divisions: 14,
                onChanged: (double value) =>
                    setState(() => _exhale = value.round()),
              ),
              Center(child: Text('Cycles: $_cycles')),
              Slider(
                value: _cycles.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (double value) =>
                    setState(() => _cycles = value.round()),
              ),
              const SizedBox(height: 12),
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
                children: BreathingVibrationLevel.values
                    .map((BreathingVibrationLevel level) {
                  return ChoiceChip(
                    label: Text(_vibrationLabel(level)),
                    selected: _vibrationLevel == level,
                    onSelected: (_) {
                      setState(() => _vibrationLevel = level);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Estimated Session Time',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_totalSessionSeconds),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
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

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  bool _didRequestStop = false;

  Future<void> _stopIfActive() async {
    if (_didRequestStop) {
      return;
    }
    final BreathingState? current =
        ref.read(breathingNotifierProvider).valueOrNull;
    if (current == null || !current.isRunning || current.didFinish) {
      return;
    }

    _didRequestStop = true;
    await ref.read(breathingNotifierProvider.notifier).stopEarly();
  }

  void _stopIfActiveNoWait() {
    if (_didRequestStop) {
      return;
    }
    final BreathingState? current =
        ref.read(breathingNotifierProvider).valueOrNull;
    if (current == null || !current.isRunning || current.didFinish) {
      return;
    }

    _didRequestStop = true;
    unawaited(ref.read(breathingNotifierProvider.notifier).stopEarly());
  }

  @override
  void dispose() {
    _stopIfActiveNoWait();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<BreathingState> state =
        ref.watch(breathingNotifierProvider);
    return PopScope(
      onPopInvoked: (bool didPop) {
        if (didPop) {
          _stopIfActiveNoWait();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Active Session'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              tooltip: 'Exit Session',
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _stopIfActive();
                if (mounted) {
                  context.go('/breathing');
                }
              },
            ),
          ],
        ),
        body: state.when(
          data: (BreathingState data) {
            if (data.didFinish) {
              Future<void>.delayed(const Duration(seconds: 3), () {
                if (context.mounted) {
                  context.go('/breathing');
                }
              });
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BreathingCircle(
                    phase: data.phase,
                    phaseProgress: ((data.phaseDuration - data.secondsRemaining) /
                            data.phaseDuration)
                        .clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 12),
                  PhaseLabel(phase: data.phase),
                  Text('${data.secondsRemaining}s'),
                  Text('Cycle ${data.completedCycles} of ${data.targetCycles}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FilledButton(
                        onPressed: data.isPaused
                            ? ref.read(breathingNotifierProvider.notifier).resume
                            : ref.read(breathingNotifierProvider.notifier).pause,
                        child: Text(data.isPaused ? 'Resume' : 'Pause'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(breathingNotifierProvider.notifier)
                              .stopEarly();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Session ended early — ${data.completedCycles} cycles completed',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                  if (data.didFinish)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: <Widget>[
                              Text('Pattern: ${data.patternName}'),
                              Text('Cycles: ${data.completedCycles}'),
                              Text(
                                'Total duration: ${(data.inhaleSeconds + data.holdSeconds + data.exhaleSeconds) * data.completedCycles}s',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object _, StackTrace __) {
            return const Center(
                child: Text('Unable to start breathing session.'));
          },
        ),
      ),
    );
  }
}
