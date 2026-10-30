#!/usr/bin/env python3
"""Coach Gideon's Workout Guidance as a short, direct brief: a one-line Mission, then bullet sections
(Why it matters, Today's focus, Effort and rest, Progress, Arm finisher, Watch for). Same coaching as before, cut down.
Each plan day (PLAN.T) gets a `brief`; the old purpose/notes stay as a fallback. Deload weeks add a line to the focus.
Usage: patch_brief.py <in> <out> <version>"""
import sys, re, json
src, dst, ver = sys.argv[1:4]
s = open(src).read()
def rep(old, new):
    global s
    assert s.count(old) == 1, ("anchor", old[:90], s.count(old))
    s = s.replace(old, new)

LIFT_EFFORT = ["Stop each set with 1 to 2 good reps left (RPE 8 to 9).", "Form breaks? End the set. Form beats weight.", "Unsure of the weight? Start lighter. It's easy to add next time."]
PROGRESS = ["Hit the top of the rep range on every set with clean form? Add 2 to 5 lb next time.", "Too hard: drop a set, lower the weight or use the alternate.", "Too easy: slow the lowering to 3 seconds before adding weight."]
ARMS = ["Superset: A1 curl, then straight into A2 triceps. No rest between.", "Rest 45 to 60 sec, then repeat for the listed rounds.", "Light to moderate weight. Leave 2 to 3 reps in the tank.", "Sharp elbow pain? Swap the exercise."]
SAFE = ["Mild soreness 1 to 2 days later is normal.", "Sharp, pinching or joint pain is not. Stop and use the alternate.", "General coaching, not medical advice. Injured or have a health condition? Check with your doctor first."]
CORE = ["Core work lives on recovery days so it never tires you before heavy sets.", "Two short core holds: hold steady, breathe, stop before your form slips."]

def lift_day(day, lead, focus1, focus2):
    return {"mission": "Get stronger. Day " + day + ": " + lead + ".",
            "why": ["Challenging weights, clean form, repeated week after week. That's how strength is built.", "Full body every session, so no single day is make-or-break."],
            "focus": [focus1, focus2],
            "effort": ["Rest 2 to 3 min between main sets. Sip water and breathe."] + LIFT_EFFORT,
            "progress": PROGRESS, "arms": ARMS, "watch": SAFE}
def built_day():
    return {"mission": "Build muscle.",
            "why": ["Muscle grows when you train close to fatigue with controlled reps, then recover.", "Full body: every major muscle gets work today."],
            "focus": ["Moderate weight, higher reps.", "Lower every rep for about 3 seconds. It makes lighter weights work harder.", "Chase good form and a steady burn, not the heaviest weight."],
            "effort": ["Rest 60 to 90 sec between sets."] + LIFT_EFFORT,
            "progress": PROGRESS, "arms": ARMS, "watch": SAFE}
RECOVER = {"mission": "Recover. Don't train.",
           "why": ["Easy movement sends blood to sore muscles and loosens stiff joints.", "Hard effort today steals from the days that build you."],
           "focus": ["At home, no equipment, 30 minutes or less.", "Easy effort only. Finish feeling better than you started.", "Feel good? Don't turn it into a workout. That's how men stall."] + CORE,
           "watch": []}
REST = {"mission": "Rest. Nothing hard, on purpose.",
        "why": ["Muscle gets stronger while you recover, not during the workout. Today is when it happens."],
        "focus": ["Sleep 7 to 9 hours.", "A palm-sized portion of protein at every meal.", "Water through the day.", "An easy walk or stretch is fine. No guilt.", "Restless? Normal early on. Trust the plan."],
        "watch": []}
