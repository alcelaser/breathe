import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recovery_app/features/breathing/data/models/breathing_session.dart';
import 'package:recovery_app/features/home/ui/home_screen.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';
import 'package:recovery_app/features/physio/providers/physio_providers.dart';
import 'package:recovery_app/features/weight/providers/weight_providers.dart';

void main() {
  testWidgets('shows all four dashboard cards', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
            path: '/breathing',
            builder: (_, __) => const Scaffold(body: Text('B'))),
        GoRoute(
            path: '/meals',
            builder: (_, __) => const Scaffold(body: Text('M'))),
        GoRoute(
            path: '/weight',
            builder: (_, __) => const Scaffold(body: Text('W'))),
        GoRoute(
            path: '/physio',
            builder: (_, __) => const Scaffold(body: Text('P'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breathingTodayProvider
              .overrideWith((ref) async => <BreathingSession>[]),
          mealsCountTodayProvider.overrideWith((ref) async => 0),
          latestWeightSummaryProvider
              .overrideWith((ref) async => (latest: null, delta: null)),
          physioTodayProgressProvider
              .overrideWith((ref) async => (exercisesDone: 0, totalReps: 0)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('BREATHING'), findsOneWidget);
    expect(find.text('MEALS'), findsOneWidget);
    expect(find.text('WEIGHT'), findsOneWidget);
    expect(find.text('PHYSIO'), findsOneWidget);
    expect(find.text('No session yet'), findsOneWidget);
    expect(find.text('No progress logged today'), findsOneWidget);
  });

  testWidgets('shows physio reps progress even when exercises are not done',
      (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
            path: '/breathing',
            builder: (_, __) => const Scaffold(body: Text('B'))),
        GoRoute(
            path: '/meals',
            builder: (_, __) => const Scaffold(body: Text('M'))),
        GoRoute(
            path: '/weight',
            builder: (_, __) => const Scaffold(body: Text('W'))),
        GoRoute(
            path: '/physio',
            builder: (_, __) => const Scaffold(body: Text('P'))),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breathingTodayProvider
              .overrideWith((ref) async => <BreathingSession>[]),
          mealsCountTodayProvider.overrideWith((ref) async => 0),
          latestWeightSummaryProvider
              .overrideWith((ref) async => (latest: null, delta: null)),
          physioTodayProgressProvider.overrideWith(
              (ref) async => (exercisesDone: 0, totalReps: 18)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('0 done • 18 reps today'), findsOneWidget);
  });
}
