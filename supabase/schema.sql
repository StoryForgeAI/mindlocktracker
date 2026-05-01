create table if not exists user_profiles (
  id uuid primary key,
  email text,
  onboarding_complete boolean default false,
  goal text,
  lock_interval_minutes int,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists usage_logs (
  id bigint generated always as identity primary key,
  user_id uuid references user_profiles(id) on delete cascade,
  package_name text not null,
  minutes int not null default 0,
  created_at timestamptz default now()
);

create table if not exists blocked_apps (
  id bigint generated always as identity primary key,
  user_id uuid references user_profiles(id) on delete cascade,
  packages text[] not null default '{}',
  updated_at timestamptz default now()
);

create table if not exists session_stats (
  id bigint generated always as identity primary key,
  user_id uuid references user_profiles(id) on delete cascade,
  focus_score int not null default 0,
  blocked_attempts int not null default 0,
  streak_days int not null default 0,
  created_at timestamptz default now()
);
