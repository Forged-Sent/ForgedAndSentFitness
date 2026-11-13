import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../core/local_date.dart';
import '../../../core/time_text.dart';
import '../../../design/fs_button.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_dialog.dart';
import '../../../design/fs_label_caps.dart';
import '../../../design/fs_marks.dart';
import '../../../design/fs_number_field.dart';
import '../../../design/fs_page_bar.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../../../design/fs_typography_workout.dart';
import '../../today/presentation/today_page.dart' show notSavedNotice;
import '../data/workout_library.dart';
import '../domain/prescription.dart';
import '../domain/workout_session.dart';
import 'workout_prayer_dialog.dart';
import 'workout_view_model.dart';

/// What the page says when midnight passed between opening it and tapping
/// Start: the session of the day on screen can no longer be started.
const String workoutNewDayNotice =
    'It is a new day. Open today’s workout from Train.';

/// What the page says when a change could not be stored.
const String workoutSaveFailedNotice = 'That did not save. Try again.';

/// The largest numbers a set accepts: the prototype's limits.
const double _maxReps = 999;
const double _maxWeightLb = 2000;
const double _maxAddedWeightLb = 400;

/// One day's workout: the plan before it is started, the set rows while it
/// is in progress, and a locked summary once it is finished. The
/// prototype's `drawWorkoutPageNow`.
class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key, required this.day, required this.onBack});

  /// The local day the page is for. A session belongs to the day it was
  /// started on.
  final LocalDate day;

  /// Returns to Train.
  final VoidCallback onBack;

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  bool _busy = false;
  bool _saveFailed = false;
  bool _newDay = false;

  /// The sets the finish check pointed at, outlined until they are fixed.
  Set<String> _needsFixing = const <String>{};

  final ScrollController _scroll = ScrollController();

  /// When the phone puts the app in the background it may stop it at any
  /// moment. Every change is already on its way to the store; this waits
  /// for the last of them.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onInactive: _flush,
    onHide: _flush,
    onPause: _flush,
  );

  WorkoutViewModel get _model =>
      ref.read(workoutViewModelProvider(widget.day).notifier);

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _flush() => unawaited(_model.flush());

  /// Follows one write: if it could not be stored, the page says so.
  void _track(Future<bool> write) {
    unawaited(
      write.then((bool saved) {
        if (!mounted || saved == !_saveFailed) return;
        setState(() => _saveFailed = !saved);
      }),
    );
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    final WorkoutLibrary library;
    try {
      library = await ref.read(workoutLibraryProvider.future);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _saveFailed = true;
        });
      }
      return;
    }
    if (!mounted) return;
    // Decision Q11: the prayer comes first, and "Not now" starts nothing.
    final amen = await showWorkoutPrayer(context, library.prayerLines);
    if (!mounted) return;
    if (!amen) {
      setState(() => _busy = false);
      return;
    }
    final outcome = await _model.start();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _saveFailed = outcome == StartOutcome.failed;
      _newDay = outcome == StartOutcome.newDay;
    });
  }

  Future<void> _finish(WorkoutSession session) async {
    if (_busy) return;
    final check = checkBeforeFinish(session);
    if (check.fixes.isNotEmpty) {
      await showFsDialog<void>(
        context,
        builder: (BuildContext context) => _FinishCheckDialog(check: check),
      );
      if (!mounted) return;
      setState(
        () => _needsFixing = <String>{
          for (final issue in check.fixes) issue.setId,
        },
      );
      return;
    }
    if (check.blanks.isNotEmpty) {
      final anyway = await showFsDialog<bool>(
        context,
        builder: (BuildContext context) => _FinishCheckDialog(check: check),
      );
      if (!mounted || anyway != true) return;
    }
    setState(() => _busy = true);
    final saved = await _model.finish();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _saveFailed = !saved;
      _needsFixing = const <String>{};
    });
    // Finish is at the foot of the page. The summary that replaces the
    // set rows, or the notice that it did not save, is at the top.
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutViewModelProvider(widget.day));
    final view = state.value;
    final colors = FsColors.of(context);

    final bar = Padding(
      padding: const EdgeInsets.fromLTRB(FsSpacing.page, 20, FsSpacing.page, 2),
      child: FsPageBar(
        onBack: widget.onBack,
        trailing: heroDateLine(widget.day),
      ),
    );

    if (view == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          bar,
          Padding(
            padding: const EdgeInsets.all(FsSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  state.hasError
                      ? 'This workout could not be loaded.'
                      : 'Loading the workout…',
                  style: FsText.body.copyWith(color: colors.text),
                ),
                if (state.hasError) ...<Widget>[
                  const SizedBox(height: 14),
                  FsButton.ghost(
                    label: 'Try again',
                    onPressed: () => _model.retry(),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    final session = view.session;
    final workout = view.planDay.workout;
    final String? meta;
    final String title;
    if (session != null) {
      meta = _meta(session.planWeek, session.planDay, session.minutes);
      title = session.title;
    } else if (view.planDay.isTrain && workout != null) {
      meta = _meta(workout.week, workout.day, workout.minutes);
      title = workout.title;
    } else {
      meta = null;
      title = 'No workout on this day.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        bar,
        if (session != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              FsSpacing.page,
              8,
              FsSpacing.page,
              4,
            ),
            child: _ClockBar(session: session),
          ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(
              FsSpacing.page,
              10,
              FsSpacing.page,
              FsSpacing.pageBottom,
            ),
            children: <Widget>[
              if (meta != null) ...<Widget>[
                FsLabelCaps(
                  meta,
                  style: FsWorkoutText.meta,
                  color: colors.textMuted,
                ),
                const SizedBox(height: 2),
              ],
              Semantics(
                header: true,
                child: Text(
                  meta == null ? title : title.toUpperCase(),
                  semanticsLabel: title,
                  style: meta == null
                      ? FsText.body.copyWith(color: colors.text)
                      : FsWorkoutText.pageTitle.copyWith(color: colors.text),
                ),
              ),
              if (!view.durable) _Notice(notSavedNotice, color: colors.danger),
              if (_newDay)
                _Notice(
                  workoutNewDayNotice,
                  key: const ValueKey<String>('fs-workout-new-day'),
                  color: colors.highlight,
                  live: true,
                ),
              if (_saveFailed)
                _Notice(
                  workoutSaveFailedNotice,
                  key: const ValueKey<String>('fs-workout-save-failed'),
                  color: colors.danger,
                  live: true,
                ),
              if (view.canStart) ...<Widget>[
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 60),
                  child: FsButton(
                    key: const ValueKey<String>('fs-start-workout'),
                    // v254's words for it (decision Q1). The prototype on
                    // `main` says "Start workout".
                    label: 'Pray, then train',
                    onPressed: _busy ? null : _start,
                  ),
                ),
              ] else if (session == null && view.planDay.isTrain)
                _Notice(
                  view.day.compareTo(view.today) < 0
                      ? 'No workout was logged on this day.'
                      : 'You can start this workout on its day.',
                  color: colors.textMuted,
                ),
              if (view.live)
                _Notice(
                  'Started ${clockTime(session!.startedAtWallClock)}. '
                  'Log each set, then rest.',
                  color: colors.textMuted,
                ),
              const SizedBox(height: 12),
              if (session == null)
                for (final line in view.planned)
                  _ExerciseFrame(
                    name: line.name,
                    prescription: line.prescription,
                  )
              else if (session.finished)
                _LockedSummary(session: session)
              else ...<Widget>[
                for (var i = 0; i < session.exercises.length; i++)
                  _LiveExercise(
                    index: i,
                    exercise: session.exercises[i],
                    lastTime: view.lastTimes[session.exercises[i].movementId],
                    needsFixing: _needsFixing,
                    model: _model,
                    track: _track,
                  ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: FsButton(
                    key: const ValueKey<String>('fs-finish-workout'),
                    label: 'Finish workout',
                    onPressed: _busy ? null : () => _finish(session),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _meta(int week, int day, int minutes) =>
      'Week $week · Day $day${minutes > 0 ? ' · $minutes min' : ''}';
}

/// A small line under the title that says where things stand.
class _Notice extends StatelessWidget {
  const _Notice(this.text, {super.key, required this.color, this.live = false});

  final String text;
  final Color color;

  /// Whether a screen reader announces the line when it appears.
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        liveRegion: live,
        child: Text(text, style: FsText.bodySmall.copyWith(color: color)),
      ),
    );
  }
}

/// A widget that redraws once a second while [running], for a time that
/// is worked out from stored timestamps and the app's clock.
class _EverySecond extends ConsumerStatefulWidget {
  const _EverySecond({required this.running, required this.builder});

  final bool running;
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  ConsumerState<_EverySecond> createState() => _EverySecondState();
}

class _EverySecondState extends ConsumerState<_EverySecond> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_EverySecond oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.running && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!widget.running) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, ref.watch(clockProvider).now());
}

