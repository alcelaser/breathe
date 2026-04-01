import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';
import 'package:recovery_app/features/breathing/ui/breathing_screen.dart';

void main() {
  testWidgets('shows config screen', (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, __) => const BreathingScreen()),
        GoRoute(
            path: '/breathing/session',
            builder: (_, __) => const ActiveSessionScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breathingNotifierProvider
              .overrideWith(() => _FakeBreathingNotifier()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Breathing'), findsOneWidget);
    expect(find.text('Pattern'), findsOneWidget);
  });
}

class _FakeBreathingNotifier extends BreathingNotifier {
  @override
  Future<BreathingState> build() async => BreathingState.initial();
}
