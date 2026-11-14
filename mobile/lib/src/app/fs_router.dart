import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../design/fs_shell.dart';
import '../features/devotional/presentation/devotional_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/today/presentation/today_page.dart';
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
/// developer's build status page is under Settings.
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
