-- =============================================================================
-- Forged & Sent: PRELIMINARY relational schema (review artifact, 2026-10-26)
-- Status: PROPOSED. Not applied anywhere. For architecture review only.
-- Target: PostgreSQL 15+ on Supabase. Auth users live in auth.users.
-- Conventions:
--   * Client-generated UUIDv7 primary keys for offline-created rows (idempotent retries).
--   * local_date + tz on every day-scoped fact; instants are timestamptz (UTC).
--   * Score-bearing tables are written ONLY by SECURITY DEFINER functions.
--   * Every public table: ENABLE + FORCE ROW LEVEL SECURITY, deny by default.
--   * visibility uses the privacy_scope enum (Section E.6.2).
-- =============================================================================

create schema if not exists app_private;
create schema if not exists content;
create schema if not exists audit;

create type privacy_scope    as enum ('private','partner','leaders','group','org');
create type group_role       as enum ('member','leader','owner');
create type membership_state as enum ('invited','active','left','removed');
create type fact_source      as enum ('manual','healthkit','health_connect','import','system');
create type session_state    as enum ('in_progress','finished','discarded');
create type set_kind         as enum ('warmup','work','extra');
create type challenge_state  as enum ('draft','scheduled','open','closed','in_review','finalized','under_appeal');
create type attempt_mode     as enum ('standard','scaled','adaptive');
create type review_status    as enum ('pending','approved','rejected','needs_info');

