import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../core/local_date.dart';
import '../../../design/fs_button.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_hero_header.dart';
import '../../../design/fs_page_bar.dart';
import '../../../design/fs_scripture.dart';
import '../../../design/fs_segmented.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../../today/presentation/today_page.dart' show notSavedNotice;
import '../../today/presentation/today_view_model.dart';
import '../domain/devotional.dart';

/// How close to the bottom counts as the end, in logical pixels. The
/// prototype's `devoScroll` uses the same margin.
const double _endMargin = 12;

/// The page is always at least this much taller than the screen, so even a
/// short reading has to be scrolled before Amen. The prototype's `sizeDevo`.
const double _extraHeight = 220;

/// What the reading says when the day changed while it was open, so he
/// knows why he is looking at another reading with Amen locked again.
const String newDayNotice = 'It is a new day. This is today’s reading.';

/// Today's reading. Scrolling to the end enables Amen; Amen checks the
/// devotional box and returns to Today; "Amen. Undo" clears it again.
class DevotionalPage extends ConsumerStatefulWidget {
  const DevotionalPage({super.key, required this.onBack});

  /// Returns to Today.
  final VoidCallback onBack;

  @override
  ConsumerState<DevotionalPage> createState() => _DevotionalPageState();
}

class _DevotionalPageState extends ConsumerState<DevotionalPage> {
  final ScrollController _scroll = ScrollController();

  /// True once the member has reached the end of this reading. It stays
  /// true if he scrolls back up, as in the prototype.
  bool _reachedEnd = false;

  /// Decision Q7: the verse opens in the BSB every time.
  Translation _translation = Translation.bsb;

  bool _saveFailed = false;
  bool _saving = false;

  /// True once the reading changed under him because the day did, so the
  /// page can say why it is back at the top with Amen locked.
  bool _newDay = false;

