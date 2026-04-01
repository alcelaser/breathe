import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/core/database/database_providers.dart';
import 'package:recovery_app/features/physio/data/exercise_log_repository.dart';
import 'package:recovery_app/features/physio/data/exercise_repository.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';
import 'package:recovery_app/features/physio/data/models/exercise_log.dart';
import 'package:recovery_app/features/physio/data/models/plan_progress_entry.dart';

class PhysioState {
  const PhysioState({
    required this.allExercises,
    required this.filteredExercises,
    required this.selectedBodyAreas,
    required this.todaysLogs,
    required this.loggedExerciseIds,
    required this.plannedExerciseIds,
    required this.planRepsToday,
    required this.planHistoryByExercise,
    required this.selectedPlanDate,
  });

  final List<Exercise> allExercises;
  final List<Exercise> filteredExercises;
  final Set<String> selectedBodyAreas;
  final List<ExerciseLog> todaysLogs;
  final Set<String> loggedExerciseIds;
  final Set<String> plannedExerciseIds;
  final Map<String, int> planRepsToday;
  final Map<String, List<PlanProgressEntry>> planHistoryByExercise;
  final DateTime selectedPlanDate;

  PhysioState copyWith({
    List<Exercise>? allExercises,
    List<Exercise>? filteredExercises,
    Set<String>? selectedBodyAreas,
    List<ExerciseLog>? todaysLogs,
    Set<String>? loggedExerciseIds,
    Set<String>? plannedExerciseIds,
    Map<String, int>? planRepsToday,
    Map<String, List<PlanProgressEntry>>? planHistoryByExercise,
    DateTime? selectedPlanDate,
  }) {
    return PhysioState(
      allExercises: allExercises ?? this.allExercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      selectedBodyAreas: selectedBodyAreas ?? this.selectedBodyAreas,
      todaysLogs: todaysLogs ?? this.todaysLogs,
      loggedExerciseIds: loggedExerciseIds ?? this.loggedExerciseIds,
      plannedExerciseIds: plannedExerciseIds ?? this.plannedExerciseIds,
      planRepsToday: planRepsToday ?? this.planRepsToday,
      planHistoryByExercise:
          planHistoryByExercise ?? this.planHistoryByExercise,
      selectedPlanDate: selectedPlanDate ?? this.selectedPlanDate,
    );
  }
}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((Ref ref) {
  return ExerciseRepository();
});

final exerciseLogRepositoryProvider =
    Provider<ExerciseLogRepository>((Ref ref) {
  final helper = ref.watch(databaseHelperProvider);
  return ExerciseLogRepository(helper: helper);
});

final physioNotifierProvider =
    AsyncNotifierProvider<PhysioNotifier, PhysioState>(PhysioNotifier.new);

