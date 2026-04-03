import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/core/database/database_providers.dart';
import 'package:recovery_app/features/breathing/data/breathing_repository.dart';
import 'package:recovery_app/features/breathing/data/models/breathing_session.dart';

enum BreathingPhase { inhale, hold, exhale, completed }

enum BreathingVibrationLevel { off, light, medium, heavy }

class BreathingState {
  const BreathingState({
    required this.phase,
    required this.secondsRemaining,
    required this.phaseDuration,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.targetCycles,
    required this.completedCycles,
    required this.patternName,
    required this.vibrationLevel,
    required this.isRunning,
    required this.isPaused,
    required this.didFinish,
  });

  factory BreathingState.initial() {
    return const BreathingState(
      phase: BreathingPhase.inhale,
      secondsRemaining: 4,
      phaseDuration: 4,
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      targetCycles: 5,
      completedCycles: 0,
      patternName: 'Box Breathing',
      vibrationLevel: BreathingVibrationLevel.light,
      isRunning: false,
      isPaused: false,
      didFinish: false,
    );
  }

  final BreathingPhase phase;
  final int secondsRemaining;
  final int phaseDuration;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int targetCycles;
  final int completedCycles;
  final String patternName;
  final BreathingVibrationLevel vibrationLevel;
  final bool isRunning;
  final bool isPaused;
  final bool didFinish;

  BreathingState copyWith({
    BreathingPhase? phase,
    int? secondsRemaining,
    int? phaseDuration,
    int? inhaleSeconds,
    int? holdSeconds,
    int? exhaleSeconds,
    int? targetCycles,
    int? completedCycles,
    String? patternName,
    BreathingVibrationLevel? vibrationLevel,
    bool? isRunning,
    bool? isPaused,
    bool? didFinish,
  }) {
    return BreathingState(
      phase: phase ?? this.phase,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      phaseDuration: phaseDuration ?? this.phaseDuration,
      inhaleSeconds: inhaleSeconds ?? this.inhaleSeconds,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      targetCycles: targetCycles ?? this.targetCycles,
      completedCycles: completedCycles ?? this.completedCycles,
      patternName: patternName ?? this.patternName,
      vibrationLevel: vibrationLevel ?? this.vibrationLevel,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      didFinish: didFinish ?? this.didFinish,
    );
  }
}

final breathingRepositoryProvider = Provider<BreathingRepository>((Ref ref) {
  final helper = ref.watch(databaseHelperProvider);
  return BreathingRepository(helper: helper);
});

final breathingNotifierProvider =
    AsyncNotifierProvider<BreathingNotifier, BreathingState>(
        BreathingNotifier.new);

