import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../design/fs_shell.dart';
import '../features/devotional/presentation/devotional_page.dart';
import '../features/journal/presentation/journal_entry_page.dart';
import '../features/journal/presentation/journal_page.dart';
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
/// Today has three pages under it: the day's reading, the private journal
/// (with a page for one entry) and Settings. The developer's build status
/// page is under Settings.
///
/// The Walk tab is the same journal (the maintainer's decision of
/// 2026-11-17: the journal lives on Walk, as in v254, without the Brothers
/// and Prayers parts until they exist). It is the same pages over the same
/// entries, in the Walk tab's own stack.
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
                // Tapping the tab he is already on returns it to its first
                // page, unless the page he is on is holding him there.
                onSelect: (int index) {
                  final current = index == navigationShell.currentIndex;
                  if (current &&
                      _topPageHoldsHim(
                        navigationShell.route.branches[index].navigatorKey,
                      )) {
                    return;
                  }
                  navigationShell.goBranch(index, initialLocation: current);
                },
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
                    onNewJournalEntry: () =>
                        context.go(ShellDestinations.journalNewPath),
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'devotional',
                    builder: (BuildContext context, GoRouterState state) {
                      return DevotionalPage(
                        onBack: () => context.go(ShellDestinations.todayPath),
                        onOpenJournal: () =>
                            context.go(ShellDestinations.journalPath),
                      );
                    },
                  ),
                  _journalRoute(
                    path: 'journal',
                    location: ShellDestinations.journalPath,
                    backTo: ShellDestinations.todayPath,
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingsPage(
                        onBack: () => context.go(ShellDestinations.todayPath),
                        onOpenStatus: () =>
                            context.go(ShellDestinations.statusPath),
                        onOpenJournal: () =>
                            context.go(ShellDestinations.journalPath),
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
                if (destination.path == ShellDestinations.walkPath)
                  // A tab's first page has nowhere to go back to.
                  _journalRoute(
                    path: ShellDestinations.walkPath,
                    location: ShellDestinations.walkPath,
                    backTo: null,
                  )
                else
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

/// True when the page on top of this tab's stack will not let Back leave it:
/// a `PopScope` there says so, as the journal's entry page does while a save
/// or a delete is on its way. Returning the tab to its first page would
/// close that page as surely as Back, so the tab tap waits as Back does. If
/// it did not, a save that then failed would find no page to keep his words
/// or to tell him.
bool _topPageHoldsHim(GlobalKey<NavigatorState> tab) {
  Route<dynamic>? top;
  // Reads the top page and removes nothing: the test is true at once.
  tab.currentState?.popUntil((Route<dynamic> route) {
    top = route;
    return true;
  });
  return top?.popDisposition == RoutePopDisposition.doNotPop;
}

/// The Journal page at [location], with its two entry pages under it:
/// `new` and `entry/:entryId`. [path] is this route's own path segment.
/// Back on the Journal page goes to [backTo]; with none, the page has no
/// Back, because it is a tab's first page.
GoRoute _journalRoute({
  required String path,
  required String location,
  required String? backTo,
}) {
  return GoRoute(
    path: path,
    builder: (BuildContext context, GoRouterState state) {
      return JournalPage(
        onBack: backTo == null ? null : () => context.go(backTo),
        onNewEntry: () => context.go('$location/new'),
        onOpenEntry: (String entryId) =>
            context.go('$location/entry/${Uri.encodeComponent(entryId)}'),
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: 'new',
        builder: (BuildContext context, GoRouterState state) {
          return JournalEntryPage(onDone: () => context.go(location));
        },
      ),
      GoRoute(
        path: 'entry/:entryId',
        builder: (BuildContext context, GoRouterState state) {
          return JournalEntryPage(
            // A new page for each entry, so one entry's text is never left
            // in another's box.
            key: ValueKey<String>('entry-${state.pathParameters['entryId']}'),
            entryId: state.pathParameters['entryId'],
            onDone: () => context.go(location),
          );
        },
      ),
    ],
  );
}
