
-- CourseMate V2: Certificates Locker
-- Review the course ID type before running.

CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  course_title TEXT,
  title TEXT NOT NULL,
  issuer TEXT NOT NULL,
  issue_date DATE,
  file_url TEXT,
  storage_path TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

-- Recreate this policy safely.
DROP POLICY IF EXISTS "Users can manage own certificates"
ON public.certificates;

CREATE POLICY "Users can manage own certificates"
ON public.certificates
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_certificates_user_id
ON public.certificates(user_id);

CREATE INDEX IF NOT EXISTS idx_certificates_course_id
ON public.certificates(course_id);

-- Private certificate storage bucket.
INSERT INTO storage.buckets (id, name, public)
VALUES ('certificates', 'certificates', false)
ON CONFLICT (id) DO NOTHING;

-- Recreate policies to avoid duplicate-policy errors.
DROP POLICY IF EXISTS "Users can upload own certificate files"
ON storage.objects;

DROP POLICY IF EXISTS "Users can view own certificate files"
ON storage.objects;

DROP POLICY IF EXISTS "Users can update own certificate files"
ON storage.objects;

DROP POLICY IF EXISTS "Users can delete own certificate files"
ON storage.objects;

CREATE POLICY "Users can upload own certificate files"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
  bucket_id = 'certificates'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view own certificate files"
ON storage.objects
FOR SELECT TO authenticated
USING (
  bucket_id = 'certificates'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update own certificate files"
ON storage.objects
FOR UPDATE TO authenticated
USING (
  bucket_id = 'certificates'
  AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'certificates'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete own certificate files"
ON storage.objects
FOR DELETE TO authenticated
USING (
  bucket_id = 'certificates'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