  /// Which reading this page is showing, counted from the one it opened
  /// with. Reaching the end of one reading must never unlock the next.
  int _reading = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onMetrics(ScrollMetrics metrics) {
    if (_reachedEnd) return;
    if (metrics.maxScrollExtent <= 0 ||
        metrics.pixels >= metrics.maxScrollExtent - _endMargin) {
      // Scroll notifications arrive during layout; change state after it.
      // By then the day may have changed and the page may be showing
      // another reading, so the unlock applies only to the reading that
      // was scrolled.
      final scrolled = _reading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_reachedEnd && scrolled == _reading) {
          setState(() => _reachedEnd = true);
        }
      });
    }
  }

  /// Past midnight the page shows the new day's reading, which has not
  /// been read: back to the top, BSB, and Amen locked again.
  void _onNewDay(LocalDate? previous, LocalDate next) {
    if (previous == next) return;
    setState(() {
      _reading++;
      _reachedEnd = false;
      _translation = Translation.bsb;
      _saveFailed = false;
      _newDay = true;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _amen(LocalDate shownDay) async {
    if (_saving) return;
    setState(() => _saving = true);
    final outcome = await ref
        .read(todayViewModelProvider.notifier)
        .completeDevotional(shownDay: shownDay);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saveFailed = outcome == AmenOutcome.failed;
    });
    // A refused tap needs nothing more here: the day on screen has already
    // been moved on, and [_onNewDay] resets the page and says why.
    if (outcome == AmenOutcome.saved) widget.onBack();
  }

  Future<void> _undo() async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await ref
        .read(todayViewModelProvider.notifier)
        .undoDevotional();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saveFailed = !saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocalDate>(todayDateProvider, _onNewDay);
    final state = ref.watch(todayViewModelProvider);
    final view = state.value;
    final colors = FsColors.of(context);

    if (view == null) {
      return _Plain(
        onBack: widget.onBack,
        message: state.hasError
            ? 'Today’s reading could not be loaded.'
            : 'Loading today’s reading…',
        onRetry: state.hasError
            ? () => ref.read(todayViewModelProvider.notifier).retry()
            : null,
      );
    }
    final reading = view.reading;
    if (reading == null) {
      return _Plain(onBack: widget.onBack, message: 'No devotional today');
    }

    final done = view.devotionalDone;
    final verse = reading.textIn(_translation);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return NotificationListener<ScrollMetricsNotification>(
          onNotification: (ScrollMetricsNotification notification) {
            _onMetrics(notification.metrics);
            return false;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              _onMetrics(notification.metrics);
              return false;
            },
            child: SingleChildScrollView(
              controller: _scroll,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight + _extraHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          FsSpacing.page,
                          20,
                          FsSpacing.page,
                          2,
                        ),
                        child: FsPageBar(
                          onBack: widget.onBack,
                          trailing: weekdayName(view.date),
                        ),
                      ),
                      if (_newDay)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            FsSpacing.page,
                            6,
                            FsSpacing.page,
                            6,
                          ),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              newDayNotice,
                              key: const ValueKey<String>('fs-new-day'),
                              style: FsText.bodySmall.copyWith(
                                color: colors.highlight,
                              ),
                            ),
                          ),
                        ),
                      FsReadingHeader(
                        kicker: reading.monthTheme.isEmpty
                            ? reading.monthName
                            : '${reading.monthName} · ${reading.monthTheme}',
                        title: monthAndDay(view.date),
                        series: reading.series,
                        note: reading.monthTag,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          FsSpacing.page,
                          28,
                          FsSpacing.page,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _Section(
                              label: 'Open in prayer',
                              child: Text(
                                reading.prayer,
                                style: FsText.body.copyWith(color: colors.text),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _Section(
                              label: 'Reading',
                              trailing: FsSegmented<Translation>(
                                selected: _translation,
                                onChanged: (Translation value) =>
                                    setState(() => _translation = value),
                                segments: const <FsSegment<Translation>>[
                                  FsSegment<Translation>(
                                    value: Translation.bsb,
                                    label: 'BSB',
                                    hint: 'Berean Standard Bible',
                                  ),
                                  FsSegment<Translation>(
                                    value: Translation.esv,
                                    label: 'ESV',
                                    hint: 'English Standard Version',
                                  ),
                                ],
                              ),
                              child: verse == null
                                  // Decision Q7: no ESV text is bundled for
                                  // this verse. No ESV text appears, so no
                                  // ESV notice does either.
                                  ? Text(
                                      ScriptureNotices.esvLimitReached,
                                      key: const ValueKey<String>(
                                        'fs-esv-limit',
                                      ),
                                      style: FsText.body.copyWith(
                                        color: colors.textMuted,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        FsScripture(
                                          text: verse,
                                          reference: reading.reference,
                                          translation: _translation.label,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          ScriptureNotices.of(_translation),
                                          key: const ValueKey<String>(
                                            'fs-scripture-notice',
                                          ),
                                          style: FsText.bodySmall.copyWith(
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 28),
                            _Section(
                              label: 'Reflect',
                              child: Text(
                                reading.reflect,
                                style: FsText.scriptureSmall.copyWith(
                                  color: colors.text,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _Section(
                              label: 'Act',
                              child: Text(
                                reading.act,
                                style: FsText.body.copyWith(color: colors.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          FsSpacing.page,
                          28,
                          FsSpacing.page,
                          FsSpacing.pageBottom,
                        ),
                        child: _End(
                          done: done,
                          reachedEnd: _reachedEnd,
                          saveFailed: _saveFailed,
                          durable: view.durable,
                          onAmen: () => _amen(view.date),
                          onUndo: _undo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A labelled part of the reading. The label is drawn as the prototype
/// draws it, with two slashes in front; a screen reader hears the words.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child, this.trailing});

  final String label;
  final Widget child;

  /// Set at the right of the label: the translation tab.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final heading = Semantics(
      header: true,
      child: Text(
        '// ${label.toUpperCase()}',
        semanticsLabel: label,
        style: FsText.sectionLabel.copyWith(color: colors.highlight),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (trailing == null)
          heading
        else
          Row(
            children: <Widget>[
              Expanded(child: heading),
              const SizedBox(width: 12),
              trailing!,
            ],
          ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// The foot of the reading: a line that says where he stands, then Amen
/// or, once the box is checked, "Amen. Undo".
class _End extends StatelessWidget {
  const _End({
    required this.done,
    required this.reachedEnd,
    required this.saveFailed,
    required this.durable,
    required this.onAmen,
    required this.onUndo,
  });

  final bool done;
  final bool reachedEnd;
  final bool saveFailed;
  final bool durable;
  final VoidCallback onAmen;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final hint = done
        ? 'Your Daily Devotional box is checked.'
        : reachedEnd
        ? 'You made it to the end.'
        : 'Read it all the way through.';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              hint,
              style: FsText.bodySmall.copyWith(color: colors.textMuted),
            ),
            if (!durable) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                notSavedNotice,
                style: FsText.bodySmall.copyWith(color: colors.danger),
              ),
            ],
            if (saveFailed) ...<Widget>[
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Text(
                  'That did not save. Try again.',
                  style: FsText.bodySmall.copyWith(color: colors.danger),
                ),
              ),
            ],
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: done
                  ? FsButton.ghost(
                      key: const ValueKey<String>('fs-amen'),
                      label: 'Amen. Undo',
                      onPressed: onUndo,
                    )
                  : FsButton(
                      key: const ValueKey<String>('fs-amen'),
                      label: reachedEnd
                          ? 'Amen'
                          : 'Scroll to the bottom to say Amen',
                      onPressed: reachedEnd ? onAmen : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page when there is no reading to show: loading, an error, or a date
/// the bundled file has nothing for.
class _Plain extends StatelessWidget {
  const _Plain({required this.onBack, required this.message, this.onRetry});

  final VoidCallback onBack;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FsSpacing.page,
        20,
        FsSpacing.page,
        FsSpacing.pageBottom,
      ),
      children: <Widget>[
        FsPageBar(onBack: onBack),
        const SizedBox(height: FsSpacing.block),
        Text(message, style: FsText.body.copyWith(color: colors.text)),
        if (onRetry != null) ...<Widget>[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FsButton.ghost(label: 'Try again', onPressed: onRetry),
          ),
        ],
      ],
    );
  }
}