/// The workout clock: how long the session has run, from the stored start
/// time. The prototype's `.wk-clock`.
class _ClockBar extends StatelessWidget {
  const _ClockBar({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final finished = session.finished;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.hairline),
          right: BorderSide(color: colors.hairline),
          bottom: BorderSide(color: colors.hairline),
          left: BorderSide(
            color: finished ? colors.highlight : colors.accent,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _EverySecond(
          running: !finished,
          builder: (BuildContext context, DateTime now) {
            final time = elapsedText(session.elapsedAt(now));
            return MergeSemantics(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FsLabelCaps(
                      finished ? 'Finished in' : 'Workout time',
                      style: FsText.stat,
                      color: colors.textMuted,
                    ),
                  ),
                  Text(
                    time,
                    key: const ValueKey<String>('fs-workout-clock'),
                    style: FsWorkoutText.clock.copyWith(color: colors.text),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// An exercise's name and prescription over whatever belongs under them,
/// with a hairline above. The prototype's `.wx`.
class _ExerciseFrame extends StatelessWidget {
  const _ExerciseFrame({
    required this.name,
    required this.prescription,
    this.children = const <Widget>[],
  });

  final String name;
  final String prescription;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // One stop for a screen reader: the exercise and what to do.
            Semantics(
              container: true,
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    name,
                    style: FsWorkoutText.exerciseName.copyWith(
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prescription,
                    style: FsWorkoutText.prescription.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// "135 lb × 5" for a loaded lift, "+25 lb × 8" for load added to a
/// bodyweight lift, "8 reps" with no weight. The prototype's `setText`.
String _setText(int reps, double? weightLb, {required bool loaded}) {
  if (weightLb != null && weightLb > 0) {
    return '${loaded ? '' : '+'}${FsNumberField.format(weightLb)} lb × $reps';
  }
  return '$reps ${reps == 1 ? 'rep' : 'reps'}';
}

/// An exercise of a session in progress: its set rows, last time's values
/// beside them, and its rest timer.
class _LiveExercise extends StatelessWidget {
  const _LiveExercise({
    required this.index,
    required this.exercise,
    required this.lastTime,
    required this.needsFixing,
    required this.model,
    required this.track,
  });

  /// The exercise's place on the page, for the keys tests find rows by.
  final int index;

  final SessionExercise exercise;

  /// What was logged the last time this movement was done, if ever.
  final LastTime? lastTime;

  final Set<String> needsFixing;
  final WorkoutViewModel model;
  final void Function(Future<bool> write) track;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final loaded = exercise.weightMode == WeightMode.required;
    final last = exercise.measure == SetMeasure.reps ? lastTime : null;

    return _ExerciseFrame(
      name: exercise.name,
      prescription: exercise.prescription,
      children: <Widget>[
        if (last != null && last.sets.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          _LastTimeLine(last: last, loaded: loaded),
        ],
        if (exercise.weightMode == WeightMode.optional &&
            exercise.measure == SetMeasure.reps) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Bodyweight lift. Leave the + box empty unless you add weight '
            'with a belt, vest or plate, and enter only that added weight, '
            'never your body weight.',
            style: FsText.bodySmall.copyWith(color: colors.textMuted),
          ),
        ],
        if (exercise.measure == SetMeasure.tick)
          _TickRow(
            index: index,
            exercise: exercise,
            onChanged: (bool ticked) =>
                track(model.setTicked(exercise.sets.first.id, ticked: ticked)),
          )
        else ...<Widget>[
          for (var i = 0; i < exercise.sets.length; i++)
            _SetRow(
              key: ValueKey<String>('fs-set-$index-$i'),
              exerciseIndex: index,
              setIndex: i,
              exercise: exercise,
              set: exercise.sets[i],
              previous: last != null && i < last.sets.length
                  ? last.sets[i]
                  : null,
              needsFixing: needsFixing.contains(exercise.sets[i].id),
              onReps: (double? reps) =>
                  track(model.setReps(exercise.sets[i].id, reps?.round())),
              onWeight: (double? weight) =>
                  track(model.setWeight(exercise.sets[i].id, weight)),
            ),
          const SizedBox(height: 6),
          Text(
            _targetLine(exercise),
            style: FsText.bodySmall.copyWith(color: colors.textMuted),
          ),
        ],
        if (exercise.hasRestTimer)
          _RestBar(index: index, exercise: exercise, model: model, track: track)
        else ...<Widget>[
          const SizedBox(height: 6),
          Text(
            'Superset: go straight to the next exercise, no rest.',
            style: FsText.bodySmall.copyWith(color: colors.textMuted),
          ),
        ],
      ],
    );
  }

  /// "Target: 5 reps per set", "Target: 25 sec per set", or for ramp sets
  /// "Target: 5, then 3, then 1 rep, adding weight each set".
  static String _targetLine(SessionExercise exercise) {
    final targets = <String>[for (final set in exercise.sets) set.target];
    if (targets.toSet().length > 1) {
      return 'Target: ${targets.join(', then ')} '
          '${targets.last == '1' ? 'rep' : 'reps'}, adding weight each set';
    }
    return exercise.measure == SetMeasure.seconds
        ? 'Target: ${targets.first} per set'
        : 'Target: ${targets.first} reps per set';
  }
}

/// "LAST TIME · NOV 9" and what the last working set was. The prototype's
/// `lastTimeEl`, without its weight advice, which needs ratings this build
/// step does not collect.
class _LastTimeLine extends StatelessWidget {
  const _LastTimeLine({required this.last, required this.loaded});

  final LastTime last;
  final bool loaded;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final set = last.sets.last;
    final weight = set.weightLb;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.highlight, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FsLabelCaps(
                'Last time · ${shortMonthAndDay(last.day)}',
                style: FsWorkoutText.statLabel,
                color: colors.textMuted,
              ),
              Text(
                '${loaded && weight != null && weight > 0 ? '${FsNumberField.format(weight)} lb × ' : ''}'
                '${set.reps} reps on your last working set',
                style: FsText.bodySmall.copyWith(color: colors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One set: its number with last time's value under it, a box for reps or
/// seconds, a box for the weight where the lift takes one, and a mark that
/// fills once the set is logged. The prototype's `.setrow`.
class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.exerciseIndex,
    required this.setIndex,
    required this.exercise,
    required this.set,
    required this.previous,
    required this.needsFixing,
    required this.onReps,
    required this.onWeight,
  });

  final int exerciseIndex;
  final int setIndex;
  final SessionExercise exercise;
  final SessionSet set;

  /// The same set the last time this movement was done.
  final LastSet? previous;

  final bool needsFixing;
  final ValueChanged<double?> onReps;
  final ValueChanged<double?> onWeight;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final timed = exercise.measure == SetMeasure.seconds;
    final loaded = exercise.weightMode == WeightMode.required;
    final label = 'Set ${setIndex + 1}';
    final logged = exercise.isLogged(set);
    final hasReps = (set.reps ?? 0) > 0;
    final before = previous;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 52,
            // The set's number and last time's value are one stop for a
            // screen reader; the two boxes after it name the set again.
            child: Semantics(
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label.toUpperCase(),
                    semanticsLabel: label,
                    style: FsWorkoutText.setLabel.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                  if (before != null)
                    Text(
                      before.weightLb != null && before.weightLb! > 0
                          ? '${loaded ? '' : '+'}'
                                '${FsNumberField.format(before.weightLb)}'
                                '×${before.reps}'
                          : '${before.reps}',
                      key: ValueKey<String>('fs-last-$exerciseIndex-$setIndex'),
                      semanticsLabel:
                          'Last time '
                          '${_setText(before.reps, before.weightLb, loaded: loaded)}',
                      style: FsWorkoutText.setPrevious.copyWith(
                        color: colors.highlight,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: FsNumberField(
              key: ValueKey<String>('fs-reps-$exerciseIndex-$setIndex'),
              value: set.reps?.toDouble(),
              onChanged: onReps,
              semanticLabel: '$label ${timed ? 'seconds' : 'reps'}',
              hint: timed
                  ? 'sec'
                  : _ramp
                  ? '${set.target} ${set.target == '1' ? 'rep' : 'reps'}'
                  : 'reps',
              max: _maxReps,
              invalid: needsFixing && !hasReps,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: switch (exercise.weightMode) {
              WeightMode.required => FsNumberField(
                key: ValueKey<String>('fs-weight-$exerciseIndex-$setIndex'),
                value: set.weightLb,
                onChanged: onWeight,
                semanticLabel: '$label weight in pounds',
                hint: 'lb',
                max: _maxWeightLb,
                decimal: true,
                invalid: needsFixing && set.weightLb == null,
              ),
              WeightMode.optional => FsNumberField(
                key: ValueKey<String>('fs-weight-$exerciseIndex-$setIndex'),
                value: set.weightLb,
                onChanged: onWeight,
                semanticLabel:
                    '$label added weight in pounds, optional. Leave empty '
                    'for bodyweight only. Do not enter your body weight.',
                hint: '+ added',
                max: _maxAddedWeightLb,
                decimal: true,
              ),
              WeightMode.none => Text(
                'Bodyweight',
                textAlign: TextAlign.center,
                style: FsWorkoutText.fieldTag.copyWith(color: colors.textMuted),
              ),
            },
          ),
          const SizedBox(width: 6),
          Semantics(
            container: true,
            label: '$label ${logged ? 'logged' : 'not logged yet'}',
            child: _LoggedMark(
              key: ValueKey<String>('fs-logged-$exerciseIndex-$setIndex'),
              on: logged,
            ),
          ),
        ],
      ),
    );
  }

  /// Ramp sets each have their own target, shown in the empty box.
  bool get _ramp =>
      exercise.sets.map((SessionSet s) => s.target).toSet().length > 1;
}

/// The round mark at the right of a set row. It fills on its own once the
/// set is logged; it is not a button.
class _LoggedMark extends StatelessWidget {
  const _LoggedMark({super.key, required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? colors.accent : const Color(0x00000000),
        border: Border.all(color: on ? colors.accent : colors.hairline),
      ),
      child: FsCheckMark(
        color: on ? colors.onAccent : colors.hairline,
        size: 13,
      ),
    );
  }
}

/// An exercise with nothing to count: "Done?" and a tick.
class _TickRow extends StatelessWidget {
  const _TickRow({
    required this.index,
    required this.exercise,
    required this.onChanged,
  });

  final int index;
  final SessionExercise exercise;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final ticked = exercise.sets.first.ticked;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 58,
            child: Text(
              'DONE?',
              semanticsLabel: 'Done?',
              style: FsWorkoutText.setLabel.copyWith(color: colors.textMuted),
            ),
          ),
          Semantics(
            button: true,
            toggled: ticked,
            label: 'Mark ${exercise.name} done',
            excludeSemantics: true,
            onTap: () => onChanged(!ticked),
            child: Material(
              key: ValueKey<String>('fs-tick-$index'),
              color: ticked ? colors.accent : const Color(0x00000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FsRadius.base),
                side: BorderSide(
                  color: ticked ? colors.accent : colors.hairline,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(!ticked),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: FsCheckMark(
                      color: ticked ? colors.onAccent : colors.textMuted,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The rest timer under an exercise: the time left, 15 seconds less or
/// more, start or pause, and reset. The prototype's `restBar`.
///
/// The time is worked out from the instant stored when the timer was
/// started, so it is right after the app was closed and opened again. It
/// makes no sound in this build step.
class _RestBar extends StatelessWidget {
  const _RestBar({
    required this.index,
    required this.exercise,
    required this.model,
    required this.track,
  });

  final int index;
  final SessionExercise exercise;
  final WorkoutViewModel model;
  final void Function(Future<bool> write) track;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.hairline)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _EverySecond(
            running: exercise.restEndsAtUtc != null,
            builder: (BuildContext context, DateTime now) {
              final rest = exercise.restAt(now.toUtc());
              final time = rest.over ? 'GO' : minutesAndSeconds(rest.left);
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  MergeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FsLabelCaps(
                          'Rest',
                          style: FsText.stat,
                          color: colors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 46),
                          child: Text(
                            time,
                            key: ValueKey<String>('fs-rest-time-$index'),
                            semanticsLabel: rest.over
                                ? 'Rest is over'
                                : '${rest.left} seconds',
                            style: FsWorkoutText.restTime.copyWith(
                              color: rest.over
                                  ? colors.danger
                                  : rest.running
                                  ? colors.accent
                                  : colors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FsButton.mini(
                    key: ValueKey<String>('fs-rest-less-$index'),
                    label: '−15',
                    semanticLabel: 'Subtract 15 seconds',
                    onPressed: () =>
                        track(model.adjustRest(exercise, -restStepSeconds)),
                  ),
                  FsButton.mini(
                    key: ValueKey<String>('fs-rest-more-$index'),
                    label: '+15',
                    semanticLabel: 'Add 15 seconds',
                    onPressed: () =>
                        track(model.adjustRest(exercise, restStepSeconds)),
                  ),
                  FsButton.mini(
                    key: ValueKey<String>('fs-rest-go-$index'),
                    label: rest.running
                        ? 'Pause'
                        : rest.paused
                        ? 'Resume'
                        : 'Start',
                    semanticLabel: rest.running
                        ? 'Pause the rest timer'
                        : rest.paused
                        ? 'Resume the rest timer'
                        : 'Start the rest timer',
                    selected: rest.running,
                    onPressed: () => track(
                      rest.running
                          ? model.pauseRest(exercise)
                          : model.startRest(exercise),
                    ),
                  ),
                  FsButton.mini(
                    key: ValueKey<String>('fs-rest-reset-$index'),
                    label: 'Reset',
                    semanticLabel: 'Reset the rest timer',
                    onPressed: () => track(model.resetRest(exercise)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A finished workout: when it was finished, what was done, and every
/// logged set as text. Nothing here can be edited. The prototype's
/// `drawLockedSummary`, without its PR count and share button, which are
/// later build steps, and without warm-up sets, which are not logged.
class _LockedSummary extends StatelessWidget {
  const _LockedSummary({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final totals = session.totals;
    final finishedAt = session.finishedAtWallClock;

    return Column(
      key: const ValueKey<String>('fs-workout-locked'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MergeSemantics(
          child: Row(
            children: <Widget>[
              FsLockMark(color: colors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  finishedAt == null
                      ? 'Finished. Locked.'
                      : 'Finished at ${clockTime(finishedAt)}. Locked.',
                  style: FsText.bodySmall.copyWith(color: colors.textMuted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colors.hairline),
            borderRadius: BorderRadius.circular(FsRadius.base),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _Stat(
                    value: _thousands(totals.volumeLb),
                    label: 'lb volume',
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: colors.hairline),
                Expanded(
                  child: _Stat(
                    value: '${totals.loggedSets}',
                    label: totals.loggedSets == 1 ? 'work set' : 'work sets',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            'WORK SETS',
            semanticsLabel: 'Work sets',
            style: FsWorkoutText.summaryHead.copyWith(color: colors.highlight),
          ),
        ),
        const SizedBox(height: 4),
        for (final exercise in session.exercises)
          _SummaryExercise(exercise: exercise),
      ],
    );
  }

  /// "12,345".
  static String _thousands(int number) {
    final digits = number.toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: FsWorkoutText.statValue.copyWith(color: colors.text),
            ),
            FsLabelCaps(
              label,
              style: FsWorkoutText.statLabel,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// One exercise of a finished workout: its name, then a line per logged
/// set, or "Not logged".
class _SummaryExercise extends StatelessWidget {
  const _SummaryExercise({required this.exercise});

  final SessionExercise exercise;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final loaded = exercise.weightMode == WeightMode.required;
    final lines = <(String, String)>[];
    for (var i = 0; i < exercise.sets.length; i++) {
      final set = exercise.sets[i];
      if (!exercise.isLogged(set)) continue;
      final String value;
      switch (exercise.measure) {
        case SetMeasure.tick:
          value = 'Done';
        case SetMeasure.seconds:
          value = '${set.reps} sec';
        case SetMeasure.reps:
          final weight = set.weightLb;
          if (loaded && weight != null) {
            value = '${set.reps} reps × ${FsNumberField.format(weight)} lb';
          } else if (weight != null && weight > 0) {
            value =
                '${set.reps} reps '
                '(bodyweight + ${FsNumberField.format(weight)} lb)';
          } else {
            value = '${set.reps} reps (bodyweight)';
          }
      }
      lines.add(('Set ${i + 1}', value));
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              exercise.name,
              style: FsWorkoutText.summaryName.copyWith(color: colors.text),
            ),
            if (lines.isEmpty)
              Text(
                'Not logged',
                style: FsText.bodySmall.copyWith(color: colors.textMuted),
              )
            else
              for (final (label, value) in lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: MergeSemantics(
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 116,
                          child: FsLabelCaps(
                            exercise.measure == SetMeasure.tick ? '' : label,
                            style: FsWorkoutText.summaryLabel,
                            color: colors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            value,
                            style: FsWorkoutText.summaryValue.copyWith(
                              color: colors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// What the finish check found: sets that must be fixed first, or sets
/// left blank that he may finish without. The prototype's `openFixes`.
///
/// Pops with true for "Finish anyway"; anything else means go back.
class _FinishCheckDialog extends StatelessWidget {
  const _FinishCheckDialog({required this.check});

  final FinishCheck check;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final hard = check.fixes.isNotEmpty;
    final list = hard ? check.fixes : check.blanks;
    const shown = 8;

    return FsDialog(
      tone: hard ? FsDialogTone.warning : FsDialogTone.notice,
      title: hard
          ? 'Fix ${list.length == 1 ? 'this set' : 'these sets'} first'
          : 'Some sets are blank',
      actionsInRow: !hard,
      actions: <Widget>[
        if (hard)
          FsButton(
            key: const ValueKey<String>('fs-finish-fix'),
            label: 'Fix it',
            onPressed: () => Navigator.of(context).pop(false),
          )
        else ...<Widget>[
          FsButton.ghost(
            key: const ValueKey<String>('fs-finish-back'),
            label: 'Go back',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FsButton(
            key: const ValueKey<String>('fs-finish-anyway'),
            label: 'Finish anyway',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ],
      children: <Widget>[
        Text(
          hard
              ? 'Every set needs reps and weight before you finish. The sets '
                    'to fix are outlined in red.'
              : 'These sets have nothing entered. Fill them in if you did '
                    'them, or finish without them.',
          style: FsWorkoutText.dialogBody.copyWith(color: colors.text),
        ),
        const SizedBox(height: 8),
        for (final issue in list.take(shown))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '• ${issue.text}',
              style: FsText.body.copyWith(color: colors.text),
            ),
          ),
        if (list.length > shown)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '• and ${list.length - shown} more',
              style: FsText.body.copyWith(color: colors.text),
            ),
          ),
      ],
    );
  }
}
