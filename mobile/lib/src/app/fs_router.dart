import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/local_date.dart';
import '../design/fs_shell.dart';
import '../features/devotional/presentation/devotional_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/today/presentation/today_page.dart';
import '../features/workout/presentation/train_page.dart';
import '../features/workout/presentation/workout_page.dart';
import 'forged_sent_app.dart';
import 'shell_destinations.dart';
import 'tab_pages.dart';

/// The app's routes: six tabs, each with its own stack, inside [FsShell].
///
/// `StatefulShellRoute.indexedStack` keeps every tab's pages alive, so a tab
/// is where the member left it, scroll position included, when he comes back
/// to it. Android's system back pops the current tab's stack.
///
/// Today has two pages under it: the day's reading and Settings. The
/// developer's build status page is under Settings. Train has one: a day's
/// workout, at `/train/workout/2026-11-13`.
///
/// If a start-up check failed, the app opens on the status page so the
/// reason is on screen. It never falls back to a cloud connection.
GoRouter buildFsRouter({
  required String mode,
  required String? startupError,
  required bool storageFailed,
}) {
  final destinations = <FsShellDestination>[
    for (final destination in ShellDestinations.all)
      FsShellDestination(label: destination.label, icon: destination.icon),
  ];

  return GoRouter(
    initialLocation: startupError == null && !storageFailed
        ? ShellDestinations.todayPath
        : ShellDestinations.statusPath,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return FsShell(
                destinations: destinations,
                currentIndex: navigationShell.currentIndex,
                // Tapping the tab he is already on returns it to its first page.
                onSelect: (int index) => navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                ),
                child: navigationShell,
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: ShellDestinations.todayPath,
                builder: (BuildContext context, GoRouterState state) {
                  return TodayPage(
                    onOpenDevotional: () =>
                        context.go(ShellDestinations.devotionalPath),
                    onOpenSettings: () =>
                        context.go(ShellDestinations.settingsPath),
                    onOpenTrain: () => context.go(ShellDestinations.trainPath),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'devotional',
                    builder: (BuildContext context, GoRouterState state) {
                      return DevotionalPage(
                        onBack: () => context.go(ShellDestinations.todayPath),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingsPage(
                        onBack: () => context.go(ShellDestinations.todayPath),
                        onOpenStatus: () =>
                            context.go(ShellDestinations.statusPath),
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'status',
                        builder: (BuildContext context, GoRouterState state) {
                          return FoundationHomeScreen(
                            mode: mode,
                            startupError: startupError,
                            storageFailed: storageFailed,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          for (final destination in ShellDestinations.all.skip(1))
            if (destination == ShellDestinations.train)
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: ShellDestinations.trainPath,
                    builder: (BuildContext context, GoRouterState state) {
                      return TrainPage(
                        onOpenWorkout: (LocalDate day) =>
                            context.go(ShellDestinations.workoutPath(day.iso)),
                      );
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'workout/:day',
                        // A link with anything but a real date goes to Train.
                        redirect: (BuildContext context, GoRouterState state) {
                          try {
                            LocalDate.parse(state.pathParameters['day'] ?? '');
                            return null;
                          } on FormatException {
                            return ShellDestinations.trainPath;
                          }
                        },
                        builder: (BuildContext context, GoRouterState state) {
                          final day = LocalDate.parse(
                            state.pathParameters['day']!,
                          );
                          return WorkoutPage(
                            // One page per day: its state never carries over
                            // to another day's workout.
                            key: ValueKey<String>('workout-${day.iso}'),
                            day: day,
                            onBack: () =>
                                context.go(ShellDestinations.trainPath),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              )
            else
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: destination.path,
                    builder: (BuildContext context, GoRouterState state) {
                      return TabPlaceholderPage(destination: destination);
                    },
                  ),
                ],
              ),
        ],
      ),
    ],
  );
}
