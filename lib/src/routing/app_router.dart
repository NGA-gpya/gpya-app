import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/src/features/dashboard/dashboard_screen.dart';
import 'package:myapp/src/features/home/home_screen.dart';
import 'package:myapp/src/features/services/services_screen.dart';
import 'package:myapp/src/features/settings/settings_screen.dart';
import 'package:myapp/src/features/tools/diagnostic_category_selector.dart';
import 'package:myapp/src/features/tools/diagnostic_screen.dart';
import 'package:myapp/src/features/tools/diagnostic_result_screen.dart';
import 'package:myapp/src/features/tools/diagnostic_models.dart';
import 'package:myapp/src/features/scaffold_with_nav_bar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      // Rutas de herramientas (Fuera del NavBar para mayor enfoque)
      GoRoute(
        path: '/diagnostic',
        builder: (context, state) => const DiagnosticCategorySelector(),
      ),
      GoRoute(
        path: '/diagnostic/:category',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          return DiagnosticScreen(categoryName: category);
        },
      ),
      GoRoute(
        path: '/diagnostic-result',
        builder: (context, state) {
          final result = state.extra as DiagnosticResult;
          return DiagnosticResultScreen(result: result);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return const HomeScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/dashboard',
                builder: (BuildContext context, GoRouterState state) {
                  return const DashboardScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/services',
                builder: (BuildContext context, GoRouterState state) {
                  return const ServicesScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) {
                  return const SettingsScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
