-- ============================================
-- Fix demo accounts: add auth.identities, raw_user_meta_data, and demo family/child/doctor data
-- Idempotent: safe to run multiple times
-- ============================================

-- 1. Update raw_user_meta_data for demo users
UPDATE auth.users SET raw_user_meta_data = '{"role":"mother","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb
WHERE id = 'D0000000-0000-0000-0000-000000000001' AND (raw_user_meta_data IS NULL OR raw_user_meta_data = '{}'::jsonb);

UPDATE auth.users SET raw_user_meta_data = '{"role":"coordinator","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb
WHERE id = 'D0000000-0000-0000-0000-000000000002' AND (raw_user_meta_data IS NULL OR raw_user_meta_data = '{}'::jsonb);

UPDATE auth.users SET raw_user_meta_data = '{"role":"admin","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb
WHERE id = 'D0000000-0000-0000-0000-000000000003' AND (raw_user_meta_data IS NULL OR raw_user_meta_data = '{}'::jsonb);

UPDATE auth.users SET raw_user_meta_data = '{"role":"doctor","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb
WHERE id = 'D0000000-0000-0000-0000-000000000004' AND (raw_user_meta_data IS NULL OR raw_user_meta_data = '{}'::jsonb);

-- 2. Add auth.identities for demo users (required for signInWithPassword)
INSERT INTO auth.identities (id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
VALUES
('D0000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000001', 'p1@demo.kz',     'email', '{"sub":"D0000000-0000-0000-0000-000000000001","email":"p1@demo.kz","email_verified":true}'::jsonb,     now(), now(), now()),
('D0000000-0000-0000-0000-000000000002', 'D0000000-0000-0000-0000-000000000002', 'dinara@demo.kz', 'email', '{"sub":"D0000000-0000-0000-0000-000000000002","email":"dinara@demo.kz","email_verified":true}'::jsonb, now(), now(), now()),
('D0000000-0000-0000-0000-000000000003', 'D0000000-0000-0000-0000-000000000003', 'admin@demo.kz',  'email', '{"sub":"D0000000-0000-0000-0000-000000000003","email":"admin@demo.kz","email_verified":true}'::jsonb,  now(), now(), now()),
('D0000000-0000-0000-0000-000000000004', 'D0000000-0000-0000-0000-000000000004', 'doctor@demo.kz', 'email', '{"sub":"D0000000-0000-0000-0000-000000000004","email":"doctor@demo.kz","email_verified":true}'::jsonb, now(), now(), now())
ON CONFLICT (id) DO NOTHING;

-- 3. Demo family for demo-mom
INSERT INTO families (id, clinic_id, primary_parent_id, secondary_parent_id, invite_code, status, created_at, updated_at)
VALUES ('F0000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000001', NULL, 'DEMO-MOM', 'active', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 4. Demo mother profile
INSERT INTO mother_profiles (id, family_id, user_id, lmp_date, edd_date, blood_type, rh_factor, allergies, chronic_conditions, pregnancy_number, gravida, para, notes, created_at, updated_at)
VALUES ('E0000000-0000-0000-0000-000000000001', 'F0000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000001', '2025-04-10', '2026-01-15', 'A', 'positive', '{}', '{}', 1, 1, 1, 'Демо-профиль', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 5. Demo child
INSERT INTO child_profiles (id, family_id, name, dob, gender, birth_weight, birth_height, apgar_1min, apgar_5min, blood_type, allergies, photo_url, is_active, created_at, updated_at)
VALUES ('C0000000-0000-0000-0000-000000000001', 'F0000000-0000-0000-0000-000000000001', 'Амира', '2026-01-15', 'female', 3.40, 51.00, 8, 9, 'A+', '{}', NULL, true, now(), now())
ON CONFLICT (id) DO NOTHING;

-- 6. Demo doctor record
INSERT INTO doctors (id, clinic_id, user_id, specialty, bio, experience_years, consultation_fee, is_active, created_at, updated_at)
VALUES ('BD000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000004', 'Педиатр', 'Демо-врач. Педиатр первой категории, опыт работы 10 лет.', 10, 120.00, true, now(), now())
ON CONFLICT (id) DO NOTHING;
