/* Decision register content. Static: what each decision is, its options and the review's recommendation.
   What people pick, note and finally decide lives in the shared database, not here. */
var AREAS = {
  foundation: { label: "Foundations", blurb: "How the app is built. These are hard to change later." },
  faith: { label: "Faith & discipleship", blurb: "How Scripture, prayer and accountability work, and what is never turned into points." },
  competition: { label: "Competition & proof", blurb: "Points, challenges, proof and fairness." },
  privacy: { label: "People, data & privacy", blurb: "Who can join, who sees what, and what happens to existing data." },
  ops: { label: "Running it", blurb: "Who keeps it safe and running after launch." }
};

var DECISIONS = [
/* ---------------- Foundations ---------------- */
{ id: "D01", area: "foundation", blocking: true, refs: "review ADR-001 · Review A, H",
  title: "Rebuild the app, or wrap the current prototype?",
  eli5: "The prototype is like a great sketch of a house drawn on a napkin: it shows what everyone wants, and people have lived in it for a few days. But it has no foundation. Anyone can move anyone else's furniture. The choice is whether to build the real house from the sketch or put walls around the napkin.",
  detail: "All 5,300 lines of JavaScript live in one HTML file. Scores, PRs, deadlines and brackets are calculated and saved by each man's own phone. The B adapter does not isolate business rules, and the app depends on claude.ai for identity, storage and database. Wrapping it (e.g., Capacitor) ships those flaws to the App Store and risks Apple guideline 4.2.",
  options: [
    { k: "rebuild", label: "Rebuild properly; keep the prototype as the spec and content source", pros: "Fixes security and scoring at the root; content and UX lessons carry over", cons: "Takes longer before the new app matches the prototype" },
    { k: "wrap", label: "Wrap the prototype in a native shell and harden it", pros: "Fastest to an app store listing", cons: "Keeps phone-side scoring, missing access rules and one-file code; likely rewrite later anyway" },
    { k: "port", label: "Port the JavaScript piece by piece", pros: "Feels incremental", cons: "The logic is tangled with the UI; porting copies the problems" }
  ], rec: "rebuild", why: "The valuable part of the prototype is its content and design decisions, not its code." },

{ id: "D02", area: "foundation", blocking: true, refs: "review ADR-002 · Review D.1, D.3 · Q1",
  title: "Mobile framework: Flutter or React Native (Expo)?",
  eli5: "This is choosing the toolbox the builders use. Both toolboxes can build the same house. The best one is the one your two builders already know how to use.",
  detail: "Weighted matrix: Flutter 4.14 vs Expo 3.98 assuming Flutter experience on the team; flips to Expo 4.18 vs Flutter 3.94 if the team knows React/TypeScript instead. Flutter: one rendering engine, Drift local database, verified 'health' plugin for HealthKit and Health Connect. Expo: over-the-air fixes, TypeScript shared with server functions and a future web admin.",
  options: [
    { k: "flutter", label: "Flutter (Dart)", pros: "Identical look on iPhone and Android; best local database; strong offline story", cons: "No code sharing with a future web admin" },
    { k: "expo", label: "React Native + Expo (TypeScript)", pros: "Fast fixes without store review; one language front to back; biggest community", cons: "Health needs two libraries; more native upgrade churn" },
    { k: "native", label: "Fully native (Swift + Kotlin)", pros: "Best platform fit", cons: "Two apps to build and maintain with two people" }
  ], rec: "flutter", why: "Wins if at least one developer is productive in Dart. Answer Q1 (team skills) before voting.", },

{ id: "D03", area: "foundation", blocking: true, refs: "review ADR-003 · Review D.2, D.4",
  title: "Backend: Firebase (approved) and how it stays honest and private",
  eli5: "Firebase is Google's app backend: sign-in, the database, file storage and notifications in one place, and it syncs when you get signal. To keep scores honest, only the server's referee code can write points, and every rule about who sees what is tested automatically.",
  detail: "Approved direction (27 Oct): Firebase Auth, Firestore, Cloud Functions, Storage, FCM, App Check, App Distribution. The review had preferred Supabase (4.41 vs 3.28); its integrity goals are met on Firebase with Functions-only ledger writes, deterministic ids, a rules test matrix in CI and daily exports (ADR-0003). Original note: Supabase scores 4.41 vs Firebase 3.28. Postgres + Row Level Security handles groups, roles, private prayer and an auditable scoring ledger with transactions. Firebase wins only on built-in offline sync and lower ops, and its per-read billing punishes broad queries (the prototype pattern ~ $630/month at 1,000 users on Firestore). Offline for personal records is handled on the phone (see D04).",
  options: [
    { k: "supabase", label: "Supabase (managed PostgreSQL)", pros: "Strong privacy rules, honest scoring, SQL reports, easy exit", cons: "Offline sync is built by us (small for this app)" },
    { k: "firebase", label: "Firebase / Firestore", pros: "Offline sync built in; very low operations", cons: "Weak fit for groups, roles and score integrity; per-read costs; harder to leave" },
    { k: "custom", label: "Our own server + PostgreSQL", pros: "Total control", cons: "Too much plumbing for two people" }
  ], rec: "firebase", why: "Approved product decision. The privacy and scoring risks are handled with Firebase controls, not by switching platforms." },

{ id: "D04", area: "foundation", blocking: true, refs: "review ADR-006, review ADR-007 · Review E.4",
  title: "How offline works",
  eli5: "In a gym with no signal, the app writes everything into a notebook on the phone first. When signal comes back, it mails the pages in. Each page has a serial number, so if it gets mailed twice, the office files it once.",
  detail: "Drift (SQLite) on the device; every set saved immediately (no lost workouts after a crash); an outbox of pending changes with client-generated IDs (UUIDv7) and idempotent server functions; a workout can only be edited on one device at a time (lease). Firebase note: Firestore also keeps its own offline cache (on by default, 100 MB, last write wins). Drift stays the source of truth for workouts in progress; the outbox hands writes to Firestore with fixed ids and waits for server confirmation (ADR-0006).",
  options: [
    { k: "outbox", label: "Local database + outbox", pros: "Small, testable, no extra vendor; crash-safe workouts", cons: "We own the sync code" },
    { k: "powersync", label: "Rely on Firestore's offline cache alone", pros: "Nothing extra to build", cons: "Pending writes are invisible, the cache can be evicted, and a lost workout is hard to recover" },
    { k: "online", label: "Online only", pros: "Simplest", cons: "Unusable in gyms and church basements" }
  ], rec: "outbox", why: "What must work offline (sets, habits, water, reflections) is personal and append-only, so nothing needs merging." },

{ id: "D05", area: "foundation", blocking: true, refs: "review ADR-004 · Review F.6, K",
  title: "Is a 'group' the unit everything belongs to (churches later)?",
  eli5: "Every post, score and prayer request belongs to one group, like one Bible study. A church with many groups can be added later as a folder that holds groups, without rebuilding anything.",
  detail: "Every shared row carries group_id from day one. Organization (church) is a nullable parent added in Stage B as an additive migration. Cross-group visibility is off by default. Reconciled: organizations and households are optional future layers that grant no access to journals, health, messages or prayers.",
  options: [
    { k: "group", label: "Group now, church/organization later", pros: "Simple pilot; no rebuild to add churches", cons: "Church-wide features wait" },
    { k: "org", label: "Build churches/organizations now", pros: "Ready for multi-church", cons: "Admin screens and rules nobody will use in the pilot" }
  ], rec: "group" },

{ id: "D06", area: "foundation", blocking: true, refs: "review ADR-008 · Review E.8, H.2",
  title: "Programs and content as versioned 'packages' generated from templates",
  eli5: "Today the year of workouts is 1,460 hand-copied pages. If you want to change one exercise, you edit hundreds of pages. Instead, we keep a recipe (\"week 1 is moderate, week 4 is easy\") and the app makes the pages. Fix the recipe once and every day updates.",
  detail: "Programs regenerate from templates (block × week-in-block × template day + variation table) with an exact-match test against today's 1,460 days. RPE/RIR intensity, stripped from the prototype's display, is restored so deload weeks are visible. Devotionals, movements, swaps and challenges become versioned, reviewed packages bundled in the app for offline first launch.",
  options: [
    { k: "templates", label: "Templates + versioned packages", pros: "Edit once; intensity and deloads shown; testable", cons: "Needs a small content tool" },
    { k: "rows", label: "Keep 1,460 copied day records", pros: "No tool to build", cons: "Every change is hundreds of edits; errors creep in" }
  ], rec: "templates" },

{ id: "D07", area: "foundation", blocking: true, refs: "review ADR-016 · Review J",
  title: "Rules for AI coding agents (protected zones)",
  eli5: "Several helpers (two people plus AI tools) work on the same house. Only one person at a time may change the blueprint (database design, scoring rules). Everyone else builds rooms. A guard at the door checks this automatically.",
  detail: "Single-writer zones: contracts/, supabase/migrations/, docs/adr/, docs/rules/, content approvals. Enforced by CODEOWNERS, a CI zone guard (label + ADR id required, merged migrations immutable) and a Claude Code PreToolUse hook. Minimum agent set: architecture reviewer and security reviewer (read-only), test engineer (tests only). AI never approves theology or merges.",
  options: [
    { k: "zones", label: "Protected zones + 3 focused agents", pros: "Prevents conflicting changes; reviews stay independent", cons: "A little process overhead" },
    { k: "free", label: "No special rules", pros: "Fast at first", cons: "Agents edit the same schema in incompatible ways" },
    { k: "big", label: "Large team of specialist agents", pros: "Looks thorough", cons: "More coordination than value for two developers" }
  ], rec: "zones" },

/* ---------------- Faith & discipleship ---------------- */
{ id: "D08", area: "faith", blocking: true, refs: "Review E.7.1 · Q2",
  title: "What is Forged & Sent, first?",
  eli5: "Is this mainly a brotherhood that helps men follow Jesus and also trains together, or mainly a fitness competition with Bible verses added? Both are fine, but they lead to different apps.",
  detail: "Today a devotional is worth 2 points and one PR is worth 25; typed steps can earn 97.5 points in a day; prayer requests, private reflection, accountability partners and group study are missing. The review reads the current app as faith-themed fitness.",
  options: [
    { k: "discipleship", label: "A discipleship brotherhood that also trains", pros: "Matches the mission (1 Cor 16:13-14, Matt 28:19)", cons: "Points and leaderboards become secondary" },
    { k: "fitness", label: "A fitness competition with faith content", pros: "Simpler and more 'gamey'", cons: "Risks reducing faith to a checkbox" },
    { k: "both", label: "Equal weight, kept in separate spaces", pros: "Fitness competes; faith accompanies", cons: "Needs careful design so one does not swallow the other" },
    { k: "integrated", label: "Integrated devotional workouts (approved)", pros: "Faith and training in one daily experience: devotional before, after, or short prompts during rest", cons: "Needs an experience engine with strict safety and privacy rules" }
  ], rec: "integrated", why: "Approved direction: a faith-centered devotional workout platform. Only private spiritual content stays out of competition." },

{ id: "D09", area: "faith", blocking: true, refs: "review ADR-012 · CP-8 · Review E.7.2",
  title: "Should Bible reading, prayer and reflection earn public points?",
  eli5: "If reading your Bible puts you higher on a scoreboard, some men read to win, and others feel judged. The proposal: faith habits stay personal. The group sees how many men read today, not who did or didn't.",
  detail: "Proposed: devotional, prayer, confession, giving and reflection never earn individual points or rank. Leaders may see aggregate participation (\"6 of 9 read today\"). Each man sees a private faithfulness calendar with grace days instead of a streak that resets.",
  options: [
    { k: "firewall", label: "No individual points for spiritual practices", pros: "Guards against performance spirituality (Matt 6:1-18)", cons: "Less 'motivation by competition' for devotions" },
    { k: "small", label: "Keep small points (like today's 2/day)", pros: "Familiar to the men", cons: "Faith becomes a box to check; still dwarfed by fitness points" },
    { k: "weighted", label: "Give spiritual practice more points than fitness", pros: "Signals priority", cons: "Strengthens the incentive to perform piety" },
    { k: "participation", label: "Small, capped participation points only; never based on what anyone prays or writes", pros: "Recognizes showing up without judging anyone's faith", cons: "Exact weights still need pastoral input (OD-01)" }
  ], rec: "participation", why: "Approved: participation may count; prayers and reflections are never scored, shared or judged." },

{ id: "D10", area: "faith", blocking: false, refs: "CP-9 · Review E.8.4",
  title: "Fasting: private and unscored?",
  eli5: "Right now, fasting checks your calorie box for a point and shows a 'Fasting' tag to everyone. Jesus taught to fast so it isn't seen by others. Also, fasting isn't safe for everyone.",
  detail: "Today a fast day auto-checks Calories (a free point, repeatable weekly) and shows a Board tag. Proposal: opt-in with a safety screen (pregnancy, diabetes, glucose medication, under 18, history of disordered eating), private by default, optional share with an accountability partner, never scored, non-food fasts offered.",
  options: [
    { k: "private", label: "Private, unscored, with safety screen", pros: "Biblical and safe", cons: "Brothers can't see who to pray for unless shared" },
    { k: "partner", label: "Private but shareable with partner", pros: "Prayer support without public display", cons: "Slightly more to build" },
    { k: "keep", label: "Keep the public tag and point", pros: "No change", cons: "Rewards not eating; public piety" }
  ], rec: "private" },

{ id: "D11", area: "faith", blocking: true, refs: "Review E.6.2 · Q8",
  title: "Who can see a prayer request by default?",
  eli5: "When a man shares something heavy, who sees it unless he picks otherwise: just his accountability partner, the group leaders, or the whole group?",
  detail: "Prayer requests carry a visibility: private, partner, leaders or group. The author can always change it per request. Push notifications never contain the text. Also decide whether anyone other than the author may ever see private items (e.g., an elder in defined circumstances).",
  options: [
    { k: "partner", label: "Accountability partner(s) by default", pros: "Safest for honest sharing", cons: "Less group-wide prayer unless he widens it" },
    { k: "group", label: "Whole group by default", pros: "Most prayer support", cons: "Men may hold back sensitive things" },
    { k: "leaders", label: "Group leaders by default", pros: "Pastoral oversight", cons: "Can feel like reporting to a boss" }
  ], rec: "partner", why: "Author picks per request; default to the narrowest sensible audience." },

{ id: "D12", area: "faith", blocking: false, refs: "Review E.6.1 · Q11",
  title: "What may a group leader see about each man?",
  eli5: "Leaders need enough to shepherd, but not a surveillance dashboard. Should a leader see that Mark skipped devotions this week, or only that 'most of the group read'?",
  detail: "Proposed default: leaders see group-scoped activity, submissions to review and reports. They see aggregates (not individuals) for spiritual practice, and never a man's private food, weight, reflections or private prayers.",
  options: [
    { k: "aggregate", label: "Aggregates only for spiritual practice", pros: "Protects trust", cons: "Leader must ask a man directly" },
    { k: "individual", label: "Individual participation visible to leaders", pros: "Easier to follow up", cons: "Feels like monitoring; chills honesty" }
  ], rec: "aggregate" },

{ id: "D13", area: "faith", blocking: false, refs: "Review E.7.1 · Q13",
  title: "Family challenges for single, divorced, widowed and childless men",
  eli5: "Many weekly family challenges say 'your wife' or 'your kids'. A man without them can't earn those points, and a man in a hard marriage may feel shut out.",
  detail: "13 of 52 family challenges mention a wife, 9 mention children, 30 assume a household. Options: write variants (household / single / any close relationship) the group or the man can pick.",
  options: [
    { k: "variants", label: "Add variants every man can do", pros: "Inclusive; same spirit", cons: "Content work for 52 weeks" },
    { k: "keep", label: "Keep a married-father focus by design", pros: "Clear audience", cons: "Excludes men in the group today or later" }
  ], rec: "variants" },

{ id: "D14", area: "faith", blocking: false, refs: "Review E.7.2",
  title: "Streaks or a 'faithfulness calendar' with grace days?",
  eli5: "A streak says 'you failed' the day you miss. A faithfulness calendar shows the days you showed up and welcomes you back, so one sick day doesn't erase a month.",
  detail: "Today a streak needs every daily box, so missing water or steps breaks a spiritual streak. Proposal: private calendar, grace days, copy that celebrates return ('Grace covers the man who gets back up').",
  options: [
    { k: "calendar", label: "Faithfulness calendar with grace", pros: "Encourages return over perfection", cons: "Less 'don't break the chain' pressure" },
    { k: "streak", label: "Keep strict streaks", pros: "Simple, motivating for some", cons: "Shame after misses; mixes fitness into spiritual streaks" }
  ], rec: "calendar" },

{ id: "D15", area: "faith", blocking: true, refs: "review ADR-009 · Review E.7.3-4 · Q9",
  title: "Who approves devotional and theological content, and which Bible translation?",
  eli5: "Before any devotional reaches the men, who checks it is faithful to Scripture and fits our church's beliefs? And which Bible text do we show?",
  detail: "Proposal: a content review board (pastor or elder + one other reader) approves each content version; AI may flag but never approves. Default translation: Berean Standard Bible (public domain since 2023). ESV quotes in the prototype need Crossway's notice or replacement; ESV API terms are non-commercial.",
  options: [
    { k: "board", label: "Pastor/elder + reader approve; BSB default", pros: "Accountable and license-safe", cons: "Needs named reviewers' time" },
    { k: "owner", label: "Project owners approve themselves", pros: "Faster", cons: "Less pastoral oversight" },
    { k: "esv", label: "Use ESV as the default translation", pros: "Familiar to many", cons: "License notice, trademark and non-commercial API limits" }
  ], rec: "board" },

{ id: "D16", area: "faith", blocking: true, refs: "Review E.7.4, H.3 · Q4",
  title: "The 366 devotionals: who wrote them and may we publish them?",
  eli5: "We need to know whose words these are before putting them in a public app, the same as you wouldn't photocopy a book to give away.",
  detail: "Source is listed as 'Daily Devotional: 365 Days for Men' with no author or license. Launch blocker. After rights are settled: automated verse check against BSB, then 12 monthly batches reviewed by two people.",
  options: [
    { k: "ours", label: "We wrote or generated them (record it, then review all)", pros: "We own them", cons: "Every entry still needs theological review" },
    { k: "licensed", label: "They come from a book; get written permission", pros: "Keeps the content", cons: "Depends on the publisher" },
    { k: "replace", label: "Replace with new or licensed content", pros: "Clean rights", cons: "Writing effort" }
  ], rec: "ours", why: "Pick whichever is true. The point is to record the answer before launch." },

/* ---------------- Competition & proof ---------------- */
{ id: "D17", area: "competition", blocking: true, refs: "review ADR-005 · Review E.5.3",
  title: "Points kept by the server in a permanent ledger",
  eli5: "Right now each man keeps his own score book and can write anything in it. The proposal: men report what they did; the referee (server) writes the points in a ledger in pen. Corrections are added as new lines, never erased.",
  detail: "Clients submit facts, never points. Points = a pure function of facts and a versioned ruleset. Score events are append-only; retries can't double-count; challenges finalize at a deadline into a snapshot with a hash; appeals add adjustments with who and why.",
  options: [
    { k: "ledger", label: "Server ledger with versioned rules", pros: "Fair, auditable, cheat-resistant", cons: "More backend work up front" },
    { k: "server", label: "Server computes but no ledger/finalization", pros: "Simpler", cons: "Scores can still shift when rules change" },
    { k: "client", label: "Keep phone-side scoring", pros: "No work", cons: "Anyone can type any score" }
  ], rec: "ledger" },

{ id: "D18", area: "competition", blocking: true, refs: "CP-7 · Review E.5.4, E.6.3",
  title: "Do men have to prove their challenge results?",
  eli5: "Do we trust each man's word, or ask for a photo or video? Proof catches cheating but costs storage, takes leaders' time to review, and can expose homes and kids on camera.",
  detail: "Options range from honor system to required video. Recommended: honor system for regular weeks with leader spot-checks; required evidence (photo, screenshot or short clip) on gauntlet weeks 13/26/39/52 and for top-3 finishes; family challenges never require photos of wife or children. Video cost dominates at scale (D19).",
  options: [
    { k: "honor", label: "Honor system only", pros: "Trust-based brotherhood; zero review work", cons: "No way to settle disputes" },
    { k: "tiered", label: "Honor + spot checks; proof required on gauntlet weeks and top 3", pros: "Fair where it matters; light review load", cons: "Some weeks rely on trust" },
    { k: "photo", label: "Photo or screenshot required every time", pros: "Consistent", cons: "Review load every week; privacy in homes" },
    { k: "video", label: "Video required every time", pros: "Strongest proof", cons: "Highest cost, review time and privacy risk" },
    { k: "configurable", label: "Video capture built in; admins set proof none / optional / required per challenge (approved)", pros: "Proof where it matters, honor system where it doesn't", cons: "Admins must set each challenge's policy" }
  ], rec: "configurable", why: "Approved: video proof ships with the first challenge release; how often it's required is a per-challenge setting." },

{ id: "D19", area: "competition", blocking: false, refs: "review ADR-014 · Review D.5",
  title: "Video uploads in the first release?",
  eli5: "Videos are big. Storing and playing them for thousands of men is the biggest bill this app will have.",
  detail: "Cost model: at 10,000 users video roughly triples the monthly bill ($139 → $425 est.); at 100,000, $1,449 → $4,307 est., before transcoding. Recommendation: photos and screenshots only in v1; revisit video with a provider and moderation plan.",
  options: [
    { k: "later", label: "Photos only in v1; video later", pros: "Cheaper, simpler, more private", cons: "Some challenges are better shown on video" },
    { k: "now", label: "Include video in v1", pros: "Richest proof and sharing", cons: "Cost, moderation and privacy work first" }
  ], rec: "now", why: "Approved: video is supported. Cost and privacy are handled with compression, reviewer-only viewing and automatic deletion after appeals." },

{ id: "D20", area: "competition", blocking: false, refs: "CP-1 · Review E.5.2",
  title: "Replace 'flat 50 for scaled' with separate divisions",
  eli5: "Today, a man who runs a slow mile scores 46, but if he also logs an easy walk he gets 50. Trying hard scores less than taking it easy. An injured man can never score above 50. Divisions fix this: Standard, Scaled and Adaptive each have their own leaderboard.",
  detail: "Current code keeps max(flat 50, standard score). Proposal: each division ranked separately on 0-100; Adaptive covers injury and equipment alternates.",
  options: [
    { k: "divisions", label: "Standard / Scaled / Adaptive divisions", pros: "No sandbagging; injury isn't punished", cons: "Smaller fields per division" },
    { k: "keep", label: "Keep flat 50 for scaled/alternate", pros: "Already built in the prototype", cons: "Rewards doing less" },
    { k: "tiers", label: "Two difficulty levels + approved alternates with published point differences (approved)", pros: "Everyone, including injured men, can meaningfully contribute; no loophole", cons: "Point multipliers need approval (OD-03)" }
  ], rec: "tiers" },

{ id: "D21", area: "competition", blocking: false, refs: "CP-2, CP-3, CP-4",
  title: "Fair across ages and abilities: brackets or 'beat your own best'?",
  eli5: "A 25-year-old and a 60-year-old shouldn't race for the same points. Either group men by age, or score each man against his own earlier results, so getting better is what wins.",
  detail: "With ~15 men in 5 age brackets, many brackets have 1-3 men and a solo bracket scores 100. Proposals: personal-improvement scoring using the season retests already designed in; or brackets with a minimum size of 4 (merge smaller ones), frozen at season enrollment.",
  options: [
    { k: "improve", label: "Personal improvement vs own benchmark", pros: "Fair for every age and ability", cons: "Needs a baseline first" },
    { k: "brackets", label: "Age brackets, minimum 4, frozen per season", pros: "Familiar race format", cons: "Small groups still thin out" },
    { k: "current", label: "Keep current brackets (solo = 100)", pros: "No change", cons: "Free 100s; editing a birthday re-brackets history" }
  ], rec: "improve" },

{ id: "D22", area: "competition", blocking: false, refs: "CP-5 · Review E.5.1, B R6",
  title: "Personal record (PR) points",
  eli5: "Today, doing one extra set counts as a record worth 25 points, and switching from dumbbells to a barbell makes every lift a 'record'. New men score huge just for being new.",
  detail: "Proposal: weight PRs only, on the same movement and equipment variant, using estimated one-rep max with a minimum improvement; no volume PR points; the first 4 weeks set baselines.",
  options: [
    { k: "strict", label: "Real PRs only (variant-matched, e1RM, baseline period)", pros: "Rewards real progress", cons: "Fewer PR celebrations early" },
    { k: "keep", label: "Keep 25 points per weight or volume PR", pros: "Lots of celebrations", cons: "Easy to inflate; unfair to veterans" },
    { k: "none", label: "No points for PRs (celebrate only)", pros: "Removes the incentive entirely", cons: "Less motivating for some" }
  ], rec: "strict" },

{ id: "D23", area: "competition", blocking: false, refs: "CP-6",
  title: "Step bonus: cap it and trust only watch/phone data?",
  eli5: "Today you can type 200,000 steps and get 97.5 bonus points in one day, more than a week of every box.",
  detail: "Proposal: bonus capped (e.g., +5/day) and only for steps imported from Apple Health or Health Connect; manual steps can check the box but earn no bonus.",
  options: [
    { k: "cap", label: "Cap the bonus; device data only", pros: "Removes the easiest cheat", cons: "Men without a tracker get the box only" },
    { k: "keep", label: "Keep uncapped manual bonus", pros: "No change", cons: "Trivially gamed" }
  ], rec: "cap" },

{ id: "D24", area: "competition", blocking: false, refs: "CP-10",
  title: "One leaderboard per group per season",
  eli5: "Today there are two scoreboards that add things up differently, so it's unclear who's actually 'winning'.",
  detail: "Kingdom Warrior board counts daily points only; profile breakdown adds challenge points. Proposal: one canonical board per group per season with declared components (e.g., workouts + challenges; no spiritual points).",
  options: [
    { k: "one", label: "One board with declared parts", pros: "Clear and explainable", cons: "Decide what's in it" },
    { k: "two", label: "Separate daily and challenge boards", pros: "Different kinds of winners", cons: "Must be labeled clearly" },
    { k: "team", label: "Team board first (normalized for team size) + personal progress for everyone (approved)", pros: "Brotherhood over individual ranking; big teams don't win by size", cons: "Normalization formula needs approval (OD-02)" }
  ], rec: "team" },

{ id: "D25", area: "competition", blocking: false, refs: "Review E.4",
  title: "Late or offline challenge submissions",
  eli5: "If a man did the challenge Saturday at a cabin with no signal and it uploads Sunday after the deadline, does it count?",
  detail: "Proposal: counts if received by deadline + a grace period (e.g., 2 hours) and performed within the challenge week; anything uploaded more than 24 hours after it was performed is flagged for leader review. Server time decides.",
  options: [
    { k: "grace", label: "Short grace window + leader review flag", pros: "Fair to offline men; hard to abuse", cons: "Slight delay before results are final" },
    { k: "strict", label: "Hard deadline by upload time", pros: "Simple", cons: "Punishes no-signal situations" },
    { k: "trust", label: "Trust the time the man says he did it", pros: "Generous", cons: "Phone clocks can be changed" }
  ], rec: "grace" },

{ id: "D26", area: "competition", blocking: true, refs: "Review M Q3",
  title: "Will there ever be prizes, money or public cross-church rankings?",
  eli5: "If a trophy or money is on the line, the proof and review rules must be much stricter, and lawyers may need to look at it.",
  detail: "Stakes decide how heavy evidence and review must be (D18), whether finalization needs appeals and audit, and whether legal review is required for contests.",
  options: [
    { k: "none", label: "No prizes; bragging rights only", pros: "Light rules work", cons: "—" },
    { k: "small", label: "Small group prizes (a shirt, a dinner)", pros: "Fun", cons: "Needs clear finalization and appeals" },
    { k: "real", label: "Money, sponsors or public rankings", pros: "Growth potential", cons: "Strict proof, legal review, abuse handling" }
  ], rec: "none" },

{ id: "D27", area: "competition", blocking: true, refs: "Review H.8 note · Q5",
  title: "The challenge season that starts Monday, November 2",
  eli5: "The prototype's 52-week challenge starts next Monday. The new app won't be ready. Do we run it on the prototype on the honor system, run it on paper, or wait?",
  detail: "The prototype can't enforce scoring or access rules. Whatever is chosen, hide the 'Testing: change the date' setting, which lets anyone backfill days and reopen closed weeks.",
  options: [
    { k: "honor", label: "Run in the prototype on the honor system (hide test-date control)", pros: "Keeps momentum", cons: "Scores are trust-based; explain that to the men" },
    { k: "paper", label: "Run challenges on paper or a spreadsheet", pros: "Clear and fair", cons: "Less fun; manual work" },
    { k: "delay", label: "Delay Season 1 until the new app", pros: "One clean start", cons: "Loses momentum" },
    { k: "practice", label: "Seasons are configurable; run practice competitions until scoring and security tests pass (approved)", pros: "No hard-coded start date; safe launch", cons: "First real season waits for test gates" }
  ], rec: "practice" },

/* ---------------- People, data & privacy ---------------- */
{ id: "D28", area: "privacy", blocking: true, refs: "Review H.5 · Q6",
  title: "Bring over data from the prototype, or start fresh?",
  eli5: "The prototype is only days old. Moving points and posts over is a lot of work for little value. Workout history might be worth keeping, and each man can export his own.",
  detail: "Private data (food, workouts, photos) is private even from the prototype's owner, so each man must export it himself. Shared data (posts, check-ins) can be read by the owner. Proposal: fresh start for points and streaks; optional 'export my training history' so men can import PR baselines.",
  options: [
    { k: "fresh", label: "Fresh start; optional personal workout export", pros: "Clean, simple", cons: "Points and posts don't carry over" },
    { k: "all", label: "Migrate everything possible", pros: "Continuity", cons: "Significant work; identities must be re-claimed" },
    { k: "nothing", label: "Fresh start, no export", pros: "Simplest", cons: "Lose early training history" }
  ], rec: "fresh" },

{ id: "D29", area: "privacy", blocking: true, refs: "review ADR-015 · Q7",
  title: "Who can join in version 1?",
  eli5: "Starting with adult men only keeps things simple and safe. Teens or a women's program need extra privacy and legal care (for example cycle tracking), so they'd come later and be designed on purpose.",
  detail: "Proposal: 18+ with an age check at sign-up. The unmerged 'women' branch includes menstrual-cycle notes, which are especially sensitive health data needing their own privacy design.",
  options: [
    { k: "adult-men", label: "Adult men only in v1", pros: "Matches the pilot; simplest legally", cons: "Wives' or women's groups wait" },
    { k: "adults", label: "Any adult in v1", pros: "Wider reach", cons: "Women's program needs its own privacy design first" },
    { k: "youth", label: "Include teens", pros: "Father/son use", cons: "Parental consent, no DMs, legal review" }
  ], rec: "adult-men" },

{ id: "D30", area: "privacy", blocking: false, refs: "Review E.8.3",
  title: "Should hitting calorie targets earn points?",
  eli5: "Calories are self-reported and easy to fudge, and rewarding 'eating less' can push some men toward unhealthy habits.",
  detail: "Proposal: food and water logging stays personal (private), using a sourced food database instead of AI guesses; calorie and protein accuracy removed from public scoring.",
  options: [
    { k: "personal", label: "Personal only, not scored", pros: "Honest logging; safer", cons: "Less nudge for some" },
    { k: "keep", label: "Keep calorie box and protein bonus points", pros: "No change", cons: "Unverifiable; can encourage restriction" },
    { k: "bounded", label: "Small capped points for logging meals and hydration; never for eating less or losing weight (approved)", pros: "Encourages healthy habits safely", cons: "Caps need approval (OD-04)" }
  ], rec: "bounded" },

{ id: "D31", area: "privacy", blocking: false, refs: "Review E.8.5 · Q14",
  title: "Apple Health / Health Connect in the pilot?",
  eli5: "Connecting watches and phones fills in steps, weight and workouts automatically, but it adds app-store paperwork and testing.",
  detail: "The Flutter 'health' plugin covers steps, workouts, weight, water and nutrition on both platforms. Requires store health declarations and duplicate detection. Proposal: Release 2.",
  options: [
    { k: "r2", label: "Release 2", pros: "Pilot ships sooner", cons: "Manual entry at first" },
    { k: "pilot", label: "In the pilot", pros: "Less typing for the men", cons: "More store review and testing up front" }
  ], rec: "r2" },

{ id: "D32", area: "privacy", blocking: false, refs: "Review I.4",
  title: "Direct messages and group chat",
  eli5: "Private messages are where harassment and pastoral emergencies happen, and they need moderation. The feed and prayer requests may be enough for the pilot.",
  detail: "Deferred in the recommended plan. If added, needs blocking, reporting, no content in notifications and a safety escalation path.",
  options: [
    { k: "defer", label: "Not in v1; use feed + prayer", pros: "Smaller safety surface", cons: "Men use text threads meanwhile" },
    { k: "group", label: "Group chat only in v1", pros: "Brotherhood feel", cons: "Moderation load" },
    { k: "dm", label: "DMs and group chat in v1", pros: "Full social", cons: "Largest safety and moderation burden" }
  ], rec: "defer" },

/* ---------------- Running it ---------------- */
{ id: "D33", area: "ops", blocking: false, refs: "Review M Q12",
  title: "Free, donation-supported or paid?",
  eli5: "Whether we ever charge changes which Bible translations and food databases we may use, and how the app stores handle it.",
  detail: "ESV API terms are non-commercial; Open Food Facts has share-alike obligations; paid apps need store billing and account-deletion handling for subscriptions.",
  options: [
    { k: "free", label: "Free (ministry)", pros: "Simplest licensing", cons: "Costs paid by the ministry" },
    { k: "donate", label: "Free with donations", pros: "Sustainable without paywalls", cons: "Donation handling rules in stores" },
    { k: "paid", label: "Paid or subscription", pros: "Funds growth", cons: "Licensing, billing and expectations" }
  ], rec: "free" },

{ id: "D34", area: "ops", blocking: false, refs: "Review E.6.4 · Q15",
  title: "Who handles reports, account problems and incidents?",
  eli5: "When someone reports a hurtful post or can't log in, a real person must answer, and we should say how fast.",
  detail: "The release security gate needs a named owner for the moderation queue, account issues and incident response, plus a target response time.",
  options: [
    { k: "leaders", label: "Group leaders first; project owners escalate", pros: "Close to the men", cons: "Leaders need training" },
    { k: "owners", label: "Project owners handle everything", pros: "Consistent", cons: "Doesn't scale past a few groups" }
  ], rec: "leaders" },

{ id: "D35", area: "ops", blocking: false, refs: "review ADR-010",
  title: "Crash and error reporting tool",
  eli5: "When the app crashes, a tool tells the developers what broke, without seeing anyone's private data.",
  detail: "Sentry or Firebase Crashlytics, with logging that strips health values, prayer text and food. Choose before the pilot.",
  options: [
    { k: "sentry", label: "Sentry", pros: "Works across app and server; rich context", cons: "Paid beyond free tier" },
    { k: "crashlytics", label: "Firebase Crashlytics", pros: "Free", cons: "Adds a Google SDK beside Supabase" }
  ], rec: "crashlytics", why: "Firebase is now the platform, so Crashlytics keeps one vendor. Redaction rules matter more than the vendor." }
];

