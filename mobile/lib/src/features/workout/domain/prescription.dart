/// How the app reads a prescription such as `3 x 5 (RPE 7, rest 2 min)`.
///
/// Every rule here is the prototype's (`index.html`: `parseSets`, `restOf`,
/// `needsWeight`, `canAddWeight` and the rest bar's base), carried over as
/// it stands and listed in the feature contract for the maintainer to
/// confirm.
library;

/// What one set of an exercise records.
enum SetMeasure {
  /// A number of reps.
  reps,

  /// A number of seconds.
  seconds,

  /// Nothing to count: the exercise is only marked done.
  tick,
}

/// Whether a set needs a weight.
enum WeightMode {
  /// A loaded lift: a set is not logged without its weight.
  required,

  /// A bodyweight lift that can be loaded with a belt, vest or plate. The
  /// weight is the added load and may be left empty.
  optional,

  /// A bodyweight move: no weight is asked for.
  none,
}

/// The sets a prescription asks for.
class SetPlan {
  const SetPlan({required this.targets, required this.measure});

  /// One entry per set: what that set aims for, for example `5`, `6-8` or
  /// `25 sec`.
  final List<String> targets;

  final SetMeasure measure;

  int get count => targets.length;
}

final RegExp _supersetPrefix = RegExp(
  r'^\s*Superset\s+[A-Z]\d+:\s*',
  caseSensitive: false,
);
final RegExp _sentenceEnd = RegExp(r'\.\s');
final RegExp _fromBracket = RegExp(r'\(.*$');
final RegExp _group = RegExp(r'(\d+)\s*x\s*(\d+)', caseSensitive: false);
final RegExp _rampOnly = RegExp(
  r'^\s*\d+\s*x\s*\d+(\s*,\s*\d+\s*x\s*\d+)+\s*$',
  caseSensitive: false,
);
final RegExp _sets = RegExp(
  r'^\s*(\d+)\s*x\s*([^(]+?)\s*(?:\(.*)?$',
  caseSensitive: false,
);
final RegExp _time = RegExp(r'\b(sec|min)\b', caseSensitive: false);

/// The most sets one exercise can have.
const int maxSets = 12;

/// Reads the sets out of [prescription], or returns null when it does not
/// describe sets, as in `12 min easy, conversational pace`. Such an
/// exercise gets one "Done?" row.
///
/// - `3 x 5 (RPE 7, rest 2 min)`: three sets aiming for 5.
/// - `2 x 25 sec`: two timed sets.
/// - `1 x 5, 1 x 3, 1 x 1 (heaviest set last)`: ramp sets, one row each
///   with its own target.
/// - `Superset A1: 3 x 12 (RIR 3). Go straight to A2`: only the sets part
///   counts.
SetPlan? parseSets(String prescription) {
  final body = prescription
      .replaceFirst(_supersetPrefix, '')
      .split(_sentenceEnd)
      .first;
  final bare = body.replaceFirst(_fromBracket, '');

  final groups = _group.allMatches(bare).toList();
  if (groups.length > 1 && _rampOnly.hasMatch(bare)) {
    final targets = <String>[];
    for (final group in groups) {
      final sets = int.parse(group.group(1)!);
      for (var i = 0; i < sets && targets.length < maxSets; i++) {
        targets.add(group.group(2)!);
      }
    }
    return SetPlan(targets: targets, measure: SetMeasure.reps);
  }

  final match = _sets.firstMatch(body);
  if (match == null) return null;
  final count = int.parse(match.group(1)!);
  if (count < 1 || count > maxSets) return null;
  final target = match.group(2)!.trim();
  return SetPlan(
    targets: List<String>.filled(count, target),
    measure: _time.hasMatch(target) ? SetMeasure.seconds : SetMeasure.reps,
  );
}

final RegExp _rest = RegExp(
  r'\brest\s+(\d+(?:\.\d+)?)(?:\s*(?:to|-)\s*(\d+(?:\.\d+)?))?\s*(sec|min)',
  caseSensitive: false,
);

