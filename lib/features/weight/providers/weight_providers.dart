import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/core/database/database_providers.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';
import 'package:recovery_app/features/weight/data/weight_repository.dart';

final weightRepositoryProvider = Provider<WeightRepository>((Ref ref) {
  final helper = ref.watch(databaseHelperProvider);
  return WeightRepository(helper: helper);
});

final weightNotifierProvider =
    AsyncNotifierProvider<WeightNotifier, List<WeightEntry>>(
        WeightNotifier.new);

final latestWeightSummaryProvider =
    FutureProvider<({WeightEntry? latest, double? delta})>((Ref ref) async {
  final repository = ref.watch(weightRepositoryProvider);
  final latest = await repository.getLatestWeightEntry();
  if (latest == null) {
    return (latest: null, delta: null);
  }
  final delta = await repository.getDeltaFromPrevious(date: latest.date);
  return (latest: latest, delta: delta);
});

class WeightNotifier extends AsyncNotifier<List<WeightEntry>> {
  WeightRepository get _repository => ref.read(weightRepositoryProvider);

  @override
  Future<List<WeightEntry>> build() async {
    return _repository.getAllWeightEntries();
  }

  Future<void> addEntry(WeightEntry entry) async {
    await _repository.insertOrUpdateWeight(entry);
    state = await AsyncValue.guard(_repository.getAllWeightEntries);
  }

  Future<void> deleteEntry(int id) async {
    await _repository.deleteWeightEntry(id);
    final List<WeightEntry> current = state.valueOrNull ?? <WeightEntry>[];
    state = AsyncData<List<WeightEntry>>(
      current.where((WeightEntry item) => item.id != id).toList(),
    );
  }

  double? deltaForEntry(WeightEntry entry) {
    final List<WeightEntry> entries = state.valueOrNull ?? <WeightEntry>[];
    final int index =
        entries.indexWhere((WeightEntry value) => value.id == entry.id);
    if (index <= 0) {
      return null;
    }
    return entry.weightKg - entries[index - 1].weightKg;
  }
}