/* Glossary for non-developers */
var GLOSSARY = [
  ["Prototype", "The current working app inside claude.ai. A test version to learn what people want."],
  ["Backend / server", "The computer in the cloud that stores everyone's data and enforces the rules, like a referee."],
  ["Database", "Organized storage for the app's information: workouts, posts, scores."],
  ["Cloud Functions", "Small pieces of server code that run when something happens, such as scoring a finished challenge. Only they can write points."],
  ["Firebase", "Google's app backend (approved): sign-in, database (Firestore), file storage, notifications and test-build distribution."],
  ["Flutter / React Native", "Toolkits for building one app that runs on both iPhone and Android."],
  ["Offline-first", "The app works without signal and catches up later."],
  ["Outbox", "A queue of changes waiting on the phone to be sent when there's signal."],
  ["Idempotent", "Doing it twice has the same result as doing it once. Sending the same check-in twice still counts once."],
  ["Security rules", "Firebase's locks: rules checked on every read and write so each person sees only what they're allowed to. Tested automatically."],
  ["Ledger", "A permanent record of points written in pen; fixes are new lines, not erasures."],
  ["Ruleset version", "A numbered copy of the scoring rules. Changing rules makes a new version, so old results stay the same."],
  ["Finalization", "Locking a challenge's results after review so they no longer change."],
  ["ADR", "Architecture Decision Record: a short note saying what we decided, why, and what we rejected."],
  ["App Check", "A Firebase feature that makes sure requests come from our real app, not a script."],
  ["Experience Engine", "The part of the app that arranges devotional, workout and prayer steps in the order each man chooses, and never asks him to read during a lift."],
  ["PR (fitness)", "Personal record: your best on a lift. (Developers also say PR for a 'pull request', a proposed code change.)"],
  ["RPE / RIR", "Effort scales. RPE 8 of 10 means hard; RIR 2 means two more good reps were left in the tank."],
  ["Deload", "A planned easier week so the body recovers and gets stronger."],
  ["e1RM", "Estimated one-rep max, calculated from a set (e.g., 5 reps at 200 lb)."],
  ["Health Connect / HealthKit", "Android's and Apple's health data hubs (steps, weight, workouts)."],
  ["CI", "Continuous integration: robots that run every check on every code change."],
  ["Protected zone", "Parts of the code only one person may change at a time (database design, scoring rules)."],
  ["Pilot / Stage A", "The first private release for one group of 5 to 30 men."]
];

