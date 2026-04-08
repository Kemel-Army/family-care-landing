-- Migration 012: Schema Alignment Fixes
-- Expands user role CHECK, adds missing clinics columns, adds push_tokens table

-- ============================================
-- 1. Expand user role CHECK constraint to match app TypeScript types
--    Old: mother, father, grandmother, coordinator, doctor, nurse, admin, superadmin
--    New: adds gynecologist, pediatrician, clinic_admin, clinic_manager, platform_admin
-- ============================================
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (
  role IN (
    'mother', 'father', 'grandmother',
    'coordinator',
    'doctor', 'nurse', 'gynecologist', 'pediatrician',
    'clinic_admin', 'clinic_manager', 'admin', 'platform_admin', 'superadmin'
  )
);

-- ============================================
-- 2. Add review link columns to clinics
-- ============================================
ALTER TABLE clinics ADD COLUMN IF NOT EXISTS review_link_2gis TEXT;
ALTER TABLE clinics ADD COLUMN IF NOT EXISTS review_link_google TEXT;

-- ============================================
-- 3. Push tokens table (for FCM push notifications)
-- ============================================
CREATE TABLE IF NOT EXISTS push_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_push_tokens_unique ON push_tokens(user_id, token);
CREATE INDEX IF NOT EXISTS idx_push_tokens_user ON push_tokens(user_id);

ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own push tokens"
  ON push_tokens FOR ALL USING (auth.uid() = user_id);
