-- ===================================
-- はらぺこループ Phase 2 バグ修正
-- 既存の Supabase プロジェクトに追加で実行してください
-- ===================================

drop policy if exists "profiles_delete" on profiles;
create policy "profiles_delete" on profiles
  for delete using (auth.uid() = id);

drop policy if exists "posts_delete" on posts;
create policy "posts_delete" on posts
  for delete using (auth.uid() = user_id);
