import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';
import 'package:recovery_app/features/weight/providers/weight_providers.dart';
import 'package:recovery_app/features/weight/ui/weight_screen.dart';

void main() {
  testWidgets('renders chart and entry list', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weightNotifierProvider.overrideWith(() => _FakeWeightNotifier()),
        ],
        child: const MaterialApp(home: WeightScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('WEIGHT'), findsOneWidget);
    expect(find.text('69.5 kg'), findsOneWidget);
  });
}

class _FakeWeightNotifier extends WeightNotifier {
  @override
  Future<List<WeightEntry>> build() async {
    return <WeightEntry>[
      WeightEntry(id: 1, date: DateTime(2026, 4, 1), weightKg: 70),
      WeightEntry(id: 2, date: DateTime(2026, 4, 2), weightKg: 69.5),
    ];
  }
}
