
#### Mobile client

| Criterion | Wt | Flutter/Dart | React Native + Expo | KMP + native UIs | Native Swift + Kotlin | Capacitor / PWA |
|---|---:|---:|---:|---:|---:|---:|
| Existing team proficiency (ASSUMPTION, see note) | 10 | 4 | 2 | 1 | 2 | 3 |
| Two devs + AI agents can maintain it | 11 | 4 | 4 | 2 | 1 | 4 |
| Offline-first & local DB maturity | 12 | 5 | 4 | 4 | 4 | 2 |
| HealthKit + Health Connect | 10 | 4 | 4 | 5 | 5 | 3 |
| Long-term maintainability | 10 | 4 | 4 | 4 | 4 | 2 |
| Developer productivity | 9 | 4 | 5 | 2 | 2 | 4 |
| UI consistency iOS/Android | 5 | 5 | 4 | 3 | 2 | 4 |
| Performance | 4 | 4 | 4 | 5 | 5 | 2 |
| Reliability / release stability | 8 | 4 | 4 | 4 | 5 | 3 |
| Hiring / community / AI training data | 4 | 4 | 5 | 3 | 4 | 4 |
| Web/admin reuse | 4 | 2 | 4 | 1 | 1 | 5 |
| Initial cost | 2 | 4 | 4 | 2 | 1 | 5 |
| Store-review risk (Apple 4.2) | 5 | 5 | 5 | 5 | 5 | 2 |
| Exit / lock-in | 6 | 4 | 4 | 4 | 4 | 3 |
| **Weighted total (max 5.00)** | 100 | **4.14** | **3.98** | **3.24** | **3.28** | **3.10** |

#### Backend and persistence

| Criterion | Wt | Supabase (managed Postgres) | Firebase / Firestore | Custom API + managed Postgres | Supabase + small domain worker | Self-hosted (home server/VPS) |
|---|---:|---:|---:|---:|---:|---:|
| Fit for relational domain (groups, scoring, audit) | 14 | 5 | 2 | 5 | 5 | 5 |
| Authorization model (RLS/rules) expressiveness | 12 | 5 | 3 | 4 | 5 | 4 |
| Scoring consistency / transactions | 12 | 5 | 3 | 5 | 5 | 5 |
| Offline sync support | 8 | 3 | 5 | 3 | 3 | 3 |
| Operational burden for 2 devs | 12 | 4 | 5 | 2 | 4 | 1 |
| Cost predictability 100->100k | 8 | 4 | 2 | 4 | 4 | 3 |
| Exit strategy / lock-in | 10 | 4 | 2 | 5 | 4 | 5 |
| Realtime feed/chat | 5 | 4 | 5 | 3 | 4 | 3 |
| Auth + storage + push included | 8 | 4 | 5 | 2 | 4 | 2 |
| Analytics/reporting (SQL) | 6 | 5 | 2 | 5 | 5 | 5 |
| AI-agent friendliness (migrations as code, local dev) | 5 | 5 | 3 | 4 | 4 | 3 |
| **Weighted total (max 5.00)** | 100 | **4.41** | **3.28** | **3.89** | **4.36** | **3.64** |

#### Mobile client - sensitivity: team knows React/TS, not Flutter

| Criterion | Wt | Flutter/Dart | React Native + Expo | KMP + native UIs | Native Swift + Kotlin | Capacitor / PWA |
|---|---:|---:|---:|---:|---:|---:|
| Existing team proficiency (ASSUMPTION, see note) | 10 | 2 | 4 | 1 | 2 | 3 |
| Two devs + AI agents can maintain it | 11 | 4 | 4 | 2 | 1 | 4 |
| Offline-first & local DB maturity | 12 | 5 | 4 | 4 | 4 | 2 |
| HealthKit + Health Connect | 10 | 4 | 4 | 5 | 5 | 3 |
| Long-term maintainability | 10 | 4 | 4 | 4 | 4 | 2 |
| Developer productivity | 9 | 4 | 5 | 2 | 2 | 4 |
| UI consistency iOS/Android | 5 | 5 | 4 | 3 | 2 | 4 |
| Performance | 4 | 4 | 4 | 5 | 5 | 2 |
| Reliability / release stability | 8 | 4 | 4 | 4 | 5 | 3 |
| Hiring / community / AI training data | 4 | 4 | 5 | 3 | 4 | 4 |
| Web/admin reuse | 4 | 2 | 4 | 1 | 1 | 5 |
| Initial cost | 2 | 4 | 4 | 2 | 1 | 5 |
| Store-review risk (Apple 4.2) | 5 | 5 | 5 | 5 | 5 | 2 |
| Exit / lock-in | 6 | 4 | 4 | 4 | 4 | 3 |
| **Weighted total (max 5.00)** | 100 | **3.94** | **4.18** | **3.24** | **3.28** | **3.10** |
