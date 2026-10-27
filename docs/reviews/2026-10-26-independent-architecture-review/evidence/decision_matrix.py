"""Weighted decision matrices for the Forged & Sent review. Scores 1 (poor) to 5 (strong).
Run: python3 decision_matrix.py  -> prints markdown tables. Weights sum to 100."""
crit = [  # (criterion, weight)
 ("Existing team proficiency (ASSUMPTION, see note)",10),("Two devs + AI agents can maintain it",11),("Offline-first & local DB maturity",12),("HealthKit + Health Connect",10),
 ("Long-term maintainability",10),("Developer productivity",9),("UI consistency iOS/Android",5),("Performance",4),
 ("Reliability / release stability",8),("Hiring / community / AI training data",4),("Web/admin reuse",4),
 ("Initial cost",2),("Store-review risk (Apple 4.2)",5),("Exit / lock-in",6)]
mobile = {
 "Flutter/Dart":            [4,4,5,4,4,4,5,4,4,4,2,4,5,4],
 "React Native + Expo":     [2,4,4,4,4,5,4,4,4,5,4,4,5,4],
 "KMP + native UIs":        [1,2,4,5,4,2,3,5,4,3,1,2,5,4],
 "Native Swift + Kotlin":   [2,1,4,5,4,2,2,5,5,4,1,1,5,4],
 "Capacitor / PWA":         [3,4,2,3,2,4,4,2,3,4,5,5,2,3],
}
bcrit = [("Fit for relational domain (groups, scoring, audit)",14),("Authorization model (RLS/rules) expressiveness",12),
 ("Scoring consistency / transactions",12),("Offline sync support",8),("Operational burden for 2 devs",12),
 ("Cost predictability 100->100k",8),("Exit strategy / lock-in",10),("Realtime feed/chat",5),
 ("Auth + storage + push included",8),("Analytics/reporting (SQL)",6),("AI-agent friendliness (migrations as code, local dev)",5)]
backend = {
 "Supabase (managed Postgres)":          [5,5,5,3,4,4,4,4,4,5,5],
 "Firebase / Firestore":                 [2,3,3,5,5,2,2,5,5,2,3],
 "Custom API + managed Postgres":        [5,4,5,3,2,4,5,3,2,5,4],
 "Supabase + small domain worker":       [5,5,5,3,4,4,4,4,4,5,4],
 "Self-hosted (home server/VPS)":        [5,4,5,3,1,3,5,3,2,5,3],
}
def table(c, opts, title):
    tot = sum(w for _, w in c); assert tot == 100, tot
    names = list(opts)
    print(f"\n#### {title}\n")
    print("| Criterion | Wt | " + " | ".join(names) + " |")
    print("|---|---:|" + "---:|" * len(names))
    for i, (n, w) in enumerate(c):
        print(f"| {n} | {w} | " + " | ".join(str(opts[k][i]) for k in names) + " |")
    totals = {k: sum(w * opts[k][i] for i, (_, w) in enumerate(c)) / 100 for k in names}
    print("| **Weighted total (max 5.00)** | 100 | " + " | ".join(f"**{totals[k]:.2f}**" for k in names) + " |")
    return totals
t1 = table(crit, mobile, "Mobile client")
t2 = table(bcrit, backend, "Backend and persistence")

# Sensitivity: if the team has equal React/TS and no Flutter experience
alt = {k: v[:] for k, v in mobile.items()}
alt["Flutter/Dart"][0] = 2; alt["React Native + Expo"][0] = 4
table(crit, alt, "Mobile client - sensitivity: team knows React/TS, not Flutter")
