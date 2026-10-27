"""Illustrative monthly Firebase cost for Forged & Sent. NOT a quote.
Prices fetched 2026-10-26: Firestore $0.03/100k reads, $0.09/100k writes beyond 50k reads/day & 20k writes/day free;
Functions 2M invocations/month free then $0.40/M (compute excluded); Storage ~$0.02/GiB-month beyond 5 GB;
egress $0.12/GiB. All usage numbers are ASSUMPTIONS to replace with pilot telemetry."""
A = dict(reads_per_user_day=250, writes_per_user_day=40, fn_calls_per_user_day=8,
         photo_mb_month=4, photo_views=8, photo_retention_months=12,
         video_mb_month=30, video_views=2, video_retention_months=2)
def month(users, video):
    r = max(0, users * A["reads_per_user_day"] - 50_000) * 30 / 1e5 * 0.03
    w = max(0, users * A["writes_per_user_day"] - 20_000) * 30 / 1e5 * 0.09
    f = max(0, users * A["fn_calls_per_user_day"] * 30 - 2e6) / 1e6 * 0.40
    stored = users * (A["photo_mb_month"] * A["photo_retention_months"] + (A["video_mb_month"] * A["video_retention_months"] if video else 0)) / 1024
    s = max(0, stored - 5) * 0.02
    eg = users * (A["photo_mb_month"] * A["photo_views"] + (A["video_mb_month"] * A["video_views"] if video else 0)) / 1024 * 0.12
    return r, w, f, s, eg, stored
print("Assumptions:", A)
print("| Active users | Video proof | Reads $ | Writes $ | Functions $ | Storage $ (GiB) | Egress $ | Total $/mo |")
print("|---:|---|---:|---:|---:|---:|---:|---:|")
for u in (100, 1000, 10000, 100000):
    for v in (False, True):
        r, w, f, s, eg, st = month(u, v)
        print(f"| {u:,} | {'yes' if v else 'no'} | {r:,.0f} | {w:,.0f} | {f:,.0f} | {s:,.0f} ({st:,.0f}) | {eg:,.0f} | **{r+w+f+s+eg:,.0f}** |")
