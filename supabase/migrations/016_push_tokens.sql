-- ============================================
-- Migration 016: Push Tokens table for FCM
-- ============================================

CREATE TABLE IF NOT EXISTS push_tokens (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token       text NOT NULL,
  platform    text NOT NULL CHECK (platform IN ('web', 'android', 'ios')),
  device_name text,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);

-- One active token per device per user
CREATE UNIQUE INDEX idx_push_tokens_user_token ON push_tokens (user_id, token);
CREATE INDEX idx_push_tokens_user_active ON push_tokens (user_id) WHERE is_active = true;

-- RLS
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- Users can manage their own tokens
CREATE POLICY "Users manage own push tokens"
  ON push_tokens FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Service role (Edge Functions) can read all tokens
CREATE POLICY "Service role reads all push tokens"
  ON push_tokens FOR SELECT
  USING (auth.role() = 'service_role');