B = {
 "Forged|1": lift_day("A", "the squat", "Squat first, so your legs get your freshest effort.", "Warm up well. Build to your first working set gradually."),
 "Forged|3": lift_day("B", "the deadlift", "Hinge and row: build the back of your body.", "Keep your back flat on every hinge and row."),
 "Forged|5": lift_day("C", "the bench press", "Press and pull: build chest, shoulders and back.", "Shoulder blades pulled back and down on every press."),
 "Forged|6": {"mission": "Bonus practice. Optional.",
              "why": ["Extra practice on your lifts and a little more muscle-building volume."],
              "focus": ["Sore, tired, busy or sleeping poorly? Skip it. Skipping never hurts your progress."],
              "effort": ["Moderate effort. Keep 2 reps in reserve. Never to failure.", "Rest 60 to 90 sec between sets."],
              "arms": ARMS, "watch": SAFE},
 "Built|1": built_day(), "Built|3": built_day(), "Built|5": built_day(),
 "Built|6": {"mission": "Bonus muscle work. Optional.",
             "why": ["More volume for growth, when your body is ready for it."],
             "focus": ["Sore, busy or sleeping poorly? Skip it.", "Lower every rep under control."],
             "effort": ["Keep 2 reps in reserve on every set.", "Rest 60 to 90 sec between sets."],
             "arms": ARMS, "watch": SAFE},
 "Engine|1": {"mission": "Build your engine.",
              "why": ["Your heart and lungs deliver the energy your muscles burn.", "Intervals train that system fast and safely."],
              "focus": ["Hard = 8 out of 10. You can say a few words, not a full sentence.", "Easy = move gently until your breathing settles.", "Pace the early rounds so the last ones are still strong.", "All out by round two? You started too hard."],
              "watch": ["Dizziness, chest pain or feeling sick: stop and rest."] + SAFE},
 "Engine|2": {"mission": "Build your aerobic base.",
              "why": ["A bigger base means faster recovery between sets, stronger interval days and less winded in daily life."],
              "focus": ["Easy pace: full sentences the whole time. Can't talk? Slow down.", "It should feel almost too easy. That's the point.", "Walk, cycle, march in place or step up on a stair. No equipment, 30 minutes or less."] + CORE,
              "watch": []},
 "Engine|3": {"mission": "Get stronger with your heart rate up.",
              "why": ["A circuit builds muscle and conditioning at the same time."],
              "focus": ["Exercises in order. Rest only as listed.", "Quality beats speed. Challenging but controlled.", "Form slips? Take extra rest, then continue."],
              "effort": ["Pick weights you can finish with 2 reps in reserve."],
              "progress": PROGRESS[1:], "watch": SAFE},
 "Engine|5": {"mission": "Full-body conditioning: the complex.",
              "why": ["Linking moves without setting the weight down trains strength, coordination and breathing together."],
              "focus": ["Light weight. Pick it for the hardest move in the complex.", "Crisp reps beat fast reps.", "Form breaks? End the round. Tired reps are where men get hurt.", "Rest as listed, then go again."],
              "watch": SAFE},
 "Engine|6": {"mission": "Bonus: loaded carries. Optional.",
              "why": ["Builds grip, core and total-body strength that carries over to real life."],
              "focus": ["Walk tall, weight close, short steady steps.", "Set the weights down by hinging at the hips, not rounding your back.", "Sore or short on time? Skip it."],
              "watch": SAFE},
 "Warrior|1": None, "Warrior|3": None,
 "Warrior|2": {"mission": "Mobility: keep your joints moving.",
               "why": ["Better hip, shoulder and spine movement means deeper squats, safer overhead presses and less stiffness."],
               "focus": ["Move slowly, breathe and stay at mild tension.", "Never force a stretch or push into pain.", "At home, no equipment, 30 minutes or less."] + CORE,
               "watch": []},
 "Warrior|5": {"mission": "Boxing conditioning.",
               "why": ["Builds stamina, coordination and toughness."],
               "focus": ["Hands up, shoulders relaxed, feet moving.", "Smooth, accurate rounds beat wild, fast ones.", "Circuit in order. Rest only as listed. Expect to breathe hard."],
               "watch": SAFE},
 "Warrior|6": {"mission": "Bonus boxing. Optional.",
               "why": ["More rounds for stamina and coordination, when you have it in you."],
               "focus": ["Sore or short on time? Skip it.", "Shoulders relaxed, hands up, steady breathing.", "Smooth technique over speed."],
               "watch": SAFE},
}
POWER = {"mission": "Train power.",
         "why": ["Power is strength expressed fast: jump, throw, sprint, catch your balance.", "It fades with age unless you train it."],
         "focus": ["Move fast with good form. Stop the set when your speed drops.", "Land softly on every jump.", "New to explosive lifts? Use the easier alternate first."],
         "effort": ["Full rest, 2 to 3 min. Tired power work is just fatigue.", "Light to moderate weights."],
         "arms": ARMS, "watch": SAFE}
