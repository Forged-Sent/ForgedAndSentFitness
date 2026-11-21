import '../../../core/local_date.dart';

/// How the member's program falls on his week.
///
/// Weekdays are numbered as [LocalDate.weekday] numbers them: Monday is 1
/// and Sunday is 7.
class WorkoutPlan {
  WorkoutPlan({
    required this.program,
    required this.equipment,
    required this.restWeekday,
    required List<int> liftWeekdays,
    required this.fourthDay,
    required this.start,
  }) : liftWeekdays = List<int>.unmodifiable(liftWeekdays),
       assert(restWeekday >= 1 && restWeekday <= 7),
       assert(liftWeekdays.length == 3),
       assert(!liftWeekdays.contains(restWeekday));

  /// The plan a new member gets on [today], since build step S3 has no
  /// setup and no plan editor.
  ///
  /// The settings are the prototype's defaults (`planDraft` and
  /// `defaultLiftDays` in `index.html`): the Forged program, a full gym,
  /// rest on Sunday, lifting on Monday, Wednesday and Friday, no fourth
  /// day.
  ///
  /// The start is not the prototype's. The prototype starts the plan on
  /// the first day after the next rest day, which can leave a new member
  /// six days with nothing to do (review finding U1). Here week 1 is the
  /// plan week that holds his next lifting day, today included, so he has
  /// a session on that day. Lifting days of that week that are already
  /// past stay unlogged.
  factory WorkoutPlan.startingFor(
    LocalDate today, {
    String program = defaultProgram,
    String equipment = defaultEquipment,
    int restWeekday = DateTime.sunday,
    List<int>? liftWeekdays,
    bool fourthDay = false,
  }) {
    final lifts = liftWeekdays ?? defaultLiftWeekdays(restWeekday);
    // Checked before the search below, which would never end on a list
    // that names no weekday.
    if (!lifts.any((int weekday) => weekday >= 1 && weekday <= 7)) {
      throw ArgumentError.value(
        liftWeekdays,
        'liftWeekdays',
        'must name at least one weekday from 1 (Monday) to 7 (Sunday)',
      );
    }
    var nextLift = today;
    while (!lifts.contains(nextLift.weekday)) {
      nextLift = nextLift.addDays(1);
    }
    return WorkoutPlan(
      program: program,
      equipment: equipment,
      restWeekday: restWeekday,
      liftWeekdays: lifts,
      fourthDay: fourthDay,
      start: _weekStartOnOrBefore(nextLift, restWeekday),
    );
  }

  static const String defaultProgram = 'Forged';
  static const String defaultEquipment = 'Full Gym';

  /// The first, third and fifth day after the rest day: the prototype's
  /// `defaultLiftDays`.
  static List<int> defaultLiftWeekdays(int restWeekday) => <int>[
    for (final offset in const <int>[1, 3, 5])
      _weekdayAfter(restWeekday, offset),
  ];

  final String program;

  /// The equipment setup movement names are shown for.
  final String equipment;

  /// The weekly rest day.
  final int restWeekday;

  /// The three lifting weekdays, in order from the day after the rest day.
  final List<int> liftWeekdays;

  /// Whether the optional fourth training day is on.
  final bool fourthDay;

  /// The first day of the plan's first week: always the day after a rest
  /// day.
  final LocalDate start;

  /// Which entry of the program's list [date] shows: 0 for the first. A
  /// negative number means the plan has not started on [date].
  ///
  /// The prototype's `planIndex`: a plan week runs from the day after the
  /// rest day to the rest day. Its three lifting days show the week's
  /// first, third and fifth entries in order, its other three days the
  /// second, fourth and sixth, and the rest day the seventh.
  int indexFor(LocalDate date) {
    final days = _daysBetween(start, date);
    if (days < 0) return days;
    final week = days ~/ 7;
    final offset = days - week * 7;
    if (offset == 6) return week * 7 + 6;
    final lift = liftWeekdays.indexOf(date.weekday);
    if (lift >= 0) return week * 7 + const <int>[0, 2, 4][lift];
    final others = <int>[
      for (var k = 1; k <= 6; k++)
        if (!liftWeekdays.contains(_weekdayAfter(restWeekday, k)))
          _weekdayAfter(restWeekday, k),
    ];
    return week * 7 + const <int>[1, 3, 5][others.indexOf(date.weekday)];
  }

