---
name: fs-db-migration
description: Create a Supabase/Postgres migration for Forged & Sent with RLS policies, pgTAP tests and regenerated client types. Use for any new table, column, index, function, policy or storage policy. Protected zone - requires the contract-change label and an ADR id.
---
# Database migration

1. New file only: `supabase migration new <slug>`. Never edit a merged migration. Renames use expand → migrate → contract across releases.
2. Every table: primary key (client UUIDv7 for offline-created rows), `created_at`, `updated_at` where mutable,
   `enable row level security; force row level security;` and explicit policies. No policy = no access, by design.
3. Score-bearing or deadline-dependent writes go through a `security definer set search_path = ''` function in `app_private`, idempotent on the client id (`on conflict do nothing`).
4. Add pgTAP tests in `supabase/tests/rls/<table>.sql` for every role (owner, other member, leader, non-member, anon) × select/insert/update/delete.
   Update `docs/rules/rls-matrix.yaml` if roles or scopes change (protected: human approval).
5. `supabase db reset && supabase test db` must pass. Regenerate types and commit them; CI fails if regeneration produces a diff.
6. PR body: ADR id, data classification of new columns (private/partner/leaders/group), deletion behavior (cascade/tombstone), and backfill plan.