B["Warrior|1"] = POWER; B["Warrior|3"] = POWER
for p in ("Forged", "Built", "Engine", "Warrior"):
    B.setdefault(p + "|7", REST)
for k in ("Forged|2", "Forged|4", "Built|2", "Built|4", "Engine|4", "Warrior|4"):
    B[k] = RECOVER

i = s.index('var PLAN = ') + len('var PLAN = ')
P, n = json.JSONDecoder().raw_decode(s[i:])
missing = [k for k in P['T'] if k not in B]
assert not missing, missing
for k in P['T']:
    P['T'][k]['brief'] = B[k]
s = s[:i] + json.dumps(P, ensure_ascii=False, separators=(',', ':')) + s[i + n:]

FN = r'''  /* Coach brief: one-line mission, then short bullet sections. */
  var BRIEF_SECS = [["why", "Why it matters"], ["focus", "Today's focus"], ["effort", "Effort and rest"], ["progress", "Progress"], ["arms", "Arm finisher"], ["watch", "Watch for"]];
  function coachBrief(box, label, br, w) {
    var d = el("details", "coach-sec coach-big coach-brief"), sm = el("summary"); d.open = true;
    var bg = el("span", "vd-badge"); bg.innerHTML = GIDEON_BADGE; sm.appendChild(bg); var tt = el("span", "cb-t"); tt.appendChild(el("b", null, label)); sm.appendChild(tt);
    d.appendChild(sm);
    var mi = el("div", "cbr-mission"); mi.appendChild(el("span", "cbr-k", "Mission")); mi.appendChild(el("p", null, br.mission)); d.appendChild(mi);
    var deload = ((w && w.exercises) || []).some(function (e) { return /deload/i.test(String(e[1] || "")); });
    var hasArms = ((w && w.superset) || []).length > 0;
    BRIEF_SECS.forEach(function (sec) {
      var items = (br[sec[0]] || []).slice();
      if (sec[0] === "focus" && deload) items.unshift("Deload week: lighter weights, fewer sets. It's planned, not slacking.");
      if (sec[0] === "arms" && !hasArms) return;
      if (!items.length) return;
      var wrap = el("div", "cbr-sec"); wrap.appendChild(el("span", "cbr-k", sec[1]));
      var ul = el("ul", "cbr-ul"); items.forEach(function (t) { ul.appendChild(el("li", null, t)); }); wrap.appendChild(ul); d.appendChild(wrap);
    });
    box.appendChild(d);
  }
'''
rep('  function coachSection(box, label, text, fold, big) {', FN + '  function coachSection(box, label, text, fold, big) {')
rep('    if (!S && !locked) coachSection(body, COACH_LABEL + "\\u2019s Workout Guidance", [th.purpose',
    '    if (!S && !locked && th.brief) coachBrief(body, COACH_LABEL + "\\u2019s Workout Guidance", th.brief, w);\n    else if (!S && !locked) coachSection(body, COACH_LABEL + "\\u2019s Workout Guidance", [th.purpose')

rep('.coach-big .cb-t { display: grid; gap: 1px; }', '''.coach-big .cb-t { display: grid; gap: 1px; }
.coach-brief { padding-bottom: 10px; }
.cbr-k { display: block; font-family: var(--f-label); font-weight: 700; font-size: 12px; letter-spacing: .12em; text-transform: uppercase; color: var(--brass, #b08d57); }
.cbr-mission { margin: 2px 0 10px; padding: 8px 10px; border-radius: var(--radius, 4px); background: var(--bg); border-left: 3px solid var(--accent); }
.cbr-mission .cbr-k { color: var(--accent); }
.coach-brief .cbr-mission p { margin: 2px 0 0; font-family: var(--f-display); font-weight: 700; font-size: 19px; line-height: 1.2; text-transform: uppercase; color: var(--ink); }
.cbr-sec { margin-top: 10px; }
.coach-brief .cbr-ul { margin: 4px 0 0; padding: 0 0 0 20px; list-style: disc outside; }
.coach-brief .cbr-ul li { display: list-item; margin: 3px 0; font-size: 15px; line-height: 1.4; color: var(--ink); }
.coach-brief .cbr-ul li::marker { color: var(--accent); }''')
m = re.search(r'var APP_VERSION = "[^"]+";', s); s = s.replace(m.group(0), 'var APP_VERSION = "%s";' % ver)
open(dst, 'w').write(s); print('ok', dst)
