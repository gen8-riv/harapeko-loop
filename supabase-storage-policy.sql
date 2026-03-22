-- ===================================
-- はらぺこループ Storage ポリシー
-- Supabase SQL Editor で実行してください
-- ===================================

-- 誰でも画像を閲覧できる
create policy "post-images_select" on storage.objects
  for select using (bucket_id = 'post-images');

-- ログインユーザーは画像をアップロードできる
create policy "post-images_insert" on storage.objects
  for insert with check (
    bucket_id = 'post-images'
    and auth.role() = 'authenticated'
  );

-- 自分がアップロードした画像を削除できる
create policy "post-images_delete" on storage.objects
  for delete using (
    bucket_id = 'post-images'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
