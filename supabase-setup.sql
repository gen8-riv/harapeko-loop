-- ===================================
-- はらぺこループ DB セットアップ
-- Supabase SQL Editor で実行してください
-- ===================================

-- 1. profiles テーブル
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null default '',
  avatar_emoji text not null default '😊',
  is_anonymous boolean not null default false,
  created_at timestamptz not null default now()
);

-- 2. posts テーブル
create table posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  status text not null default 'hungry' check (status in ('hungry', 'full')),
  hungry_text text not null,
  hungry_image_url text,
  full_text text,
  full_image_url text,
  hungry_at timestamptz not null default now(),
  full_at timestamptz,
  created_at timestamptz not null default now()
);

-- 3. reactions テーブル
create table reactions (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references posts(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  emoji text not null,
  target text not null check (target in ('hungry', 'full')),
  created_at timestamptz not null default now(),
  -- 同じユーザーが同じ投稿の同じターゲットに同じ絵文字は1回まで
  unique (post_id, user_id, emoji, target)
);

-- ===================================
-- Row Level Security (RLS) を有効化
-- ===================================
alter table profiles enable row level security;
alter table posts enable row level security;
alter table reactions enable row level security;

-- profiles: 誰でも読める、自分だけ更新できる
create policy "profiles_select" on profiles for select using (true);
create policy "profiles_insert" on profiles for insert with check (auth.uid() = id);
create policy "profiles_update" on profiles for update using (auth.uid() = id);

-- posts: 誰でも読める、自分だけ投稿・更新できる
create policy "posts_select" on posts for select using (true);
create policy "posts_insert" on posts for insert with check (auth.uid() = user_id);
create policy "posts_update" on posts for update using (auth.uid() = user_id);

-- reactions: 誰でも読める、自分だけ追加・削除できる
create policy "reactions_select" on reactions for select using (true);
create policy "reactions_insert" on reactions for insert with check (auth.uid() = user_id);
create policy "reactions_delete" on reactions for delete using (auth.uid() = user_id);

-- ===================================
-- インデックス（パフォーマンス用）
-- ===================================
create index idx_posts_status on posts(status);
create index idx_posts_created_at on posts(created_at desc);
create index idx_posts_user_id on posts(user_id);
create index idx_reactions_post_id on reactions(post_id);
