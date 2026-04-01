import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recovery_app/core/theme/app_theme.dart';
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
            onDestinationSelected: (int index) {
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