final selectedPlanDateProvider = StateProvider<DateTime>((Ref ref) {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final physioCompletedTodayCountProvider = FutureProvider<int>((Ref ref) async {
  final logs = await ref.watch(physioNotifierProvider.future);
  return logs.loggedExerciseIds.length;
});

class PhysioNotifier extends AsyncNotifier<PhysioState> {
  ExerciseRepository get _exerciseRepository =>
      ref.read(exerciseRepositoryProvider);

  ExerciseLogRepository get _logRepository =>
      ref.read(exerciseLogRepositoryProvider);

  @override
  Future<PhysioState> build() async {
    final List<Exercise> exercises = await _exerciseRepository.loadExercises();
    final DateTime selectedDate = ref.watch(selectedPlanDateProvider);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<ExerciseLog> logs = await _logRepository.getLogsForDate(today);
    final Set<String> planIds = await _logRepository.getPlannedExerciseIds();
    final Map<String, int> repsToday =
      await _logRepository.getPlanRepsForDate(selectedDate);
    final Map<String, List<PlanProgressEntry>> history =
        <String, List<PlanProgressEntry>>{};
    for (final String exerciseId in planIds) {
      history[exerciseId] =
          await _logRepository.getPlanHistoryForExercise(exerciseId);
    }
    return PhysioState(
      allExercises: exercises,
      filteredExercises: exercises,
      selectedBodyAreas: <String>{},
      todaysLogs: logs,
      loggedExerciseIds: logs.map((ExerciseLog log) => log.exerciseId).toSet(),
      plannedExerciseIds: planIds,
      planRepsToday: repsToday,
      planHistoryByExercise: history,
      selectedPlanDate: selectedDate,
    );
  }

  Future<void> loadPlanForDate(DateTime date) async {
    final PhysioState? current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final DateTime normalized = DateTime(date.year, date.month, date.day);
    ref.read(selectedPlanDateProvider.notifier).state = normalized;
    final Map<String, int> repsForDate =
        await _logRepository.getPlanRepsForDate(normalized);

    state = AsyncData<PhysioState>(
      current.copyWith(
        selectedPlanDate: normalized,
        planRepsToday: repsForDate,
      ),
    );
  }

  void toggleBodyArea(String bodyArea) {
    final PhysioState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    final Set<String> next = <String>{...current.selectedBodyAreas};
    if (next.contains(bodyArea)) {
      next.remove(bodyArea);
    } else {
      next.add(bodyArea);
    }

    final List<Exercise> filtered = _exerciseRepository.filterByBodyArea(
      exercises: current.allExercises,
      selectedBodyAreas: next,
    );

    state = AsyncData<PhysioState>(
      current.copyWith(
        selectedBodyAreas: next,
        filteredExercises: filtered,
      ),
    );
  }

  void clearFilters() {
    final PhysioState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    state = AsyncData<PhysioState>(
      current.copyWith(
        selectedBodyAreas: <String>{},
        filteredExercises: current.allExercises,
      ),
    );
  }

  Future<void> markDone(String exerciseId) async {
    final PhysioState? current = state.valueOrNull;
    if (current == null || current.loggedExerciseIds.contains(exerciseId)) {
      return;
    }
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    await _logRepository.logExercise(exerciseId: exerciseId, date: today);
    final List<ExerciseLog> logs = await _logRepository.getLogsForDate(today);
    state = AsyncData<PhysioState>(
      current.copyWith(
        todaysLogs: logs,
        loggedExerciseIds:
            logs.map((ExerciseLog item) => item.exerciseId).toSet(),
      ),
    );
  }

  Future<void> addToPlan(String exerciseId) async {
    final PhysioState? current = state.valueOrNull;
    if (current == null || current.plannedExerciseIds.contains(exerciseId)) {
      return;
    }
    await _logRepository.addToPlan(exerciseId);
    final Set<String> refreshed = await _logRepository.getPlannedExerciseIds();
    final Map<String, List<PlanProgressEntry>> history =
        <String, List<PlanProgressEntry>>{...current.planHistoryByExercise};
    history[exerciseId] =
        await _logRepository.getPlanHistoryForExercise(exerciseId);
    state = AsyncData<PhysioState>(
      current.copyWith(
        plannedExerciseIds: refreshed,
        planHistoryByExercise: history,
      ),
    );
  }

  Future<void> removeFromPlan(String exerciseId) async {
    final PhysioState? current = state.valueOrNull;
    if (current == null) {
      return;
    }
    await _logRepository.removeFromPlan(exerciseId);
    final Set<String> refreshed = await _logRepository.getPlannedExerciseIds();
    final Map<String, List<PlanProgressEntry>> history =
        <String, List<PlanProgressEntry>>{...current.planHistoryByExercise};
    history.remove(exerciseId);
    final Map<String, int> repsToday = <String, int>{...current.planRepsToday};
    repsToday.remove(exerciseId);
    state = AsyncData<PhysioState>(
      current.copyWith(
        plannedExerciseIds: refreshed,
        planHistoryByExercise: history,
        planRepsToday: repsToday,
      ),
    );
  }

  Future<void> logPlanReps({
    required String exerciseId,
    required int reps,
  }) async {
    final PhysioState? current = state.valueOrNull;
    if (current == null || reps <= 0) {
      return;
    }

    final DateTime selectedDate = current.selectedPlanDate;
    await _logRepository.incrementPlanReps(
      exerciseId: exerciseId,
      reps: reps,
      date: selectedDate,
    );
    final Map<String, int> repsToday =
        await _logRepository.getPlanRepsForDate(selectedDate);
    final List<PlanProgressEntry> history =
        await _logRepository.getPlanHistoryForExercise(exerciseId);
    final Map<String, List<PlanProgressEntry>> historyMap =
        <String, List<PlanProgressEntry>>{...current.planHistoryByExercise};
    historyMap[exerciseId] = history;

    state = AsyncData<PhysioState>(
      current.copyWith(
        planRepsToday: repsToday,
        planHistoryByExercise: historyMap,
      ),
    );
  }
}
