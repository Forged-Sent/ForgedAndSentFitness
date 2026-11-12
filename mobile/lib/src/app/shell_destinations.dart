import 'package:flutter/foundation.dart';

import '../design/fs_hero_header.dart';
import '../design/fs_icons.dart';

/// One of the six top-level pages.
@immutable
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.title,
    required this.kicker,
    required this.actions,
  });

  /// The word under the tab's icon.
  final String label;

  /// The tab's root location.
  final String path;

  final FsIconData icon;

  /// The page's hero title. Not always the tab's label: the Board tab opens
  /// on "Standings".
  final String title;

  /// The small caps line above the title.
  final String kicker;

  /// The round buttons the prototype shows in this page's header. None of
  /// them does anything yet.
  final List<FsHeroAction> actions;
}

const List<FsHeroAction> _standardActions = <FsHeroAction>[
  FsHeroAction(FsHeroActionKind.search, label: 'Search how the app works'),
  FsHeroAction(FsHeroActionKind.help, label: 'How this page works'),
  FsHeroAction(FsHeroActionKind.journal, label: 'New journal entry'),
  FsHeroAction(FsHeroActionKind.tags, label: 'Tags'),
  FsHeroAction(FsHeroActionKind.profile, label: 'Your profile'),
];

const List<FsHeroAction> _walkActions = <FsHeroAction>[
  FsHeroAction(FsHeroActionKind.journal, label: 'New journal entry'),
  FsHeroAction(FsHeroActionKind.tags, label: 'Tags'),
  FsHeroAction(FsHeroActionKind.profile, label: 'Your profile'),
];

/// The six tabs, in order. Decision Q1: v254's layout and navigation
/// (`versions/app-v254.html` at `3ff4a6f`, the `.tabbar` at line 2665).
/// Titles and small caps lines are each page's header text in that file.
abstract final class ShellDestinations {
  static const String todayPath = '/today';

  /// The developer status page, nested under Today.
  static const String statusPath = '/today/status';

  static const ShellDestination today = ShellDestination(
    label: 'Today',
    path: todayPath,
    icon: FsIcons.today,
    title: 'Today’s Mission',
    // Today shows the date here instead.
    kicker: '',
    actions: _standardActions,
  );

  static const List<ShellDestination> all = <ShellDestination>[
    today,
    ShellDestination(
      label: 'Fuel',
      path: '/fuel',
      icon: FsIcons.fuel,
      title: 'Fuel',
      kicker: 'Stewardship of the body',
      actions: _standardActions,
    ),
    ShellDestination(
      label: 'Train',
      path: '/train',
      icon: FsIcons.train,
      title: 'Train',
      kicker: 'Strength is for serving',
      actions: _standardActions,
    ),
    ShellDestination(
      label: 'Walk',
      path: '/walk',
      icon: FsIcons.walk,
      title: 'Walk',
      kicker: 'Walk with your brothers',
      actions: _walkActions,
    ),
    ShellDestination(
      label: 'Board',
      path: '/board',
      icon: FsIcons.board,
      title: 'Standings',
      kicker: 'Carry each other',
      actions: _standardActions,
    ),
    ShellDestination(
      label: 'Rally',
      path: '/rally',
      icon: FsIcons.rally,
      title: 'Rally',
      kicker: 'Encourage a brother',
      actions: _standardActions,
    ),
  ];
}