/* Reconciliation of 27 Oct 2026 (docs/architecture/00-reconciliation-matrix.md): [class, final disposition, approval needed, refs] */
var RECON = {
"D01": [
"Aligned",
"Rebuild in Flutter; the prototype is kept unchanged as the behavioral reference.",
"No",
""
],
"D02": [
"Aligned",
"Flutter/Dart approved.",
"No",
""
],
"D03": [
"Conflict → superseded",
"Firebase (approved). Supabase recommendation rejected; integrity controls moved to Firebase.",
"No",
"ADR-0003"
],
"D04": [
"Aligned + improvement",
"Drift + outbox in front of Firestore's own offline cache.",
"Library only",
"OD-08"
],
"D05": [
"Aligned + improvement",
"Group isolation now; optional organization and household layers later that grant nothing by themselves.",
"No",
"ADR-0004"
],
"D06": [
"Aligned",
"Generated programs with equivalence tests against all 1,460 existing days.",
"No",
"ADR-0007"
],
"D07": [
"Improvement",
"Specialist catalog; 2–4 active roles per change; file ownership; independent reviewers; no agent merges.",
"No",
"ADR-0015"
],
"D08": [
"Conflict → resolved",
"Integrated devotional workouts via the Experience Engine.",
"No",
"ADR-0008"
],
"D09": [
"Conflict + open",
"Participation-only, capped faith points; never content-based. Weights open.",
"Yes",
"OD-01"
],
"D10": [
"Aligned",
"Private by default; explicit sharing; unscored; safety screen.",
"No",
""
],
"D11": [
"Aligned + open",
"Author chooses the audience per request; default audience to decide.",
"Yes",
"OD-05"
],
"D12": [
"Aligned",
"No broad leader access; journals never visible.",
"No",
""
],
"D13": [
"Aligned",
"Inclusive variants for every mission.",
"No",
""
],
"D14": [
"Aligned",
"Faithfulness calendar with grace days.",
"Parameter",
"OD-21"
],
"D15": [
"Aligned",
"Content approval workflow; BSB default.",
"Reviewers",
"OD-10"
],
"D16": [
"Aligned + open",
"Rights must be settled before public release.",
"Yes",
"OD-11"
],
"D17": [
"Aligned",
"Functions-only append-only ledger; versioned rules; finalization.",
"No",
"ADR-0005"
],
"D18": [
"Conflict → resolved",
"Video capture required capability; proof policy set per challenge.",
"No",
"ADR-0010"
],
"D19": [
"Conflict → superseded",
"Video supported with compression, reviewer-only access and retention limits.",
"Retention",
"OD-06"
],
"D20": [
"Conflict → reconciled",
"Two difficulty tiers + approved alternates with published point differences.",
"Yes",
"OD-03"
],
"D21": [
"Aligned",
"Personal improvement against frozen baselines.",
"No",
""
],
"D22": [
"Aligned",
"Variant-keyed e1RM PRs with caps.",
"Cap",
"OD-18"
],
"D23": [
"Aligned",
"Capped, device-sourced steps only.",
"Cap",
"OD-14"
],
"D24": [
"Improvement",
"Team board first (normalized) with breakdowns; personal progress always on.",
"Formula",
"OD-02"
],
"D25": [
"Aligned + open",
"Server time + configurable grace; late offline attempts go to review.",
"Window",
"OD-13"
],
"D26": [
"Aligned",
"No cash or gambling-like prizes.",
"No",
""
],
"D27": [
"Superseded",
"Configurable seasons; practice competitions until tests pass.",
"Pilot date",
"OD-12"
],
"D28": [
"Aligned",
"Optional portability; not a release blocker.",
"No",
""
],
"D29": [
"Aligned + improvement",
"Adult pilot; gender- and family-neutral model; youth inactive.",
"No",
"ADR-0013"
],
"D30": [
"Conflict → resolved",
"Bounded nutrition participation points; never deficit-based.",
"Yes",
"OD-04"
],
"D31": [
"Aligned + improvement",
"Health data model now; device sync can come later.",
"No",
""
],
"D32": [
"Aligned",
"No DMs or youth messaging without a safety design.",
"No",
"ADR-0017"
],
"D33": [
"Open",
"Commercial model still to decide; budget alerts now.",
"Yes",
"OD-16"
],
"D34": [
"Aligned + open",
"Named moderation owners and response times.",
"Yes",
"OD-17"
],
"D35": [
"Superseded",
"Crashlytics with redaction.",
"No",
"ADR-0016"
]
};
