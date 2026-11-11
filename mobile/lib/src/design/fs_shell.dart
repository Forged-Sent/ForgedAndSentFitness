import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_icons.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

/// One tab in the bottom bar.
@immutable
class FsShellDestination {
  const FsShellDestination({required this.label, required this.icon});

  final String label;
  final FsIconData icon;
}

/// The frame around every top-level page: the brand bar on top, the page in
/// the middle and the tab bar at the bottom.
///
/// Both bars are dark in both themes, as in the prototype (`.appbar`,
/// `.tabbar`). The bar holds six tabs, more than Material's
/// `NavigationBar` is meant for, so it is drawn here.
///
/// This widget knows nothing about routing. The router passes the current
/// index, the page and what to do when a tab is tapped.
class FsShell extends StatelessWidget {
  const FsShell({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    required this.child,
  });

  final List<FsShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: FsColors.of(context).background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _BrandBar(topInset: inset.top),
          Expanded(
            // The bars already cover the status bar and the home indicator.
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: child,
            ),
          ),
          _TabBar(
            destinations: destinations,
            currentIndex: currentIndex,
            onSelect: onSelect,
            inset: inset,
          ),
        ],
      ),
    );
  }
}

class _BrandBar extends StatelessWidget {
  const _BrandBar({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: FsColors.night,
        border: Border(bottom: BorderSide(color: FsColors.brandBarRule)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: FsSizes.brandBar),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FsSpacing.page,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const FsIcon(
                  FsIcons.shield,
                  size: 15,
                  color: FsColors.brandMark,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'FORGED & SENT',
                    semanticsLabel: 'Forged & Sent',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FsText.brandBar.copyWith(color: FsColors.heroInk),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    required this.inset,
  });

  final List<FsShellDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final EdgeInsets inset;

  @override
  Widget build(BuildContext context) {
    // A Material, so a tapped tab shows its ink on the dark bar.
    return Material(
      color: FsColors.night,
      shape: const Border(top: BorderSide(color: FsColors.tabBarRule)),
      child: Padding(
        padding: EdgeInsets.only(
          left: inset.left > 8 ? inset.left : 8,
          right: inset.right > 8 ? inset.right : 8,
          bottom: inset.bottom,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (var i = 0; i < destinations.length; i++)
              Expanded(
                child: _Tab(
                  destination: destinations[i],
                  current: i == currentIndex,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.destination,
    required this.current,
    required this.onTap,
  });

  final FsShellDestination destination;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = current ? FsColors.tabActive : FsColors.tabInactive;
    return Semantics(
      button: true,
      selected: current,
      label: destination.label,
      // This node stands in for everything under it, so it has to carry the
      // tap itself, or a screen reader could name the tab but not open it.
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        key: ValueKey<String>('fs-tab-${destination.label.toLowerCase()}'),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: FsSizes.tabBar),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: current ? FsColors.tabActive : const Color(0x00000000),
                width: FsSizes.tabIndicator,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FsIcon(destination.icon, color: color),
              const SizedBox(height: 3),
              // Six tabs share the width, so a label shrinks before it
              // spills when the text size is turned up.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  destination.label.toUpperCase(),
                  maxLines: 1,
                  softWrap: false,
                  style: FsText.tabLabel.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