/// The rest written in [prescription], in seconds: `rest 2 min` is 120 and
/// `rest 45 to 60 sec` is 60, the top of the range. 0 if none is written or
/// it is outside 10 seconds to 10 minutes.
int restSecondsIn(String prescription) {
  final match = _rest.firstMatch(prescription);
  if (match == null) return 0;
  final amount = double.parse(match.group(2) ?? match.group(1)!);
  final seconds =
      amount * (match.group(3)!.toLowerCase().startsWith('min') ? 60 : 1);
  return seconds >= 10 && seconds <= 600 ? seconds.round() : 0;
}

final RegExp _supersetFirst = RegExp(
  r'^\s*Superset\s+[A-Z]1:',
  caseSensitive: false,
);
final RegExp _supersetLater = RegExp(
  r'^\s*Superset\s+[A-Z][2-9]:',
  caseSensitive: false,
);

/// True for the first exercise of a superset. It has no rest timer: he
/// goes straight to the next exercise.
bool isSupersetFirst(String prescription) =>
    _supersetFirst.hasMatch(prescription);

/// The rest timer's length when nothing else says so.
const int defaultRestSeconds = 90;

/// The shortest and longest a rest timer can be set to, and the step of
/// its plus and minus buttons.
const int minRestSeconds = 15;
const int maxRestSeconds = 600;
const int restStepSeconds = 15;

/// The rest timer's starting length for [prescription]: the rest it
/// writes, else a minute after the second exercise of a superset, else
/// [defaultRestSeconds].
int restBaseFor(String prescription) {
  final written = restSecondsIn(prescription);
  if (written > 0) return written;
  return _supersetLater.hasMatch(prescription) ? 60 : defaultRestSeconds;
}

final RegExp _loaded = RegExp(
  r'barbell|dumbbell|kettlebell|cable|machine|weighted|loaded|plate|sled|'
  r'landmine|\bez\b|trap bar|medicine ball|backpack|band|pulldown|'
  r'press(?!-)|smith|hack|sandbag|bike|rower|rowing|ski|treadmill',
  caseSensitive: false,
);
final RegExp _bodyweight = RegExp(
  r'pull-up|chin-up|push-up|\bdip|plank|burpee|inverted row|hanging|'
  r'bodyweight|air squat|crawl|climber|hold|bridge|crunch|sit-up|jumping|'
  r'jack|high knees|shadow|sprawl|hollow|bird dog|dead bug|superman|'
  r'wall sit|pistol|nordic|leg raise|knee raise|skater|broad jump|box jump|'
  r'jump squat|tuck jump|bear|inchworm|stretch|rotation',
  caseSensitive: false,
);
final RegExp _bodyweightMore = RegExp(
  r'bounding|road ride|brisk walk|l-sit|slider hamstring|thoracic extension|'
  r'ab wheel|battle rope|dead hang|elliptical|reverse hyperextension|'
  r'prone back extension|back extension \(45',
  caseSensitive: false,
);
final RegExp _canAddWeight = RegExp(
  r'pull-up|chin-up|\bdips?\b|back extension \(45',
  caseSensitive: false,
);
final RegExp _neverAddWeight = RegExp(
  r'scapular|assisted|band',
  caseSensitive: false,
);

/// Whether a set of the movement shown as [shownName] needs a weight.
/// [bodyweightName] is the same movement's name in the "Bodyweight Only"
/// equipment setup.
///
/// The prototype decides this from the words in the name: a name that
/// mentions a loaded implement needs a weight; one that names a known
/// bodyweight move does not; anything else needs a weight unless it is
/// the same move a man with no equipment would do.
WeightMode weightModeFor({
  required String shownName,
  required String bodyweightName,
}) {
  final bool needsWeight;
  if (_loaded.hasMatch(shownName)) {
    needsWeight = true;
  } else if (_bodyweight.hasMatch(shownName) ||
      _bodyweightMore.hasMatch(shownName)) {
    needsWeight = false;
  } else {
    needsWeight = shownName != bodyweightName;
  }
  if (needsWeight) return WeightMode.required;
  return _canAddWeight.hasMatch(shownName) &&
          !_neverAddWeight.hasMatch(shownName)
      ? WeightMode.optional
      : WeightMode.none;
}