-- ---------------------------------------------------------------------------
-- Identity & tenancy
-- ---------------------------------------------------------------------------
create table profile (
  user_id        uuid primary key references auth.users(id) on delete cascade,
  display_name   text not null check (length(display_name) between 1 and 60),
  handle         citext unique check (handle ~ '^[a-z0-9_]{3,20}$'),   -- uniqueness enforced HERE, not client
  avatar_object  text,                                                 -- storage path, avatars bucket
  motto          text check (length(motto) <= 140),
  birth_year     smallint check (birth_year between 1900 and 2100),    -- year only; full DOB not needed
  adult_attested_at timestamptz not null,                              -- 18+ gate (E.6.4 #11)
  tz             text not null default 'America/Phoenix',
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- Organization is DEFERRED (Stage B). Adding it later = nullable FK on "group"; no rewrite.
create table "group" (
  id             uuid primary key,
  name           text not null,
  tz             text not null,                    -- deadlines are evaluated in the group's tz
  settings       jsonb not null default '{}',      -- translation, plan, prayer default scope, ...
  created_by     uuid not null references profile(user_id),
  created_at     timestamptz not null default now()
);

create table group_membership (
  group_id       uuid references "group"(id) on delete cascade,
  user_id        uuid references profile(user_id) on delete cascade,
  role           group_role not null default 'member',
  state          membership_state not null default 'invited',
  joined_at      timestamptz,
  primary key (group_id, user_id)
);

create table group_invite (
  id             uuid primary key,
  group_id       uuid not null references "group"(id) on delete cascade,
  token_hash     bytea not null unique,            -- store hash only
  created_by     uuid not null references profile(user_id),
  expires_at     timestamptz not null,
  max_uses       int not null default 1,
  used_count     int not null default 0
);

create table accountability_partner (
  user_id        uuid references profile(user_id) on delete cascade,
  partner_id     uuid references profile(user_id) on delete cascade,
  group_id       uuid not null references "group"(id) on delete cascade,
  accepted_at    timestamptz,
  primary key (user_id, partner_id, group_id),
  check (user_id <> partner_id)
);

-- ---------------------------------------------------------------------------
-- Versioned content (read-only to clients; published by platform admins)
-- ---------------------------------------------------------------------------
create table content.package (
  id             uuid primary key,
  kind           text not null check (kind in ('program','movements','devotional_plan','challenges','standards','substitutions')),
  slug           text not null,                    -- e.g. 'forged', 'forged-daily'
  version        int  not null,
  sha256         text not null,                    -- of the published artifact
  license        text not null,                    -- e.g. 'BSB public domain', 'internal'
  approved_by    uuid references profile(user_id), -- human approval (theology/fitness review)
  approved_at    timestamptz,
  published_at   timestamptz,
  unique (kind, slug, version)
);
-- Expanded rows for querying (generated by tools/fs_content from the package):
create table content.movement (id text primary key, name text not null, pattern text, muscles text[]);
create table content.movement_variant (
  id text primary key, movement_id text not null references content.movement(id),
  name text not null, equipment_setup text not null, loaded boolean not null);
create table content.substitution (
  from_variant text references content.movement_variant(id), to_variant text references content.movement_variant(id),
  reason text not null, reason_type text not null check (reason_type in ('equipment','injury')), note text,
  primary key (from_variant, to_variant, reason));
create table content.devotional (
  package_id uuid references content.package(id), day_key text, -- 'MM-DD' or plan day 'D001'
  scripture_ref text not null, translation text not null, scripture_text text not null,
  prayer text, reflect text, act text, primary key (package_id, day_key));

-- ---------------------------------------------------------------------------
-- Discipleship (private by default)
-- ---------------------------------------------------------------------------
create table devotional_completion (               -- immutable fact
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  package_id uuid not null references content.package(id), day_key text not null,
  local_date date not null, tz text not null, completed_at timestamptz not null,
  unique (user_id, package_id, day_key));
create table reflection_entry (                    -- editable by owner; never shared unless scoped
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  local_date date not null, prompt_ref text, body text not null, visibility privacy_scope not null default 'private',
  created_at timestamptz not null, updated_at timestamptz not null);
create table prayer_request (
  id uuid primary key, author_id uuid not null references profile(user_id) on delete cascade,
  group_id uuid not null references "group"(id) on delete cascade,
  visibility privacy_scope not null check (visibility in ('private','partner','leaders','group')),
  title text not null, body text, status text not null default 'open' check (status in ('open','answered','closed')),
  created_at timestamptz not null, updated_at timestamptz not null);
create table prayer_update (id uuid primary key, request_id uuid not null references prayer_request(id) on delete cascade,
  body text not null, created_at timestamptz not null);
create table prayer_commitment (                   -- "I prayed"; count visible to requester only
  request_id uuid references prayer_request(id) on delete cascade,
  user_id uuid references profile(user_id) on delete cascade, prayed_on date not null,
  primary key (request_id, user_id, prayed_on));

-- ---------------------------------------------------------------------------
-- Habits & check-ins (facts; points derived elsewhere)
-- ---------------------------------------------------------------------------
create table habit_definition (
  id uuid primary key, group_id uuid references "group"(id) on delete cascade,   -- null = personal
  owner_id uuid references profile(user_id) on delete cascade,                    -- set when personal
  title text not null, kind text not null,  -- check|water|workout|steps|weigh|devotion
  scored boolean not null default false,    -- personal habits are unscored by default
  cadence text not null default 'daily',    -- daily|weekly_rest_day
  archived_at timestamptz,
  check ((group_id is null) <> (owner_id is null)));
create table habit_checkin (                       -- immutable; "uncheck" = a retraction row
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  habit_id uuid not null references habit_definition(id),
  local_date date not null, tz text not null, source fact_source not null,
  performed_at timestamptz not null, received_at timestamptz not null default now(),
  retracted_at timestamptz,
  unique (user_id, habit_id, local_date));          -- no double completion across devices

-- ---------------------------------------------------------------------------
-- Training
-- ---------------------------------------------------------------------------
create table program_enrollment (
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  program_package_id uuid not null references content.package(id),     -- pinned version
  start_date date not null, rest_dow smallint not null check (rest_dow between 0 and 6),
  equipment_setup text not null, optional_day boolean not null default false,
  active boolean not null default true, created_at timestamptz not null);
create table schedule_override (                   -- moved/skipped/swapped; schedule itself is computed
  id uuid primary key, enrollment_id uuid not null references program_enrollment(id) on delete cascade,
  plan_day int not null, kind text not null check (kind in ('move','skip','swap')),
  new_date date, slot_id text, to_variant text references content.movement_variant(id),
  created_at timestamptz not null);
create table workout_session (                     -- aggregate root, single-writer (device lease)
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  enrollment_id uuid references program_enrollment(id), plan_day int, kind text not null default 'planned', -- planned|ad_hoc
  local_date date not null, tz text not null, state session_state not null,
  started_at timestamptz not null, finished_at timestamptz,
  lease_device_id text not null, revision int not null default 1,
  prescription_snapshot jsonb,                     -- what was prescribed at start (history survives program edits)
  perceived_effort smallint check (perceived_effort between 1 and 10), notes text,
  visibility privacy_scope not null default 'group',
  updated_at timestamptz not null);
create table session_exercise (
  id uuid primary key, session_id uuid not null references workout_session(id) on delete cascade,
  position int not null, slot_id text, variant_id text references content.movement_variant(id),
  custom_name text, substitution_reason text, unique (session_id, position));
create table set_entry (
  id uuid primary key, session_exercise_id uuid not null references session_exercise(id) on delete cascade,
  set_no int not null, kind set_kind not null,
  load_kg numeric(6,2), reps int check (reps between 0 and 500), seconds int, distance_m numeric(8,1),
  rpe_reported numeric(3,1), completed_at timestamptz, unique (session_exercise_id, set_no, kind));
create table personal_record (                     -- DERIVED, recomputable from set_entry
  user_id uuid references profile(user_id) on delete cascade, variant_id text references content.movement_variant(id),
  metric text not null check (metric in ('e1rm','max_load_at_reps','max_reps_bw','longest_hold')),
  value numeric not null, achieved_set uuid references set_entry(id), achieved_on date not null,
  primary key (user_id, variant_id, metric));

-- ---------------------------------------------------------------------------
-- Nutrition / hydration / fasting (private)
-- ---------------------------------------------------------------------------
create table food_entry (
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  local_date date not null, meal text not null check (meal in ('breakfast','lunch','dinner','snack')),
  name text not null, source text not null check (source in ('fdc','off','manual','estimate')), source_ref text,
  servings numeric(6,2) not null default 1, kcal numeric(7,1), protein_g numeric(6,1), fat_g numeric(6,1), carb_g numeric(6,1),
  created_at timestamptz not null);               -- daily totals are a VIEW, never stored
create table water_entry (id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  local_date date not null, ml int not null check (ml between 1 and 5000), source fact_source not null, created_at timestamptz not null);
create table fast_plan (user_id uuid primary key references profile(user_id) on delete cascade,
  weekly_dows smallint[] not null default '{}', dates jsonb not null default '{}', safety_ack_at timestamptz);
create table health_sample (                       -- raw imported samples, private
  id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  type text not null, start_at timestamptz not null, end_at timestamptz not null,
  value numeric not null, unit text not null, source fact_source not null,
  source_bundle text, platform_uuid text, unique (user_id, source, platform_uuid));
create table body_measurement (id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  measured_on date not null, weight_kg numeric(5,2), waist_cm numeric(5,1), source fact_source not null);
create table progress_photo (id uuid primary key, user_id uuid not null references profile(user_id) on delete cascade,
  taken_on date not null, pose text not null, object_path text not null);   -- progress-private bucket

-- ---------------------------------------------------------------------------
-- Competition
-- ---------------------------------------------------------------------------
create table ruleset (                             -- immutable once approved
  id uuid primary key, slug text not null, version int not null, body jsonb not null,  -- validated by contracts/ruleset.schema.json
  approved_by uuid references profile(user_id), approved_at timestamptz, unique (slug, version));
create table season (
  id uuid primary key, group_id uuid not null references "group"(id) on delete cascade,
  name text not null, starts_on date not null, ends_on date not null, ruleset_id uuid not null references ruleset(id));
create table season_enrollment (                   -- bracket frozen here (CP-4)
  season_id uuid references season(id) on delete cascade, user_id uuid references profile(user_id) on delete cascade,
  bracket text, team_id uuid, enrolled_at timestamptz not null, primary key (season_id, user_id));
create table team (id uuid primary key, season_id uuid not null references season(id) on delete cascade, name text not null);
create table challenge_instance (
  id uuid primary key, season_id uuid not null references season(id) on delete cascade,
  definition_ref text not null,                    -- e.g. 'w01-endure' in a challenges package
  package_id uuid not null references content.package(id),
  opens_at timestamptz not null, closes_at timestamptz not null, review_until timestamptz not null,
  state challenge_state not null default 'scheduled', ruleset_id uuid not null references ruleset(id));
create table challenge_attempt (                   -- immutable fact; corrections = new attempt + review
  id uuid primary key, instance_id uuid not null references challenge_instance(id),
  user_id uuid not null references profile(user_id) on delete cascade,
  mode attempt_mode not null, value numeric, value2 numeric, unit text not null, variant_note text,
  performed_at timestamptz not null, received_at timestamptz not null default now(),
  note text, withdrawn_at timestamptz);
create table evidence_object (id uuid primary key, attempt_id uuid not null references challenge_attempt(id) on delete cascade,
  object_path text not null, media_type text not null, bytes int not null, sha256 text not null);
create table review_decision (id uuid primary key, attempt_id uuid not null references challenge_attempt(id) on delete cascade,
  reviewer_id uuid not null references profile(user_id), status review_status not null, reason text, decided_at timestamptz not null);
create table score_event (                         -- APPEND-ONLY ledger
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profile(user_id) on delete cascade, group_id uuid not null references "group"(id),
  season_id uuid references season(id), kind text not null, points numeric(8,2) not null,
  source_type text not null, source_id uuid not null, rule_version int not null,
  supersedes uuid references score_event(id), created_at timestamptz not null default now(),
  unique (source_type, source_id, rule_version, kind));
create table score_adjustment (id uuid primary key, score_event_id uuid references score_event(id),
  user_id uuid not null references profile(user_id), delta numeric(8,2) not null, reason text not null,
  actor_id uuid not null references profile(user_id), approved_by uuid references profile(user_id), created_at timestamptz not null default now());
create table standings_snapshot (                  -- frozen at finalization
  id uuid primary key, instance_id uuid references challenge_instance(id), season_id uuid references season(id),
  taken_at timestamptz not null, rows jsonb not null, sha256 text not null);

-- ---------------------------------------------------------------------------
-- Social, moderation, notifications
-- ---------------------------------------------------------------------------
create table post (id uuid primary key, group_id uuid not null references "group"(id) on delete cascade,
  author_id uuid references profile(user_id) on delete set null,   -- tombstone on account deletion
  kind text not null default 'text', body text check (length(body) <= 2000), workout_session_id uuid references workout_session(id) on delete set null,
  created_at timestamptz not null, edited_at timestamptz, removed_at timestamptz, removed_by uuid);
create table comment (id uuid primary key, post_id uuid not null references post(id) on delete cascade,
  author_id uuid references profile(user_id) on delete set null, body text not null check (length(body) <= 1000),
  created_at timestamptz not null, edited_at timestamptz, removed_at timestamptz);
create table reaction (post_id uuid references post(id) on delete cascade, user_id uuid references profile(user_id) on delete cascade,
  kind text not null check (kind in ('strong','brother')), primary key (post_id, user_id));
create table media_object (id uuid primary key, owner_id uuid references profile(user_id) on delete cascade,
  bucket text not null, path text not null unique, media_type text not null, bytes int not null, sha256 text not null,
  post_id uuid references post(id) on delete cascade, created_at timestamptz not null);
create table block (blocker_id uuid references profile(user_id) on delete cascade, blocked_id uuid references profile(user_id) on delete cascade,
  created_at timestamptz not null default now(), primary key (blocker_id, blocked_id));
create table report (id uuid primary key, group_id uuid not null references "group"(id), reporter_id uuid references profile(user_id) on delete set null,
  target_type text not null, target_id uuid not null, reason text not null, created_at timestamptz not null default now(),
  status text not null default 'open' check (status in ('open','actioned','dismissed')));
create table moderation_action (id uuid primary key, report_id uuid references report(id), actor_id uuid not null references profile(user_id),
  action text not null check (action in ('remove','warn','mute','remove_member','dismiss')), note text, created_at timestamptz not null default now());
create table push_token (user_id uuid references profile(user_id) on delete cascade, token text not null, platform text not null,
  updated_at timestamptz not null, primary key (user_id, token));
create table feature_flag (key text, group_id uuid references "group"(id), enabled boolean not null, primary key (key, group_id));
create table audit.audit_log (id bigint generated always as identity primary key, at timestamptz not null default now(),
  actor_id uuid, action text not null, target_type text, target_id uuid, correlation_id uuid, detail jsonb);

-- ---------------------------------------------------------------------------
-- RLS sketches (illustrative; full policy set is a Phase 2 deliverable)
-- ---------------------------------------------------------------------------
create or replace function app_private.is_member(g uuid) returns boolean
  language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.group_membership m
                 where m.group_id = g and m.user_id = auth.uid() and m.state = 'active') $$;
create or replace function app_private.is_leader(g uuid) returns boolean
  language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.group_membership m
                 where m.group_id = g and m.user_id = auth.uid() and m.state = 'active' and m.role in ('leader','owner')) $$;