final breathingTodayProvider =
    FutureProvider<List<BreathingSession>>((Ref ref) {
  final repository = ref.watch(breathingRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return repository.getSessionsForDate(today);
});

class BreathingNotifier extends AsyncNotifier<BreathingState> {
  Timer? _timer;

  BreathingRepository get _repository => ref.read(breathingRepositoryProvider);

  @override
  Future<BreathingState> build() async {
    ref.onDispose(() => _timer?.cancel());
    return BreathingState.initial();
  }

  Future<void> startSession({
    required String patternName,
    required int inhale,
    required int hold,
    required int exhale,
    required int cycles,
    BreathingVibrationLevel vibrationLevel = BreathingVibrationLevel.light,
  }) async {
    final BreathingState next = BreathingState.initial().copyWith(
      patternName: patternName,
      inhaleSeconds: inhale,
      holdSeconds: hold,
      exhaleSeconds: exhale,
      targetCycles: cycles,
      vibrationLevel: vibrationLevel,
      phase: BreathingPhase.inhale,
      secondsRemaining: inhale,
      phaseDuration: inhale,
      isRunning: true,
      isPaused: false,
      completedCycles: 0,
      didFinish: false,
    );
    state = AsyncData<BreathingState>(next);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    _playPhaseCue();
  }

  void tick() {
    final BreathingState? current = state.valueOrNull;
    if (current == null || !current.isRunning || current.isPaused) {
      return;
    }

    if (current.secondsRemaining > 1) {
      state = AsyncData<BreathingState>(
        current.copyWith(secondsRemaining: current.secondsRemaining - 1),
      );
      return;
    }

    if (current.phase == BreathingPhase.inhale) {
      if (current.holdSeconds > 0) {
        state = AsyncData<BreathingState>(
          current.copyWith(
            phase: BreathingPhase.hold,
            secondsRemaining: current.holdSeconds,
            phaseDuration: current.holdSeconds,
          ),
        );
      } else {
        state = AsyncData<BreathingState>(
          current.copyWith(
            phase: BreathingPhase.exhale,
            secondsRemaining: current.exhaleSeconds,
            phaseDuration: current.exhaleSeconds,
          ),
        );
      }
      _playPhaseCue();
      return;
    }

    if (current.phase == BreathingPhase.hold) {
      state = AsyncData<BreathingState>(
        current.copyWith(
          phase: BreathingPhase.exhale,
          secondsRemaining: current.exhaleSeconds,
          phaseDuration: current.exhaleSeconds,
        ),
      );
      _playPhaseCue();
      return;
    }

    if (current.phase == BreathingPhase.exhale) {
      final int nextCycle = current.completedCycles + 1;
      if (nextCycle >= current.targetCycles) {
        _finishSession(nextCycle);
      } else {
        state = AsyncData<BreathingState>(
          current.copyWith(
            phase: BreathingPhase.inhale,
            completedCycles: nextCycle,
            secondsRemaining: current.inhaleSeconds,
            phaseDuration: current.inhaleSeconds,
          ),
        );
        _playPhaseCue();
      }
    }
  }

  void pause() {
    final BreathingState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData<BreathingState>(current.copyWith(isPaused: true));
  }

  void resume() {
    final BreathingState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData<BreathingState>(current.copyWith(isPaused: false));
  }

  Future<void> stopEarly() async {
    final BreathingState? current = state.valueOrNull;
    if (current == null || !current.isRunning) {
      return;
    }
    _timer?.cancel();
    await _repository.insertSession(
      BreathingSession(
        date: DateTime.now(),
        patternName: current.patternName,
        inhaleSeconds: current.inhaleSeconds,
        holdSeconds: current.holdSeconds,
        exhaleSeconds: current.exhaleSeconds,
        cyclesCompleted: current.completedCycles,
      ),
    );
    state = AsyncData<BreathingState>(
      current.copyWith(
        isRunning: false,
        isPaused: false,
        phase: BreathingPhase.completed,
        didFinish: true,
      ),
    );
  }

  Future<void> _finishSession(int completedCycles) async {
    final BreathingState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    _timer?.cancel();
    await _repository.insertSession(
      BreathingSession(
        date: DateTime.now(),
        patternName: current.patternName,
        inhaleSeconds: current.inhaleSeconds,
        holdSeconds: current.holdSeconds,
        exhaleSeconds: current.exhaleSeconds,
        cyclesCompleted: completedCycles,
      ),
    );
    state = AsyncData<BreathingState>(
      current.copyWith(
        completedCycles: completedCycles,
        isRunning: false,
        isPaused: false,
        phase: BreathingPhase.completed,
        didFinish: true,
      ),
    );
    _playPhaseCue();
  }

  void _playPhaseCue() {
    final BreathingState? current = state.valueOrNull;
    if (kIsWeb || current == null) {
      return;
    }
    if (current.vibrationLevel == BreathingVibrationLevel.off) {
      return;
    }

    if (current.vibrationLevel == BreathingVibrationLevel.light) {
      HapticFeedback.lightImpact();
    } else if (current.vibrationLevel == BreathingVibrationLevel.medium) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    SystemSound.play(SystemSoundType.alert);
  }
}
