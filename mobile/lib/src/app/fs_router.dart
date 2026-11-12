import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../design/fs_shell.dart';
import 'forged_sent_app.dart';
import 'shell_destinations.dart';
import 'tab_pages.dart';

/// The app's routes: six tabs, each with its own stack, inside [FsShell].
///
/// `StatefulShellRoute.indexedStack` keeps every tab's pages alive, so a tab
/// is where the member left it, scroll position included, when he comes back
/// to it. Android's system back pops the current tab's stack.
///
/// If the start-up check failed, the app opens on the status page so the
/// reason is on screen. It never falls back to a cloud connection.
GoRouter buildFsRouter({
  required String mode,
  required String? startupError,
  required DateTime Function() now,
}) {
  final destinations = <FsShellDestination>[
    for (final destination in ShellDestinations.all)
      FsShellDestination(label: destination.label, icon: destination.icon),
  ];

  return GoRouter(
    initialLocation: startupError == null
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
                  return TodayPlaceholderPage(
                    now: now,
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
                      );
                    },
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