alter table habit_checkin enable row level security;  alter table habit_checkin force row level security;
create policy hc_owner_read  on habit_checkin for select using (user_id = auth.uid());
-- inserts only via app_private.submit_checkin(); no direct insert/update/delete policy for clients

alter table prayer_request enable row level security; alter table prayer_request force row level security;
create policy pr_read on prayer_request for select using (
     author_id = auth.uid()
  or (visibility = 'group'   and app_private.is_member(group_id))
  or (visibility = 'leaders' and app_private.is_leader(group_id))
  or (visibility = 'partner' and exists (select 1 from accountability_partner ap
                                         where ap.user_id = prayer_request.author_id and ap.partner_id = auth.uid()
                                           and ap.group_id = prayer_request.group_id and ap.accepted_at is not null)));
create policy pr_write on prayer_request for all using (author_id = auth.uid()) with check (author_id = auth.uid());

alter table score_event enable row level security; alter table score_event force row level security;
create policy se_read on score_event for select using (user_id = auth.uid() or app_private.is_member(group_id));
-- no insert/update/delete policies: written only by SECURITY DEFINER scoring functions

-- Idempotent command example (sketch)
create or replace function app_private.submit_checkin(p_id uuid, p_habit uuid, p_local_date date, p_tz text,
  p_source fact_source, p_performed_at timestamptz) returns uuid
  language plpgsql security definer set search_path = '' as $$
declare v_today date := (now() at time zone p_tz)::date;
begin
  if p_local_date not between v_today - 1 and v_today then
    raise exception 'checkin date out of window' using errcode = '22023';
  end if;
  insert into public.habit_checkin(id, user_id, habit_id, local_date, tz, source, performed_at)
  values (p_id, auth.uid(), p_habit, p_local_date, p_tz, p_source, p_performed_at)
  on conflict do nothing;                 -- retry-safe (pk) and duplicate-safe (user,habit,date)
  -- perform app_private.evaluate_checkin(p_id);  -- writes score_event under current ruleset, idempotently
  return p_id;
end $$;
