create extension if not exists citext; create extension if not exists pgcrypto;
create schema auth; create table auth.users(id uuid primary key);
create function auth.uid() returns uuid language sql stable as $$ select null::uuid $$;
