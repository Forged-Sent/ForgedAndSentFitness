/* Owner decision workshop W01–W12 (docs/planning/03-decision-workshop.md). Option keys are stable: votes reference them. */
var WORKSHOP = [
{ id: "W01", area: "workshop", blocking: true, refs: "Needed by M1 · OD-21",
  title: "What does a man open the app for each day?",
  eli5: "When a man opens the app in the morning, what's the first thing he sees? This shapes the home screen, the reminders and how the devotional fits around his workout.",
  detail: "The default is a training-first Today screen: today's workout, with the devotional placed where he chose (before, after, short prompts during rest, or at another time), and the faithfulness calendar below it. The calendar default is 2 grace days a week, with no shaming when a streak ends. Choosing B changes the Today screen and the onboarding order, but not the architecture.",
  options: [
    { k: "training", label: "Training-first Today, devotional placed by his chosen mode", pros: "Matches 'fitness platform built around discipleship'; one daily rhythm", cons: "Men who come mainly for the devotional take one extra tap" },
    { k: "devotional", label: "Devotional-first Today", pros: "Puts Scripture first in the day", cons: "Training can feel secondary; doesn't fit the product framing" },
    { k: "dashboard", label: "Equal tiles for workout, devotion, food and team", pros: "Everything visible at once", cons: "No daily rhythm; more design work" }
  ], rec: "training", why: "Training is the daily core and discipleship runs through it. The Experience Engine already places the devotional where each man wants it." },

{ id: "W02", area: "workshop", blocking: true, refs: "Needed by M1 · OD-04 timing",
  title: "Which pillars are in the first release the men use?",
  eli5: "We can't build everything at once. Do the men start using a smaller app soon and get more each month, or wait until it's all done?",
  detail: "Staged plan: M1 training and devotion (owners and testers), M2 the brotherhood features (pilot alpha with the men), M3 challenges with video proof (practice season), M4 nutrition and health. Nutrition points are approved, but they can only count once nutrition logging ships in M4.",
  options: [
    { k: "staged", label: "Staged: training + devotion → brotherhood → challenges → nutrition", pros: "The men are using it after two milestones; feedback early", cons: "Challenges and nutrition come later than the prototype shows" },
    { k: "all", label: "Everything before anyone uses it", pros: "One big launch", cons: "Months more without real feedback" },
    { k: "challenges", label: "Challenges first", pros: "That's where the prototype's energy is", cons: "Hardest subsystem first, with no daily habit loop under it" }
  ], rec: "staged", why: "It validates the core habit loop with real men soonest. The architecture is the same whichever order you choose." },

{ id: "W03", area: "workshop", blocking: false, refs: "Needed by M3 · OD-22",
  title: "Are accountability teams the same as competition teams?",
  eli5: "In a group of 20 men, do the 4 guys you pray with also make up your challenge team, or are those different groups?",
  detail: "Default: one persistent team of 3–6 men that also acts as the default prayer and accountability audience. A leader can reshuffle teams between seasons. Weekly missions default to 1 a week (OD-22); mission evidence is optional and never requires family members' faces. Option B can be added later without migrating data.",
  options: [
    { k: "same", label: "One persistent team (competition + accountability)", pros: "Simple; teammates know each other", cons: "Less flexible in large groups" },
    { k: "separate", label: "Separate accountability circles + season teams", pros: "Flexible at scale", cons: "Two concepts to explain and build" },
    { k: "season", label: "Season teams only; partners handle accountability", pros: "Fresh teams each season", cons: "Accountability resets often" }
  ], rec: "same", why: "With 10–30 men, two kinds of subgroup is overhead. Starting with one doesn't block adding circles later." },

{ id: "W04", area: "workshop", blocking: false, refs: "Needed by M3 exit · OD-01 · ADR-0012",
  title: "How visible and how heavy is faith participation in scoring?",
  eli5: "You've agreed faith habits can earn a few team points. How many, and does anyone see who earned them? (Matthew 6: don't practice righteousness to be seen.)",
  detail: "Default: 1 point per day for completing that day's devotional stages, at most 5 a week, about 10% of a team's weekly maximum, counted only in the team total and never on an individual board. Points come from completion, never from what anyone wrote or prayed. It's a ruleset parameter, so it can change between seasons. Recommendation: hold a short retrospective with the pastor after the practice season.",
  options: [
    { k: "team_bool", label: "Boolean participation, team total only, capped", pros: "Encourages the habit without ranking anyone's spirituality", cons: "Some men may still feel it as scorekeeping" },
    { k: "zero", label: "No faith points; recognition only", pros: "Safest on perception", cons: "Loses a gentle motivator you wanted" },
    { k: "equal", label: "Weighted equal to workouts", pros: "Strong incentive", cons: "Checkbox devotion; comparison" }
  ], rec: "team_bool", why: "It keeps the approved principle (participation, never content) and the Matthew 6 guardrail." },

{ id: "W05", area: "workshop", blocking: false, refs: "Needed by M3 · OD-06 · ADR-0010",
  title: "How much proof culture do we want?",
  eli5: "Video proof is in. But do we ask for video on everything, or only on the big weekly challenge?",
  detail: "Default: one weekly proof challenge requires video. Workouts and missions are honor-based, with random spot checks. Proof is deleted 30 days after the appeal window closes. Two leaders review proof, never their own team's. Expected cost is about $1/month at 100 users.",
  options: [
    { k: "weekly", label: "Video for the weekly proof challenge only; honor + spot checks otherwise", pros: "Integrity where it matters; low friction", cons: "Some honor-system risk on daily items" },
    { k: "all", label: "Video for every scored physical activity", pros: "Strongest integrity", cons: "Men skip rather than film; heavy review load" },
    { k: "optional", label: "Honor only; video optional", pros: "Easiest", cons: "Recreates the prototype's trust problem" }
  ], rec: "weekly", why: "It uses the approved video capability without making filming the price of taking part." },

{ id: "W06", area: "workshop", blocking: true, refs: "Needed by M2 · OD-05, OD-09, OD-17",
  title: "Who sees prayer requests and faith participation, and who moderates?",
  eli5: "When a man writes a prayer request, who sees it by default? Can leaders see who did their devotions? Who handles a report?",
  detail: "Defaults:\n- A new prayer request goes to my team; the author changes the audience per request (private, partner, team, leaders, group).\n- Leaders see faith participation as aggregates only.\n- Moderation: leaders respond within 24 h and owners escalate within 72 h, with one named incident contact.\n\nApple guideline 1.2 requires report, block and timely moderation for user-generated content.",
  options: [
    { k: "team_agg", label: "Team default · leaders see aggregates · leaders moderate, owners escalate", pros: "Meaningful audience; no surveillance", cons: "Leaders can't follow up individually without being told" },
    { k: "private_agg", label: "Private default · aggregates · same moderation", pros: "Maximum privacy", cons: "Few requests get shared; less burden-bearing" },
    { k: "group_member", label: "Whole-group default · per-member leader view (with consent)", pros: "Most visibility", cons: "Men self-censor; a privacy risk" }
  ], rec: "team_agg", why: "Galatians 6:2 needs someone to see the burden. The team is small enough to be safe." },

{ id: "W07", area: "workshop", blocking: true, refs: "Needed by M1 · ADR-0007",
  title: "Which training content ships first?",
  eli5: "The prototype has four year-long programs. Do we launch with one polished program, or all four?",
  detail: "Default: the Forged program (365 days, verified against the prototype), plus a quick or custom log for travel and other gyms. The other three programs follow in M4. Equipment profiles at launch: full gym, home dumbbells, bodyweight.",
  options: [
    { k: "forged", label: "Forged program + quick/custom log", pros: "One program to verify; fast to the pilot", cons: "Less choice at first" },
    { k: "all4", label: "All four programs", pros: "Full choice", cons: "1,460 days to verify and review before M1" },
    { k: "new", label: "A new simplified starter program", pros: "Cleaner content", cons: "Loses tested prototype programming" }
  ], rec: "forged", why: "It's the shortest path to men training on the real app, without throwing away tested content." },

{ id: "W08", area: "workshop", blocking: true, refs: "Needed by M1 content freeze · OD-10, OD-11",
  title: "Who approves content, and what are the devotional rights?",
  eli5: "Someone with pastoral standing should sign off on the devotionals, and someone who knows training should check the workouts. We also need to know where each devotional came from.",
  detail: "Default: name one pastor or elder and one fitness reviewer now, and record the provenance of each of the 366 devotionals before the pilot (written by you, AI-assisted, or third-party). Rights must be settled before public release. That blocks release, not the pilot.",
  options: [
    { k: "named", label: "Name a pastor/elder + fitness reviewer; record provenance now", pros: "Pilot proceeds; real review", cons: "Asks something of two volunteers" },
    { k: "owners", label: "Owners review everything", pros: "Fastest", cons: "Weaker theological and safety review" },
    { k: "licensed", label: "Replace devotionals with a licensed source", pros: "Clear rights", cons: "Cost; loses your voice" }
  ], rec: "named", why: "Content is the voice of the app. Review protects the men and you." },

{ id: "W09", area: "workshop", blocking: false, refs: "Needed by M5 · OD-16",
  title: "What's the money model and monthly budget ceiling?",
  eli5: "Is this a free ministry tool, donation-supported, or paid for churches later? And at what monthly cost do we get an alert?",
  detail: "Default: free ministry, with a $25/month budget alert during the pilot (expected cost $0–5). Revisit at Stage 2. The model affects ESV, Open Food Facts and food-provider terms.",
  options: [
    { k: "free", label: "Free ministry + budget alert", pros: "Simple; easiest licensing", cons: "Owners fund it" },
    { k: "donate", label: "Donations", pros: "Shared support", cons: "Payment provider; store rules" },
    { k: "paid", label: "Paid tier for churches (Stage 2+)", pros: "Funds growth", cons: "Licensing, billing, support obligations" }
  ], rec: "free", why: "The pilot costs almost nothing, and revenue questions can wait for Stage 2." },

{ id: "W10", area: "workshop", blocking: false, refs: "Before Stage 2 · ADR-0013",
  title: "When and how do wives, families and youth come in?",
  eli5: "Wives will want in. Do they join their own groups like the men, or do we build shared family accounts first? And when, if ever, do kids come in?",
  detail: "Default: women's groups first, as ordinary adult groups (nothing in the model assumes male). Households (couples, families) come at Stage 2 with their own design; household membership never unlocks private data. Youth not before Stage 3, and only with its own ADR covering guardian consent, no messaging and moderation.",
  options: [
    { k: "groups_first", label: "Women's groups first; households Stage 2; youth Stage 3+", pros: "No new privacy model until needed", cons: "Couples can't share challenges at first" },
    { k: "couples", label: "Couples together at Stage 1", pros: "Families engaged early", cons: "Needs the household design now" },
    { k: "youth", label: "Youth with families", pros: "Whole-family ministry", cons: "Large legal, consent and moderation scope" }
  ], rec: "groups_first", why: "It reaches wives quickly with zero new access semantics. The model is already ready for households." },

{ id: "W11", area: "workshop", blocking: true, refs: "Needed by M2 · OD-12",
  title: "What does pilot success look like?",
  eli5: "Before the men start, agree what 'it worked' means, so we measure the right things and know when to start a real season.",
  detail: "Default:\n- A 4-week pilot alpha after M2: at least 70% of members complete at least 3 workouts a week, and at least 50% engage with a devotional stage at least 4 days a week.\n- Zero lost workouts; cost within budget.\n- A qualitative review by the owners and the pastor.\n- A practice season after M3. The first real season date is set only after it passes.",
  options: [
    { k: "default", label: "Workouts ≥3/wk for 70%; devotion ≥4 days/wk for 50%; zero data loss", pros: "Measures the habit loop", cons: "Targets may need tuning" },
    { k: "qual", label: "Qualitative review only", pros: "No tracking", cons: "Harder to decide go/no-go" },
    { k: "custom", label: "Our own targets (explain in a note)", pros: "Fits your group", cons: "—" }
  ], rec: "default", why: "Clear exit criteria keep the pilot honest. Analytics events carry counts, never content." },

{ id: "W12", area: "workshop", blocking: true, refs: "Needed now · ADR-0020 (proposed) · AP-11",
  title: "Where do we plan and decide together, and how does the prototype relate?",
  eli5: "We need one place to suggest ideas and vote, and one official record that the coding tools must follow. This page is the first; GitHub is the second.",
  detail: "Default: a hybrid.\n- This Planning Hub is for ideas, discussion and votes.\n- A ruling becomes authoritative only when it's recorded in docs/planning/decision-log.yaml (and an ADR when architectural), merged with both owners' approval.\n- AI agents read only the repository record and can't change it.\n- The prototype keeps evolving independently with the legacy-change label; a prototype change becomes a requirement only through a hub decision.",
  options: [
    { k: "hybrid", label: "Hybrid: this hub to discuss and vote; GitHub decision log authoritative", pros: "Friendly discussion + durable, enforceable record", cons: "Two places; export step at decision time" },
    { k: "github", label: "GitHub only (issues, discussions, project board)", pros: "One place; free; native traceability", cons: "Voting and plain-words explanations are clunky for non-developers" },
    { k: "portal", label: "Build our own portal on Firebase", pros: "Fully custom", cons: "A second product to build and secure; weeks of work" }
  ], rec: "hybrid", why: "It's the smallest setup that gives real collaboration, reliable persistence and a record agents can be held to." }
];
