import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recovery_app/core/theme/app_theme.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';
import 'package:recovery_app/features/breathing/ui/breathing_screen.dart';
import 'package:recovery_app/features/home/ui/home_screen.dart';
import 'package:recovery_app/features/meals/ui/meals_screen.dart';
import 'package:recovery_app/features/physio/ui/plan_screen.dart';
import 'package:recovery_app/features/physio/ui/physio_screen.dart';
import 'package:recovery_app/features/weight/ui/weight_screen.dart';

class RecoveryApp extends StatelessWidget {
  const RecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Breathe',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

Future<bool> _confirmStopBreathingSession(BuildContext context) async {
  final bool? shouldStop = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Leave Breathing Session?'),
        content: const Text(
          'Switching tabs will stop your current breathing session.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Stop and Leave'),
          ),
        ],
      );
    },
  );

  return shouldStop ?? false;
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) async {
              final bool switchingBranch = index != navigationShell.currentIndex;
              final bool isActiveBreathingRoute =
                  state.uri.toString().startsWith('/breathing/session');
              final ProviderContainer container =
                  ProviderScope.containerOf(context, listen: false);
              final BreathingState? breathingState =
                  container.read(breathingNotifierProvider).valueOrNull;
              final bool shouldConfirmStop =
                  switchingBranch && isActiveBreathingRoute &&
                  (breathingState?.isRunning ?? false);

              if (shouldConfirmStop) {
                final bool confirmStop =
                    await _confirmStopBreathingSession(context);
                if (!confirmStop) {
                  return;
                }

                await container
                    .read(breathingNotifierProvider.notifier)
                    .stopEarly();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Breathing session stopped.'),
                    ),
                  );
                }
              }

              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.air),
                label: 'Breathing',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant),
                label: 'Meals',
              ),
              NavigationDestination(
                icon: Icon(Icons.monitor_weight),
                label: 'Weight',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center),
                label: 'Physio',
              ),
              NavigationDestination(
                icon: Icon(Icons.checklist),
                label: 'Plan',
              ),
            ],
          ),
        );
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/breathing',
              builder: (BuildContext context, GoRouterState state) {
                return const BreathingScreen();
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'session',
                  builder: (BuildContext context, GoRouterState state) {
                    return const ActiveSessionScreen();
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/meals',
              builder: (BuildContext context, GoRouterState state) {
                return const MealsScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/weight',
              builder: (BuildContext context, GoRouterState state) {
                return const WeightScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
             GoRoute(
              path: '/physio',
              builder: (BuildContext context, GoRouterState state) {
                return const PhysioScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/plan',
              builder: (BuildContext context, GoRouterState state) {
                return const PlanScreen();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