  WorkoutPlan copyWith({
    String? program,
    String? equipment,
    int? restWeekday,
    List<int>? liftWeekdays,
    bool? fourthDay,
    LocalDate? start,
  }) => WorkoutPlan(
    program: program ?? this.program,
    equipment: equipment ?? this.equipment,
    restWeekday: restWeekday ?? this.restWeekday,
    liftWeekdays: liftWeekdays ?? this.liftWeekdays,
    fourthDay: fourthDay ?? this.fourthDay,
    start: start ?? this.start,
  );

  @override
  bool operator ==(Object other) =>
      other is WorkoutPlan &&
      other.program == program &&
      other.equipment == equipment &&
      other.restWeekday == restWeekday &&
      _sameList(other.liftWeekdays, liftWeekdays) &&
      other.fourthDay == fourthDay &&
      other.start == start;

  @override
  int get hashCode => Object.hash(
    program,
    equipment,
    restWeekday,
    Object.hashAll(liftWeekdays),
    fourthDay,
    start,
  );
}

bool _sameList(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The weekday [offset] days after [weekday], both numbered 1 to 7.
int _weekdayAfter(int weekday, int offset) => (weekday - 1 + offset) % 7 + 1;

int _daysBetween(LocalDate from, LocalDate to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// The latest day on or before [date] that follows a rest day.
LocalDate _weekStartOnOrBefore(LocalDate date, int restWeekday) {
  final first = _weekdayAfter(restWeekday, 1);
  var day = date;
  while (day.weekday != first) {
    day = day.previous;
  }
  return day;
}

/// One exercise as the program prescribes it.
class PlannedExercise {
  const PlannedExercise({required this.movementId, required this.prescription});

  /// The movement's key in the workout library. The library has no other
  /// identifier for a movement than this name (accepted for build step S3;
  /// stable ids are on the work board).
  final String movementId;

  /// For example `3 x 5 (RPE 7, rest 2 min)`.
  final String prescription;
}

/// One entry of a program's list: what one plan day asks for.
class PlannedWorkout {
  const PlannedWorkout({
    required this.day,
    required this.week,
    required this.templateDay,
    required this.sessionType,
    required this.title,
    required this.minutes,
    required this.exercises,
  });

  /// The plan day, from 1.
  final int day;

  /// The plan week, from 1.
  final int week;

  /// The day's place in the weekly template, 1 to 7. 6 is the optional
  /// fourth training day and 7 the rest day.
  final int templateDay;

  /// `Core`, `Recovery`, `Optional` or `Rest`.
  final String sessionType;

  final String title;
  final int minutes;
  final List<PlannedExercise> exercises;
}

/// What the plan holds for one date. The prototype's `workoutFor`.
enum PlanDayKind {
  /// The plan has not started yet.
  before,

  /// The program's list has run out.
  over,

  /// The weekly rest day.
  rest,

  /// The optional fourth training day, which is switched off.
  off,

  /// A day with a session to do: a lifting day or a recovery day.
  train,
}

class PlanDay {
  const PlanDay(this.kind, [this.workout]);

  final PlanDayKind kind;

  /// The program's entry for the day. Null for [PlanDayKind.before] and
  /// [PlanDayKind.over].
  final PlannedWorkout? workout;

  bool get isTrain => kind == PlanDayKind.train;

  /// A day the plan gives to rest: the weekly rest day, or the optional
  /// fourth day while that is switched off. Train calls both "Rest day",
  /// and on such a day Today's Workout box is not a to-do.
  bool get isRest => kind == PlanDayKind.rest || kind == PlanDayKind.off;
}

/// What [plan] holds for [date], given the program's list of [days].
PlanDay planDayFor(
  WorkoutPlan plan,
  List<PlannedWorkout> days,
  LocalDate date,
) {
  final index = plan.indexFor(date);
  if (index < 0) return const PlanDay(PlanDayKind.before);
  if (index >= days.length) return const PlanDay(PlanDayKind.over);
  final workout = days[index];
  if (workout.templateDay == 6 && !plan.fourthDay) {
    return PlanDay(PlanDayKind.off, workout);
  }
  return PlanDay(
    workout.sessionType == 'Rest' ? PlanDayKind.rest : PlanDayKind.train,
    workout,
  );
}
