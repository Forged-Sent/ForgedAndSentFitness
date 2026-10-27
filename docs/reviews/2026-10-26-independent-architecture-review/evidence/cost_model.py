"""Illustrative monthly cost scenarios for Supabase Pro. NOT a quote.
Prices: supabase.com/pricing, fetched 2026-10-26 (Pro $25 incl. $10 compute credit; MAU 100k incl;
DB 8 GB incl then $0.125/GB; storage 100 GB incl then $0.0213/GB; egress 250 GB incl then $0.09/GB;
compute Micro $10, Small $15, Medium $60, Large $110, 2XL $410, 4XL $960; PITR $100 per 7 days).
Every usage figure below is an ASSUMPTION to be replaced with pilot telemetry."""
PRO, CREDIT = 25, 10
COMPUTE = {"Micro": 10, "Small": 15, "Medium": 60, "Large": 110, "2XL": 410, "4XL": 960}
A = dict(
    db_mb_per_user=1.5,          # workouts, sets, habits, logs, feed rows, indexes, per user-year
    photo_mb_per_user_month=4,   # ~8 compressed feed photos at ~0.5 MB
    video_mb_per_user_month=30,  # ~2 proof clips at ~15 MB (only if video proof ships)
    views_per_media=8,           # how many members open each media object
    months=12,                   # storage accumulates for a year (no lifecycle policy)
)
SCEN = [(100, "Micro", False), (1000, "Small", False), (10000, "Large", False), (100000, "4XL", True)]
def cost(users, tier, pitr, video):
    db_gb = users * A["db_mb_per_user"] / 1024
    media_month = users * (A["photo_mb_per_user_month"] + (A["video_mb_per_user_month"] if video else 0)) / 1024
    storage_gb = media_month * A["months"]
    egress_gb = media_month * A["views_per_media"]
    c = PRO + max(0, COMPUTE[tier] - CREDIT)
    c += max(0, db_gb - 8) * 0.125 + max(0, storage_gb - 100) * 0.0213 + max(0, egress_gb - 250) * 0.09
    c += 100 if pitr else 0
    return db_gb, storage_gb, egress_gb, c
print("| Active users | Compute (assumed) | Video proof | DB GB | Media stored GB (12 mo) | Media egress GB/mo | Est. $/mo |")
print("|---:|---|---|---:|---:|---:|---:|")
for u, t, p in SCEN:
    for v in (False, True):
        d, s, e, c = cost(u, t, p, v)
        print(f"| {u:,} | {t}{' + PITR' if p else ''} | {'yes' if v else 'no'} | {d:,.1f} | {s:,.0f} | {e:,.0f} | ${c:,.0f} |")
