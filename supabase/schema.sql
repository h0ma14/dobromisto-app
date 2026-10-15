-- Starter Supabase schema. User clients must never set verified mission status,
-- Dobryk awards, levels, or evolution. Keep those writes in trusted server code.
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade, display_name text not null default 'Добродій', created_at timestamptz not null default now());
create table if not exists public.missions(id uuid primary key default gen_random_uuid(), title text not null, description text not null default '', category text not null, participation_type text not null, organizer text not null, reward_xp int not null default 0 check(reward_xp>=0), active boolean not null default true);
create table if not exists public.mission_registrations(id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade, mission_id uuid not null references public.missions(id), status text not null default 'registered' check(status in ('registered','pending','approved','rejected','cancelled')), registered_at timestamptz not null default now(), unique(user_id,mission_id));
create table if not exists public.mission_completions(id uuid primary key default gen_random_uuid(), registration_id uuid not null unique references public.mission_registrations(id), verified_by uuid references public.profiles(id), verified_at timestamptz, note text, check(verified_at is null or verified_by is not null));
create table if not exists public.chapters(id uuid primary key default gen_random_uuid(), slug text unique not null, title text not null, scenes jsonb not null default '[]', sort_order int not null default 0, published boolean not null default false);
create table if not exists public.chapter_progress(user_id uuid not null references public.profiles(id) on delete cascade, chapter_id uuid not null references public.chapters(id), scene_index int not null default 0, completed_at timestamptz, primary key(user_id,chapter_id));
create table if not exists public.dobryks(id uuid primary key default gen_random_uuid(), slug text unique not null, name text not null, category text not null, story jsonb not null default '{}');
create table if not exists public.user_dobryks(user_id uuid not null references public.profiles(id) on delete cascade, dobryk_id uuid not null references public.dobryks(id), level int not null default 1 check(level>=1), form text not null default 'seedling', primary key(user_id,dobryk_id));
create table if not exists public.dobryk_customizations(user_id uuid not null references public.profiles(id) on delete cascade, dobryk_id uuid not null references public.dobryks(id), customization_id text not null, primary key(user_id,dobryk_id,customization_id));
create table if not exists public.charity_campaigns(id uuid primary key default gen_random_uuid(), title text not null, organization text not null, description text not null default '', official_url text, report_url text, active boolean not null default true);
create table if not exists public.garden_items(user_id uuid not null references public.profiles(id) on delete cascade, item_id text not null, position jsonb not null default '{}', primary key(user_id,item_id));
alter table public.profiles enable row level security;
alter table public.missions enable row level security;
alter table public.mission_registrations enable row level security;
alter table public.mission_completions enable row level security;
alter table public.chapters enable row level security;
alter table public.chapter_progress enable row level security;
alter table public.dobryks enable row level security;
alter table public.user_dobryks enable row level security;
alter table public.dobryk_customizations enable row level security;
alter table public.charity_campaigns enable row level security;
alter table public.garden_items enable row level security;
create policy "read own profile" on public.profiles for select using(auth.uid()=id);
create policy "update own profile" on public.profiles for update using(auth.uid()=id) with check(auth.uid()=id);
create policy "read active missions" on public.missions for select using(active);
create policy "read published chapters" on public.chapters for select using(published);
create policy "read dobryks" on public.dobryks for select using(true);
create policy "read active campaigns" on public.charity_campaigns for select using(active);
create policy "read own registrations" on public.mission_registrations for select using(auth.uid()=user_id);
create policy "register own" on public.mission_registrations for insert with check(auth.uid()=user_id and status='registered');
create policy "read own completions" on public.mission_completions for select using(exists(select 1 from public.mission_registrations r where r.id=registration_id and r.user_id=auth.uid()));
-- No client insert/update policies for verified completion or awarded Dobryk/level state.
create policy "read own chapter progress" on public.chapter_progress for select using(auth.uid()=user_id);
create policy "read own Dobryks" on public.user_dobryks for select using(auth.uid()=user_id);
create policy "read own customization" on public.dobryk_customizations for select using(auth.uid()=user_id);
create policy "manage own garden" on public.garden_items for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
