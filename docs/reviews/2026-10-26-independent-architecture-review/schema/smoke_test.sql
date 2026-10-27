create or replace function auth.uid() returns uuid language sql stable as $$ select '00000000-0000-0000-0000-000000000001'::uuid $$;
insert into auth.users values ('00000000-0000-0000-0000-000000000001');
insert into profile(user_id, display_name, adult_attested_at) values (auth.uid(),'Test', now());
insert into habit_definition(id, owner_id, title, kind) values ('00000000-0000-0000-0000-0000000000aa', auth.uid(), 'Water', 'water');
select app_private.submit_checkin('00000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000000aa',(now() at time zone 'America/Phoenix')::date,'America/Phoenix','manual',now());
select app_private.submit_checkin('00000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000000aa',(now() at time zone 'America/Phoenix')::date,'America/Phoenix','manual',now()); -- retry
select app_private.submit_checkin('00000000-0000-0000-0000-0000000000c2','00000000-0000-0000-0000-0000000000aa',(now() at time zone 'America/Phoenix')::date,'America/Phoenix','manual',now()); -- 2nd device
select count(*) as rows_after_retry_and_second_device from habit_checkin;
\set ON_ERROR_STOP 0
select app_private.submit_checkin(gen_random_uuid(),'00000000-0000-0000-0000-0000000000aa','2026-01-01','America/Phoenix','manual',now()); -- backdate
-- Result on PostgreSQL 16 (2026-10-26): DDL applied cleanly (44 public tables, 4 policies);
-- retry + second-device check-in -> 1 row; backdated check-in -> ERROR 'checkin date out of window'.
