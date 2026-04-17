-- ============================================
-- SEED 01: Core Data (auth.users, clinics, users, families, mother_profiles, child_profiles, consents)
-- ============================================
BEGIN;

-- ============================================
-- 0. DEMO ACCOUNTS (4 records — used by /api/auth/demo-login)
-- ============================================
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', 'D0000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'p1@demo.kz',      crypt('DemoPass123!', gen_salt('bf')), now(), '{"role":"mother","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb,      now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'D0000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'dinara@demo.kz',  crypt('DemoPass123!', gen_salt('bf')), now(), '{"role":"coordinator","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb, now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'D0000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'admin@demo.kz',   crypt('DemoPass123!', gen_salt('bf')), now(), '{"role":"admin","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb,       now(), now(), '', '', '', ''),
('00000000-0000-0000-0000-000000000000', 'D0000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'doctor@demo.kz',  crypt('DemoPass123!', gen_salt('bf')), now(), '{"role":"doctor","clinic_id":"10000000-0000-0000-0000-000000000001"}'::jsonb,      now(), now(), '', '', '', '');

-- auth.identities required for signInWithPassword to work
INSERT INTO auth.identities (id, user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
VALUES
('D0000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000001', 'p1@demo.kz',     'email', '{"sub":"D0000000-0000-0000-0000-000000000001","email":"p1@demo.kz","email_verified":true}'::jsonb,     now(), now(), now()),
('D0000000-0000-0000-0000-000000000002', 'D0000000-0000-0000-0000-000000000002', 'dinara@demo.kz', 'email', '{"sub":"D0000000-0000-0000-0000-000000000002","email":"dinara@demo.kz","email_verified":true}'::jsonb, now(), now(), now()),
('D0000000-0000-0000-0000-000000000003', 'D0000000-0000-0000-0000-000000000003', 'admin@demo.kz',  'email', '{"sub":"D0000000-0000-0000-0000-000000000003","email":"admin@demo.kz","email_verified":true}'::jsonb,  now(), now(), now()),
('D0000000-0000-0000-0000-000000000004', 'D0000000-0000-0000-0000-000000000004', 'doctor@demo.kz', 'email', '{"sub":"D0000000-0000-0000-0000-000000000004","email":"doctor@demo.kz","email_verified":true}'::jsonb, now(), now(), now());

INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('D0000000-0000-0000-0000-000000000001', 'p1@demo.kz',      '+77000000001', 'mother',      '10000000-0000-0000-0000-000000000001', 'Айгерим',  'Демо',     NULL, true, now(), now(), now()),
('D0000000-0000-0000-0000-000000000002', 'dinara@demo.kz',  '+77000000002', 'coordinator', '10000000-0000-0000-0000-000000000001', 'Динара',   'Демо',     NULL, true, now(), now(), now()),
('D0000000-0000-0000-0000-000000000003', 'admin@demo.kz',   '+77000000003', 'admin',       '10000000-0000-0000-0000-000000000001', 'Аскар',    'Демо',     NULL, true, now(), now(), now()),
('D0000000-0000-0000-0000-000000000004', 'doctor@demo.kz',  '+77000000004', 'doctor',      '10000000-0000-0000-0000-000000000001', 'Сауле',    'Демо',     NULL, true, now(), now(), now());

-- Demo family for demo-mom (Айгерим)
INSERT INTO families (id, clinic_id, primary_parent_id, secondary_parent_id, invite_code, status, created_at, updated_at)
VALUES
('F0000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000001', NULL, 'DEMO-MOM', 'active', now(), now());

INSERT INTO mother_profiles (id, family_id, user_id, lmp_date, edd_date, blood_type, rh_factor, allergies, chronic_conditions, pregnancy_number, gravida, para, notes, created_at, updated_at)
VALUES
('E0000000-0000-0000-0000-000000000001', 'F0000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000001',
 '2025-04-10', '2026-01-15', 'A', 'positive', '{}', '{}', 1, 1, 1, 'Демо-профиль', now(), now());

INSERT INTO child_profiles (id, family_id, name, dob, gender, birth_weight, birth_height, apgar_1min, apgar_5min, blood_type, allergies, photo_url, is_active, created_at, updated_at)
VALUES
('C0000000-0000-0000-0000-000000000001', 'F0000000-0000-0000-0000-000000000001', 'Амира', '2026-01-15', 'female', 3.40, 51.00, 8, 9, 'A+', '{}', NULL, true, now(), now());

-- Demo doctor record for demo-doctor (Сауле)
INSERT INTO doctors (id, clinic_id, user_id, specialty, bio, experience_years, consultation_fee, is_active, created_at, updated_at)
VALUES
('BD000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'D0000000-0000-0000-0000-000000000004',
 'Педиатр', 'Демо-врач. Педиатр первой категории, опыт работы 10 лет.', 10, 120.00, true, now(), now());

-- ============================================
-- 1. AUTH.USERS (48 records)
-- ============================================

-- Mothers (20)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'aigul01@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '730 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'dana02@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '545 days', CURRENT_TIMESTAMP - INTERVAL '545 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'asel03@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '150 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'madina04@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '365 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'kamila05@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '365 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated', 'gulnara06@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '455 days', CURRENT_TIMESTAMP - INTERVAL '455 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000007', 'authenticated', 'authenticated', 'dinara07@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '790 days', CURRENT_TIMESTAMP - INTERVAL '790 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000008', 'authenticated', 'authenticated', 'tomiris08@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_TIMESTAMP - INTERVAL '90 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000009', 'authenticated', 'authenticated', 'zhanna09@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '395 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000010', 'authenticated', 'authenticated', 'lyazzat10@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '300 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000011', 'authenticated', 'authenticated', 'aliya11@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '670 days', CURRENT_TIMESTAMP - INTERVAL '670 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000012', 'authenticated', 'authenticated', 'sabina12@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '210 days', CURRENT_TIMESTAMP - INTERVAL '210 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000013', 'authenticated', 'authenticated', 'karina13@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '365 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000014', 'authenticated', 'authenticated', 'nurgul14@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '850 days', CURRENT_TIMESTAMP - INTERVAL '850 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000015', 'authenticated', 'authenticated', 'ayaulym15@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '330 days', CURRENT_TIMESTAMP - INTERVAL '330 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000016', 'authenticated', 'authenticated', 'fariza16@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_TIMESTAMP - INTERVAL '60 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000017', 'authenticated', 'authenticated', 'adina17@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '515 days', CURRENT_TIMESTAMP - INTERVAL '515 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000018', 'authenticated', 'authenticated', 'saltanat18@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '270 days', CURRENT_TIMESTAMP - INTERVAL '270 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000019', 'authenticated', 'authenticated', 'dariga19@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '608 days', CURRENT_TIMESTAMP - INTERVAL '608 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '20000000-0000-0000-0000-000000000020', 'authenticated', 'authenticated', 'inzhu20@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '120 days', '', '', '', '');

-- Fathers (10)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'nurlan01@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '730 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'erzhan02@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '545 days', CURRENT_TIMESTAMP - INTERVAL '545 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'arman03@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '150 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'damir04@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '365 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'timur05@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '365 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated', 'bauyrzhan06@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '455 days', CURRENT_TIMESTAMP - INTERVAL '455 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000007', 'authenticated', 'authenticated', 'daniyar07@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '790 days', CURRENT_TIMESTAMP - INTERVAL '790 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000008', 'authenticated', 'authenticated', 'askhat08@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_TIMESTAMP - INTERVAL '90 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000009', 'authenticated', 'authenticated', 'alikhan09@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '395 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '30000000-0000-0000-0000-000000000010', 'authenticated', 'authenticated', 'ruslan10@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '300 days', '', '', '', '');

-- Doctors (8)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'saule.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'botagoz.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'erzhan.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'laura.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000005', 'authenticated', 'authenticated', 'marat.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000006', 'authenticated', 'authenticated', 'anara.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000007', 'authenticated', 'authenticated', 'darya.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '600 days', CURRENT_TIMESTAMP - INTERVAL '600 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '40000000-0000-0000-0000-000000000008', 'authenticated', 'authenticated', 'alexey.dr@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '600 days', CURRENT_TIMESTAMP - INTERVAL '600 days', '', '', '', '');

-- Coordinators (3)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', '50000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'moldir.co@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '50000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'ainur.co@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '50000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'botakoz.co@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '600 days', CURRENT_TIMESTAMP - INTERVAL '600 days', '', '', '', '');

-- Nurses (4)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', '60000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'gulmira.nu@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '60000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'bayan.nu@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '60000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'nurzhamal.nu@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '60000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'azhar.nu@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '600 days', CURRENT_TIMESTAMP - INTERVAL '600 days', '', '', '', '');

-- Admins (3)
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES
('00000000-0000-0000-0000-000000000000', '70000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'askar.ad@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1000 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '70000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'erbolat.ad@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '600 days', CURRENT_TIMESTAMP - INTERVAL '600 days', '', '', '', ''),
('00000000-0000-0000-0000-000000000000', '70000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'maksat.sa@example.com', crypt('password123', gen_salt('bf')), now(), CURRENT_TIMESTAMP - INTERVAL '1100 days', CURRENT_TIMESTAMP - INTERVAL '1100 days', '', '', '', '');

-- ============================================
-- 2. CLINICS (3 records)
-- ============================================
INSERT INTO clinics (id, name, slug, logo_url, theme_json, settings_json, timezone, phone, address, is_active, created_at, updated_at)
VALUES
(
  '10000000-0000-0000-0000-000000000001',
  'MediFamily Almaty',
  'medifamily-almaty',
  '/logos/medifamily.svg',
  '{"primaryColor": "#2563EB", "accentColor": "#10B981", "fontFamily": "Inter"}',
  '{"features": {"ai_assistant": true, "video_calls": true, "whatsapp": true}, "working_hours": {"start": "08:00", "end": "20:00"}, "appointment_duration": 30}',
  'Asia/Almaty',
  '+7 727 312 4567',
  'ул. Абая 52, Алматы, 050000',
  true,
  CURRENT_TIMESTAMP - INTERVAL '1100 days',
  CURRENT_TIMESTAMP - INTERVAL '1 day'
),
(
  '10000000-0000-0000-0000-000000000002',
  'BabyBest Astana',
  'babybest-astana',
  '/logos/babybest.svg',
  '{"primaryColor": "#7C3AED", "accentColor": "#F59E0B", "fontFamily": "Inter"}',
  '{"features": {"ai_assistant": true, "video_calls": true, "whatsapp": false}, "working_hours": {"start": "09:00", "end": "19:00"}, "appointment_duration": 25}',
  'Asia/Almaty',
  '+7 717 250 8899',
  'пр. Мангилик Ел 34, Астана, 010000',
  true,
  CURRENT_TIMESTAMP - INTERVAL '700 days',
  CURRENT_TIMESTAMP - INTERVAL '1 day'
),
(
  '10000000-0000-0000-0000-000000000003',
  'CareKids Shymkent',
  'carekids-shymkent',
  '/logos/carekids.svg',
  '{"primaryColor": "#059669", "accentColor": "#EF4444", "fontFamily": "Roboto"}',
  '{"features": {"ai_assistant": false, "video_calls": true, "whatsapp": true}, "working_hours": {"start": "08:30", "end": "18:30"}, "appointment_duration": 20}',
  'Asia/Almaty',
  '+7 725 444 7712',
  'ул. Тауке хана 12, Шымкент, 160000',
  true,
  CURRENT_TIMESTAMP - INTERVAL '400 days',
  CURRENT_TIMESTAMP - INTERVAL '1 day'
);

-- ============================================
-- 3. PUBLIC.USERS (48 records)
-- ============================================

-- Mothers (20)
INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('20000000-0000-0000-0000-000000000001', 'aigul01@example.com',    '+77011234501', 'mother', '10000000-0000-0000-0000-000000000001', 'Айгерим',   'Нурланова',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '2 hours',  CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('20000000-0000-0000-0000-000000000002', 'dana02@example.com',     '+77021234502', 'mother', '10000000-0000-0000-0000-000000000001', 'Дана',      'Касымова',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '1 day',    CURRENT_TIMESTAMP - INTERVAL '545 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('20000000-0000-0000-0000-000000000003', 'asel03@example.com',     '+77031234503', 'mother', '10000000-0000-0000-0000-000000000001', 'Асель',     'Бектурова',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '5 hours',  CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '5 hours'),
('20000000-0000-0000-0000-000000000004', 'madina04@example.com',   '+77041234504', 'mother', '10000000-0000-0000-0000-000000000001', 'Мадина',    'Жумабаева',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '3 hours',  CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('20000000-0000-0000-0000-000000000005', 'kamila05@example.com',   '+77051234505', 'mother', '10000000-0000-0000-0000-000000000001', 'Камила',    'Ахметова',       NULL, false, CURRENT_TIMESTAMP - INTERVAL '90 days',  CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000006', 'gulnara06@example.com',  '+77061234506', 'mother', '10000000-0000-0000-0000-000000000001', 'Гульнара',  'Сериккызы',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP - INTERVAL '455 days', CURRENT_TIMESTAMP - INTERVAL '12 hours'),
('20000000-0000-0000-0000-000000000007', 'dinara07@example.com',   '+77071234507', 'mother', '10000000-0000-0000-0000-000000000001', 'Динара',    'Оспанова',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '6 hours',  CURRENT_TIMESTAMP - INTERVAL '790 days', CURRENT_TIMESTAMP - INTERVAL '6 hours'),
('20000000-0000-0000-0000-000000000008', 'tomiris08@example.com',  '+77081234508', 'mother', '10000000-0000-0000-0000-000000000001', 'Томирис',   'Абдрахманова',   NULL, true,  CURRENT_TIMESTAMP - INTERVAL '1 hour',   CURRENT_TIMESTAMP - INTERVAL '90 days',  CURRENT_TIMESTAMP - INTERVAL '1 hour'),
('20000000-0000-0000-0000-000000000009', 'zhanna09@example.com',   '+77091234509', 'mother', '10000000-0000-0000-0000-000000000001', 'Жанна',     'Тулегенова',     NULL, true,  CURRENT_TIMESTAMP - INTERVAL '2 days',   CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('20000000-0000-0000-0000-000000000010', 'lyazzat10@example.com',  '+77011234510', 'mother', '10000000-0000-0000-0000-000000000001', 'Ляззат',    'Калиева',        NULL, true,  CURRENT_TIMESTAMP - INTERVAL '4 hours',  CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '4 hours'),
('20000000-0000-0000-0000-000000000011', 'aliya11@example.com',    '+77021234511', 'mother', '10000000-0000-0000-0000-000000000001', 'Алия',      'Муратова',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '8 hours',  CURRENT_TIMESTAMP - INTERVAL '670 days', CURRENT_TIMESTAMP - INTERVAL '8 hours'),
('20000000-0000-0000-0000-000000000012', 'sabina12@example.com',   '+77031234512', 'mother', '10000000-0000-0000-0000-000000000001', 'Сабина',    'Ермекова',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '3 hours',  CURRENT_TIMESTAMP - INTERVAL '210 days', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('20000000-0000-0000-0000-000000000013', 'karina13@example.com',   '+77041234513', 'mother', '10000000-0000-0000-0000-000000000001', 'Карина',    'Байтурсынова',   NULL, true,  CURRENT_TIMESTAMP - INTERVAL '1 day',    CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('20000000-0000-0000-0000-000000000014', 'nurgul14@example.com',   '+77051234514', 'mother', '10000000-0000-0000-0000-000000000001', 'Нургуль',   'Амиржанова',     NULL, true,  CURRENT_TIMESTAMP - INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '850 days', CURRENT_TIMESTAMP - INTERVAL '10 hours'),
('20000000-0000-0000-0000-000000000015', 'ayaulym15@example.com',  '+77061234515', 'mother', '10000000-0000-0000-0000-000000000001', 'Аяулым',    'Досжанова',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '5 hours',  CURRENT_TIMESTAMP - INTERVAL '330 days', CURRENT_TIMESTAMP - INTERVAL '5 hours'),
('20000000-0000-0000-0000-000000000016', 'fariza16@example.com',   '+77071234516', 'mother', '10000000-0000-0000-0000-000000000002', 'Фариза',    'Токтарова',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
('20000000-0000-0000-0000-000000000017', 'adina17@example.com',    '+77081234517', 'mother', '10000000-0000-0000-0000-000000000002', 'Адина',     'Кенжебаева',     NULL, true,  CURRENT_TIMESTAMP - INTERVAL '3 days',   CURRENT_TIMESTAMP - INTERVAL '515 days', CURRENT_TIMESTAMP - INTERVAL '3 days'),
('20000000-0000-0000-0000-000000000018', 'saltanat18@example.com', '+77091234518', 'mother', '10000000-0000-0000-0000-000000000001', 'Салтанат',  'Нурпеисова',     NULL, true,  CURRENT_TIMESTAMP - INTERVAL '7 hours',  CURRENT_TIMESTAMP - INTERVAL '270 days', CURRENT_TIMESTAMP - INTERVAL '7 hours'),
('20000000-0000-0000-0000-000000000019', 'dariga19@example.com',   '+77011234519', 'mother', '10000000-0000-0000-0000-000000000001', 'Дарига',    'Сагындыкова',    NULL, false, CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '608 days', CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'inzhu20@example.com',    '+77021234520', 'mother', '10000000-0000-0000-0000-000000000001', 'Инжу',      'Байжанова',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '1 hour',   CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '1 hour');

-- Fathers (10)
INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('30000000-0000-0000-0000-000000000001', 'nurlan01@example.com',    '+77011234601', 'father', '10000000-0000-0000-0000-000000000001', 'Нурлан',    'Нурланов',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '1 day',    CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('30000000-0000-0000-0000-000000000002', 'erzhan02@example.com',    '+77021234602', 'father', '10000000-0000-0000-0000-000000000001', 'Ержан',     'Касымов',        NULL, true,  CURRENT_TIMESTAMP - INTERVAL '2 days',   CURRENT_TIMESTAMP - INTERVAL '545 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('30000000-0000-0000-0000-000000000003', 'arman03@example.com',     '+77031234603', 'father', '10000000-0000-0000-0000-000000000001', 'Арман',     'Бектуров',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '1 day',    CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('30000000-0000-0000-0000-000000000004', 'damir04@example.com',     '+77041234604', 'father', '10000000-0000-0000-0000-000000000001', 'Дамир',     'Жумабаев',       NULL, true,  CURRENT_TIMESTAMP - INTERVAL '5 hours',  CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '5 hours'),
('30000000-0000-0000-0000-000000000005', 'timur05@example.com',     '+77051234605', 'father', '10000000-0000-0000-0000-000000000001', 'Тимур',     'Ахметов',        NULL, false, CURRENT_TIMESTAMP - INTERVAL '100 days', CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '100 days'),
('30000000-0000-0000-0000-000000000006', 'bauyrzhan06@example.com', '+77061234606', 'father', '10000000-0000-0000-0000-000000000001', 'Бауыржан',  'Серикович',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '2 days',   CURRENT_TIMESTAMP - INTERVAL '455 days', CURRENT_TIMESTAMP - INTERVAL '2 days'),
('30000000-0000-0000-0000-000000000007', 'daniyar07@example.com',   '+77071234607', 'father', '10000000-0000-0000-0000-000000000001', 'Данияр',    'Оспанов',        NULL, true,  CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP - INTERVAL '790 days', CURRENT_TIMESTAMP - INTERVAL '12 hours'),
('30000000-0000-0000-0000-000000000008', 'askhat08@example.com',    '+77081234608', 'father', '10000000-0000-0000-0000-000000000001', 'Асхат',     'Абдрахманов',    NULL, true,  CURRENT_TIMESTAMP - INTERVAL '3 hours',  CURRENT_TIMESTAMP - INTERVAL '90 days',  CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('30000000-0000-0000-0000-000000000009', 'alikhan09@example.com',   '+77091234609', 'father', '10000000-0000-0000-0000-000000000001', 'Алихан',    'Тулегенов',      NULL, true,  CURRENT_TIMESTAMP - INTERVAL '3 days',   CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '3 days'),
('30000000-0000-0000-0000-000000000010', 'ruslan10@example.com',    '+77011234610', 'father', '10000000-0000-0000-0000-000000000001', 'Руслан',    'Калиев',         NULL, true,  CURRENT_TIMESTAMP - INTERVAL '8 hours',  CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '8 hours');

-- Doctors (8)
INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('40000000-0000-0000-0000-000000000001', 'saule.dr@example.com',   '+77011234701', 'doctor', '10000000-0000-0000-0000-000000000001', 'Сауле',    'Исмаилова',    NULL, true, CURRENT_TIMESTAMP - INTERVAL '1 hour',  CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1 hour'),
('40000000-0000-0000-0000-000000000002', 'botagoz.dr@example.com', '+77021234702', 'doctor', '10000000-0000-0000-0000-000000000001', 'Ботагоз',  'Жакипова',     NULL, true, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('40000000-0000-0000-0000-000000000003', 'erzhan.dr@example.com',  '+77031234703', 'doctor', '10000000-0000-0000-0000-000000000001', 'Ержан',    'Сулейменов',   NULL, true, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('40000000-0000-0000-0000-000000000004', 'laura.dr@example.com',   '+77041234704', 'doctor', '10000000-0000-0000-0000-000000000001', 'Лаура',    'Алиева',       NULL, true, CURRENT_TIMESTAMP - INTERVAL '5 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '5 hours'),
('40000000-0000-0000-0000-000000000005', 'marat.dr@example.com',   '+77051234705', 'doctor', '10000000-0000-0000-0000-000000000001', 'Марат',    'Кенесов',      NULL, true, CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '4 hours'),
('40000000-0000-0000-0000-000000000006', 'anara.dr@example.com',   '+77061234706', 'doctor', '10000000-0000-0000-0000-000000000001', 'Анара',    'Бейсенова',    NULL, true, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '6 hours'),
('40000000-0000-0000-0000-000000000007', 'darya.dr@example.com',   '+77071234707', 'doctor', '10000000-0000-0000-0000-000000000002', 'Дарья',    'Ким',          NULL, true, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '600 days',  CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('40000000-0000-0000-0000-000000000008', 'alexey.dr@example.com',  '+77081234708', 'doctor', '10000000-0000-0000-0000-000000000002', 'Алексей',  'Цой',          NULL, true, CURRENT_TIMESTAMP - INTERVAL '1 hour',  CURRENT_TIMESTAMP - INTERVAL '600 days',  CURRENT_TIMESTAMP - INTERVAL '1 hour');

-- Coordinators (3)
INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('50000000-0000-0000-0000-000000000001', 'moldir.co@example.com',  '+77011234801', 'coordinator', '10000000-0000-0000-0000-000000000001', 'Молдир',   'Нуржанова',    NULL, true, CURRENT_TIMESTAMP - INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
('50000000-0000-0000-0000-000000000002', 'ainur.co@example.com',   '+77021234802', 'coordinator', '10000000-0000-0000-0000-000000000001', 'Айнур',    'Сабитова',     NULL, true, CURRENT_TIMESTAMP - INTERVAL '1 hour',     CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '1 hour'),
('50000000-0000-0000-0000-000000000003', 'botakoz.co@example.com', '+77031234803', 'coordinator', '10000000-0000-0000-0000-000000000002', 'Ботакоз',  'Темирханова',  NULL, true, CURRENT_TIMESTAMP - INTERVAL '2 hours',    CURRENT_TIMESTAMP - INTERVAL '600 days',  CURRENT_TIMESTAMP - INTERVAL '2 hours');

-- Nurses (4)
INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('60000000-0000-0000-0000-000000000001', 'gulmira.nu@example.com',   '+77011234901', 'nurse', '10000000-0000-0000-0000-000000000001', 'Гульмира',  'Есенова',     NULL, true, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('60000000-0000-0000-0000-000000000002', 'bayan.nu@example.com',     '+77021234902', 'nurse', '10000000-0000-0000-0000-000000000001', 'Баян',      'Жолдасова',   NULL, true, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('60000000-0000-0000-0000-000000000003', 'nurzhamal.nu@example.com', '+77031234903', 'nurse', '10000000-0000-0000-0000-000000000001', 'Нуржамал',  'Курманова',   NULL, true, CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '4 hours'),
('60000000-0000-0000-0000-000000000004', 'azhar.nu@example.com',     '+77041234904', 'nurse', '10000000-0000-0000-0000-000000000002', 'Ажар',      'Каирбекова',  NULL, true, CURRENT_TIMESTAMP - INTERVAL '1 hour',  CURRENT_TIMESTAMP - INTERVAL '600 days',  CURRENT_TIMESTAMP - INTERVAL '1 hour');

-- Admins (3)
INSERT INTO users (id, email, phone, role, clinic_id, first_name, last_name, avatar_url, is_active, last_seen_at, created_at, updated_at)
VALUES
('70000000-0000-0000-0000-000000000001', 'askar.ad@example.com',   '+77015551001', 'admin',      '10000000-0000-0000-0000-000000000001', 'Аскар',   'Ибрагимов',     NULL, true, CURRENT_TIMESTAMP - INTERVAL '20 minutes', CURRENT_TIMESTAMP - INTERVAL '1000 days', CURRENT_TIMESTAMP - INTERVAL '20 minutes'),
('70000000-0000-0000-0000-000000000002', 'erbolat.ad@example.com', '+77025551002', 'admin',      '10000000-0000-0000-0000-000000000002', 'Ерболат', 'Сатыбалдиев',   NULL, true, CURRENT_TIMESTAMP - INTERVAL '1 hour',     CURRENT_TIMESTAMP - INTERVAL '600 days',  CURRENT_TIMESTAMP - INTERVAL '1 hour'),
('70000000-0000-0000-0000-000000000003', 'maksat.sa@example.com',  '+77035551003', 'superadmin', NULL,                                   'Максат',  'Алтынбеков',    NULL, true, CURRENT_TIMESTAMP - INTERVAL '10 minutes', CURRENT_TIMESTAMP - INTERVAL '1100 days', CURRENT_TIMESTAMP - INTERVAL '10 minutes');

-- ============================================
-- 4. FAMILIES (20 records)
-- ============================================
INSERT INTO families (id, clinic_id, primary_parent_id, secondary_parent_id, invite_code, status, created_at, updated_at)
VALUES
('80000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'INV-A1K7M', 'active',   CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', '30000000-0000-0000-0000-000000000002', 'INV-B2L8N', 'active',   CURRENT_TIMESTAMP - INTERVAL '545 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'INV-C3M9P', 'active',   CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000004', '30000000-0000-0000-0000-000000000004', 'INV-D4N0Q', 'active',   CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', '30000000-0000-0000-0000-000000000005', 'INV-E5P1R', 'archived', CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '90 days'),
('80000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', '30000000-0000-0000-0000-000000000006', 'INV-F6Q2S', 'active',   CURRENT_TIMESTAMP - INTERVAL '455 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000007', '30000000-0000-0000-0000-000000000007', 'INV-G7R3T', 'active',   CURRENT_TIMESTAMP - INTERVAL '790 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000008', '30000000-0000-0000-0000-000000000008', 'INV-H8S4U', 'active',   CURRENT_TIMESTAMP - INTERVAL '90 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000009', '30000000-0000-0000-0000-000000000009', 'INV-J9T5V', 'active',   CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000010', '30000000-0000-0000-0000-000000000010', 'INV-K0U6W', 'active',   CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000011', NULL,                                   'INV-L1V7X', 'active',   CURRENT_TIMESTAMP - INTERVAL '670 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000012', NULL,                                   'INV-M2W8Y', 'active',   CURRENT_TIMESTAMP - INTERVAL '210 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000013', NULL,                                   'INV-N3X9Z', 'active',   CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000014', NULL,                                   'INV-P4Y0A', 'active',   CURRENT_TIMESTAMP - INTERVAL '850 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000015', NULL,                                   'INV-Q5Z1B', 'active',   CURRENT_TIMESTAMP - INTERVAL '330 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000016', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000016', NULL,                                   'INV-R6A2C', 'active',   CURRENT_TIMESTAMP - INTERVAL '60 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000017', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000017', NULL,                                   'INV-S7B3D', 'active',   CURRENT_TIMESTAMP - INTERVAL '515 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000018', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000018', NULL,                                   'INV-T8C4E', 'active',   CURRENT_TIMESTAMP - INTERVAL '270 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('80000000-0000-0000-0000-000000000019', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000019', NULL,                                   'INV-U9D5F', 'inactive', CURRENT_TIMESTAMP - INTERVAL '608 days', CURRENT_TIMESTAMP - INTERVAL '120 days'),
('80000000-0000-0000-0000-000000000020', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000020', NULL,                                   'INV-V0E6G', 'active',   CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '1 day');

-- ============================================
-- 5. MOTHER PROFILES (20 records)
-- ============================================
-- Families with children use lmp = child_dob - 280, edd = child_dob
-- Pregnant families (fa03, fa08, fa12, fa16, fa20) have future edd
INSERT INTO mother_profiles (id, family_id, user_id, lmp_date, edd_date, blood_type, rh_factor, allergies, chronic_conditions, pregnancy_number, gravida, para, notes, created_at, updated_at)
VALUES
-- m01: fa01, kids ch01(CD-670) ch02(CD-150). Latest=ch02. lmp=CD-430, edd=CD-150. para=2
('A0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
 CURRENT_DATE - 430, CURRENT_DATE - 150, 'A', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 2, 2, 2, NULL,
 CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m02: fa02, kid ch03(CD-425). lmp=CD-705, edd=CD-425. para=1
('A0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002',
 CURRENT_DATE - 705, CURRENT_DATE - 425, 'B', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '545 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m03: fa03, pregnant (no children). edd=CD+90, lmp=CD-190. para=0
('A0000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003',
 CURRENT_DATE - 190, CURRENT_DATE + 90, 'A', 'positive', ARRAY['пенициллин']::TEXT[], ARRAY[]::TEXT[], 1, 1, 0, 'Первая беременность, аллергия на пенициллин',
 CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m04: fa04, kid ch04(CD-42). lmp=CD-322, edd=CD-42. para=1
('A0000000-0000-0000-0000-000000000004', '80000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000004',
 CURRENT_DATE - 322, CURRENT_DATE - 42, 'A', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m05: fa05, kid ch05(CD-300). lmp=CD-580, edd=CD-300. para=1. Archived.
('A0000000-0000-0000-0000-000000000005', '80000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000005',
 CURRENT_DATE - 580, CURRENT_DATE - 300, 'O', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, 'Семья архивирована',
 CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '90 days'),

-- m06: fa06, kid ch06(CD-335). lmp=CD-615, edd=CD-335. para=1
('A0000000-0000-0000-0000-000000000006', '80000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000006',
 CURRENT_DATE - 615, CURRENT_DATE - 335, 'A', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '455 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m07: fa07, kids ch07(CD-610) ch08(CD-120). Latest=ch08. lmp=CD-400, edd=CD-120. para=2
('A0000000-0000-0000-0000-000000000007', '80000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000007',
 CURRENT_DATE - 400, CURRENT_DATE - 120, 'B', 'positive', ARRAY['пыльца','арахис']::TEXT[], ARRAY[]::TEXT[], 2, 2, 2, 'Аллергия на пыльцу и арахис',
 CURRENT_TIMESTAMP - INTERVAL '790 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m08: fa08, pregnant (no children). edd=CD+120, lmp=CD-160. para=0
('A0000000-0000-0000-0000-000000000008', '80000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000008',
 CURRENT_DATE - 160, CURRENT_DATE + 120, 'O', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 0, 'Первая беременность, 20-я неделя',
 CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m09: fa09, kid ch09(CD-270). lmp=CD-550, edd=CD-270. para=1
('A0000000-0000-0000-0000-000000000009', '80000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000009',
 CURRENT_DATE - 550, CURRENT_DATE - 270, 'AB', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m10: fa10, kid ch10(CD-60). lmp=CD-340, edd=CD-60. para=1
('A0000000-0000-0000-0000-000000000010', '80000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000010',
 CURRENT_DATE - 340, CURRENT_DATE - 60, 'O', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m11: fa11, kids ch11(CD-550) ch12(CD-90). Latest=ch12. lmp=CD-370, edd=CD-90. para=2
('A0000000-0000-0000-0000-000000000011', '80000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000011',
 CURRENT_DATE - 370, CURRENT_DATE - 90, 'A', 'positive', ARRAY[]::TEXT[], ARRAY['гипотиреоз']::TEXT[], 2, 2, 2, 'Хронический гипотиреоз, на заместительной терапии',
 CURRENT_TIMESTAMP - INTERVAL '670 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m12: fa12, pregnant (no children). edd=CD+60, lmp=CD-220. para=0
('A0000000-0000-0000-0000-000000000012', '80000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000012',
 CURRENT_DATE - 220, CURRENT_DATE + 60, 'B', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 0, 'Первая беременность, 31-я неделя',
 CURRENT_TIMESTAMP - INTERVAL '210 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m13: fa13, kid ch13(CD-240). lmp=CD-520, edd=CD-240. para=1
('A0000000-0000-0000-0000-000000000013', '80000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000013',
 CURRENT_DATE - 520, CURRENT_DATE - 240, 'O', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m14: fa14, kids ch14(CD-730) ch15(CD-240). Latest=ch15. lmp=CD-520, edd=CD-240. para=2
('A0000000-0000-0000-0000-000000000014', '80000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000014',
 CURRENT_DATE - 520, CURRENT_DATE - 240, 'A', 'positive', ARRAY[]::TEXT[], ARRAY['анемия']::TEXT[], 2, 2, 2, 'Железодефицитная анемия',
 CURRENT_TIMESTAMP - INTERVAL '850 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m15: fa15, kid ch16(CD-30). lmp=CD-310, edd=CD-30. para=1
('A0000000-0000-0000-0000-000000000015', '80000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000015',
 CURRENT_DATE - 310, CURRENT_DATE - 30, 'O', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '330 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m16: fa16, pregnant (no children). edd=CD+180, lmp=CD-100. para=0. clinic2
('A0000000-0000-0000-0000-000000000016', '80000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000016',
 CURRENT_DATE - 100, CURRENT_DATE + 180, 'A', 'positive', ARRAY['латекс']::TEXT[], ARRAY[]::TEXT[], 1, 1, 0, 'Первая беременность, аллергия на латекс',
 CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m17: fa17, kids ch17(CD-395) ch18(CD-30). Latest=ch18. lmp=CD-310, edd=CD-30. para=2. clinic2
('A0000000-0000-0000-0000-000000000017', '80000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000017',
 CURRENT_DATE - 310, CURRENT_DATE - 30, 'A', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 2, 2, 2, NULL,
 CURRENT_TIMESTAMP - INTERVAL '515 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m18: fa18, kid ch19(CD-90). lmp=CD-370, edd=CD-90. para=1
('A0000000-0000-0000-0000-000000000018', '80000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000018',
 CURRENT_DATE - 370, CURRENT_DATE - 90, 'B', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 1, NULL,
 CURRENT_TIMESTAMP - INTERVAL '270 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),

-- m19: fa19, kid ch20(CD-488). lmp=CD-768, edd=CD-488. para=1. Inactive.
('A0000000-0000-0000-0000-000000000019', '80000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000019',
 CURRENT_DATE - 768, CURRENT_DATE - 488, 'A', 'negative', ARRAY[]::TEXT[], ARRAY['астма']::TEXT[], 1, 1, 1, 'Бронхиальная астма, семья неактивна',
 CURRENT_TIMESTAMP - INTERVAL '608 days', CURRENT_TIMESTAMP - INTERVAL '120 days'),

-- m20: fa20, pregnant (no children). edd=CD+100, lmp=CD-180. para=0
('A0000000-0000-0000-0000-000000000020', '80000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000020',
 CURRENT_DATE - 180, CURRENT_DATE + 100, 'O', 'positive', ARRAY[]::TEXT[], ARRAY[]::TEXT[], 1, 1, 0, 'Первая беременность, 26-я неделя',
 CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '1 day');

-- ============================================
-- 6. CHILD PROFILES (20 records)
-- ============================================
INSERT INTO child_profiles (id, family_id, name, dob, gender, birth_weight, birth_height, apgar_1min, apgar_5min, blood_type, allergies, photo_url, is_active, created_at, updated_at)
VALUES
('90000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', 'Амир',      CURRENT_DATE - 670, 'male',   3.55, 52, 8, 9,  'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '670 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000001', 'Аяна',      CURRENT_DATE - 150, 'female', 3.20, 50, 8, 9,  'O+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000002', 'Адам',      CURRENT_DATE - 425, 'male',   3.80, 53, 9, 10, 'B+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '425 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000004', '80000000-0000-0000-0000-000000000004', 'Алина',     CURRENT_DATE - 42,  'female', 3.10, 49, 7, 8,  'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '42 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000005', '80000000-0000-0000-0000-000000000005', 'Арман',     CURRENT_DATE - 300, 'male',   3.65, 51, 8, 9,  'O+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '300 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000006', '80000000-0000-0000-0000-000000000006', 'Дарья',     CURRENT_DATE - 335, 'female', 3.40, 50, 9, 10, 'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '335 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000007', '80000000-0000-0000-0000-000000000007', 'Ерасыл',    CURRENT_DATE - 610, 'male',   3.75, 52, 8, 9,  'B+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '610 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000008', '80000000-0000-0000-0000-000000000007', 'Айлин',     CURRENT_DATE - 120, 'female', 3.15, 49, 8, 9,  'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000009', '80000000-0000-0000-0000-000000000009', 'Мирас',     CURRENT_DATE - 270, 'male',   3.50, 51, 9, 10, 'AB+', ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '270 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000010', '80000000-0000-0000-0000-000000000010', 'Томирис',   CURRENT_DATE - 60,  'female', 3.30, 50, 8, 9,  'O+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '60 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000011', '80000000-0000-0000-0000-000000000011', 'Алихан',    CURRENT_DATE - 550, 'male',   3.90, 54, 9, 10, 'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '550 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000012', '80000000-0000-0000-0000-000000000011', 'Амина',     CURRENT_DATE - 90,  'female', 3.05, 48, 7, 9,  'B+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '90 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000013', '80000000-0000-0000-0000-000000000013', 'Нурай',     CURRENT_DATE - 240, 'female', 3.25, 49, 8, 9,  'O+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '240 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000014', '80000000-0000-0000-0000-000000000014', 'Диас',      CURRENT_DATE - 730, 'male',   3.70, 53, 9, 10, 'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '730 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000015', '80000000-0000-0000-0000-000000000014', 'Камила',    CURRENT_DATE - 240, 'female', 3.35, 50, 8, 9,  'B+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '240 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000016', '80000000-0000-0000-0000-000000000015', 'Аружан',    CURRENT_DATE - 30,  'female', 2.95, 48, 7, 8,  'O+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '30 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000017', '80000000-0000-0000-0000-000000000017', 'Тамерлан',  CURRENT_DATE - 395, 'male',   3.60, 52, 9, 10, 'A+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '395 days', CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000018', '80000000-0000-0000-0000-000000000017', 'Жасмин',    CURRENT_DATE - 30,  'female', 3.00, 47, 8, 9,  'O+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '30 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000019', '80000000-0000-0000-0000-000000000018', 'Даниял',    CURRENT_DATE - 90,  'male',   3.45, 51, 8, 9,  'B+',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '90 days',  CURRENT_TIMESTAMP - INTERVAL '1 day'),
('90000000-0000-0000-0000-000000000020', '80000000-0000-0000-0000-000000000019', 'Айару',     CURRENT_DATE - 488, 'female', 3.30, 50, 9, 10, 'A-',  ARRAY[]::TEXT[], NULL, true, CURRENT_TIMESTAMP - INTERVAL '488 days', CURRENT_TIMESTAMP - INTERVAL '1 day');

-- ============================================
-- 7. CONSENTS (140 records: 7 types x 20 mothers)
-- ============================================

-- m01 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000001', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days'),
('20000000-0000-0000-0000-000000000001', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days'),
('20000000-0000-0000-0000-000000000001', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days'),
('20000000-0000-0000-0000-000000000001', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days'),
('20000000-0000-0000-0000-000000000001', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days'),
('20000000-0000-0000-0000-000000000001', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days'),
('20000000-0000-0000-0000-000000000001', 'telemedicine',true, CURRENT_TIMESTAMP - INTERVAL '730 days', NULL, CURRENT_TIMESTAMP - INTERVAL '730 days');

-- m02 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000002', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days'),
('20000000-0000-0000-0000-000000000002', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days'),
('20000000-0000-0000-0000-000000000002', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days'),
('20000000-0000-0000-0000-000000000002', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days'),
('20000000-0000-0000-0000-000000000002', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days'),
('20000000-0000-0000-0000-000000000002', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days'),
('20000000-0000-0000-0000-000000000002', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '545 days', NULL, CURRENT_TIMESTAMP - INTERVAL '545 days');

-- m03 - data_sharing not granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000003', 'push',         true,  CURRENT_TIMESTAMP - INTERVAL '150 days', NULL, CURRENT_TIMESTAMP - INTERVAL '150 days'),
('20000000-0000-0000-0000-000000000003', 'whatsapp',     true,  CURRENT_TIMESTAMP - INTERVAL '150 days', NULL, CURRENT_TIMESTAMP - INTERVAL '150 days'),
('20000000-0000-0000-0000-000000000003', 'sms',          true,  CURRENT_TIMESTAMP - INTERVAL '150 days', NULL, CURRENT_TIMESTAMP - INTERVAL '150 days'),
('20000000-0000-0000-0000-000000000003', 'email',        true,  CURRENT_TIMESTAMP - INTERVAL '150 days', NULL, CURRENT_TIMESTAMP - INTERVAL '150 days'),
('20000000-0000-0000-0000-000000000003', 'data_sharing', false, NULL,                                     NULL, CURRENT_TIMESTAMP - INTERVAL '150 days'),
('20000000-0000-0000-0000-000000000003', 'ai',           true,  CURRENT_TIMESTAMP - INTERVAL '150 days', NULL, CURRENT_TIMESTAMP - INTERVAL '150 days'),
('20000000-0000-0000-0000-000000000003', 'telemedicine', true,  CURRENT_TIMESTAMP - INTERVAL '150 days', NULL, CURRENT_TIMESTAMP - INTERVAL '150 days');

-- m04 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000004', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000004', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000004', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000004', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000004', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000004', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000004', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days');

-- m05 - whatsapp and sms revoked (archived family)
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000005', 'push',         true,  CURRENT_TIMESTAMP - INTERVAL '365 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000005', 'whatsapp',     false, CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '100 days', CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000005', 'sms',          false, CURRENT_TIMESTAMP - INTERVAL '365 days', CURRENT_TIMESTAMP - INTERVAL '100 days', CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000005', 'email',        true,  CURRENT_TIMESTAMP - INTERVAL '365 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000005', 'data_sharing', true,  CURRENT_TIMESTAMP - INTERVAL '365 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000005', 'ai',           true,  CURRENT_TIMESTAMP - INTERVAL '365 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000005', 'telemedicine', true,  CURRENT_TIMESTAMP - INTERVAL '365 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '365 days');

-- m06 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000006', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days'),
('20000000-0000-0000-0000-000000000006', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days'),
('20000000-0000-0000-0000-000000000006', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days'),
('20000000-0000-0000-0000-000000000006', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days'),
('20000000-0000-0000-0000-000000000006', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days'),
('20000000-0000-0000-0000-000000000006', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days'),
('20000000-0000-0000-0000-000000000006', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '455 days', NULL, CURRENT_TIMESTAMP - INTERVAL '455 days');

-- m07 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000007', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days'),
('20000000-0000-0000-0000-000000000007', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days'),
('20000000-0000-0000-0000-000000000007', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days'),
('20000000-0000-0000-0000-000000000007', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days'),
('20000000-0000-0000-0000-000000000007', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days'),
('20000000-0000-0000-0000-000000000007', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days'),
('20000000-0000-0000-0000-000000000007', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '790 days', NULL, CURRENT_TIMESTAMP - INTERVAL '790 days');

-- m08 - telemedicine not granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000008', 'push',         true,  CURRENT_TIMESTAMP - INTERVAL '90 days', NULL, CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000008', 'whatsapp',     true,  CURRENT_TIMESTAMP - INTERVAL '90 days', NULL, CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000008', 'sms',          true,  CURRENT_TIMESTAMP - INTERVAL '90 days', NULL, CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000008', 'email',        true,  CURRENT_TIMESTAMP - INTERVAL '90 days', NULL, CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000008', 'data_sharing', true,  CURRENT_TIMESTAMP - INTERVAL '90 days', NULL, CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000008', 'ai',           true,  CURRENT_TIMESTAMP - INTERVAL '90 days', NULL, CURRENT_TIMESTAMP - INTERVAL '90 days'),
('20000000-0000-0000-0000-000000000008', 'telemedicine', false, NULL,                                    NULL, CURRENT_TIMESTAMP - INTERVAL '90 days');

-- m09 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000009', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days'),
('20000000-0000-0000-0000-000000000009', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days'),
('20000000-0000-0000-0000-000000000009', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days'),
('20000000-0000-0000-0000-000000000009', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days'),
('20000000-0000-0000-0000-000000000009', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days'),
('20000000-0000-0000-0000-000000000009', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days'),
('20000000-0000-0000-0000-000000000009', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '395 days', NULL, CURRENT_TIMESTAMP - INTERVAL '395 days');

-- m10 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000010', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days'),
('20000000-0000-0000-0000-000000000010', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days'),
('20000000-0000-0000-0000-000000000010', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days'),
('20000000-0000-0000-0000-000000000010', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days'),
('20000000-0000-0000-0000-000000000010', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days'),
('20000000-0000-0000-0000-000000000010', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days'),
('20000000-0000-0000-0000-000000000010', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '300 days', NULL, CURRENT_TIMESTAMP - INTERVAL '300 days');

-- m11 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000011', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days'),
('20000000-0000-0000-0000-000000000011', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days'),
('20000000-0000-0000-0000-000000000011', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days'),
('20000000-0000-0000-0000-000000000011', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days'),
('20000000-0000-0000-0000-000000000011', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days'),
('20000000-0000-0000-0000-000000000011', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days'),
('20000000-0000-0000-0000-000000000011', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '670 days', NULL, CURRENT_TIMESTAMP - INTERVAL '670 days');

-- m12 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000012', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days'),
('20000000-0000-0000-0000-000000000012', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days'),
('20000000-0000-0000-0000-000000000012', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days'),
('20000000-0000-0000-0000-000000000012', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days'),
('20000000-0000-0000-0000-000000000012', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days'),
('20000000-0000-0000-0000-000000000012', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days'),
('20000000-0000-0000-0000-000000000012', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '210 days', NULL, CURRENT_TIMESTAMP - INTERVAL '210 days');

-- m13 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000013', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000013', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000013', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000013', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000013', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000013', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days'),
('20000000-0000-0000-0000-000000000013', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '365 days', NULL, CURRENT_TIMESTAMP - INTERVAL '365 days');

-- m14 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000014', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days'),
('20000000-0000-0000-0000-000000000014', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days'),
('20000000-0000-0000-0000-000000000014', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days'),
('20000000-0000-0000-0000-000000000014', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days'),
('20000000-0000-0000-0000-000000000014', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days'),
('20000000-0000-0000-0000-000000000014', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days'),
('20000000-0000-0000-0000-000000000014', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '850 days', NULL, CURRENT_TIMESTAMP - INTERVAL '850 days');

-- m15 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000015', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days'),
('20000000-0000-0000-0000-000000000015', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days'),
('20000000-0000-0000-0000-000000000015', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days'),
('20000000-0000-0000-0000-000000000015', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days'),
('20000000-0000-0000-0000-000000000015', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days'),
('20000000-0000-0000-0000-000000000015', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days'),
('20000000-0000-0000-0000-000000000015', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '330 days', NULL, CURRENT_TIMESTAMP - INTERVAL '330 days');

-- m16 - ai not granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000016', 'push',         true,  CURRENT_TIMESTAMP - INTERVAL '60 days', NULL, CURRENT_TIMESTAMP - INTERVAL '60 days'),
('20000000-0000-0000-0000-000000000016', 'whatsapp',     true,  CURRENT_TIMESTAMP - INTERVAL '60 days', NULL, CURRENT_TIMESTAMP - INTERVAL '60 days'),
('20000000-0000-0000-0000-000000000016', 'sms',          true,  CURRENT_TIMESTAMP - INTERVAL '60 days', NULL, CURRENT_TIMESTAMP - INTERVAL '60 days'),
('20000000-0000-0000-0000-000000000016', 'email',        true,  CURRENT_TIMESTAMP - INTERVAL '60 days', NULL, CURRENT_TIMESTAMP - INTERVAL '60 days'),
('20000000-0000-0000-0000-000000000016', 'data_sharing', true,  CURRENT_TIMESTAMP - INTERVAL '60 days', NULL, CURRENT_TIMESTAMP - INTERVAL '60 days'),
('20000000-0000-0000-0000-000000000016', 'ai',           false, NULL,                                    NULL, CURRENT_TIMESTAMP - INTERVAL '60 days'),
('20000000-0000-0000-0000-000000000016', 'telemedicine', true,  CURRENT_TIMESTAMP - INTERVAL '60 days', NULL, CURRENT_TIMESTAMP - INTERVAL '60 days');

-- m17 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000017', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days'),
('20000000-0000-0000-0000-000000000017', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days'),
('20000000-0000-0000-0000-000000000017', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days'),
('20000000-0000-0000-0000-000000000017', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days'),
('20000000-0000-0000-0000-000000000017', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days'),
('20000000-0000-0000-0000-000000000017', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days'),
('20000000-0000-0000-0000-000000000017', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '515 days', NULL, CURRENT_TIMESTAMP - INTERVAL '515 days');

-- m18 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000018', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days'),
('20000000-0000-0000-0000-000000000018', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days'),
('20000000-0000-0000-0000-000000000018', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days'),
('20000000-0000-0000-0000-000000000018', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days'),
('20000000-0000-0000-0000-000000000018', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days'),
('20000000-0000-0000-0000-000000000018', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days'),
('20000000-0000-0000-0000-000000000018', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '270 days', NULL, CURRENT_TIMESTAMP - INTERVAL '270 days');

-- m19 - push and ai revoked (inactive family)
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000019', 'push',         false, CURRENT_TIMESTAMP - INTERVAL '608 days', CURRENT_TIMESTAMP - INTERVAL '130 days', CURRENT_TIMESTAMP - INTERVAL '608 days'),
('20000000-0000-0000-0000-000000000019', 'whatsapp',     true,  CURRENT_TIMESTAMP - INTERVAL '608 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '608 days'),
('20000000-0000-0000-0000-000000000019', 'sms',          true,  CURRENT_TIMESTAMP - INTERVAL '608 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '608 days'),
('20000000-0000-0000-0000-000000000019', 'email',        true,  CURRENT_TIMESTAMP - INTERVAL '608 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '608 days'),
('20000000-0000-0000-0000-000000000019', 'data_sharing', true,  CURRENT_TIMESTAMP - INTERVAL '608 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '608 days'),
('20000000-0000-0000-0000-000000000019', 'ai',           false, CURRENT_TIMESTAMP - INTERVAL '608 days', CURRENT_TIMESTAMP - INTERVAL '130 days', CURRENT_TIMESTAMP - INTERVAL '608 days'),
('20000000-0000-0000-0000-000000000019', 'telemedicine', true,  CURRENT_TIMESTAMP - INTERVAL '608 days', NULL,                                     CURRENT_TIMESTAMP - INTERVAL '608 days');

-- m20 - all granted
INSERT INTO consents (user_id, type, granted, granted_at, revoked_at, created_at) VALUES
('20000000-0000-0000-0000-000000000020', 'push',         true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'whatsapp',     true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'sms',          true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'email',        true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'data_sharing', true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'ai',           true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days'),
('20000000-0000-0000-0000-000000000020', 'telemedicine', true, CURRENT_TIMESTAMP - INTERVAL '120 days', NULL, CURRENT_TIMESTAMP - INTERVAL '120 days');

-- NOTE: COMMIT will be in the final seed file (seed_04).
-- End of seed_01_core.sql
-- ============================================
-- SEED 02: Journey Templates, Journeys, Journey Events
-- ============================================

-- 8 journey templates (2 per type)
INSERT INTO journey_templates (id, clinic_id, type, name, description, events_json, is_default, is_active, created_at) VALUES
('c0000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','pregnancy','Ведение беременности (стандарт)','Стандартный план ведения беременности: 12 визитов, 3 УЗИ, скрининги','[{"week":12,"type":"uzi","title":"УЗИ 1 триместр"},{"week":20,"type":"uzi","title":"УЗИ 2 триместр"},{"week":32,"type":"uzi","title":"УЗИ 3 триместр"}]',true,true, CURRENT_DATE - interval '730 days'),
('c0000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001','postpartum','Послеродовое наблюдение','План наблюдения мамы и малыша в первые 6 недель','[{"day":3,"type":"visit","title":"Патронаж день 3"},{"day":7,"type":"visit","title":"Патронаж день 7"},{"week":6,"type":"visit","title":"Осмотр 6 недель"}]',true,true, CURRENT_DATE - interval '730 days'),
('c0000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','infant','Наблюдение до 1 года','Ежемесячные осмотры, вакцинация, развитие','[{"month":1,"type":"visit","title":"Осмотр 1 мес"},{"month":3,"type":"visit","title":"Осмотр 3 мес"},{"month":6,"type":"visit","title":"Осмотр 6 мес"},{"month":9,"type":"visit","title":"Осмотр 9 мес"},{"month":12,"type":"visit","title":"Осмотр 12 мес"}]',true,true, CURRENT_DATE - interval '730 days'),
('c0000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','toddler','Наблюдение 1-3 года','Ежеквартальные осмотры, развитие речи, социализация','[{"month":15,"type":"visit","title":"Осмотр 15 мес"},{"month":18,"type":"visit","title":"Осмотр 18 мес"},{"month":24,"type":"visit","title":"Осмотр 2 года"},{"month":36,"type":"visit","title":"Осмотр 3 года"}]',true,true, CURRENT_DATE - interval '730 days'),
('c0000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000002','pregnancy','Ведение беременности (премиум)','Расширенный план: доп. УЗИ, консультации генетика','[{"week":8,"type":"uzi","title":"УЗИ раннее"},{"week":12,"type":"uzi","title":"УЗИ 1 триместр + НИПТ"},{"week":20,"type":"uzi","title":"УЗИ 2 триместр 3D"},{"week":32,"type":"uzi","title":"УЗИ 3 триместр"}]',false,true, CURRENT_DATE - interval '500 days'),
('c0000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000002','postpartum','Послеродовое (премиум)','Расширенное послеродовое наблюдение с психологом','[{"day":1,"type":"visit","title":"Первый день"},{"day":3,"type":"visit","title":"Патронаж"},{"week":2,"type":"visit","title":"Осмотр 2 нед"},{"week":6,"type":"visit","title":"Осмотр 6 нед"}]',false,true, CURRENT_DATE - interval '500 days'),
('c0000000-0000-0000-0000-000000000007','10000000-0000-0000-0000-000000000002','infant','Наблюдение до 1 года (премиум)','Расширенные осмотры каждые 2 недели в первый квартал','[]',false,true, CURRENT_DATE - interval '500 days'),
('c0000000-0000-0000-0000-000000000008','10000000-0000-0000-0000-000000000003','pregnancy','Беременность (базовый)','Базовый план для CareKids Shymkent','[]',false,true, CURRENT_DATE - interval '300 days');

-- ~35 journeys mapped to families
-- Pregnant families: fa03,fa08,fa12,fa16,fa20 → pregnancy journeys (active)
-- Postpartum families: fa04,fa10,fa15,fa16(newborn ch16 age30d) → postpartum (active/completed)
-- Infant families: fa02,fa05,fa06,fa09,fa13,fa18 → infant journeys (active)
-- Toddler families: fa01,fa07,fa11 → toddler (active) + completed infant + completed postpartum
-- Archived: fa14,fa17 → completed journeys

INSERT INTO journeys (id, family_id, template_id, child_id, type, status, started_at, completed_at, created_at) VALUES
-- fa01 Нурлановы (toddler, ch01=670d, ch02=150d) - full history
('d0000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','completed', CURRENT_DATE - interval '700 days', CURRENT_DATE - interval '670 days', CURRENT_DATE - interval '700 days'),
('d0000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000001','postpartum','completed', CURRENT_DATE - interval '670 days', CURRENT_DATE - interval '628 days', CURRENT_DATE - interval '670 days'),
('d0000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000001','infant','completed', CURRENT_DATE - interval '628 days', CURRENT_DATE - interval '305 days', CURRENT_DATE - interval '628 days'),
('d0000000-0000-0000-0000-000000000004','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000001','toddler','active', CURRENT_DATE - interval '305 days', NULL, CURRENT_DATE - interval '305 days'),
('d0000000-0000-0000-0000-000000000005','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','completed', CURRENT_DATE - interval '180 days', CURRENT_DATE - interval '150 days', CURRENT_DATE - interval '180 days'),
('d0000000-0000-0000-0000-000000000006','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000002','postpartum','completed', CURRENT_DATE - interval '150 days', CURRENT_DATE - interval '108 days', CURRENT_DATE - interval '150 days'),
('d0000000-0000-0000-0000-000000000007','80000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000002','infant','active', CURRENT_DATE - interval '108 days', NULL, CURRENT_DATE - interval '108 days'),

-- fa02 Касымовы (infant, ch03=425d)
('d0000000-0000-0000-0000-000000000008','80000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','completed', CURRENT_DATE - interval '455 days', CURRENT_DATE - interval '425 days', CURRENT_DATE - interval '455 days'),
('d0000000-0000-0000-0000-000000000009','80000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000003','postpartum','completed', CURRENT_DATE - interval '425 days', CURRENT_DATE - interval '383 days', CURRENT_DATE - interval '425 days'),
('d0000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000003','infant','completed', CURRENT_DATE - interval '383 days', CURRENT_DATE - interval '60 days', CURRENT_DATE - interval '383 days'),
('d0000000-0000-0000-0000-000000000035','80000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000003','toddler','active', CURRENT_DATE - interval '60 days', NULL, CURRENT_DATE - interval '60 days'),

-- fa03 Бектуровы (pregnant, no child)
('d0000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000003','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','active', CURRENT_DATE - interval '150 days', NULL, CURRENT_DATE - interval '150 days'),

-- fa04 Жумабаевы (postpartum, ch04=42d)
('d0000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000004','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','completed', CURRENT_DATE - interval '72 days', CURRENT_DATE - interval '42 days', CURRENT_DATE - interval '72 days'),
('d0000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000004','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000004','postpartum','active', CURRENT_DATE - interval '42 days', NULL, CURRENT_DATE - interval '42 days'),

-- fa05 (infant ch05=300d)
('d0000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000005','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000005','infant','active', CURRENT_DATE - interval '258 days', NULL, CURRENT_DATE - interval '258 days'),

-- fa06 (infant ch06=335d)
('d0000000-0000-0000-0000-000000000015','80000000-0000-0000-0000-000000000006','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000006','infant','active', CURRENT_DATE - interval '293 days', NULL, CURRENT_DATE - interval '293 days'),

-- fa07 (toddler, ch07=610d, ch08=120d)
('d0000000-0000-0000-0000-000000000016','80000000-0000-0000-0000-000000000007','c0000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000007','toddler','active', CURRENT_DATE - interval '245 days', NULL, CURRENT_DATE - interval '245 days'),
('d0000000-0000-0000-0000-000000000017','80000000-0000-0000-0000-000000000007','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000008','infant','active', CURRENT_DATE - interval '78 days', NULL, CURRENT_DATE - interval '78 days'),

-- fa08 (pregnant)
('d0000000-0000-0000-0000-000000000018','80000000-0000-0000-0000-000000000008','c0000000-0000-0000-0000-000000000005',NULL,'pregnancy','active', CURRENT_DATE - interval '120 days', NULL, CURRENT_DATE - interval '120 days'),

-- fa09 (infant ch09=270d)
('d0000000-0000-0000-0000-000000000019','80000000-0000-0000-0000-000000000009','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000009','infant','active', CURRENT_DATE - interval '228 days', NULL, CURRENT_DATE - interval '228 days'),

-- fa10 (postpartum ch10=60d)
('d0000000-0000-0000-0000-000000000020','80000000-0000-0000-0000-000000000010','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000010','postpartum','active', CURRENT_DATE - interval '60 days', NULL, CURRENT_DATE - interval '60 days'),

-- fa11 (toddler ch11=550d, ch12=90d)
('d0000000-0000-0000-0000-000000000021','80000000-0000-0000-0000-000000000011','c0000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000011','toddler','active', CURRENT_DATE - interval '185 days', NULL, CURRENT_DATE - interval '185 days'),
('d0000000-0000-0000-0000-000000000022','80000000-0000-0000-0000-000000000011','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000012','postpartum','completed', CURRENT_DATE - interval '90 days', CURRENT_DATE - interval '48 days', CURRENT_DATE - interval '90 days'),

-- fa12 (pregnant)
('d0000000-0000-0000-0000-000000000023','80000000-0000-0000-0000-000000000012','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','active', CURRENT_DATE - interval '200 days', NULL, CURRENT_DATE - interval '200 days'),

-- fa13 (infant ch13=240d)
('d0000000-0000-0000-0000-000000000024','80000000-0000-0000-0000-000000000013','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000013','infant','active', CURRENT_DATE - interval '198 days', NULL, CURRENT_DATE - interval '198 days'),

-- fa14 (archived, ch14=730d, ch15=240d) — completed all
('d0000000-0000-0000-0000-000000000025','80000000-0000-0000-0000-000000000014','c0000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000014','toddler','completed', CURRENT_DATE - interval '365 days', CURRENT_DATE - interval '90 days', CURRENT_DATE - interval '365 days'),
('d0000000-0000-0000-0000-000000000026','80000000-0000-0000-0000-000000000014','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000015','infant','completed', CURRENT_DATE - interval '240 days', CURRENT_DATE - interval '90 days', CURRENT_DATE - interval '240 days'),

-- fa15 (postpartum ch16=30d)
('d0000000-0000-0000-0000-000000000027','80000000-0000-0000-0000-000000000015','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000016','postpartum','active', CURRENT_DATE - interval '30 days', NULL, CURRENT_DATE - interval '30 days'),

-- fa16 (pregnant)
('d0000000-0000-0000-0000-000000000028','80000000-0000-0000-0000-000000000016','c0000000-0000-0000-0000-000000000001',NULL,'pregnancy','active', CURRENT_DATE - interval '90 days', NULL, CURRENT_DATE - interval '90 days'),

-- fa17 (archived, ch17=395d, ch18=30d)
('d0000000-0000-0000-0000-000000000029','80000000-0000-0000-0000-000000000017','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000017','infant','cancelled', CURRENT_DATE - interval '353 days', CURRENT_DATE - interval '200 days', CURRENT_DATE - interval '353 days'),

-- fa18 (infant ch19=90d)
('d0000000-0000-0000-0000-000000000030','80000000-0000-0000-0000-000000000018','c0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000019','postpartum','completed', CURRENT_DATE - interval '90 days', CURRENT_DATE - interval '48 days', CURRENT_DATE - interval '90 days'),
('d0000000-0000-0000-0000-000000000031','80000000-0000-0000-0000-000000000018','c0000000-0000-0000-0000-000000000003','90000000-0000-0000-0000-000000000019','infant','active', CURRENT_DATE - interval '48 days', NULL, CURRENT_DATE - interval '48 days'),

-- fa19 (infant ch20=488d)
('d0000000-0000-0000-0000-000000000032','80000000-0000-0000-0000-000000000019','c0000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000020','toddler','active', CURRENT_DATE - interval '123 days', NULL, CURRENT_DATE - interval '123 days'),

-- fa20 (pregnant)
('d0000000-0000-0000-0000-000000000033','80000000-0000-0000-0000-000000000020','c0000000-0000-0000-0000-000000000008',NULL,'pregnancy','active', CURRENT_DATE - interval '80 days', NULL, CURRENT_DATE - interval '80 days');

-- ~250 journey events using generate_series-based CTEs
-- Events for completed journeys (postpartum: ~5 events, infant: ~8 events, pregnancy: ~6 events, toddler: ~4 events)

-- Pregnancy journey events (for completed + active pregnancy journeys)
INSERT INTO journey_events (journey_id, type, title, description, trigger_week, due_date, status, is_mandatory, completed_at, completed_by, created_at)
SELECT
  j.id,
  CASE (s.n % 6)
    WHEN 0 THEN 'appointment'
    WHEN 1 THEN 'uzi'
    WHEN 2 THEN 'analysis'
    WHEN 3 THEN 'screening'
    WHEN 4 THEN 'appointment'
    WHEN 5 THEN 'education'
  END,
  CASE (s.n % 6)
    WHEN 0 THEN 'Осмотр акушера-гинеколога (неделя ' || (8 + s.n * 4) || ')'
    WHEN 1 THEN 'УЗИ ' || CASE WHEN s.n < 3 THEN '1' WHEN s.n < 5 THEN '2' ELSE '3' END || ' триместр'
    WHEN 2 THEN 'Анализ крови (триместр ' || LEAST((s.n/2)+1, 3) || ')'
    WHEN 3 THEN 'Скрининг ' || CASE WHEN s.n < 3 THEN '1' ELSE '2' END || ' триместра'
    WHEN 4 THEN 'Консультация ' || CASE WHEN s.n < 4 THEN 'терапевта' ELSE 'эндокринолога' END
    WHEN 5 THEN 'Занятие по подготовке к родам'
  END,
  'Плановое мероприятие программы ведения беременности',
  8 + s.n * 4,
  j.started_at::date + (s.n * 28),
  CASE
    WHEN j.status = 'completed' THEN 'completed'
    WHEN (j.started_at::date + (s.n * 28)) < CURRENT_DATE - interval '7 days' THEN
      CASE WHEN random() < 0.85 THEN 'completed' ELSE 'overdue' END
    WHEN (j.started_at::date + (s.n * 28)) < CURRENT_DATE THEN 'due'
    ELSE 'upcoming'
  END,
  true,
  CASE
    WHEN j.status = 'completed' THEN j.started_at + (s.n * interval '28 days') + interval '1 day'
    WHEN (j.started_at::date + (s.n * 28)) < CURRENT_DATE - interval '7 days' AND random() < 0.85
      THEN (j.started_at + (s.n * interval '28 days') + interval '2 days')
    ELSE NULL
  END,
  CASE
    WHEN j.status = 'completed' OR ((j.started_at::date + (s.n * 28)) < CURRENT_DATE - interval '7 days' AND random() < 0.85)
      THEN '40000000-0000-0000-0000-000000000001'::uuid
    ELSE NULL
  END,
  j.created_at
FROM journeys j
CROSS JOIN generate_series(0, 6) AS s(n)
WHERE j.type = 'pregnancy';

-- Postpartum journey events
INSERT INTO journey_events (journey_id, type, title, description, trigger_day, due_date, status, is_mandatory, completed_at, completed_by, created_at)
SELECT
  j.id,
  CASE s.n
    WHEN 0 THEN 'visit' WHEN 1 THEN 'visit' WHEN 2 THEN 'screening'
    WHEN 3 THEN 'appointment' ELSE 'education'
  END,
  CASE s.n
    WHEN 0 THEN 'Патронаж новорожденного (день 3)'
    WHEN 1 THEN 'Патронаж новорожденного (день 7)'
    WHEN 2 THEN 'ЭПДС скрининг (2 недели)'
    WHEN 3 THEN 'Осмотр педиатра (1 месяц)'
    ELSE 'Осмотр гинеколога (6 недель)'
  END,
  'Послеродовое наблюдение',
  CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END,
  j.started_at::date + CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END,
  CASE
    WHEN j.status = 'completed' THEN 'completed'
    WHEN (j.started_at::date + CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END) < CURRENT_DATE - interval '3 days' THEN
      CASE WHEN random() < 0.9 THEN 'completed' ELSE 'overdue' END
    WHEN (j.started_at::date + CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END) <= CURRENT_DATE THEN 'due'
    ELSE 'upcoming'
  END,
  true,
  CASE
    WHEN j.status = 'completed' THEN j.started_at + (CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END * interval '1 day') + interval '1 day'
    WHEN (j.started_at::date + CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END) < CURRENT_DATE - interval '3 days' AND random() < 0.9
      THEN j.started_at + (CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END * interval '1 day') + interval '1 day'
    ELSE NULL
  END,
  CASE
    WHEN j.status = 'completed' OR ((j.started_at::date + CASE s.n WHEN 0 THEN 3 WHEN 1 THEN 7 WHEN 2 THEN 14 WHEN 3 THEN 30 ELSE 42 END) < CURRENT_DATE - interval '3 days' AND random() < 0.9)
      THEN '40000000-0000-0000-0000-000000000002'::uuid
    ELSE NULL
  END,
  j.created_at
FROM journeys j
CROSS JOIN generate_series(0, 4) AS s(n)
WHERE j.type = 'postpartum';

-- Infant journey events (monthly checks + vaccinations)
INSERT INTO journey_events (journey_id, type, title, description, trigger_day, due_date, status, is_mandatory, completed_at, completed_by, created_at)
SELECT
  j.id,
  CASE (s.n % 3) WHEN 0 THEN 'appointment' WHEN 1 THEN 'vaccination' ELSE 'screening' END,
  CASE s.n
    WHEN 0 THEN 'Осмотр педиатра (1 мес)'
    WHEN 1 THEN 'Вакцинация АКДС-1'
    WHEN 2 THEN 'Оценка развития (3 мес)'
    WHEN 3 THEN 'Осмотр педиатра (4 мес)'
    WHEN 4 THEN 'Вакцинация АКДС-2'
    WHEN 5 THEN 'Оценка развития (6 мес)'
    WHEN 6 THEN 'Осмотр педиатра (9 мес)'
    WHEN 7 THEN 'Вакцинация ККП'
    ELSE 'Осмотр педиатра (12 мес)'
  END,
  'Программа наблюдения до 1 года',
  s.n * 40 + 30,
  j.started_at::date + (s.n * 40 + 30),
  CASE
    WHEN j.status = 'completed' THEN 'completed'
    WHEN (j.started_at::date + (s.n * 40 + 30)) < CURRENT_DATE - interval '7 days' THEN
      CASE WHEN random() < 0.8 THEN 'completed' WHEN random() < 0.5 THEN 'overdue' ELSE 'skipped' END
    WHEN (j.started_at::date + (s.n * 40 + 30)) <= CURRENT_DATE THEN 'due'
    ELSE 'upcoming'
  END,
  true,
  CASE
    WHEN j.status = 'completed' THEN j.started_at + ((s.n * 40 + 30) * interval '1 day')
    WHEN (j.started_at::date + (s.n * 40 + 30)) < CURRENT_DATE - interval '7 days' AND random() < 0.8
      THEN j.started_at + ((s.n * 40 + 30) * interval '1 day') + interval '2 days'
    ELSE NULL
  END,
  CASE
    WHEN j.status = 'completed' OR ((j.started_at::date + (s.n * 40 + 30)) < CURRENT_DATE - interval '7 days' AND random() < 0.8)
      THEN '40000000-0000-0000-0000-000000000002'::uuid
    ELSE NULL
  END,
  j.created_at
FROM journeys j
CROSS JOIN generate_series(0, 8) AS s(n)
WHERE j.type = 'infant';

-- Toddler journey events (quarterly checks)
INSERT INTO journey_events (journey_id, type, title, description, trigger_day, due_date, status, is_mandatory, completed_at, completed_by, created_at)
SELECT
  j.id,
  CASE (s.n % 2) WHEN 0 THEN 'appointment' ELSE 'screening' END,
  CASE s.n
    WHEN 0 THEN 'Осмотр педиатра (15 мес)'
    WHEN 1 THEN 'Оценка речи (18 мес)'
    WHEN 2 THEN 'Осмотр педиатра (21 мес)'
    WHEN 3 THEN 'Осмотр + оценка развития (2 года)'
    ELSE 'Социализация — консультация'
  END,
  'Программа наблюдения 1-3 года',
  s.n * 90,
  j.started_at::date + (s.n * 90),
  CASE
    WHEN j.status = 'completed' THEN 'completed'
    WHEN (j.started_at::date + (s.n * 90)) < CURRENT_DATE - interval '7 days' THEN
      CASE WHEN random() < 0.85 THEN 'completed' ELSE 'overdue' END
    WHEN (j.started_at::date + (s.n * 90)) <= CURRENT_DATE THEN 'due'
    ELSE 'upcoming'
  END,
  true,
  CASE
    WHEN j.status = 'completed' THEN j.started_at + (s.n * interval '90 days')
    WHEN (j.started_at::date + (s.n * 90)) < CURRENT_DATE - interval '7 days' AND random() < 0.85
      THEN j.started_at + (s.n * interval '90 days') + interval '3 days'
    ELSE NULL
  END,
  CASE
    WHEN j.status = 'completed' OR ((j.started_at::date + (s.n * 90)) < CURRENT_DATE - interval '7 days' AND random() < 0.85)
      THEN '40000000-0000-0000-0000-000000000002'::uuid
    ELSE NULL
  END,
  j.created_at
FROM journeys j
CROSS JOIN generate_series(0, 4) AS s(n)
WHERE j.type = 'toddler';
-- =============================================================================
-- seed_02b_doctors.sql  –  Doctors, appointment slots, appointments
-- Part of the umai-health-landing seed pipeline (no BEGIN/COMMIT)
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. doctors  (8 records)
-- ---------------------------------------------------------------------------
INSERT INTO doctors (
  id, clinic_id, user_id, specialty, bio, experience_years,
  consultation_fee, is_active, created_at, updated_at
) VALUES
  (
    'b0000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    'Акушер-гинеколог',
    'Врач высшей категории. Стаж работы более 15 лет. Специализация: ведение беременности высокого риска, УЗИ-диагностика.',
    15,
    18000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '800 days',
    CURRENT_TIMESTAMP - INTERVAL '800 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000002',
    'Педиатр',
    'Педиатр первой категории. Опыт работы в неонатологии и педиатрии. Консультации по грудному вскармливанию.',
    12,
    12000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '750 days',
    CURRENT_TIMESTAMP - INTERVAL '750 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000003',
    'Неонатолог',
    'Специалист по наблюдению новорождённых. Опыт работы в перинатальном центре.',
    10,
    15000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '700 days',
    CURRENT_TIMESTAMP - INTERVAL '700 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000004',
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000004',
    'Детский невролог',
    'Диагностика и лечение неврологических нарушений у детей раннего возраста.',
    8,
    15000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '650 days',
    CURRENT_TIMESTAMP - INTERVAL '650 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000005',
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000005',
    'Детский хирург',
    'Хирург высшей категории. Малоинвазивная хирургия у детей.',
    20,
    20000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '900 days',
    CURRENT_TIMESTAMP - INTERVAL '900 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000006',
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000006',
    'Семейный врач',
    'Семейная медицина, профилактические осмотры, вакцинация.',
    18,
    10000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '850 days',
    CURRENT_TIMESTAMP - INTERVAL '850 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000007',
    '10000000-0000-0000-0000-000000000002',
    '40000000-0000-0000-0000-000000000007',
    'УЗИ-специалист',
    'Ультразвуковая диагностика. Специализация: пренатальная и детская эхография.',
    14,
    8000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '600 days',
    CURRENT_TIMESTAMP - INTERVAL '600 days'
  ),
  (
    'b0000000-0000-0000-0000-000000000008',
    '10000000-0000-0000-0000-000000000002',
    '40000000-0000-0000-0000-000000000008',
    'Педиатр',
    'Молодой специалист. Современные подходы к педиатрии.',
    6,
    10000.00,
    true,
    CURRENT_TIMESTAMP - INTERVAL '400 days',
    CURRENT_TIMESTAMP - INTERVAL '400 days'
  );


-- ---------------------------------------------------------------------------
-- 2. appointment_slots  (~8 300+ records via generate_series)
--    8 doctors  x  ~87 weekdays (121 calendar days)  x  12 daily time-slots
-- ---------------------------------------------------------------------------
INSERT INTO appointment_slots (doctor_id, date, start_time, end_time, is_available)
SELECT
  d.id,
  dates.d::date,
  times.t,
  times.t + INTERVAL '30 minutes',
  CASE WHEN dates.d::date < CURRENT_DATE THEN false ELSE true END
FROM (VALUES
  ('b0000000-0000-0000-0000-000000000001'::uuid),
  ('b0000000-0000-0000-0000-000000000002'::uuid),
  ('b0000000-0000-0000-0000-000000000003'::uuid),
  ('b0000000-0000-0000-0000-000000000004'::uuid),
  ('b0000000-0000-0000-0000-000000000005'::uuid),
  ('b0000000-0000-0000-0000-000000000006'::uuid),
  ('b0000000-0000-0000-0000-000000000007'::uuid),
  ('b0000000-0000-0000-0000-000000000008'::uuid)
) AS d(id)
CROSS JOIN generate_series(
  CURRENT_DATE - 60,
  CURRENT_DATE + 60,
  INTERVAL '1 day'
) AS dates(d)
CROSS JOIN (VALUES
  ('09:00'::time), ('09:30'::time), ('10:00'::time), ('10:30'::time),
  ('11:00'::time), ('11:30'::time), ('14:00'::time), ('14:30'::time),
  ('15:00'::time), ('15:30'::time), ('16:00'::time), ('16:30'::time)
) AS times(t)
WHERE extract(isodow FROM dates.d) BETWEEN 1 AND 5;


-- ---------------------------------------------------------------------------
-- 3. appointments  (278 records via CTE + generate_series)
--    Spread across 2 years: CURRENT_DATE - 730  ..  CURRENT_DATE + 30
--
--    Family totals (>= 15 per active family):
--      fa01:15  fa02:15  fa03:15  fa04:15  fa05:15  fa06:15  fa07:15
--      fa08:15  fa09:15  fa10:15  fa11:15  fa12:15  fa13:15  fa14:15
--      fa15:15  fa16:4   fa17:15  fa18:15  fa19:4   fa20:15
-- ---------------------------------------------------------------------------
WITH

-- 25 family -> doctor -> child mappings with appointment counts
mappings (family_id, doctor_id, child_id, num_appts) AS (VALUES
  -- fa01  children ch01, ch02
  ('80000000-0000-0000-0000-000000000001'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000001'::uuid, 8),
  ('80000000-0000-0000-0000-000000000001'::uuid, 'b0000000-0000-0000-0000-000000000004'::uuid, '90000000-0000-0000-0000-000000000002'::uuid, 7),
  -- fa02  child ch03
  ('80000000-0000-0000-0000-000000000002'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000003'::uuid, 15),
  -- fa03  pregnant (no child) -> gynecologist
  ('80000000-0000-0000-0000-000000000003'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, NULL::uuid, 15),
  -- fa04  child ch04
  ('80000000-0000-0000-0000-000000000004'::uuid, 'b0000000-0000-0000-0000-000000000006'::uuid, '90000000-0000-0000-0000-000000000004'::uuid, 15),
  -- fa05  child ch05
  ('80000000-0000-0000-0000-000000000005'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000005'::uuid, 15),
  -- fa06  child ch06 -> neurologist
  ('80000000-0000-0000-0000-000000000006'::uuid, 'b0000000-0000-0000-0000-000000000004'::uuid, '90000000-0000-0000-0000-000000000006'::uuid, 15),
  -- fa07  children ch07, ch08
  ('80000000-0000-0000-0000-000000000007'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000007'::uuid, 8),
  ('80000000-0000-0000-0000-000000000007'::uuid, 'b0000000-0000-0000-0000-000000000006'::uuid, '90000000-0000-0000-0000-000000000008'::uuid, 7),
  -- fa08  pregnant -> gynecologist
  ('80000000-0000-0000-0000-000000000008'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, NULL::uuid, 15),
  -- fa09  child ch09
  ('80000000-0000-0000-0000-000000000009'::uuid, 'b0000000-0000-0000-0000-000000000006'::uuid, '90000000-0000-0000-0000-000000000009'::uuid, 15),
  -- fa10  child ch10 -> ultrasound specialist
  ('80000000-0000-0000-0000-000000000010'::uuid, 'b0000000-0000-0000-0000-000000000007'::uuid, '90000000-0000-0000-0000-000000000010'::uuid, 15),
  -- fa11  children ch11, ch12
  ('80000000-0000-0000-0000-000000000011'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000011'::uuid, 8),
  ('80000000-0000-0000-0000-000000000011'::uuid, 'b0000000-0000-0000-0000-000000000004'::uuid, '90000000-0000-0000-0000-000000000012'::uuid, 7),
  -- fa12  pregnant -> gynecologist
  ('80000000-0000-0000-0000-000000000012'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, NULL::uuid, 15),
  -- fa13  child ch13 -> neurologist
  ('80000000-0000-0000-0000-000000000013'::uuid, 'b0000000-0000-0000-0000-000000000004'::uuid, '90000000-0000-0000-0000-000000000013'::uuid, 15),
  -- fa14  children ch14, ch15
  ('80000000-0000-0000-0000-000000000014'::uuid, 'b0000000-0000-0000-0000-000000000006'::uuid, '90000000-0000-0000-0000-000000000014'::uuid, 8),
  ('80000000-0000-0000-0000-000000000014'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000015'::uuid, 7),
  -- fa15  child ch16
  ('80000000-0000-0000-0000-000000000015'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000016'::uuid, 15),
  -- fa16  pregnant (other family, 3-5 appts) -> gynecologist
  ('80000000-0000-0000-0000-000000000016'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, NULL::uuid, 4),
  -- fa17  children ch17, ch18
  ('80000000-0000-0000-0000-000000000017'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000017'::uuid, 8),
  ('80000000-0000-0000-0000-000000000017'::uuid, 'b0000000-0000-0000-0000-000000000007'::uuid, '90000000-0000-0000-0000-000000000018'::uuid, 7),
  -- fa18  child ch19
  ('80000000-0000-0000-0000-000000000018'::uuid, 'b0000000-0000-0000-0000-000000000006'::uuid, '90000000-0000-0000-0000-000000000019'::uuid, 15),
  -- fa19  child ch20 (other family, 3-5 appts)
  ('80000000-0000-0000-0000-000000000019'::uuid, 'b0000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000020'::uuid, 4),
  -- fa20  pregnant -> gynecologist
  ('80000000-0000-0000-0000-000000000020'::uuid, 'b0000000-0000-0000-0000-000000000001'::uuid, NULL::uuid, 15)
),

-- Generate evenly-spaced appointment dates for each mapping
raw_appts AS (
  SELECT
    m.family_id,
    m.doctor_id,
    m.child_id,
    gs.n,
    m.num_appts,
    -- Spread appointments evenly across the 760-day window
    (CURRENT_DATE - 730 +
      CASE WHEN m.num_appts > 1
           THEN ((gs.n - 1) * (760.0 / (m.num_appts - 1)))::int
           ELSE 0
      END
    )::date AS apt_date,
    -- Cycle through 12 time-slots
    (ARRAY[
      '09:00','09:30','10:00','10:30','11:00','11:30',
      '14:00','14:30','15:00','15:30','16:00','16:30'
    ])[1 + ((gs.n - 1) % 12)]::time AS start_t,
    random() AS r_status,
    random() AS r_visit
  FROM mappings m
  CROSS JOIN LATERAL generate_series(1, m.num_appts) AS gs(n)
),

-- Derive status and visit_type from random rolls
with_attrs AS (
  SELECT
    ra.*,
    -- Status distribution by date bucket
    CASE
      WHEN ra.apt_date < CURRENT_DATE - 7 THEN
        CASE
          WHEN ra.r_status < 0.10 THEN 'cancelled'
          WHEN ra.r_status < 0.15 THEN 'no_show'
          ELSE 'completed'                              -- ~85 %
        END
      WHEN ra.apt_date <= CURRENT_DATE THEN
        CASE
          WHEN ra.r_status < 0.80 THEN 'completed'
          ELSE 'confirmed'
        END
      ELSE
        CASE
          WHEN ra.r_status < 0.60 THEN 'confirmed'
          WHEN ra.r_status < 0.90 THEN 'requested'
          ELSE 'rescheduled'
        END
    END AS status,
    -- Visit type: 80 % in_person, 15 % video, 5 % phone
    CASE
      WHEN ra.r_visit < 0.80 THEN 'in_person'
      WHEN ra.r_visit < 0.95 THEN 'video'
      ELSE 'phone'
    END AS visit_type
  FROM raw_appts ra
)

INSERT INTO appointments (
  family_id, doctor_id, child_id, status, appointment_date,
  start_time, end_time, visit_type, reason, post_visit_notes,
  cancelled_at, cancel_reason, created_at, updated_at
)
SELECT
  wa.family_id,
  wa.doctor_id,
  wa.child_id,
  wa.status,
  wa.apt_date,
  wa.start_t,
  wa.start_t + INTERVAL '30 minutes',
  wa.visit_type,

  -- reason (cycle through 8 Russian-language options)
  (ARRAY[
    'Плановый осмотр',
    'УЗИ скрининг',
    'Вакцинация',
    'Контрольный осмотр',
    'Консультация педиатра',
    'Осмотр невролога',
    'Анализы',
    'Жалобы на самочувствие'
  ])[1 + ((wa.n - 1) % 8)],

  -- post_visit_notes  (only for completed appointments)
  CASE WHEN wa.status = 'completed' THEN
    (ARRAY[
      'Осмотр без патологий. Рекомендации даны.',
      'Развитие соответствует возрасту. Следующий визит через месяц.',
      'Назначены дополнительные анализы.',
      'Вакцинация проведена. Реакций не наблюдается.'
    ])[1 + ((wa.n - 1) % 4)]
  END,

  -- cancelled_at
  CASE WHEN wa.status = 'cancelled'
       THEN wa.apt_date::timestamptz - INTERVAL '1 day'
  END,

  -- cancel_reason
  CASE WHEN wa.status = 'cancelled' THEN
    (ARRAY[
      'Болезнь ребёнка',
      'Личные обстоятельства',
      'Перенос по просьбе пациента'
    ])[1 + ((wa.n - 1) % 3)]
  END,

  -- created_at  (booked 3-14 days before the appointment)
  wa.apt_date::timestamptz - (3 + (wa.n % 12)) * INTERVAL '1 day',

  -- updated_at
  CASE
    WHEN wa.status IN ('completed', 'no_show')
      THEN wa.apt_date::timestamptz
    WHEN wa.status = 'cancelled'
      THEN wa.apt_date::timestamptz - INTERVAL '1 day'
    ELSE wa.apt_date::timestamptz - (3 + (wa.n % 12)) * INTERVAL '1 day'
  END

FROM with_attrs wa;
-- ============================================
-- SEED 03: Medical — Documents, Prescriptions, Dose Logs, Vaccinations
-- ============================================

-- ~80 documents (various types across families)
INSERT INTO documents (family_id, child_id, type, title, description, file_url, file_type, file_size, tags, uploaded_by, created_at)
SELECT
  fam.family_id,
  fam.child_id,
  dt.doc_type,
  dt.title,
  dt.description,
  'https://storage.supabase.co/v1/object/public/documents/' || fam.family_id || '/' || dt.doc_type || '_' || s.n || '.pdf',
  'application/pdf',
  (50000 + floor(random() * 450000))::int,
  dt.tags,
  CASE WHEN random() < 0.6 THEN fam.mother_id ELSE '40000000-0000-0000-0000-000000000002'::uuid END,
  fam.joined + (s.n * interval '30 days') + (floor(random() * 14) * interval '1 day')
FROM (
  VALUES
    ('80000000-0000-0000-0000-000000000001'::uuid, '90000000-0000-0000-0000-000000000001'::uuid, '20000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE - interval '700 days'),
    ('80000000-0000-0000-0000-000000000002'::uuid, '90000000-0000-0000-0000-000000000003'::uuid, '20000000-0000-0000-0000-000000000002'::uuid, CURRENT_DATE - interval '455 days'),
    ('80000000-0000-0000-0000-000000000003'::uuid, NULL, '20000000-0000-0000-0000-000000000003'::uuid, CURRENT_DATE - interval '150 days'),
    ('80000000-0000-0000-0000-000000000004'::uuid, '90000000-0000-0000-0000-000000000004'::uuid, '20000000-0000-0000-0000-000000000004'::uuid, CURRENT_DATE - interval '72 days'),
    ('80000000-0000-0000-0000-000000000005'::uuid, '90000000-0000-0000-0000-000000000005'::uuid, '20000000-0000-0000-0000-000000000005'::uuid, CURRENT_DATE - interval '330 days'),
    ('80000000-0000-0000-0000-000000000006'::uuid, '90000000-0000-0000-0000-000000000006'::uuid, '20000000-0000-0000-0000-000000000006'::uuid, CURRENT_DATE - interval '365 days'),
    ('80000000-0000-0000-0000-000000000007'::uuid, '90000000-0000-0000-0000-000000000007'::uuid, '20000000-0000-0000-0000-000000000007'::uuid, CURRENT_DATE - interval '640 days'),
    ('80000000-0000-0000-0000-000000000009'::uuid, '90000000-0000-0000-0000-000000000009'::uuid, '20000000-0000-0000-0000-000000000009'::uuid, CURRENT_DATE - interval '300 days'),
    ('80000000-0000-0000-0000-000000000011'::uuid, '90000000-0000-0000-0000-000000000011'::uuid, '20000000-0000-0000-0000-000000000011'::uuid, CURRENT_DATE - interval '580 days'),
    ('80000000-0000-0000-0000-000000000013'::uuid, '90000000-0000-0000-0000-000000000013'::uuid, '20000000-0000-0000-0000-000000000013'::uuid, CURRENT_DATE - interval '270 days')
) AS fam(family_id, child_id, mother_id, joined)
CROSS JOIN generate_series(0, 3) AS s(n)
CROSS JOIN (
  VALUES
    ('analysis', 'Общий анализ крови', 'Результаты ОАК', ARRAY['анализ','кровь']),
    ('ultrasound', 'УЗИ плода / ребёнка', 'Протокол ультразвукового исследования', ARRAY['узи','скрининг'])
) AS dt(doc_type, title, description, tags)
WHERE fam.joined + (s.n * interval '30 days') < CURRENT_DATE;

-- ~40 prescriptions across families
INSERT INTO prescriptions (id, family_id, child_id, medication, dosage, frequency, time_of_day, start_date, end_date, instructions, is_active, prescribed_by, created_at) VALUES
-- Pregnant mothers (folic acid, vitamins)
('f0000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000003',NULL,'Фолиевая кислота','400 мкг','1 раз в день','{morning}', CURRENT_DATE - interval '150 days', CURRENT_DATE + interval '120 days','Принимать утром натощак',true,'40000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '150 days'),
('f0000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000003',NULL,'Элевит Пронаталь','1 таблетка','1 раз в день','{morning}', CURRENT_DATE - interval '120 days', CURRENT_DATE + interval '120 days','Во время еды',true,'40000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '120 days'),
('f0000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000008',NULL,'Фолиевая кислота','400 мкг','1 раз в день','{morning}', CURRENT_DATE - interval '120 days', CURRENT_DATE + interval '150 days','Принимать утром',true,'40000000-0000-0000-0000-000000000003', CURRENT_DATE - interval '120 days'),
('f0000000-0000-0000-0000-000000000004','80000000-0000-0000-0000-000000000012',NULL,'Йодомарин','200 мкг','1 раз в день','{morning}', CURRENT_DATE - interval '200 days', CURRENT_DATE + interval '60 days','Принимать с едой',true,'40000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '200 days'),
('f0000000-0000-0000-0000-000000000005','80000000-0000-0000-0000-000000000016',NULL,'Магне B6','2 таблетки','2 раза в день','{morning,evening}', CURRENT_DATE - interval '60 days', CURRENT_DATE + interval '170 days','По 1 таблетке утром и вечером',true,'40000000-0000-0000-0000-000000000005', CURRENT_DATE - interval '60 days'),
('f0000000-0000-0000-0000-000000000006','80000000-0000-0000-0000-000000000020',NULL,'Элевит Пронаталь','1 таблетка','1 раз в день','{morning}', CURRENT_DATE - interval '80 days', CURRENT_DATE + interval '180 days','Во время завтрака',true,'40000000-0000-0000-0000-000000000007', CURRENT_DATE - interval '80 days'),
-- Postpartum mothers (iron, vitamins)
('f0000000-0000-0000-0000-000000000007','80000000-0000-0000-0000-000000000004',NULL,'Феррум Лек','100 мг','1 раз в день','{evening}', CURRENT_DATE - interval '42 days', CURRENT_DATE + interval '48 days','После еды, запивать соком',true,'40000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '42 days'),
('f0000000-0000-0000-0000-000000000008','80000000-0000-0000-0000-000000000010',NULL,'Кальций Д3','1 таблетка','2 раза в день','{morning,evening}', CURRENT_DATE - interval '55 days', CURRENT_DATE + interval '35 days','Принимать во время еды',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '55 days'),
-- Infants (vitamin D, colic, etc.)
('f0000000-0000-0000-0000-000000000009','80000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000001','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '650 days', CURRENT_DATE - interval '285 days','Капать в ложку воды',false,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '650 days'),
('f0000000-0000-0000-0000-000000000010','80000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000002','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '140 days', NULL,'Капать в ложку воды',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '140 days'),
('f0000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000003','Аквадетрим','2 капли (1000 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '380 days', CURRENT_DATE - interval '60 days','Капать в ложку воды (увеличенная доза, зима)',false,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '380 days'),
('f0000000-0000-0000-0000-000000000012','80000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000004','Эспумизан бэби','25 капель','3 раза в день','{morning,afternoon,evening}', CURRENT_DATE - interval '35 days', CURRENT_DATE + interval '25 days','Перед кормлением',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '35 days'),
('f0000000-0000-0000-0000-000000000013','80000000-0000-0000-0000-000000000005','90000000-0000-0000-0000-000000000005','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '280 days', NULL,'Профилактика рахита',true,'40000000-0000-0000-0000-000000000004', CURRENT_DATE - interval '280 days'),
('f0000000-0000-0000-0000-000000000014','80000000-0000-0000-0000-000000000006','90000000-0000-0000-0000-000000000006','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '300 days', NULL,'Профилактика рахита',true,'40000000-0000-0000-0000-000000000004', CURRENT_DATE - interval '300 days'),
('f0000000-0000-0000-0000-000000000015','80000000-0000-0000-0000-000000000006','90000000-0000-0000-0000-000000000006','Бифиформ бэби','1 доза','1 раз в день','{morning}', CURRENT_DATE - interval '200 days', CURRENT_DATE - interval '170 days','Во время кормления',false,'40000000-0000-0000-0000-000000000004', CURRENT_DATE - interval '200 days'),
('f0000000-0000-0000-0000-000000000016','80000000-0000-0000-0000-000000000007','90000000-0000-0000-0000-000000000007','Мультитабс бэби','1 мл','1 раз в день','{morning}', CURRENT_DATE - interval '400 days', CURRENT_DATE - interval '245 days','Витаминный комплекс',false,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '400 days'),
('f0000000-0000-0000-0000-000000000017','80000000-0000-0000-0000-000000000007','90000000-0000-0000-0000-000000000008','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '110 days', NULL,'Профилактика рахита',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '110 days'),
('f0000000-0000-0000-0000-000000000018','80000000-0000-0000-0000-000000000009','90000000-0000-0000-0000-000000000009','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '250 days', NULL,'Профилактика рахита',true,'40000000-0000-0000-0000-000000000006', CURRENT_DATE - interval '250 days'),
('f0000000-0000-0000-0000-000000000019','80000000-0000-0000-0000-000000000010','90000000-0000-0000-0000-000000000010','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '50 days', NULL,'Профилактика рахита',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '50 days'),
('f0000000-0000-0000-0000-000000000020','80000000-0000-0000-0000-000000000011','90000000-0000-0000-0000-000000000011','Аквадетрим','2 капли (1000 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '500 days', CURRENT_DATE - interval '185 days','Зимняя дозировка',false,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '500 days'),
('f0000000-0000-0000-0000-000000000021','80000000-0000-0000-0000-000000000011','90000000-0000-0000-0000-000000000012','Эспумизан бэби','25 капель','3 раза в день','{morning,afternoon,evening}', CURRENT_DATE - interval '80 days', CURRENT_DATE - interval '50 days','При коликах',false,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '80 days'),
('f0000000-0000-0000-0000-000000000022','80000000-0000-0000-0000-000000000013','90000000-0000-0000-0000-000000000013','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '220 days', NULL,'Профилактика рахита',true,'40000000-0000-0000-0000-000000000006', CURRENT_DATE - interval '220 days'),
('f0000000-0000-0000-0000-000000000023','80000000-0000-0000-0000-000000000014','90000000-0000-0000-0000-000000000014','Мультитабс бэби','1 мл','1 раз в день','{morning}', CURRENT_DATE - interval '600 days', CURRENT_DATE - interval '365 days','Витаминный комплекс',false,'40000000-0000-0000-0000-000000000004', CURRENT_DATE - interval '600 days'),
('f0000000-0000-0000-0000-000000000024','80000000-0000-0000-0000-000000000015','90000000-0000-0000-0000-000000000016','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '25 days', NULL,'Профилактика',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '25 days'),
('f0000000-0000-0000-0000-000000000025','80000000-0000-0000-0000-000000000018','90000000-0000-0000-0000-000000000019','Аквадетрим','1 капля (500 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '80 days', NULL,'Профилактика',true,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '80 days'),
('f0000000-0000-0000-0000-000000000026','80000000-0000-0000-0000-000000000019','90000000-0000-0000-0000-000000000020','Аквадетрим','2 капли (1000 МЕ)','1 раз в день','{morning}', CURRENT_DATE - interval '450 days', CURRENT_DATE - interval '123 days','Зимняя дозировка',false,'40000000-0000-0000-0000-000000000006', CURRENT_DATE - interval '450 days'),
-- Additional prescriptions for variety
('f0000000-0000-0000-0000-000000000027','80000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000001','Линекс для детей','1 саше','1 раз в день','{morning}', CURRENT_DATE - interval '550 days', CURRENT_DATE - interval '520 days','Развести в молоке',false,'40000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '550 days'),
('f0000000-0000-0000-0000-000000000028','80000000-0000-0000-0000-000000000005','90000000-0000-0000-0000-000000000005','Нурофен детский','2.5 мл','по необходимости','{evening}', CURRENT_DATE - interval '100 days', CURRENT_DATE - interval '97 days','При температуре выше 38.5',false,'40000000-0000-0000-0000-000000000004', CURRENT_DATE - interval '100 days'),
('f0000000-0000-0000-0000-000000000029','80000000-0000-0000-0000-000000000009','90000000-0000-0000-0000-000000000009','Бифиформ бэби','1 доза','1 раз в день','{morning}', CURRENT_DATE - interval '180 days', CURRENT_DATE - interval '150 days','С молоком',false,'40000000-0000-0000-0000-000000000006', CURRENT_DATE - interval '180 days'),
('f0000000-0000-0000-0000-000000000030','80000000-0000-0000-0000-000000000001',NULL,'Феррум Лек','100 мг','1 раз в день','{evening}', CURRENT_DATE - interval '680 days', CURRENT_DATE - interval '620 days','После еды',false,'40000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '680 days');

-- ~2000 dose_logs via generate_series (for active and recently completed prescriptions)
-- High adherence families: fa01,fa02,fa05,fa07 (90%+ confirmed)
-- Medium adherence: fa03,fa06,fa09,fa11,fa13 (70% confirmed)
-- Low adherence: fa04,fa08,fa14,fa17 (40-60% confirmed)

INSERT INTO dose_logs (prescription_id, family_id, scheduled_at, status, confirmed_at, confirmed_by, created_at)
SELECT
  p.id,
  p.family_id,
  ts,
  CASE
    WHEN p.family_id IN ('80000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000005','80000000-0000-0000-0000-000000000007') THEN
      CASE WHEN random() < 0.92 THEN 'confirmed' WHEN random() < 0.5 THEN 'missed' ELSE 'skipped' END
    WHEN p.family_id IN ('80000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000006','80000000-0000-0000-0000-000000000009','80000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000013') THEN
      CASE WHEN random() < 0.72 THEN 'confirmed' WHEN random() < 0.6 THEN 'missed' ELSE 'skipped' END
    ELSE
      CASE WHEN random() < 0.48 THEN 'confirmed' WHEN random() < 0.7 THEN 'missed' ELSE 'skipped' END
  END,
  CASE
    WHEN (p.family_id IN ('80000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000005','80000000-0000-0000-0000-000000000007') AND random() < 0.92)
      OR (p.family_id IN ('80000000-0000-0000-0000-000000000003','80000000-0000-0000-0000-000000000006','80000000-0000-0000-0000-000000000009','80000000-0000-0000-0000-000000000011','80000000-0000-0000-0000-000000000013') AND random() < 0.72)
      OR (random() < 0.48)
      THEN ts + interval '30 minutes' + (random() * interval '4 hours')
    ELSE NULL
  END,
  CASE
    WHEN random() < 0.7 THEN (SELECT mother_profiles.user_id FROM mother_profiles WHERE mother_profiles.family_id = p.family_id LIMIT 1)
    ELSE NULL
  END,
  ts
FROM prescriptions p
CROSS JOIN LATERAL generate_series(
  p.start_date::timestamptz + interval '8 hours',
  LEAST(COALESCE(p.end_date::timestamptz, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP),
  CASE
    WHEN p.frequency LIKE '%3 раза%' THEN interval '8 hours'
    WHEN p.frequency LIKE '%2 раза%' THEN interval '12 hours'
    ELSE interval '1 day'
  END
) AS ts
WHERE ts < CURRENT_TIMESTAMP;

-- ~150 vaccinations (KZ national calendar)
-- BCG (birth), HepB (birth, 2,4 mo), DTP+HepB+Hib (2,3,4,18 mo), OPV (2,3,4,18 mo), IPV (3,4 mo), PCV (2,4,12 mo), MMR (12,6y)
INSERT INTO vaccinations (child_id, vaccine_name, dose_number, scheduled_date, status, administered_date, batch_number, doctor_id, reactions, notes, created_at)
SELECT
  c.id AS child_id,
  v.vaccine_name,
  v.dose_number,
  (c.created_at::date - c.age_days + v.day_offset)::date AS scheduled_date,
  CASE
    WHEN (c.created_at::date - c.age_days + v.day_offset) < CURRENT_DATE - interval '14 days' THEN
      CASE WHEN random() < 0.88 THEN 'completed' WHEN random() < 0.5 THEN 'postponed' ELSE 'skipped' END
    WHEN (c.created_at::date - c.age_days + v.day_offset) <= CURRENT_DATE THEN 'scheduled'
    ELSE 'scheduled'
  END,
  CASE
    WHEN (c.created_at::date - c.age_days + v.day_offset) < CURRENT_DATE - interval '14 days' AND random() < 0.88
      THEN (c.created_at::date - c.age_days + v.day_offset + floor(random() * 7))::date
    ELSE NULL
  END,
  CASE WHEN random() < 0.88 THEN 'KZ-' || floor(random() * 900000 + 100000)::text ELSE NULL END,
  ('b0000000-0000-0000-0000-00000000000' || (1 + floor(random() * 8))::text)::uuid,
  CASE WHEN random() < 0.15 THEN 'Лёгкое покраснение в месте инъекции' ELSE NULL END,
  NULL,
  (c.created_at::date - c.age_days + v.day_offset - 7)::date
FROM (
  SELECT id, created_at,
    CASE id
      WHEN '90000000-0000-0000-0000-000000000001' THEN 670
      WHEN '90000000-0000-0000-0000-000000000002' THEN 150
      WHEN '90000000-0000-0000-0000-000000000003' THEN 425
      WHEN '90000000-0000-0000-0000-000000000004' THEN 42
      WHEN '90000000-0000-0000-0000-000000000005' THEN 300
      WHEN '90000000-0000-0000-0000-000000000006' THEN 335
      WHEN '90000000-0000-0000-0000-000000000007' THEN 610
      WHEN '90000000-0000-0000-0000-000000000008' THEN 120
      WHEN '90000000-0000-0000-0000-000000000009' THEN 270
      WHEN '90000000-0000-0000-0000-000000000010' THEN 60
      WHEN '90000000-0000-0000-0000-000000000011' THEN 550
      WHEN '90000000-0000-0000-0000-000000000012' THEN 90
      WHEN '90000000-0000-0000-0000-000000000013' THEN 240
      WHEN '90000000-0000-0000-0000-000000000014' THEN 730
      WHEN '90000000-0000-0000-0000-000000000015' THEN 240
      WHEN '90000000-0000-0000-0000-000000000016' THEN 30
      WHEN '90000000-0000-0000-0000-000000000017' THEN 395
      WHEN '90000000-0000-0000-0000-000000000018' THEN 30
      WHEN '90000000-0000-0000-0000-000000000019' THEN 90
      WHEN '90000000-0000-0000-0000-000000000020' THEN 488
    END AS age_days
  FROM child_profiles
) c
CROSS JOIN (
  VALUES
    ('БЦЖ', 1, 1),
    ('Гепатит B', 1, 1),
    ('Гепатит B', 2, 60),
    ('Гепатит B', 3, 120),
    ('АКДС+ГепВ+Хиб', 1, 60),
    ('АКДС+ГепВ+Хиб', 2, 90),
    ('АКДС+ГепВ+Хиб', 3, 120),
    ('АКДС+ГепВ+Хиб', 4, 540),
    ('ОПВ', 1, 60),
    ('ОПВ', 2, 90),
    ('ОПВ', 3, 120),
    ('ОПВ', 4, 540),
    ('ИПВ', 1, 90),
    ('ИПВ', 2, 120),
    ('ПКВ', 1, 60),
    ('ПКВ', 2, 120),
    ('ПКВ', 3, 365),
    ('ККП', 1, 365)
) AS v(vaccine_name, dose_number, day_offset)
WHERE v.day_offset <= c.age_days + 30;
-- =============================================
-- seed_04_operations.sql
-- coordinator_tasks, notifications, visit_ratings, service_transactions
-- Part of a larger seed — no BEGIN/COMMIT
-- =============================================

-- -----------------------------------------------
-- 1. coordinator_tasks (70 records)
-- -----------------------------------------------

INSERT INTO coordinator_tasks
  (clinic_id, family_id, type, priority, status, assigned_to, due_date, title, notes, result, created_by, completed_at, created_at, updated_at)
VALUES
-- === welcome_call (18) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2025-10-15','Приветственный звонок: семья Нурлановы','Первый контакт после регистрации на платформе','Звонок проведён. Семья ознакомлена с платформой. Вопросов нет.','system','2025-10-15 11:30:00+06','2025-10-10 09:00:00+06','2025-10-15 11:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000002','welcome_call','medium','completed','50000000-0000-0000-0000-000000000002','2025-10-20','Приветственный звонок: семья Ахметовы','Первый контакт после регистрации','Звонок проведён. Мама задала вопросы по вакцинации. Разъяснения даны.','system','2025-10-19 14:00:00+06','2025-10-12 10:00:00+06','2025-10-19 14:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000003','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2025-10-25','Приветственный звонок: семья Жумабаевы','Первый контакт после регистрации','Звонок проведён. Семья ознакомлена с функционалом. Подключён календарь.','system','2025-10-24 10:15:00+06','2025-10-20 08:30:00+06','2025-10-24 10:15:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000004','welcome_call','medium','completed','50000000-0000-0000-0000-000000000002','2025-10-30','Приветственный звонок: семья Сериковы','Первый контакт после регистрации','Звонок проведён. Семья ознакомлена с платформой. Просьба перезвонить по расписанию.','system','2025-10-28 16:00:00+06','2025-10-25 09:00:00+06','2025-10-28 16:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000005','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2025-11-05','Приветственный звонок: семья Тулегеновы','Первый контакт после регистрации','Звонок проведён. Мама не ответила. Повторный звонок через 2 дня — успешно.','system','2025-11-05 11:00:00+06','2025-11-01 09:00:00+06','2025-11-05 11:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000006','welcome_call','medium','completed','50000000-0000-0000-0000-000000000002','2025-11-12','Приветственный звонок: семья Бекболатовы','Первый контакт после регистрации','Звонок проведён. Семья благодарна за внимание. Вопросов нет.','system','2025-11-11 13:30:00+06','2025-11-08 10:00:00+06','2025-11-11 13:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000007','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2025-11-18','Приветственный звонок: семья Касымовы','Первый контакт после регистрации','Звонок проведён. Обсудили план наблюдения. Настроены уведомления.','system','2025-11-17 09:45:00+06','2025-11-14 08:00:00+06','2025-11-17 09:45:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000008','welcome_call','medium','completed','50000000-0000-0000-0000-000000000002','2025-11-25','Приветственный звонок: семья Муратовы','Первый контакт после регистрации','Звонок проведён. Мама попросила помощь с настройкой приложения. Помогли.','system','2025-11-24 15:00:00+06','2025-11-20 09:00:00+06','2025-11-24 15:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000009','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2025-12-03','Приветственный звонок: семья Оспановы','Первый контакт после регистрации','Звонок проведён. Семья ознакомлена с платформой. Вопросов нет.','system','2025-12-02 10:00:00+06','2025-11-28 09:00:00+06','2025-12-02 10:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000010','welcome_call','medium','completed','50000000-0000-0000-0000-000000000002','2025-12-10','Приветственный звонок: семья Сагындыковы','Первый контакт после регистрации','Звонок проведён. Мама благодарна. Подключили напоминания о вакцинации.','system','2025-12-09 14:30:00+06','2025-12-05 10:00:00+06','2025-12-09 14:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000011','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2026-01-10','Приветственный звонок: семья Темирбековы','Первый контакт после регистрации','Звонок проведён. Всё понятно, семья готова пользоваться платформой.','system','2026-01-09 11:00:00+06','2026-01-05 09:00:00+06','2026-01-09 11:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000012','welcome_call','medium','completed','50000000-0000-0000-0000-000000000002','2026-01-18','Приветственный звонок: семья Есенбаевы','Первый контакт после регистрации','Звонок проведён. Семья ознакомлена с платформой и получила инструкции.','system','2026-01-17 10:30:00+06','2026-01-14 09:00:00+06','2026-01-17 10:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000013','welcome_call','medium','completed','50000000-0000-0000-0000-000000000001','2026-02-05','Приветственный звонок: семья Мадиевы','Первый контакт после регистрации','Звонок проведён. Мама попросила информацию о педиатре. Направлена запись.','system','2026-02-04 16:00:00+06','2026-02-01 09:00:00+06','2026-02-04 16:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000014','welcome_call','medium','in_progress','50000000-0000-0000-0000-000000000002','2026-03-22','Приветственный звонок: семья Кожабековы','Попытка связаться по телефону. Не ответили. Повтор.',NULL,'system',NULL,'2026-03-18 09:00:00+06','2026-03-20 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000015','welcome_call','medium','in_progress','50000000-0000-0000-0000-000000000001','2026-03-28','Приветственный звонок: семья Токтаровы','Запланирован звонок. Мама просила перезвонить после 14:00.',NULL,'system',NULL,'2026-03-24 08:30:00+06','2026-03-26 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000016','welcome_call','medium','pending','50000000-0000-0000-0000-000000000002','2026-04-08','Приветственный звонок: семья Иманбековы','Новая семья. Требуется первый контакт.',NULL,'system',NULL,'2026-04-03 09:00:00+06','2026-04-03 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000017','welcome_call','medium','pending','50000000-0000-0000-0000-000000000001','2026-04-10','Приветственный звонок: семья Даулетовы','Новая семья. Требуется первый контакт.',NULL,'system',NULL,'2026-04-05 09:00:00+06','2026-04-05 09:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000020','welcome_call','medium','pending','50000000-0000-0000-0000-000000000003','2026-04-12','Приветственный звонок: семья Ермековы','Новая семья в клинике 2. Требуется первый контакт.',NULL,'system',NULL,'2026-04-06 10:00:00+06','2026-04-06 10:00:00+06'),

-- === overdue_followup (12) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000002','overdue_followup','high','completed','50000000-0000-0000-0000-000000000001','2025-11-08','Семья Ахметовы: просроченное событие — осмотр педиатра','Плановый осмотр просрочен на 5 дней','Связались с семьёй. Визит перенесён на 12.11. Причина: болезнь ребёнка.','system','2025-11-07 14:00:00+06','2025-11-03 09:00:00+06','2025-11-07 14:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000004','overdue_followup','high','completed','50000000-0000-0000-0000-000000000002','2025-11-22','Семья Сериковы: просроченное событие — консультация гинеколога','Консультация просрочена на 7 дней','Мама записалась на повторный приём. Причина пропуска — командировка мужа.','system','2025-11-21 11:00:00+06','2025-11-16 10:00:00+06','2025-11-21 11:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000006','overdue_followup','high','completed','50000000-0000-0000-0000-000000000001','2025-12-12','Семья Бекболатовы: просроченное событие — плановое УЗИ','УЗИ просрочено на 10 дней','Визит перенесён. Семья уведомлена о важности своевременных обследований.','system','2025-12-11 16:30:00+06','2025-12-06 09:00:00+06','2025-12-11 16:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000008','overdue_followup','high','completed','50000000-0000-0000-0000-000000000002','2026-01-12','Семья Муратовы: просроченное событие — анализы крови','Анализы просрочены на 14 дней','Мама сдала анализы. Результаты в норме. Напомнили о следующем визите.','system','2026-01-11 10:00:00+06','2026-01-06 09:00:00+06','2026-01-11 10:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000009','overdue_followup','high','completed','50000000-0000-0000-0000-000000000001','2026-01-28','Семья Оспановы: просроченное событие — осмотр невролога','Осмотр невролога просрочен на 8 дней','Записаны на приём. Провели разъяснительную беседу о важности наблюдения.','system','2026-01-27 15:00:00+06','2026-01-22 09:00:00+06','2026-01-27 15:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000011','overdue_followup','high','pending','50000000-0000-0000-0000-000000000002','2026-02-18','Семья Темирбековы: просроченное событие — скрининг','Скрининг просрочен на 12 дней. Попытки связаться безуспешны.',NULL,'system',NULL,'2026-02-10 09:00:00+06','2026-02-10 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000013','overdue_followup','high','pending','50000000-0000-0000-0000-000000000001','2026-03-05','Семья Мадиевы: просроченное событие — консультация ортопеда','Консультация просрочена на 6 дней',NULL,'system',NULL,'2026-02-28 09:00:00+06','2026-02-28 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000015','overdue_followup','high','pending','50000000-0000-0000-0000-000000000002','2026-03-18','Семья Токтаровы: просроченное событие — контрольный визит педиатра','Контрольный визит просрочен на 4 дня',NULL,'system',NULL,'2026-03-12 09:00:00+06','2026-03-12 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000017','overdue_followup','high','pending','50000000-0000-0000-0000-000000000001','2026-04-03','Семья Даулетовы: просроченное событие — осмотр педиатра','Осмотр просрочен на 3 дня',NULL,'system',NULL,'2026-03-30 09:00:00+06','2026-03-30 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000003','overdue_followup','high','in_progress','50000000-0000-0000-0000-000000000002','2026-03-12','Семья Жумабаевы: просроченное событие — плановое УЗИ','УЗИ просрочено на 9 дней. Звоним повторно.',NULL,'system',NULL,'2026-03-05 09:00:00+06','2026-03-10 09:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000019','overdue_followup','high','in_progress','50000000-0000-0000-0000-000000000003','2026-03-22','Семья Кенжебаевы: просроченное событие — анализы крови','Анализы просрочены на 15 дней. Семья неактивна.',NULL,'system',NULL,'2026-03-15 09:00:00+06','2026-03-20 09:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000020','overdue_followup','high','dismissed','50000000-0000-0000-0000-000000000003','2026-02-05','Семья Ермековы: просроченное событие — осмотр педиатра','Осмотр просрочен. Семья посетила другую клинику.',NULL,'system',NULL,'2026-01-28 09:00:00+06','2026-02-03 09:00:00+06'),

-- === missed_appointment (8) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001','missed_appointment','high','completed','50000000-0000-0000-0000-000000000001','2025-11-10','Пропущенный визит: Консультация педиатра','Семья Нурлановы не явились на плановый приём','Связались с семьёй. Визит перенесён. Причина: забыли о записи.','system','2025-11-09 15:00:00+06','2025-11-06 09:00:00+06','2025-11-09 15:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000003','missed_appointment','high','completed','50000000-0000-0000-0000-000000000002','2025-12-18','Пропущенный визит: Плановое УЗИ','Семья Жумабаевы не явились на УЗИ','Перезаписаны на следующую неделю. Включили SMS-напоминание.','system','2025-12-17 11:00:00+06','2025-12-14 09:00:00+06','2025-12-17 11:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000007','missed_appointment','high','completed','50000000-0000-0000-0000-000000000001','2026-01-22','Пропущенный визит: Консультация гинеколога','Семья Касымовы пропустили приём гинеколога','Мама перезвонила сама. Записана на 25.01. Причина: транспорт.','system','2026-01-21 14:00:00+06','2026-01-18 09:00:00+06','2026-01-21 14:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000010','missed_appointment','high','pending','50000000-0000-0000-0000-000000000002','2026-03-08','Пропущенный визит: Осмотр невролога','Семья Сагындыковы не явились на осмотр невролога',NULL,'system',NULL,'2026-03-04 09:00:00+06','2026-03-04 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000012','missed_appointment','high','pending','50000000-0000-0000-0000-000000000001','2026-03-20','Пропущенный визит: Консультация педиатра','Семья Есенбаевы пропустили плановый приём',NULL,'system',NULL,'2026-03-16 09:00:00+06','2026-03-16 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000014','missed_appointment','high','pending','50000000-0000-0000-0000-000000000002','2026-04-04','Пропущенный визит: Скрининг','Семья Кожабековы не пришли на скрининг',NULL,'system',NULL,'2026-04-01 09:00:00+06','2026-04-01 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000016','missed_appointment','high','in_progress','50000000-0000-0000-0000-000000000001','2026-03-30','Пропущенный визит: Вакцинация','Семья Иманбековы не явились на вакцинацию. Звоним.',NULL,'system',NULL,'2026-03-26 09:00:00+06','2026-03-28 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000018','missed_appointment','high','dismissed','50000000-0000-0000-0000-000000000002','2025-12-22','Пропущенный визит: Консультация педиатра','Семья Абильдаевы. Визит отменён по инициативе клиники.',NULL,'system',NULL,'2025-12-18 09:00:00+06','2025-12-22 09:00:00+06'),

-- === low_adherence (7) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000005','low_adherence','critical','completed','50000000-0000-0000-0000-000000000001','2025-11-18','Низкая приверженность лечению: семья Тулегеновы','Приверженность 15%. Не принимают витамин D. Пропущены 3 визита.','Проведена беседа. Мама обещала возобновить приём препаратов. Контроль через неделю.','system','2025-11-17 16:00:00+06','2025-11-12 09:00:00+06','2025-11-17 16:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000019','low_adherence','critical','completed','50000000-0000-0000-0000-000000000003','2025-12-08','Низкая приверженность лечению: семья Кенжебаевы','Приверженность 10%. Семья неактивна более 20 дней.','Удалось связаться. Мама объяснила причины. План коррекции составлен.','system','2025-12-07 14:30:00+06','2025-12-02 09:00:00+06','2025-12-07 14:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000002','low_adherence','high','pending','50000000-0000-0000-0000-000000000002','2026-03-12','Низкая приверженность лечению: семья Ахметовы','Приверженность 40%. Нерегулярный приём железа.',NULL,'system',NULL,'2026-03-08 09:00:00+06','2026-03-08 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000008','low_adherence','high','pending','50000000-0000-0000-0000-000000000001','2026-03-28','Низкая приверженность лечению: семья Муратовы','Приверженность 35%. Пропуски в приёме Аквадетрим.',NULL,'system',NULL,'2026-03-22 09:00:00+06','2026-03-22 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000011','low_adherence','critical','in_progress','50000000-0000-0000-0000-000000000002','2026-02-22','Низкая приверженность лечению: семья Темирбековы','Приверженность 12%. Критически низкий уровень. Требуется вмешательство.',NULL,'system',NULL,'2026-02-16 09:00:00+06','2026-02-20 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000015','low_adherence','high','in_progress','50000000-0000-0000-0000-000000000001','2026-03-08','Низкая приверженность лечению: семья Токтаровы','Приверженность 30%. Нерегулярные визиты и приём лекарств.',NULL,'system',NULL,'2026-03-02 09:00:00+06','2026-03-06 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000017','low_adherence','high','dismissed','50000000-0000-0000-0000-000000000002','2026-01-18','Низкая приверженность лечению: семья Даулетовы','Приверженность 45%. Показатель улучшился после беседы. Задача закрыта.',NULL,'system',NULL,'2026-01-12 09:00:00+06','2026-01-18 09:00:00+06'),

-- === vaccination_reminder (10) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001','vaccination_reminder','medium','completed','50000000-0000-0000-0000-000000000001','2025-11-22','Напоминание о вакцинации: АКДС (2-я доза)','Семья Нурлановы. Вакцинация по графику.','Мама уведомлена. Вакцинация проведена в срок.','system','2025-11-21 10:00:00+06','2025-11-16 09:00:00+06','2025-11-21 10:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000003','vaccination_reminder','medium','completed','50000000-0000-0000-0000-000000000002','2025-12-15','Напоминание о вакцинации: Полиомиелит (3-я доза)','Семья Жумабаевы. Вакцинация по графику.','Уведомление отправлено. Вакцинация прошла успешно.','system','2025-12-14 11:00:00+06','2025-12-10 09:00:00+06','2025-12-14 11:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000004','vaccination_reminder','medium','completed','50000000-0000-0000-0000-000000000001','2026-01-18','Напоминание о вакцинации: Гепатит B (2-я доза)','Семья Сериковы. Вакцинация по графику.','Вакцинация проведена. Реакция нормальная.','system','2026-01-17 10:30:00+06','2026-01-12 09:00:00+06','2026-01-17 10:30:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000006','vaccination_reminder','medium','pending','50000000-0000-0000-0000-000000000002','2026-03-22','Напоминание о вакцинации: Пневмококк','Семья Бекболатовы. Приближается срок вакцинации.',NULL,'system',NULL,'2026-03-18 09:00:00+06','2026-03-18 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000007','vaccination_reminder','medium','pending','50000000-0000-0000-0000-000000000001','2026-04-05','Напоминание о вакцинации: Корь, краснуха, паротит','Семья Касымовы. Первая доза КПК.',NULL,'system',NULL,'2026-03-30 09:00:00+06','2026-03-30 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000009','vaccination_reminder','medium','pending','50000000-0000-0000-0000-000000000002','2026-04-12','Напоминание о вакцинации: АКДС (3-я доза)','Семья Оспановы. Вакцинация по графику.',NULL,'system',NULL,'2026-04-06 09:00:00+06','2026-04-06 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000010','vaccination_reminder','medium','pending','50000000-0000-0000-0000-000000000001','2026-04-18','Напоминание о вакцинации: Полиомиелит (2-я доза)','Семья Сагындыковы. Вакцинация по графику.',NULL,'system',NULL,'2026-04-07 09:00:00+06','2026-04-07 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000012','vaccination_reminder','medium','in_progress','50000000-0000-0000-0000-000000000002','2026-03-28','Напоминание о вакцинации: Ротавирус','Семья Есенбаевы. Уведомление отправлено, ожидаем подтверждения.',NULL,'system',NULL,'2026-03-22 09:00:00+06','2026-03-26 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000014','vaccination_reminder','medium','in_progress','50000000-0000-0000-0000-000000000001','2026-04-08','Напоминание о вакцинации: Гепатит B','Семья Кожабековы. Связываемся для подтверждения даты.',NULL,'system',NULL,'2026-04-02 09:00:00+06','2026-04-06 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000016','vaccination_reminder','medium','in_progress','50000000-0000-0000-0000-000000000002','2026-04-10','Напоминание о вакцинации: БЦЖ','Семья Иманбековы. Ожидаем ответ от мамы.',NULL,'system',NULL,'2026-04-04 09:00:00+06','2026-04-07 09:00:00+06'),

-- === epds_alert (3) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000003','epds_alert','critical','in_progress','50000000-0000-0000-0000-000000000001','2026-03-18','Высокий балл EPDS: Мадина Жумабаева (15 баллов)','Результат опросника EPDS = 15. Риск послеродовой депрессии. Требуется консультация психолога.',NULL,'system',NULL,'2026-03-14 09:00:00+06','2026-03-16 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000008','epds_alert','critical','in_progress','50000000-0000-0000-0000-000000000002','2026-03-22','Высокий балл EPDS: Алия Муратова (18 баллов)','Результат EPDS = 18. Высокий риск. Срочно направить к психологу.',NULL,'system',NULL,'2026-03-18 09:00:00+06','2026-03-20 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000017','epds_alert','critical','pending','50000000-0000-0000-0000-000000000001','2026-04-08','Высокий балл EPDS: Жансая Даулетова (13 баллов)','Результат EPDS = 13. Пограничный уровень. Рекомендована консультация.',NULL,'system',NULL,'2026-04-05 09:00:00+06','2026-04-05 09:00:00+06'),

-- === reactivation (5) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000005','reactivation','high','completed','50000000-0000-0000-0000-000000000002','2025-12-05','Реактивация: семья Тулегеновы не активна 30+ дней','Семья не заходила в приложение более 30 дней. Нет визитов.','Связались по телефону. Мама объяснила семейными обстоятельствами. Возобновлено наблюдение.','system','2025-12-04 14:00:00+06','2025-11-28 09:00:00+06','2025-12-04 14:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000005','reactivation','high','completed','50000000-0000-0000-0000-000000000001','2026-02-12','Реактивация: семья Тулегеновы не активна 45+ дней','Повторная неактивность. Семья не отвечает на уведомления.','Удалось связаться через WhatsApp. Семья вернулась к наблюдению.','system','2026-02-11 11:00:00+06','2026-02-05 09:00:00+06','2026-02-11 11:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000019','reactivation','high','pending','50000000-0000-0000-0000-000000000003','2026-03-18','Реактивация: семья Кенжебаевы не активна 30+ дней','Семья неактивна. Последний вход 15.02.',NULL,'system',NULL,'2026-03-12 09:00:00+06','2026-03-12 09:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000019','reactivation','high','pending','50000000-0000-0000-0000-000000000003','2026-04-05','Реактивация: семья Кенжебаевы не активна 60+ дней','Повторная попытка реактивации. Семья по-прежнему неактивна.',NULL,'system',NULL,'2026-04-01 09:00:00+06','2026-04-01 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000018','reactivation','medium','dismissed','50000000-0000-0000-0000-000000000002','2026-01-22','Реактивация: семья Абильдаевы не активна 20+ дней','Неактивность связана с отпуском. Задача неактуальна.',NULL,'system',NULL,'2026-01-15 09:00:00+06','2026-01-22 09:00:00+06'),

-- === custom (7) ===
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000001','custom','medium','completed','50000000-0000-0000-0000-000000000001','2025-11-08','Уточнить данные о беременности','Семья Нурлановы: нет данных о сроке беременности в карте','Данные уточнены и внесены. Срок 24 недели на момент регистрации.','system','2025-11-07 12:00:00+06','2025-11-03 09:00:00+06','2025-11-07 12:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000002','custom','low','completed','50000000-0000-0000-0000-000000000002','2025-12-05','Подготовить документы для выписки','Семья Ахметовы: подготовка выписного эпикриза','Документы подготовлены и отправлены маме на email.','system','2025-12-04 16:00:00+06','2025-11-28 09:00:00+06','2025-12-04 16:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000006','custom','medium','completed','50000000-0000-0000-0000-000000000001','2026-01-12','Оформить направление к узкому специалисту','Семья Бекболатовы: направление к аллергологу','Направление оформлено. Запись на 18.01.','system','2026-01-11 10:00:00+06','2026-01-08 09:00:00+06','2026-01-11 10:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000009','custom','medium','pending','50000000-0000-0000-0000-000000000002','2026-03-22','Проверить результаты анализов','Семья Оспановы: результаты биохимии не загружены в систему',NULL,'system',NULL,'2026-03-18 09:00:00+06','2026-03-18 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000012','custom','low','pending','50000000-0000-0000-0000-000000000001','2026-04-08','Обновить контактные данные семьи','Семья Есенбаевы: сменился номер телефона',NULL,'system',NULL,'2026-04-03 09:00:00+06','2026-04-03 09:00:00+06'),
('10000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000015','custom','medium','in_progress','50000000-0000-0000-0000-000000000002','2026-03-30','Согласовать план лечения с педиатром','Семья Токтаровы: требуется корректировка плана наблюдения',NULL,'system',NULL,'2026-03-25 09:00:00+06','2026-03-28 09:00:00+06'),
('10000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000020','custom','low','dismissed','50000000-0000-0000-0000-000000000003','2026-02-18','Перевести карту из другой клиники','Семья Ермековы: запросили перевод мед. карты. Отменено по желанию семьи.',NULL,'system',NULL,'2026-02-10 09:00:00+06','2026-02-18 09:00:00+06');


-- -----------------------------------------------
-- 2. notifications (~300 records via generate_series)
-- -----------------------------------------------

INSERT INTO notifications (user_id, type, channel, title, body, status, sent_at, read_at, created_at)
SELECT
  mothers.id,
  (ARRAY[
    'appointment_reminder','dose_reminder','journey_event',
    'vaccination_due','achievement','education_content','system'
  ])[floor(random()*7+1)],
  (ARRAY[
    'in_app','in_app','push','push','whatsapp','sms','email'
  ])[floor(random()*7+1)],
  CASE floor(random()*7)::int
    WHEN 0 THEN 'Напоминание о приёме'
    WHEN 1 THEN 'Время принять лекарство'
    WHEN 2 THEN 'Предстоящее событие'
    WHEN 3 THEN 'Вакцинация скоро'
    WHEN 4 THEN 'Новое достижение!'
    WHEN 5 THEN 'Новая статья для вас'
    ELSE 'Системное уведомление'
  END,
  CASE floor(random()*7)::int
    WHEN 0 THEN 'У вас запланирован приём на завтра в 10:00'
    WHEN 1 THEN 'Не забудьте принять Аквадетрим'
    WHEN 2 THEN 'Осмотр педиатра через 3 дня'
    WHEN 3 THEN 'Вакцинация АКДС запланирована на следующую неделю'
    WHEN 4 THEN 'Вы получили значок «Активная мама»!'
    WHEN 5 THEN 'Прочитайте: Введение прикорма — первые шаги'
    ELSE 'Обновление системы завершено'
  END,
  CASE
    WHEN random() < 0.60 THEN 'read'
    WHEN random() < 0.80 THEN 'delivered'
    WHEN random() < 0.90 THEN 'sent'
    WHEN random() < 0.95 THEN 'pending'
    ELSE 'failed'
  END,
  d - interval '1 minute',
  CASE WHEN random() < 0.6 THEN d + interval '30 minutes' * random() ELSE NULL END,
  d
FROM (VALUES
  ('20000000-0000-0000-0000-000000000001'::uuid),
  ('20000000-0000-0000-0000-000000000002'::uuid),
  ('20000000-0000-0000-0000-000000000003'::uuid),
  ('20000000-0000-0000-0000-000000000004'::uuid),
  ('20000000-0000-0000-0000-000000000005'::uuid),
  ('20000000-0000-0000-0000-000000000006'::uuid),
  ('20000000-0000-0000-0000-000000000007'::uuid),
  ('20000000-0000-0000-0000-000000000008'::uuid),
  ('20000000-0000-0000-0000-000000000009'::uuid),
  ('20000000-0000-0000-0000-000000000010'::uuid),
  ('20000000-0000-0000-0000-000000000011'::uuid),
  ('20000000-0000-0000-0000-000000000012'::uuid),
  ('20000000-0000-0000-0000-000000000013'::uuid),
  ('20000000-0000-0000-0000-000000000014'::uuid),
  ('20000000-0000-0000-0000-000000000015'::uuid),
  ('20000000-0000-0000-0000-000000000016'::uuid),
  ('20000000-0000-0000-0000-000000000017'::uuid),
  ('20000000-0000-0000-0000-000000000018'::uuid),
  ('20000000-0000-0000-0000-000000000019'::uuid),
  ('20000000-0000-0000-0000-000000000020'::uuid)
) AS mothers(id)
CROSS JOIN generate_series(
  CURRENT_DATE - 365,
  CURRENT_DATE - 1,
  interval '1 day'
) AS dates(d)
WHERE random() < 0.042;


-- -----------------------------------------------
-- 3. visit_ratings (~100 records from completed appointments)
-- -----------------------------------------------

INSERT INTO visit_ratings (appointment_id, family_id, rating, comment, created_at)
SELECT
  a.id,
  a.family_id,
  CASE
    WHEN random() < 0.40 THEN 5
    WHEN random() < 0.70 THEN 4
    WHEN random() < 0.85 THEN 3
    WHEN random() < 0.95 THEN 2
    ELSE 1
  END,
  CASE floor(random()*10)::int
    WHEN 0 THEN 'Отличный доктор, очень внимательная!'
    WHEN 1 THEN 'Всё прошло хорошо, ребёнок не плакал'
    WHEN 2 THEN 'Профессионально и быстро'
    WHEN 3 THEN 'Рекомендую! Доктор всё подробно объяснила'
    WHEN 4 THEN 'Длительное ожидание в очереди'
    WHEN 5 THEN 'Хороший приём, но дорого'
    WHEN 6 THEN 'Доктор торопился, не всё успели обсудить'
    WHEN 7 THEN 'Замечательный специалист!'
    WHEN 8 THEN 'Всё на высшем уровне'
    ELSE NULL
  END,
  a.created_at + interval '1 day'
FROM appointments a
WHERE a.status = 'completed'
ORDER BY random()
LIMIT 100;


-- -----------------------------------------------
-- 4. service_transactions (~300 records, growing trend over 24 months)
-- -----------------------------------------------

INSERT INTO service_transactions
  (family_id, clinic_id, service_type, amount, doctor_id, description, date, created_at)
SELECT
  (ARRAY[
    '80000000-0000-0000-0000-000000000001',
    '80000000-0000-0000-0000-000000000002',
    '80000000-0000-0000-0000-000000000003',
    '80000000-0000-0000-0000-000000000004',
    '80000000-0000-0000-0000-000000000005',
    '80000000-0000-0000-0000-000000000006',
    '80000000-0000-0000-0000-000000000007',
    '80000000-0000-0000-0000-000000000008',
    '80000000-0000-0000-0000-000000000009',
    '80000000-0000-0000-0000-000000000010',
    '80000000-0000-0000-0000-000000000011',
    '80000000-0000-0000-0000-000000000012',
    '80000000-0000-0000-0000-000000000013',
    '80000000-0000-0000-0000-000000000014',
    '80000000-0000-0000-0000-000000000015',
    '80000000-0000-0000-0000-000000000016',
    '80000000-0000-0000-0000-000000000017',
    '80000000-0000-0000-0000-000000000018'
  ]::uuid[])[floor(random()*18+1)],
  '10000000-0000-0000-0000-000000000001'::uuid,
  services.stype,
  services.base_amount + floor(random() * services.variance),
  services.doctor_id,
  services.description,
  d::date,
  d
FROM generate_series(
  CURRENT_DATE - 730,
  CURRENT_DATE - 1,
  interval '1 day'
) AS dates(d)
CROSS JOIN (VALUES
  ('Консультация гинеколога',  15000, 3000,  'b0000000-0000-0000-0000-000000000001'::uuid, 'Плановая консультация гинеколога'),
  ('Консультация педиатра',    10000, 2000,  'b0000000-0000-0000-0000-000000000002'::uuid, 'Осмотр ребёнка'),
  ('УЗИ',                      8000,  7000,  'b0000000-0000-0000-0000-000000000007'::uuid, 'Ультразвуковое исследование'),
  ('Анализы',                   5000,  20000, NULL::uuid,                                   'Лабораторные исследования'),
  ('Вакцинация',                8000,  7000,  'b0000000-0000-0000-0000-000000000002'::uuid, 'Плановая вакцинация'),
  ('Программа ведения беременности', 75000, 75000, 'b0000000-0000-0000-0000-000000000001'::uuid, 'Комплексное ведение беременности'),
  ('Скрининг',                  12000, 8000,  'b0000000-0000-0000-0000-000000000003'::uuid, 'Скрининговое обследование'),
  ('Осмотр специалиста',        15000, 5000,  'b0000000-0000-0000-0000-000000000005'::uuid, 'Осмотр профильного специалиста')
) AS services(stype, base_amount, variance, doctor_id, description)
WHERE random() < (
  0.025 + 0.03 * (
    extract(epoch FROM d - (CURRENT_DATE - 730))
    / extract(epoch FROM interval '730 days')
  )
);
-- Probability grows from ~0.025 to ~0.055 over 2 years.
-- 730 days x 8 services x avg(0.04) ≈ 233 rows from clinic 1.
-- Second INSERT below adds clinic 2 rows to reach ~300 total.

-- Clinic 2 transactions (smaller volume)
INSERT INTO service_transactions
  (family_id, clinic_id, service_type, amount, doctor_id, description, date, created_at)
SELECT
  (ARRAY[
    '80000000-0000-0000-0000-000000000019',
    '80000000-0000-0000-0000-000000000020'
  ]::uuid[])[floor(random()*2+1)],
  '10000000-0000-0000-0000-000000000002'::uuid,
  services.stype,
  services.base_amount + floor(random() * services.variance),
  services.doctor_id,
  services.description,
  d::date,
  d
FROM generate_series(
  CURRENT_DATE - 730,
  CURRENT_DATE - 1,
  interval '1 day'
) AS dates(d)
CROSS JOIN (VALUES
  ('Консультация гинеколога',  15000, 3000,  'b0000000-0000-0000-0000-000000000004'::uuid, 'Плановая консультация гинеколога'),
  ('Консультация педиатра',    10000, 2000,  'b0000000-0000-0000-0000-000000000005'::uuid, 'Осмотр ребёнка'),
  ('УЗИ',                      8000,  7000,  'b0000000-0000-0000-0000-000000000008'::uuid, 'Ультразвуковое исследование'),
  ('Анализы',                   5000,  20000, NULL::uuid,                                   'Лабораторные исследования'),
  ('Вакцинация',                8000,  7000,  'b0000000-0000-0000-0000-000000000005'::uuid, 'Плановая вакцинация'),
  ('Скрининг',                  12000, 8000,  'b0000000-0000-0000-0000-000000000004'::uuid, 'Скрининговое обследование')
) AS services(stype, base_amount, variance, doctor_id, description)
WHERE random() < (
  0.008 + 0.01 * (
    extract(epoch FROM d - (CURRENT_DATE - 730))
    / extract(epoch FROM interval '730 days')
  )
);
-- ~730 * 6 * avg(0.013) ≈ 57 rows from clinic 2.
-- Combined total ≈ 290-310 rows.
-- =============================================================================
-- SEED 05 EXTENDED — Part of a larger seed file (no BEGIN/COMMIT)
-- =============================================================================

-- =============================================================================
-- 1. HEALTH PASSPORT ENTRIES (~80 records, 4 per child)
-- =============================================================================

-- ch01 (670 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000001', 'birth_record', 'рождение', CURRENT_DATE - 670, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3350 г, рост 51 см. Оценка по Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000001', 'vaccination', 'иммунизация', CURRENT_DATE - 669, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена в левое плечо. Реакция в пределах нормы.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000001', 'measurement', 'рост', CURRENT_DATE - 580, 'Измерение роста и веса 3 мес', 'Вес 6.1 кг, рост 61 см. Развитие соответствует возрасту.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000001', 'diagnosis', 'диагностика', CURRENT_DATE - 300, 'Диагноз: железодефицитная анемия лёгкой степени', 'Гемоглобин 105 г/л. Назначены препараты железа курсом 1 месяц.', 'b0000000-0000-0000-0000-000000000002', 'clinic');

-- ch02 (150 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000002', 'birth_record', 'рождение', CURRENT_DATE - 150, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3500 г, рост 52 см. Оценка по Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000002', 'vaccination', 'иммунизация', CURRENT_DATE - 149, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена в левое плечо. Без осложнений.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000002', 'vaccination', 'иммунизация', CURRENT_DATE - 88, 'Вакцинация АКДС (1-я доза)', 'Первая доза АКДС введена. Местная реакция: лёгкое покраснение.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000002', 'measurement', 'рост', CURRENT_DATE - 60, 'Измерение роста и веса 3 мес', 'Вес 6.2 кг, рост 60 см. Показатели в норме.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch03 (425 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000003', 'birth_record', 'рождение', CURRENT_DATE - 425, 'Запись о рождении', 'Роды путём кесарева сечения, срок 38 недель. Вес 3200 г, рост 49 см. Апгар 7/8.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000003', 'vaccination', 'иммунизация', CURRENT_DATE - 424, 'Вакцинация гепатит B (1-я доза)', 'Первая доза вакцины против гепатита B. Переносимость хорошая.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000003', 'screening', 'скрининг', CURRENT_DATE - 420, 'Неонатальный скрининг', 'Забор крови на 5 наследственных заболеваний. Результаты в норме.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000003', 'measurement', 'рост', CURRENT_DATE - 245, 'Измерение роста и веса 6 мес', 'Вес 7.8 кг, рост 67 см. Развитие по возрасту.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch04 (42 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000004', 'birth_record', 'рождение', CURRENT_DATE - 42, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3450 г, рост 50 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000004', 'vaccination', 'иммунизация', CURRENT_DATE - 41, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена. Реакция нормальная.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000004', 'vaccination', 'иммунизация', CURRENT_DATE - 41, 'Вакцинация гепатит B (1-я доза)', 'Первая доза в роддоме. Без осложнений.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000004', 'screening', 'скрининг', CURRENT_DATE - 38, 'Неонатальный скрининг', 'Забор крови из пятки. Все показатели в пределах нормы.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch05 (300 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000005', 'birth_record', 'рождение', CURRENT_DATE - 300, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3600 г, рост 52 см. Апгар 9/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000005', 'vaccination', 'иммунизация', CURRENT_DATE - 299, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена в левое плечо.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000005', 'allergy_test', 'аллергология', CURRENT_DATE - 120, 'Аллергопроба: яйцо', 'Выявлена аллергическая реакция на яичный белок. IgE повышен. Рекомендована элиминационная диета.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000005', 'measurement', 'рост', CURRENT_DATE - 120, 'Измерение роста и веса 6 мес', 'Вес 7.5 кг, рост 66 см. Физическое развитие в норме.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch06 (335 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000006', 'birth_record', 'рождение', CURRENT_DATE - 335, 'Запись о рождении', 'Роды естественные, срок 38 недель. Вес 3100 г, рост 49 см. Апгар 8/8.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000006', 'vaccination', 'иммунизация', CURRENT_DATE - 274, 'Вакцинация АКДС (1-я доза)', 'Введена первая доза АКДС. Температура 37.5 на следующий день — норма.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000006', 'measurement', 'рост', CURRENT_DATE - 155, 'Измерение роста и веса 6 мес', 'Вес 7.6 кг, рост 66 см. Рост стабильный.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000006', 'diagnosis', 'диагностика', CURRENT_DATE - 100, 'Диагноз: функциональное расстройство ЖКТ', 'Периодические срыгивания. Рекомендовано дробное кормление, наблюдение.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch07 (610 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000007', 'birth_record', 'рождение', CURRENT_DATE - 610, 'Запись о рождении', 'Роды естественные, срок 41 неделя. Вес 3700 г, рост 53 см. Апгар 9/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000007', 'vaccination', 'иммунизация', CURRENT_DATE - 609, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М. Рубчик сформировался к 3 месяцам.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000007', 'vaccination', 'иммунизация', CURRENT_DATE - 245, 'Вакцинация КПК (корь, паротит, краснуха)', 'Вакцина КПК введена в 12 месяцев. Переносимость хорошая.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000007', 'measurement', 'рост', CURRENT_DATE - 65, 'Измерение роста и веса 18 мес', 'Вес 11.3 кг, рост 82 см. Показатели выше среднего.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch08 (120 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000008', 'birth_record', 'рождение', CURRENT_DATE - 120, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3250 г, рост 50 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000008', 'vaccination', 'иммунизация', CURRENT_DATE - 119, 'Вакцинация гепатит B (1-я доза)', 'Первая доза гепатит B в роддоме. Без реакции.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000008', 'screening', 'скрининг', CURRENT_DATE - 116, 'Аудиологический скрининг', 'Проверка слуха новорождённого. Результат: норма с обеих сторон.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000008', 'measurement', 'рост', CURRENT_DATE - 30, 'Измерение роста и веса 3 мес', 'Вес 5.9 кг, рост 60 см. Прибавка в весе хорошая.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch09 (270 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000009', 'birth_record', 'рождение', CURRENT_DATE - 270, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3400 г, рост 51 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000009', 'vaccination', 'иммунизация', CURRENT_DATE - 269, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена. Нормальная поствакцинальная реакция.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000009', 'allergy_test', 'аллергология', CURRENT_DATE - 60, 'Аллергопроба: коровье молоко', 'Выявлена непереносимость белка коровьего молока. Рекомендована гипоаллергенная смесь.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000009', 'measurement', 'рост', CURRENT_DATE - 0, 'Измерение роста и веса 9 мес', 'Вес 8.7 кг, рост 71 см. Развитие нормальное.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch10 (60 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000010', 'birth_record', 'рождение', CURRENT_DATE - 60, 'Запись о рождении', 'Роды путём кесарева сечения, срок 37 недель. Вес 2900 г, рост 48 см. Апгар 7/8.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000010', 'vaccination', 'иммунизация', CURRENT_DATE - 59, 'Вакцинация гепатит B (1-я доза)', 'Первая доза в роддоме. Переносимость удовлетворительная.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000010', 'screening', 'скрининг', CURRENT_DATE - 56, 'Неонатальный скрининг', 'Результаты неонатального скрининга — норма по всем показателям.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000010', 'measurement', 'рост', CURRENT_DATE - 30, 'Измерение роста и веса 1 мес', 'Вес 3.8 кг, рост 52 см. Набор веса нормальный.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch11 (550 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000011', 'birth_record', 'рождение', CURRENT_DATE - 550, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3550 г, рост 52 см. Апгар 9/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000011', 'vaccination', 'иммунизация', CURRENT_DATE - 549, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена. Нормальный рубчик.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000011', 'vaccination', 'иммунизация', CURRENT_DATE - 185, 'Вакцинация КПК', 'Вакцина КПК в 12 месяцев. Лёгкая сыпь на 7-й день — вариант нормы.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000011', 'measurement', 'рост', CURRENT_DATE - 10, 'Измерение роста и веса 18 мес', 'Вес 11.0 кг, рост 81 см. Развитие в норме.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch12 (90 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000012', 'birth_record', 'рождение', CURRENT_DATE - 90, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3300 г, рост 50 см. Апгар 8/8.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000012', 'vaccination', 'иммунизация', CURRENT_DATE - 89, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М. Без осложнений.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000012', 'screening', 'скрининг', CURRENT_DATE - 86, 'Аудиологический скрининг', 'Проверка слуха: норма.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000012', 'measurement', 'рост', CURRENT_DATE - 0, 'Измерение роста и веса 3 мес', 'Вес 6.0 кг, рост 60 см. Нормальное развитие.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch13 (240 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000013', 'birth_record', 'рождение', CURRENT_DATE - 240, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3150 г, рост 49 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000013', 'vaccination', 'иммунизация', CURRENT_DATE - 179, 'Вакцинация АКДС (1-я доза)', 'Первая доза АКДС. Температура 37.8 — рекомендован парацетамол.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000013', 'allergy_test', 'аллергология', CURRENT_DATE - 50, 'Аллергопроба: яйцо', 'Положительная реакция на яичный белок. IgE 12.5 кЕд/л. Элиминационная диета.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000013', 'measurement', 'рост', CURRENT_DATE - 60, 'Измерение роста и веса 6 мес', 'Вес 7.4 кг, рост 65 см. Показатели на нижней границе нормы.', 'b0000000-0000-0000-0000-000000000002', 'clinic');

-- ch14 (730 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000014', 'birth_record', 'рождение', CURRENT_DATE - 730, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3650 г, рост 53 см. Апгар 9/10.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000014', 'vaccination', 'иммунизация', CURRENT_DATE - 365, 'Вакцинация КПК', 'КПК в 12 месяцев. Без побочных эффектов.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000014', 'diagnosis', 'диагностика', CURRENT_DATE - 200, 'Диагноз: атопический дерматит', 'Сухость кожи на щеках и сгибах. Назначены эмоленты и гипоаллергенная диета.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000014', 'measurement', 'рост', CURRENT_DATE - 5, 'Измерение роста и веса 24 мес', 'Вес 12.6 кг, рост 87 см. Развитие соответствует возрасту.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch15 (240 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000015', 'birth_record', 'рождение', CURRENT_DATE - 240, 'Запись о рождении', 'Роды естественные, срок 38 недель. Вес 3050 г, рост 48 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000015', 'vaccination', 'иммунизация', CURRENT_DATE - 239, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М. Нормальная реакция.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000015', 'vaccination', 'иммунизация', CURRENT_DATE - 178, 'Вакцинация АКДС (1-я доза)', 'АКДС первая доза. Лёгкое уплотнение в месте инъекции.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000015', 'measurement', 'рост', CURRENT_DATE - 60, 'Измерение роста и веса 6 мес', 'Вес 7.3 кг, рост 65 см. Развитие в норме.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch16 (30 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000016', 'birth_record', 'рождение', CURRENT_DATE - 30, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3200 г, рост 50 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000016', 'vaccination', 'иммунизация', CURRENT_DATE - 29, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М. Без осложнений.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000016', 'vaccination', 'иммунизация', CURRENT_DATE - 29, 'Вакцинация гепатит B (1-я доза)', 'Первая доза гепатит B. Переносимость хорошая.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000016', 'screening', 'скрининг', CURRENT_DATE - 26, 'Неонатальный скрининг', 'Скрининг 5 наследственных заболеваний — норма.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch17 (395 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000017', 'birth_record', 'рождение', CURRENT_DATE - 395, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3500 г, рост 51 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000017', 'vaccination', 'иммунизация', CURRENT_DATE - 394, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М. Рубчик 5 мм к 3 мес.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000017', 'vaccination', 'иммунизация', CURRENT_DATE - 30, 'Вакцинация КПК', 'КПК в 12 месяцев. Переносимость хорошая.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000017', 'measurement', 'рост', CURRENT_DATE - 30, 'Измерение роста и веса 12 мес', 'Вес 9.9 кг, рост 76 см. Хорошая прибавка.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch18 (30 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000018', 'birth_record', 'рождение', CURRENT_DATE - 30, 'Запись о рождении', 'Роды путём кесарева сечения, срок 38 недель. Вес 3100 г, рост 49 см. Апгар 7/8.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000018', 'vaccination', 'иммунизация', CURRENT_DATE - 29, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М введена.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000018', 'vaccination', 'иммунизация', CURRENT_DATE - 29, 'Вакцинация гепатит B (1-я доза)', 'Первая доза гепатит B в роддоме.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000018', 'screening', 'скрининг', CURRENT_DATE - 26, 'Неонатальный скрининг', 'Анализ крови из пятки: все показатели в норме.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch19 (90 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000019', 'birth_record', 'рождение', CURRENT_DATE - 90, 'Запись о рождении', 'Роды естественные, срок 40 недель. Вес 3400 г, рост 51 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000019', 'vaccination', 'иммунизация', CURRENT_DATE - 89, 'Вакцинация БЦЖ', 'БЦЖ-М. Без осложнений.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000019', 'measurement', 'рост', CURRENT_DATE - 60, 'Измерение роста и веса 1 мес', 'Вес 4.2 кг, рост 54 см. Набор веса хороший.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000019', 'measurement', 'рост', CURRENT_DATE - 0, 'Измерение роста и веса 3 мес', 'Вес 5.8 кг, рост 60 см. Развитие по возрасту.', 'b0000000-0000-0000-0000-000000000006', 'clinic');

-- ch20 (488 days old)
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000020', 'birth_record', 'рождение', CURRENT_DATE - 488, 'Запись о рождении', 'Роды естественные, срок 39 недель. Вес 3350 г, рост 51 см. Апгар 8/9.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000020', 'vaccination', 'иммунизация', CURRENT_DATE - 487, 'Вакцинация БЦЖ', 'Вакцина БЦЖ-М. Рубчик сформировался нормально.', 'b0000000-0000-0000-0000-000000000002', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000020', 'vaccination', 'иммунизация', CURRENT_DATE - 123, 'Вакцинация КПК', 'КПК в 12 месяцев. Без побочных реакций.', 'b0000000-0000-0000-0000-000000000006', 'clinic');
INSERT INTO health_passport_entries (child_id, type, category, date, title, description, doctor_id, source)
VALUES ('90000000-0000-0000-0000-000000000020', 'measurement', 'рост', CURRENT_DATE - 38, 'Измерение роста и веса 15 мес', 'Вес 10.6 кг, рост 79 см. Развитие стабильное.', 'b0000000-0000-0000-0000-000000000006', 'clinic');


-- =============================================================================
-- 2. AI CONVERSATIONS (20 records)
-- =============================================================================

-- ai01: m01/ch01 — Ребёнку 22 месяца, не говорит фразы
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001',
'[{"role":"user","content":"Моему ребёнку 22 месяца, но он до сих пор не говорит фразами. Только отдельные слова: мама, папа, дай. Это нормально?","timestamp":"2026-03-15T10:30:00Z"},{"role":"assistant","content":"В 22 месяца многие дети ещё не говорят фразами — это вариант нормы. Важно, чтобы ребёнок понимал обращённую речь и имел словарный запас не менее 10-15 слов. Рекомендую: больше читайте вслух, комментируйте свои действия, задавайте простые вопросы. Если к 2 годам фразовая речь не появится, стоит проконсультироваться с логопедом.","timestamp":"2026-03-15T10:30:05Z"},{"role":"user","content":"А какие упражнения можно делать дома для развития речи?","timestamp":"2026-03-15T10:31:00Z"},{"role":"assistant","content":"Отличные упражнения для развития речи: 1) Пальчиковые игры — они стимулируют речевые центры мозга. 2) Дыхательная гимнастика — дуть на перышко, мыльные пузыри. 3) Артикуляционная гимнастика — высовывать язык, надувать щёки, цокать. 4) Чтение книг с картинками — просите показывать и называть предметы. 5) Пение простых песенок с повторами. Занимайтесь по 5-10 минут несколько раз в день в игровой форме.","timestamp":"2026-03-15T10:31:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '24 days', CURRENT_TIMESTAMP - interval '24 days');

-- ai02: m02/ch03 — Температура после вакцинации
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000003',
'[{"role":"user","content":"Вчера сделали прививку АКДС, сегодня температура 37.8. Ребёнку 14 месяцев. Что делать?","timestamp":"2026-03-18T09:15:00Z"},{"role":"assistant","content":"Температура 37.8°C после прививки АКДС — нормальная поствакцинальная реакция, которая обычно длится 1-3 дня. Рекомендую: давайте больше жидкости, одевайте легко, проветривайте комнату. Если температура поднимется выше 38.5°C, можно дать жаропонижающее (ибупрофен или парацетамол в возрастной дозировке). Место инъекции может быть слегка покрасневшим — это тоже нормально.","timestamp":"2026-03-18T09:15:05Z"},{"role":"user","content":"А когда нужно вызывать врача?","timestamp":"2026-03-18T09:16:00Z"},{"role":"assistant","content":"Обратитесь к врачу, если: 1) Температура выше 39.5°C и не снижается жаропонижающими. 2) Температура держится более 3 дней. 3) Появилась сильная отёчность или покраснение более 8 см в месте укола. 4) Ребёнок непрерывно плачет более 3 часов. 5) Появились судороги. 6) Ребёнок отказывается от еды и питья. В вашем случае 37.8 — это неопасно, но следите за состоянием малыша.","timestamp":"2026-03-18T09:16:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '21 days', CURRENT_TIMESTAMP - interval '21 days');

-- ai03: m04/ch04 — Новорождённый плохо спит
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000004', '90000000-0000-0000-0000-000000000004',
'[{"role":"user","content":"Нашему малышу 6 недель, он очень плохо спит ночью. Просыпается каждый час и плачет. Мы совершенно измотаны.","timestamp":"2026-03-20T23:45:00Z"},{"role":"assistant","content":"Понимаю вашу усталость — это один из самых сложных периодов. В 6 недель сон ещё не организован, циклы короткие (40-50 минут). Попробуйте: 1) Пеленание — создаёт чувство безопасности. 2) Белый шум — напоминает звуки в утробе. 3) Укачивание или ношение на руках перед сном. 4) Затемнение комнаты ночью. 5) Кормление по требованию — малыш может просыпаться от голода. К 3 месяцам сон обычно становится более организованным.","timestamp":"2026-03-20T23:45:05Z"},{"role":"user","content":"Пеленание не навредит?","timestamp":"2026-03-20T23:46:00Z"},{"role":"assistant","content":"Свободное пеленание безопасно и рекомендуется педиатрами до 3-4 месяцев. Важно: 1) Не пеленайте слишком туго — бёдра должны свободно двигаться. 2) Используйте тонкую хлопковую пелёнку. 3) Не перегревайте ребёнка. 4) Укладывайте спать только на спину. 5) Прекратите пеленание, когда малыш начнёт переворачиваться. Многие малыши действительно лучше спят в пелёнке, так как она предотвращает рефлекс Моро (вздрагивание).","timestamp":"2026-03-20T23:46:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '19 days', CURRENT_TIMESTAMP - interval '19 days');

-- ai04: m06/ch06 — Прикорм в 6 месяцев
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000004', '20000000-0000-0000-0000-000000000006', '90000000-0000-0000-0000-000000000006',
'[{"role":"user","content":"Ребёнку скоро 6 месяцев. Какой прикорм лучше начать? С чего начать?","timestamp":"2026-02-10T14:00:00Z"},{"role":"assistant","content":"ВОЗ рекомендует начинать прикорм с 6 месяцев. Лучше всего начать с овощного пюре — кабачок считается идеальным первым овощем: он гипоаллергенный, мягкий и легко усваивается. Схема введения: 1) Первый день — 0.5-1 чайная ложка. 2) Каждый день увеличивайте на 1 ложку. 3) За 7-10 дней доведите до 100-150 г. 4) Затем вводите следующий овощ — брокколи или цветную капусту. 5) Новый продукт — раз в 3-5 дней. Давайте прикорм в первой половине дня, чтобы отследить реакцию.","timestamp":"2026-02-10T14:00:05Z"},{"role":"user","content":"А каши когда добавлять?","timestamp":"2026-02-10T14:01:00Z"},{"role":"assistant","content":"Каши обычно вводят через 2-3 недели после овощей. Начните с безглютеновых: рисовая, гречневая или кукурузная каша. Готовьте на воде или грудном молоке (не на коровьем молоке до 1 года). Начинайте также с 1 чайной ложки, постепенно увеличивая объём. К 7 месяцам малыш может съедать 100-150 г каши. Глютеновые каши (овсяная, пшеничная) лучше отложить до 7-8 месяцев.","timestamp":"2026-02-10T14:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '57 days', CURRENT_TIMESTAMP - interval '57 days');

-- ai05: m07/ch07 — Ребёнок бьётся головой
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000005', '20000000-0000-0000-0000-000000000007', '90000000-0000-0000-0000-000000000007',
'[{"role":"user","content":"Мой ребёнок (20 месяцев) стал биться головой о пол или стенку, когда злится. Это очень пугает. Он нормальный?","timestamp":"2026-03-10T18:20:00Z"},{"role":"assistant","content":"Это пугающее, но довольно распространённое поведение у детей 18-24 месяцев. В этом возрасте ребёнок ещё не умеет управлять эмоциями и выражает фрустрацию физически. Обычно это проходит к 3 годам. Рекомендации: 1) Сохраняйте спокойствие — не показывайте испуг. 2) Обеспечьте безопасность — подложите мягкое. 3) Не подкрепляйте поведение чрезмерным вниманием. 4) Помогите назвать эмоцию: «Ты злишься». 5) Предложите альтернативу: потопать ножками, помять пластилин.","timestamp":"2026-03-10T18:20:05Z"},{"role":"user","content":"А когда стоит беспокоиться?","timestamp":"2026-03-10T18:21:00Z"},{"role":"assistant","content":"Обратитесь к педиатру или неврологу, если: 1) Ребёнок бьётся головой очень часто (более 10 раз в день). 2) Поведение продолжается после 3 лет. 3) Ребёнок причиняет себе заметные травмы. 4) Сопровождается задержкой речи или социального развития. 5) Происходит не только при злости, но и в спокойном состоянии (например, перед сном ритмично). В вашем случае, если это только при фрустрации — скорее всего, нормальный этап развития.","timestamp":"2026-03-10T18:21:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '29 days', CURRENT_TIMESTAMP - interval '29 days');

-- ai06: m09/ch09 — Колики у ребёнка 9 месяцев
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000006', '20000000-0000-0000-0000-000000000009', '90000000-0000-0000-0000-000000000009',
'[{"role":"user","content":"У ребёнка 9 месяцев часто болит живот, поджимает ножки и плачет. Это колики? Думала, они к 3 месяцам проходят.","timestamp":"2026-03-05T11:00:00Z"},{"role":"assistant","content":"Вы правы — классические колики обычно проходят к 3-4 месяцам. В 9 месяцев боли в животе чаще связаны с введением прикорма, запорами или газообразованием от новых продуктов. Рекомендации: 1) Массаж живота по часовой стрелке. 2) Выкладывание на животик. 3) Тёплая пелёнка на живот. 4) Пересмотрите рацион — возможно, какой-то продукт вызывает дискомфорт. 5) Следите за стулом. Если боли частые и сильные, обратитесь к педиатру для исключения других причин.","timestamp":"2026-03-05T11:00:05Z"},{"role":"user","content":"Может, это аллергия на что-то?","timestamp":"2026-03-05T11:01:00Z"},{"role":"assistant","content":"Пищевая аллергия или непереносимость действительно может вызывать боли в животе. Признаки: боль после определённого продукта, вздутие, изменение стула (пенистый, с примесью слизи), кожные проявления. Попробуйте вести пищевой дневник 1-2 недели, отмечая все продукты и реакции. Если подозреваете аллергию — исключите подозрительный продукт на 2 недели и наблюдайте. Для точной диагностики можно сдать анализ на специфические IgE.","timestamp":"2026-03-05T11:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '34 days', CURRENT_TIMESTAMP - interval '34 days');

-- ai07: m10/ch10 — Срыгивания у 2-месячного
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000007', '20000000-0000-0000-0000-000000000010', '90000000-0000-0000-0000-000000000010',
'[{"role":"user","content":"Малышу 2 месяца, после каждого кормления срыгивает. Иногда довольно много. Это нормально?","timestamp":"2026-03-22T07:30:00Z"},{"role":"assistant","content":"Срыгивания у детей до 4-6 месяцев — очень частое явление и в большинстве случаев являются нормой. Нормальный объём срыгивания — до 1-2 столовых ложек (кажется больше, чем есть). Это связано с незрелостью сфинктера между пищеводом и желудком. Рекомендации: 1) Держите малыша вертикально 15-20 минут после кормления. 2) Не перекармливайте. 3) Слегка приподнимите головной конец кроватки. 4) Убедитесь в правильном захвате груди. К 6-7 месяцам срыгивания обычно прекращаются.","timestamp":"2026-03-22T07:30:05Z"},{"role":"user","content":"А когда срыгивания опасны?","timestamp":"2026-03-22T07:31:00Z"},{"role":"assistant","content":"Обратитесь к врачу, если: 1) Рвота фонтаном на расстояние 30+ см. 2) Срыгивания зелёного или коричневого цвета. 3) Ребёнок плохо набирает вес. 4) Малыш выгибается и плачет при кормлении. 5) Срыгивания усиливаются после 4-5 месяцев. 6) Есть примесь крови. Это может указывать на гастроэзофагеальный рефлюкс или стеноз привратника, которые требуют лечения.","timestamp":"2026-03-22T07:31:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '17 days', CURRENT_TIMESTAMP - interval '17 days');

-- ai08: m11/ch11 — Когда начинать чистить зубы
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000008', '20000000-0000-0000-0000-000000000011', '90000000-0000-0000-0000-000000000011',
'[{"role":"user","content":"Ребёнку 18 месяцев, у него 12 зубов. Когда нужно начинать чистить зубы и какой пастой?","timestamp":"2026-02-25T20:00:00Z"},{"role":"assistant","content":"Начинать чистить зубы нужно с появления первого зуба! Но не поздно начать и сейчас. Рекомендации: 1) Используйте мягкую детскую щётку с маленькой головкой. 2) Паста — детская, с содержанием фтора 500-1000 ppm, размером с рисовое зёрнышко. 3) Чистите 2 раза в день — утром и перед сном. 4) До 3 лет зубы чистят родители. 5) Движения — от десны к краю зуба, каждую поверхность. 6) Не давайте полоскать рот — пусть выплюнет остатки пасты.","timestamp":"2026-02-25T20:00:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '42 days', CURRENT_TIMESTAMP - interval '42 days');

-- ai09: m13/ch13 — Аллергия на яйцо
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000009', '20000000-0000-0000-0000-000000000013', '90000000-0000-0000-0000-000000000013',
'[{"role":"user","content":"У ребёнка 8 месяцев проявилась аллергия на яйцо — высыпания по телу после того, как попробовал омлет. Что теперь делать?","timestamp":"2026-03-01T12:00:00Z"},{"role":"assistant","content":"Аллергия на яйцо — одна из самых частых пищевых аллергий у детей. Важно: 1) Полностью исключите яйцо и продукты с ним из рациона (выпечка, макароны, соусы). 2) Читайте состав всех продуктов. 3) Обратитесь к аллергологу для подтверждения диагноза (анализ крови на IgE к яичному белку). 4) Имейте антигистаминное средство под рукой. Хорошая новость: большинство детей перерастают аллергию на яйцо к 5-7 годам.","timestamp":"2026-03-01T12:00:05Z"},{"role":"user","content":"А вакцины? Там же яичный белок может быть?","timestamp":"2026-03-01T12:01:00Z"},{"role":"assistant","content":"Это важный вопрос. Некоторые вакцины (КПК, против гриппа) могут содержать следы яичного белка. Однако современные исследования показали, что вакцина КПК безопасна даже для детей с аллергией на яйцо — количество белка минимально. Вакцину от гриппа можно заменить на не содержащую яйца. Обязательно предупредите педиатра перед каждой вакцинацией о наличии аллергии. Прививки делаются под наблюдением 30 минут.","timestamp":"2026-03-01T12:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '38 days', CURRENT_TIMESTAMP - interval '38 days');

-- ai10: m14/ch14 — Ребёнок 2 года не ест мясо
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000010', '20000000-0000-0000-0000-000000000014', '90000000-0000-0000-0000-000000000014',
'[{"role":"user","content":"Сыну 2 года, категорически отказывается есть мясо — выплёвывает. Боюсь, что не хватает белка и железа.","timestamp":"2026-02-20T16:00:00Z"},{"role":"assistant","content":"Отказ от мяса в 2 года — частое явление. Дети могут не любить текстуру мяса. Альтернативные источники белка и железа: 1) Птица (индейка, курица) — попробуйте котлеты, тефтели, суфле. 2) Рыба — если нет аллергии. 3) Бобовые — чечевица, горох. 4) Яйца — если нет аллергии. 5) Творог, кефир. 6) Гречневая каша — источник железа. Для лучшего усвоения железа давайте с витамином С (фрукты). Попробуйте разные формы приготовления мяса — суфле и тефтели дети принимают лучше, чем куски.","timestamp":"2026-02-20T16:00:05Z"},{"role":"user","content":"Может, стоит сдать анализ на гемоглобин?","timestamp":"2026-02-20T16:01:00Z"},{"role":"assistant","content":"Обязательно стоит. Общий анализ крови покажет уровень гемоглобина. Норма для 2 лет — от 110 г/л. Также полезно проверить сывороточное железо и ферритин — они покажут запасы железа в организме. Если гемоглобин снижен, педиатр назначит препараты железа. Анализ лучше сдавать утром натощак (или через 2 часа после еды).","timestamp":"2026-02-20T16:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '47 days', CURRENT_TIMESTAMP - interval '47 days');

-- ai11: m01/ch02 — Как увеличить лактацию
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000011', '20000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000002',
'[{"role":"user","content":"Второму ребёнку 5 месяцев, кажется, что молока стало меньше. Как увеличить лактацию?","timestamp":"2026-03-25T08:00:00Z"},{"role":"assistant","content":"Ощущение нехватки молока — очень частая тревога мам, но часто молока достаточно. Проверьте: ребёнок мочит 6+ подгузников в день? Набирает вес? Если да — молока хватает. Для поддержания лактации: 1) Частое прикладывание — каждые 2-3 часа, включая ночью. 2) Полноценное опорожнение груди. 3) Обильное питьё — 2-2.5 литра в день. 4) Полноценное питание. 5) Контакт «кожа к коже». 6) Отдых и сон — стресс снижает выработку молока. 7) Чай с фенхелем может помочь.","timestamp":"2026-03-25T08:00:05Z"},{"role":"user","content":"А лактогонные чаи помогают?","timestamp":"2026-03-25T08:01:00Z"},{"role":"assistant","content":"Лактогонные чаи (с фенхелем, тмином, анисом) могут оказывать лёгкий стимулирующий эффект, но основной фактор — это частое и правильное прикладывание. Доказанного сильного эффекта у чаёв нет. Самое главное — принцип спроса и предложения: чем чаще ребёнок сосёт, тем больше молока вырабатывается. Избегайте допаивания смесью без рекомендации врача — это может снизить лактацию.","timestamp":"2026-03-25T08:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '14 days', CURRENT_TIMESTAMP - interval '14 days');

-- ai12: m07/ch08 — Младенец тянет всё в рот
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000012', '20000000-0000-0000-0000-000000000007', '90000000-0000-0000-0000-000000000008',
'[{"role":"user","content":"Младшему 4 месяца, тянет абсолютно всё в рот — пальцы, игрушки, одежду. Это нормально или зубы лезут?","timestamp":"2026-03-12T15:00:00Z"},{"role":"assistant","content":"Это совершенно нормальное поведение для 4 месяцев! Оральная фаза развития — ребёнок познаёт мир через рот. Это не обязательно означает прорезывание зубов (хотя и может совпасть). Для малыша рот — главный инструмент исследования. Рекомендации: 1) Давайте безопасные прорезыватели и игрушки без мелких деталей. 2) Следите за чистотой предметов. 3) Не запрещайте — это важный этап развития. 4) Уберите мелкие и опасные предметы из зоны досягаемости. Оральная фаза длится примерно до 12-18 месяцев.","timestamp":"2026-03-12T15:00:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '27 days', CURRENT_TIMESTAMP - interval '27 days');

-- ai13: m02/NULL — Как подготовиться к прикорму
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000013', '20000000-0000-0000-0000-000000000002', NULL,
'[{"role":"user","content":"Хочу заранее подготовиться к введению прикорма. Что нужно купить и знать?","timestamp":"2026-03-08T10:00:00Z"},{"role":"assistant","content":"Отлично, что готовитесь заранее! Чек-лист для начала прикорма: Что купить: 1) Силиконовая ложка с мягким кончиком. 2) Тарелка на присоске. 3) Нагрудник (силиконовый с кармашком). 4) Блендер или погружной измельчитель. 5) Контейнеры для заморозки порций. 6) Стульчик для кормления. Что знать: 1) Начинайте не ранее 6 месяцев. 2) Признаки готовности: сидит с поддержкой, интересуется едой, исчез рефлекс выталкивания. 3) Первый продукт — кабачок или рисовая каша. 4) Новый продукт — раз в 3-5 дней. 5) Начинайте с 0.5 чайной ложки.","timestamp":"2026-03-08T10:00:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '31 days', CURRENT_TIMESTAMP - interval '31 days');

-- ai14: m03/NULL — Тошнота на 20 неделе
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000014', '20000000-0000-0000-0000-000000000003', NULL,
'[{"role":"user","content":"Я на 20 неделе беременности, а тошнота всё ещё не прошла. Когда это закончится?","timestamp":"2026-02-15T09:30:00Z"},{"role":"assistant","content":"К сожалению, у некоторых женщин тошнота может сохраняться до 20-22 недель, а в редких случаях — до конца беременности. Рекомендации: 1) Ешьте маленькими порциями каждые 2-3 часа. 2) Имбирный чай или имбирные леденцы. 3) Сухое печенье утром перед подъёмом. 4) Избегайте резких запахов. 5) Витамин B6 (пиридоксин) — по рекомендации врача. 6) Свежий воздух и прогулки. Если рвота более 3-4 раз в день, теряете вес или обезвоживание — обязательно обратитесь к врачу.","timestamp":"2026-02-15T09:30:05Z"},{"role":"user","content":"А имбирь точно безопасен при беременности?","timestamp":"2026-02-15T09:31:00Z"},{"role":"assistant","content":"Да, имбирь считается безопасным при беременности в умеренных количествах — до 1 г сухого имбиря в день. Исследования подтверждают его эффективность против тошноты. Можно пить имбирный чай (свежий имбирь залить кипятком), рассасывать имбирные леденцы или добавлять в еду. Единственное ограничение — не превышайте дозировку и не принимайте концентрированные добавки. Если принимаете препараты, разжижающие кровь — проконсультируйтесь с врачом.","timestamp":"2026-02-15T09:31:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '52 days', CURRENT_TIMESTAMP - interval '52 days');

-- ai15: m08/NULL — Можно ли летать на 15 неделе
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000015', '20000000-0000-0000-0000-000000000008', NULL,
'[{"role":"user","content":"Можно ли летать на самолёте на 15 неделе беременности? Нужно полететь к родителям.","timestamp":"2026-03-02T12:00:00Z"},{"role":"assistant","content":"Да, в целом авиаперелёты безопасны во время беременности, особенно во втором триместре (14-27 недель) — это самый комфортный период. Рекомендации: 1) Получите разрешение от вашего врача. 2) В самолёте пейте больше воды. 3) Ходите по салону каждые 1-2 часа. 4) Наденьте компрессионные чулки для профилактики тромбозов. 5) Пристёгивайте ремень под животом. 6) Возьмите обменную карту и медицинскую справку. Авиакомпании обычно разрешают перелёты до 36 недели (32 при многоплодной).","timestamp":"2026-03-02T12:00:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '37 days', CURRENT_TIMESTAMP - interval '37 days');

-- ai16: m12/NULL — Боли в пояснице при беременности
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000016', '20000000-0000-0000-0000-000000000012', NULL,
'[{"role":"user","content":"Болит поясница, беременность 28 недель. Что можно сделать? Обезболивающие нельзя...","timestamp":"2026-02-28T19:00:00Z"},{"role":"assistant","content":"Боли в пояснице — частая проблема в третьем триместре из-за смещения центра тяжести и гормона релаксина. Безопасные способы облегчения: 1) Упражнения: «кошка-корова» на четвереньках, наклоны таза. 2) Плавание или аквааэробика для беременных. 3) Дородовой бандаж — поддерживает живот и снимает нагрузку. 4) Массаж поясницы (мягкий). 5) Тёплый (не горячий!) компресс на 15-20 минут. 6) Удобная обувь без каблука. 7) Подушка между колен во время сна. 8) Правильная осанка — не прогибайтесь в пояснице.","timestamp":"2026-02-28T19:00:05Z"},{"role":"user","content":"А йога для беременных поможет?","timestamp":"2026-02-28T19:01:00Z"},{"role":"assistant","content":"Да, йога для беременных очень полезна при болях в спине. Она помогает укрепить мышцы, улучшить осанку и расслабиться. Безопасные позы: 1) Баласана (поза ребёнка) — с широко разведёнными коленями. 2) Марджариасана (кошка) — разминка позвоночника. 3) Тадасана (гора) — работа с осанкой. 4) Випарита карани — ноги на стену. Избегайте: скручиваний, поз на животе, глубоких прогибов назад, перевёрнутых поз. Лучше заниматься с сертифицированным инструктором по пренатальной йоге.","timestamp":"2026-02-28T19:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '39 days', CURRENT_TIMESTAMP - interval '39 days');

-- ai17: m15/ch16 — Пупочная ранка
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000017', '20000000-0000-0000-0000-000000000015', '90000000-0000-0000-0000-000000000016',
'[{"role":"user","content":"Малышу месяц, а пупочная ранка всё ещё не зажила полностью. Иногда есть выделения. Это нормально?","timestamp":"2026-03-28T11:00:00Z"},{"role":"assistant","content":"Пупочная ранка обычно заживает за 2-3 недели, но у некоторых малышей процесс может затянуться до 4-5 недель. Небольшие серозные (прозрачные или желтоватые) выделения допустимы. Правила ухода: 1) Обрабатывайте 1-2 раза в день хлоргексидином или перекисью водорода 3%. 2) Используйте ватные палочки. 3) Дайте ранке просохнуть на воздухе. 4) Не заклеивайте пластырем. 5) Подгузник подворачивайте ниже пупка. 6) Купайте в кипячёной воде или с добавлением марганцовки (слабо-розовый раствор).","timestamp":"2026-03-28T11:00:05Z"},{"role":"user","content":"А когда бежать к врачу?","timestamp":"2026-03-28T11:01:00Z"},{"role":"assistant","content":"Срочно обратитесь к педиатру, если: 1) Есть гнойные выделения (зелёные, с запахом). 2) Кожа вокруг пупка красная, горячая, припухшая. 3) Ранка кровоточит. 4) Повысилась температура тела ребёнка. 5) Малыш беспокойный, плачет при прикосновении к пупку. 6) Ранка не заживает более 4-5 недель. Эти признаки могут указывать на омфалит (воспаление пупочной ранки), который требует лечения антибиотиками.","timestamp":"2026-03-28T11:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '11 days', CURRENT_TIMESTAMP - interval '11 days');

-- ai18: m18/ch19 — Зелёный стул у грудничка
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000018', '20000000-0000-0000-0000-000000000018', '90000000-0000-0000-0000-000000000019',
'[{"role":"user","content":"Ребёнку 3 месяца, на грудном вскармливании. Стул стал зеленоватого цвета. Стоит ли беспокоиться?","timestamp":"2026-03-30T08:00:00Z"},{"role":"assistant","content":"Зеленоватый стул у грудничка на ГВ — чаще всего вариант нормы. Причины: 1) Ребёнок получает больше переднего (жидкого) молока. 2) Мама ела зелёные овощи. 3) Приём витаминов или препаратов железа мамой. 4) Окисление стула на воздухе (нормальный стул может позеленеть). 5) Незрелость пищеварительной системы. Нормальный стул грудничка может быть жёлтым, зелёным, горчичным, с белыми комочками — всё это варианты нормы. Главное — ребёнок хорошо себя чувствует и набирает вес.","timestamp":"2026-03-30T08:00:05Z"},{"role":"user","content":"А если он ещё и пенистый?","timestamp":"2026-03-30T08:01:00Z"},{"role":"assistant","content":"Пенистый зелёный стул может указывать на дисбаланс переднего и заднего молока. Переднее молоко богато лактозой, его избыток может вызывать пенистый стул и газы. Решение: 1) Не меняйте грудь слишком часто — дайте ребёнку опорожнить одну грудь полностью. 2) Кормите из одной груди 2-3 кормления подряд, затем меняйте. 3) Если проблема сохраняется более 2 недель, обратитесь к консультанту по ГВ или педиатру для исключения лактазной недостаточности.","timestamp":"2026-03-30T08:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '9 days', CURRENT_TIMESTAMP - interval '9 days');

-- ai19: m17/ch17 — Ребёнок 13 мес не ходит
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000019', '20000000-0000-0000-0000-000000000017', '90000000-0000-0000-0000-000000000017',
'[{"role":"user","content":"Сыну 13 месяцев, он ещё не ходит самостоятельно. Ходит только за ручку или вдоль мебели. Все знакомые дети уже ходят.","timestamp":"2026-03-14T17:00:00Z"},{"role":"assistant","content":"Не переживайте — нормой считается начало самостоятельной ходьбы до 18 месяцев. Средний возраст — 12-14 месяцев, но диапазон нормы широк: от 9 до 18 месяцев. То, что ваш сын ходит вдоль мебели и за руку — отличный знак, он уже готовится! Помочь можно: 1) Поощряйте ходьбу вдоль мебели. 2) Дайте каталку-толкалку (не ходунки!). 3) Не сравнивайте с другими детьми. 4) Ходите босиком дома — это укрепляет стопы. 5) Создайте безопасное пространство для практики. Ходунки, наоборот, могут замедлить развитие.","timestamp":"2026-03-14T17:00:05Z"},{"role":"user","content":"А ходунки вредны?","timestamp":"2026-03-14T17:01:00Z"},{"role":"assistant","content":"Да, педиатры не рекомендуют ходунки. Причины: 1) Ребёнок в ходунках не учится держать равновесие. 2) Неправильная нагрузка на стопу — ходит на носочках. 3) Риск травм — ходунки могут перевернуться у порога. 4) Замедляют развитие самостоятельной ходьбы. 5) Ребёнок не учится падать безопасно. Лучшая альтернатива — каталка-толкалка, за которую ребёнок ходит сам, контролируя скорость и равновесие.","timestamp":"2026-03-14T17:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '25 days', CURRENT_TIMESTAMP - interval '25 days');

-- ai20: m11/ch12 — Кормление смесью
INSERT INTO ai_conversations (id, user_id, child_id, messages, created_at, updated_at)
VALUES ('ab000000-0000-0000-0000-000000000020', '20000000-0000-0000-0000-000000000011', '90000000-0000-0000-0000-000000000012',
'[{"role":"user","content":"Перехожу на смешанное вскармливание. Малышу 3 месяца. Какую смесь лучше выбрать?","timestamp":"2026-03-26T10:00:00Z"},{"role":"assistant","content":"Выбор смеси лучше обсудить с вашим педиатром, но общие рекомендации: 1) Для здорового ребёнка — адаптированная молочная смесь 1 ступени (0-6 мес). 2) Проверенные марки: NAN, Nutrilon, Similac, Hipp — все сертифицированы в РК. 3) Выбирайте смесь с пребиотиками и нуклеотидами. 4) Если есть склонность к аллергии — гипоаллергенная смесь (ГА). 5) Не меняйте смесь без причины. 6) Разводите строго по инструкции. 7) Готовая смесь хранится не более 1 часа при комнатной температуре.","timestamp":"2026-03-26T10:00:05Z"},{"role":"user","content":"Как совмещать грудь и смесь?","timestamp":"2026-03-26T10:01:00Z"},{"role":"assistant","content":"Правила смешанного вскармливания: 1) Сначала давайте грудь, потом докорм смесью. 2) Или чередуйте кормления: одно грудь, следующее смесь. 3) Используйте бутылочку с медленной соской (поток для новорождённого), чтобы ребёнок не отказался от груди. 4) Ночные кормления лучше оставить грудные — для поддержания лактации. 5) Следите за объёмом — в 3 месяца общий объём питания ~800-900 мл в сутки. 6) Если хотите сохранить ГВ — сцеживайтесь в пропущенные кормления.","timestamp":"2026-03-26T10:01:05Z"}]'::jsonb,
CURRENT_TIMESTAMP - interval '13 days', CURRENT_TIMESTAMP - interval '13 days');


-- =============================================================================
-- 3. AI FEEDBACK (15 records)
-- =============================================================================

INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000001', 1, true, true, 'Полезный совет, спасибо!');
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000002', 1, true, true, 'Помогло успокоиться');
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000003', 1, true, true, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000004', 1, true, NULL, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000005', 1, true, true, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000006', 1, false, false, 'Слишком общий ответ');
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000007', 1, true, true, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000008', 1, true, true, 'Полезный совет, спасибо!');
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000009', 1, true, NULL, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000010', 1, true, true, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000011', 1, false, false, 'Слишком общий ответ');
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000012', 1, true, true, 'Помогло успокоиться');
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000013', 1, true, NULL, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000014', 1, false, NULL, NULL);
INSERT INTO ai_feedback (conversation_id, message_index, was_helpful, doctor_agreed, comment)
VALUES ('ab000000-0000-0000-0000-000000000015', 1, true, true, NULL);


-- =============================================================================
-- 4. VIDEO CONSULTATIONS (15 records)
-- =============================================================================

-- 10 completed
INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001',
  CURRENT_TIMESTAMP - interval '152 days' + interval '10 hours',
  CURRENT_TIMESTAMP - interval '152 days' + interval '10 hours 2 minutes',
  CURRENT_TIMESTAMP - interval '152 days' + interval '10 hours 27 minutes',
  25, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Плановый осмотр. Развитие соответствует возрасту. Рекомендована сдача ОАК.',
  CURRENT_TIMESTAMP - interval '152 days', CURRENT_TIMESTAMP - interval '152 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000003',
  CURRENT_TIMESTAMP - interval '135 days' + interval '14 hours',
  CURRENT_TIMESTAMP - interval '135 days' + interval '14 hours 1 minute',
  CURRENT_TIMESTAMP - interval '135 days' + interval '14 hours 31 minutes',
  30, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Консультация по прикорму. Рекомендовано начать с овощных пюре.',
  CURRENT_TIMESTAMP - interval '135 days', CURRENT_TIMESTAMP - interval '135 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000004', '90000000-0000-0000-0000-000000000004',
  CURRENT_TIMESTAMP - interval '120 days' + interval '11 hours',
  CURRENT_TIMESTAMP - interval '120 days' + interval '11 hours 3 minutes',
  CURRENT_TIMESTAMP - interval '120 days' + interval '11 hours 18 minutes',
  15, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Осмотр новорождённого. Пупочная ранка заживает. Рефлексы в норме.',
  CURRENT_TIMESTAMP - interval '120 days', CURRENT_TIMESTAMP - interval '120 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000005', '90000000-0000-0000-0000-000000000005',
  CURRENT_TIMESTAMP - interval '105 days' + interval '9 hours',
  CURRENT_TIMESTAMP - interval '105 days' + interval '9 hours 5 minutes',
  CURRENT_TIMESTAMP - interval '105 days' + interval '9 hours 25 minutes',
  20, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Обсуждение аллергии на яичный белок. Назначена элиминационная диета.',
  CURRENT_TIMESTAMP - interval '105 days', CURRENT_TIMESTAMP - interval '105 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000004', '80000000-0000-0000-0000-000000000006', '90000000-0000-0000-0000-000000000006',
  CURRENT_TIMESTAMP - interval '90 days' + interval '16 hours',
  CURRENT_TIMESTAMP - interval '90 days' + interval '16 hours 2 minutes',
  CURRENT_TIMESTAMP - interval '90 days' + interval '16 hours 37 minutes',
  35, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Жалобы на частые срыгивания. Рекомендовано дробное кормление, вертикальное положение.',
  CURRENT_TIMESTAMP - interval '90 days', CURRENT_TIMESTAMP - interval '90 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000007', '90000000-0000-0000-0000-000000000007',
  CURRENT_TIMESTAMP - interval '75 days' + interval '10 hours',
  CURRENT_TIMESTAMP - interval '75 days' + interval '10 hours 1 minute',
  CURRENT_TIMESTAMP - interval '75 days' + interval '10 hours 26 minutes',
  25, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Консультация по поведению (битьё головой). Нормальный этап развития.',
  CURRENT_TIMESTAMP - interval '75 days', CURRENT_TIMESTAMP - interval '75 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000005', '80000000-0000-0000-0000-000000000009', '90000000-0000-0000-0000-000000000009',
  CURRENT_TIMESTAMP - interval '60 days' + interval '13 hours',
  CURRENT_TIMESTAMP - interval '60 days' + interval '13 hours 4 minutes',
  CURRENT_TIMESTAMP - interval '60 days' + interval '13 hours 24 minutes',
  20, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Боли в животе. Исключён аппендицит. Назначен пробиотик.',
  CURRENT_TIMESTAMP - interval '60 days', CURRENT_TIMESTAMP - interval '60 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000010', '90000000-0000-0000-0000-000000000010',
  CURRENT_TIMESTAMP - interval '45 days' + interval '11 hours',
  CURRENT_TIMESTAMP - interval '45 days' + interval '11 hours 2 minutes',
  CURRENT_TIMESTAMP - interval '45 days' + interval '11 hours 17 minutes',
  15, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Осмотр в 1 месяц. Набор веса 800 г. Рефлексы в норме.',
  CURRENT_TIMESTAMP - interval '45 days', CURRENT_TIMESTAMP - interval '45 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000006', '80000000-0000-0000-0000-000000000011', '90000000-0000-0000-0000-000000000011',
  CURRENT_TIMESTAMP - interval '30 days' + interval '15 hours',
  CURRENT_TIMESTAMP - interval '30 days' + interval '15 hours 3 minutes',
  CURRENT_TIMESTAMP - interval '30 days' + interval '15 hours 43 minutes',
  40, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Подробная консультация по развитию речи и моторики в 18 месяцев. Всё в норме.',
  CURRENT_TIMESTAMP - interval '30 days', CURRENT_TIMESTAMP - interval '30 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, started_at, ended_at, duration_minutes, room_url, status, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000013', '90000000-0000-0000-0000-000000000013',
  CURRENT_TIMESTAMP - interval '14 days' + interval '10 hours',
  CURRENT_TIMESTAMP - interval '14 days' + interval '10 hours 1 minute',
  CURRENT_TIMESTAMP - interval '14 days' + interval '10 hours 31 minutes',
  30, 'https://meet.umai-health.kz/' || gen_random_uuid(), 'completed',
  'Консультация аллерголога. Подтверждена аллергия на яйцо. Расписана диета.',
  CURRENT_TIMESTAMP - interval '14 days', CURRENT_TIMESTAMP - interval '14 days');

-- 2 cancelled
INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, status, room_url, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000014', '90000000-0000-0000-0000-000000000014',
  CURRENT_TIMESTAMP - interval '30 days' + interval '9 hours',
  'cancelled', 'https://meet.umai-health.kz/' || gen_random_uuid(),
  'Отменена по инициативе пациента.',
  CURRENT_TIMESTAMP - interval '32 days', CURRENT_TIMESTAMP - interval '30 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, status, room_url, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000004', '80000000-0000-0000-0000-000000000017', '90000000-0000-0000-0000-000000000017',
  CURRENT_TIMESTAMP - interval '21 days' + interval '14 hours',
  'cancelled', 'https://meet.umai-health.kz/' || gen_random_uuid(),
  'Отменена: врач заболел. Предложена замена даты.',
  CURRENT_TIMESTAMP - interval '25 days', CURRENT_TIMESTAMP - interval '21 days');

-- 2 scheduled (future)
INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, status, room_url, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000002', '80000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000002',
  CURRENT_TIMESTAMP + interval '3 days' + interval '10 hours',
  'scheduled', 'https://meet.umai-health.kz/' || gen_random_uuid(),
  CURRENT_TIMESTAMP - interval '2 days', CURRENT_TIMESTAMP - interval '2 days');

INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, status, room_url, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000005', '80000000-0000-0000-0000-000000000007', '90000000-0000-0000-0000-000000000008',
  CURRENT_TIMESTAMP + interval '7 days' + interval '15 hours',
  'scheduled', 'https://meet.umai-health.kz/' || gen_random_uuid(),
  CURRENT_TIMESTAMP - interval '1 day', CURRENT_TIMESTAMP - interval '1 day');

-- 1 missed
INSERT INTO video_consultations (doctor_id, family_id, child_id, scheduled_at, status, room_url, notes, created_at, updated_at)
VALUES ('b0000000-0000-0000-0000-000000000003', '80000000-0000-0000-0000-000000000015', '90000000-0000-0000-0000-000000000016',
  CURRENT_TIMESTAMP - interval '10 days' + interval '11 hours',
  'missed', 'https://meet.umai-health.kz/' || gen_random_uuid(),
  'Пациент не подключился. Отправлено напоминание о переносе.',
  CURRENT_TIMESTAMP - interval '12 days', CURRENT_TIMESTAMP - interval '10 days');


-- =============================================================================
-- 5. MOOD LOGS (~400 records via generate_series)
-- =============================================================================

INSERT INTO mood_logs (user_id, date, score, notes)
SELECT
  m.id,
  (CURRENT_DATE - day_num)::date,
  GREATEST(1, LEAST(5, m.base_score + (floor(random() * 3) - 1)::int)),
  CASE WHEN random() < 0.15 THEN
    (ARRAY[
      'Хороший день',
      'Устала',
      'Малыш капризничал',
      'Отлично выспалась',
      'Тревожно',
      'Продуктивный день',
      'Чувствую себя хорошо'
    ])[1 + floor(random() * 7)::int]
  ELSE NULL END
FROM (VALUES
  ('20000000-0000-0000-0000-000000000001'::uuid, 4, 180),
  ('20000000-0000-0000-0000-000000000002'::uuid, 3, 120),
  ('20000000-0000-0000-0000-000000000004'::uuid, 3, 42),
  ('20000000-0000-0000-0000-000000000007'::uuid, 4, 150),
  ('20000000-0000-0000-0000-000000000009'::uuid, 3, 90),
  ('20000000-0000-0000-0000-000000000010'::uuid, 3, 60),
  ('20000000-0000-0000-0000-000000000011'::uuid, 4, 200),
  ('20000000-0000-0000-0000-000000000014'::uuid, 4, 365)
) AS m(id, base_score, days_back)
CROSS JOIN LATERAL generate_series(1, m.days_back) AS day_num
WHERE random() > 0.08
ON CONFLICT (user_id, date) DO NOTHING;


-- =============================================================================
-- 6. EPDS SCREENINGS (~43 records)
-- =============================================================================

-- m04 (ch04 born 42 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level, reviewed_by, reviewed_at)
VALUES ('20000000-0000-0000-0000-000000000004', CURRENT_DATE - 28, '[2,1,1,1,1,1,1,1,1,1]'::jsonb, 11, 'moderate',
  '40000000-0000-0000-0000-000000000002', CURRENT_TIMESTAMP - interval '26 days');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000004', CURRENT_DATE - 0, '[1,1,1,1,0,1,1,1,0,1]'::jsonb, 8, 'low');

-- m10 (ch10 born 60 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level, reviewed_by, reviewed_at)
VALUES ('20000000-0000-0000-0000-000000000010', CURRENT_DATE - 46, '[1,1,1,1,1,0,1,1,1,1]'::jsonb, 9, 'moderate',
  '40000000-0000-0000-0000-000000000002', CURRENT_TIMESTAMP - interval '44 days');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000010', CURRENT_DATE - 18, '[1,1,0,1,1,0,1,1,0,1]'::jsonb, 7, 'low');

-- m15 (ch16 born 30 days ago) — HIGH risk
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level, reviewed_by, reviewed_at)
VALUES ('20000000-0000-0000-0000-000000000015', CURRENT_DATE - 16, '[2,2,1,2,1,1,1,1,1,2]'::jsonb, 14, 'high',
  '40000000-0000-0000-0000-000000000002', CURRENT_TIMESTAMP - interval '15 days');

-- m18 (ch19 born 90 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000018', CURRENT_DATE - 76, '[1,1,0,1,0,1,0,1,0,1]'::jsonb, 6, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000018', CURRENT_DATE - 48, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000018', CURRENT_DATE - 0, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');

-- m01 ch02 (born 150 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000001', CURRENT_DATE - 136, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000001', CURRENT_DATE - 108, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000001', CURRENT_DATE - 60, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');

-- m07 ch08 (born 120 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000007', CURRENT_DATE - 106, '[1,1,0,1,1,0,1,1,0,1]'::jsonb, 7, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000007', CURRENT_DATE - 78, '[1,1,0,1,0,1,0,1,0,1]'::jsonb, 6, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000007', CURRENT_DATE - 30, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');

-- m11 ch12 (born 90 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level, reviewed_by, reviewed_at)
VALUES ('20000000-0000-0000-0000-000000000011', CURRENT_DATE - 76, '[1,1,1,1,1,1,1,1,1,1]'::jsonb, 10, 'moderate',
  '40000000-0000-0000-0000-000000000002', CURRENT_TIMESTAMP - interval '74 days');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000011', CURRENT_DATE - 48, '[1,1,1,1,0,1,1,1,0,1]'::jsonb, 8, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000011', CURRENT_DATE - 0, '[1,1,0,1,0,1,0,1,0,1]'::jsonb, 6, 'low');

-- m09 ch09 (born 270 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000009', CURRENT_DATE - 256, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000009', CURRENT_DATE - 228, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000009', CURRENT_DATE - 180, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000009', CURRENT_DATE - 90, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000009', CURRENT_DATE - 0, '[0,0,0,1,0,0,0,0,0,1]'::jsonb, 2, 'low');

-- m02 ch03 (born 425 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000002', CURRENT_DATE - 411, '[1,1,0,1,0,1,0,1,0,1]'::jsonb, 6, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000002', CURRENT_DATE - 383, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000002', CURRENT_DATE - 335, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000002', CURRENT_DATE - 245, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000002', CURRENT_DATE - 155, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000002', CURRENT_DATE - 60, '[0,0,0,1,0,0,0,0,0,1]'::jsonb, 2, 'low');

-- m06 ch06 (born 335 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000006', CURRENT_DATE - 321, '[1,1,1,1,0,1,1,1,0,1]'::jsonb, 8, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000006', CURRENT_DATE - 293, '[1,1,0,1,1,0,1,1,0,1]'::jsonb, 7, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000006', CURRENT_DATE - 245, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000006', CURRENT_DATE - 155, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000006', CURRENT_DATE - 65, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');

-- m13 ch13 (born 240 days ago)
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000013', CURRENT_DATE - 226, '[1,1,0,1,1,0,1,1,0,1]'::jsonb, 7, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000013', CURRENT_DATE - 198, '[1,1,0,1,0,1,0,1,0,1]'::jsonb, 6, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000013', CURRENT_DATE - 150, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000013', CURRENT_DATE - 60, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');

-- m14 ch14 (born 730 days ago) — all done, all low
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000014', CURRENT_DATE - 716, '[1,1,0,1,0,1,0,1,0,1]'::jsonb, 6, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000014', CURRENT_DATE - 688, '[1,0,1,0,1,0,1,0,0,1]'::jsonb, 5, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000014', CURRENT_DATE - 640, '[1,0,0,1,0,0,1,0,0,1]'::jsonb, 4, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000014', CURRENT_DATE - 550, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000014', CURRENT_DATE - 460, '[0,0,1,0,1,0,0,0,0,1]'::jsonb, 3, 'low');
INSERT INTO epds_screenings (user_id, date, answers, total_score, risk_level)
VALUES ('20000000-0000-0000-0000-000000000014', CURRENT_DATE - 365, '[0,0,0,1,0,0,0,0,0,1]'::jsonb, 2, 'low');


-- =============================================================================
-- 7. GROWTH METRICS (~140 records)
-- =============================================================================

-- ch01 (670 days, ~22 months): birth,1m,2m,3m,4m,6m,9m,12m,15m,18m,21m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 670, 3.35, 51.0, 34.5, 'doctor'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 640, 4.40, 54.5, 37.0, 'doctor'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 610, 5.40, 58.0, 39.5, 'parent'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 580, 6.10, 61.5, 40.5, 'doctor'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 550, 6.80, 64.0, 41.5, 'parent'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 490, 7.80, 67.5, 43.0, 'doctor'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 400, 9.00, 72.5, 45.5, 'parent'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 305, 9.90, 76.0, 46.5, 'doctor'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 220, 10.60, 79.0, 47.0, 'parent'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 130, 11.30, 82.5, 48.0, 'doctor'),
('90000000-0000-0000-0000-000000000001', CURRENT_DATE - 40, 11.90, 85.0, 48.5, 'parent');

-- ch02 (150 days, ~5 months): birth,1m,2m,3m,5m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000002', CURRENT_DATE - 150, 3.50, 52.0, 35.0, 'doctor'),
('90000000-0000-0000-0000-000000000002', CURRENT_DATE - 120, 4.50, 55.0, 37.5, 'doctor'),
('90000000-0000-0000-0000-000000000002', CURRENT_DATE - 90, 5.50, 58.5, 39.0, 'parent'),
('90000000-0000-0000-0000-000000000002', CURRENT_DATE - 60, 6.20, 61.0, 40.5, 'doctor'),
('90000000-0000-0000-0000-000000000002', CURRENT_DATE - 0, 7.30, 66.0, 42.5, 'parent');

-- ch03 (425 days, ~14 months): birth,1m,2m,3m,4m,6m,9m,12m,14m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 425, 3.20, 49.0, 33.5, 'doctor'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 395, 4.10, 53.0, 36.5, 'doctor'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 365, 5.10, 56.5, 38.5, 'parent'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 335, 5.80, 60.0, 39.5, 'doctor'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 305, 6.50, 62.5, 40.5, 'parent'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 245, 7.60, 66.5, 42.5, 'doctor'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 155, 8.70, 71.5, 44.5, 'parent'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 60, 9.60, 75.5, 46.0, 'doctor'),
('90000000-0000-0000-0000-000000000003', CURRENT_DATE - 5, 10.20, 77.0, 46.5, 'parent');

-- ch04 (42 days, ~1.5 months): birth,1m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000004', CURRENT_DATE - 42, 3.45, 50.0, 34.0, 'doctor'),
('90000000-0000-0000-0000-000000000004', CURRENT_DATE - 12, 4.20, 53.5, 36.5, 'doctor');

-- ch05 (300 days, ~10 months): birth,1m,2m,3m,4m,6m,9m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 300, 3.60, 52.0, 35.0, 'doctor'),
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 270, 4.60, 55.5, 37.5, 'doctor'),
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 240, 5.60, 58.0, 39.5, 'parent'),
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 210, 6.30, 61.5, 40.5, 'doctor'),
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 180, 6.90, 63.5, 41.5, 'parent'),
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 120, 7.90, 67.5, 43.5, 'doctor'),
('90000000-0000-0000-0000-000000000005', CURRENT_DATE - 30, 9.10, 72.0, 45.0, 'parent');

-- ch06 (335 days, ~11 months): birth,1m,2m,3m,4m,6m,9m,11m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 335, 3.10, 49.0, 33.5, 'doctor'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 305, 4.00, 52.5, 36.0, 'doctor'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 275, 5.00, 56.0, 38.0, 'parent'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 245, 5.70, 59.0, 39.5, 'doctor'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 215, 6.40, 62.0, 40.5, 'parent'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 155, 7.50, 66.0, 42.5, 'doctor'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 65, 8.60, 71.0, 44.5, 'parent'),
('90000000-0000-0000-0000-000000000006', CURRENT_DATE - 5, 9.30, 73.5, 45.5, 'doctor');

-- ch07 (610 days, ~20 months): birth,1m,2m,3m,4m,6m,9m,12m,15m,18m,20m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 610, 3.70, 53.0, 35.5, 'doctor'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 580, 4.70, 56.5, 38.0, 'doctor'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 550, 5.70, 59.0, 39.5, 'parent'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 520, 6.40, 62.0, 40.5, 'doctor'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 490, 7.00, 64.0, 41.5, 'parent'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 430, 8.10, 68.0, 43.5, 'doctor'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 340, 9.20, 73.0, 45.5, 'parent'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 245, 10.10, 76.5, 46.5, 'doctor'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 160, 10.80, 79.5, 47.5, 'parent'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 70, 11.50, 83.0, 48.0, 'doctor'),
('90000000-0000-0000-0000-000000000007', CURRENT_DATE - 10, 11.90, 84.5, 48.5, 'parent');

-- ch08 (120 days, ~4 months): birth,1m,2m,3m,4m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000008', CURRENT_DATE - 120, 3.25, 50.0, 34.0, 'doctor'),
('90000000-0000-0000-0000-000000000008', CURRENT_DATE - 90, 4.20, 53.5, 36.5, 'doctor'),
('90000000-0000-0000-0000-000000000008', CURRENT_DATE - 60, 5.10, 56.5, 38.5, 'parent'),
('90000000-0000-0000-0000-000000000008', CURRENT_DATE - 30, 5.90, 60.0, 40.0, 'doctor'),
('90000000-0000-0000-0000-000000000008', CURRENT_DATE - 0, 6.60, 62.5, 41.0, 'parent');

-- ch09 (270 days, ~9 months): birth,1m,2m,3m,4m,6m,9m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 270, 3.40, 51.0, 34.5, 'doctor'),
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 240, 4.30, 54.5, 37.0, 'doctor'),
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 210, 5.30, 57.5, 39.0, 'parent'),
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 180, 6.00, 60.5, 40.0, 'doctor'),
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 150, 6.60, 63.0, 41.0, 'parent'),
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 90, 7.60, 67.0, 43.0, 'doctor'),
('90000000-0000-0000-0000-000000000009', CURRENT_DATE - 0, 8.70, 71.5, 45.0, 'doctor');

-- ch10 (60 days, ~2 months): birth,1m,2m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000010', CURRENT_DATE - 60, 2.90, 48.0, 33.0, 'doctor'),
('90000000-0000-0000-0000-000000000010', CURRENT_DATE - 30, 3.80, 52.0, 36.0, 'doctor'),
('90000000-0000-0000-0000-000000000010', CURRENT_DATE - 0, 4.80, 55.5, 38.0, 'parent');

-- ch11 (550 days, ~18 months): birth,1m,2m,3m,4m,6m,9m,12m,15m,18m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 550, 3.55, 52.0, 35.0, 'doctor'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 520, 4.50, 55.5, 37.5, 'doctor'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 490, 5.50, 58.5, 39.0, 'parent'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 460, 6.20, 61.0, 40.0, 'doctor'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 430, 6.80, 63.5, 41.0, 'parent'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 370, 7.80, 67.0, 43.0, 'doctor'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 280, 8.90, 72.0, 45.0, 'parent'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 185, 9.80, 75.5, 46.0, 'doctor'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 100, 10.50, 78.5, 47.0, 'parent'),
('90000000-0000-0000-0000-000000000011', CURRENT_DATE - 10, 11.00, 81.5, 48.0, 'doctor');

-- ch12 (90 days, ~3 months): birth,1m,2m,3m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000012', CURRENT_DATE - 90, 3.30, 50.0, 34.0, 'doctor'),
('90000000-0000-0000-0000-000000000012', CURRENT_DATE - 60, 4.20, 53.5, 36.5, 'doctor'),
('90000000-0000-0000-0000-000000000012', CURRENT_DATE - 30, 5.20, 57.0, 38.5, 'parent'),
('90000000-0000-0000-0000-000000000012', CURRENT_DATE - 0, 6.00, 60.0, 40.0, 'doctor');

-- ch13 (240 days, ~8 months): birth,1m,2m,3m,4m,6m,8m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 240, 3.15, 49.0, 33.5, 'doctor'),
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 210, 4.10, 52.5, 36.0, 'doctor'),
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 180, 5.00, 56.0, 38.0, 'parent'),
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 150, 5.70, 59.0, 39.5, 'doctor'),
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 120, 6.30, 62.0, 40.5, 'parent'),
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 60, 7.40, 65.5, 42.5, 'doctor'),
('90000000-0000-0000-0000-000000000013', CURRENT_DATE - 0, 8.30, 69.5, 44.0, 'parent');

-- ch14 (730 days, ~24 months): birth,1m,2m,3m,4m,6m,9m,12m,15m,18m,21m,24m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 730, 3.65, 53.0, 35.5, 'doctor'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 700, 4.70, 56.0, 37.5, 'doctor'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 670, 5.60, 59.0, 39.5, 'parent'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 640, 6.30, 62.0, 40.5, 'doctor'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 610, 7.00, 64.0, 41.5, 'parent'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 550, 8.00, 68.0, 43.0, 'doctor'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 460, 9.10, 72.5, 45.0, 'parent'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 365, 10.00, 76.0, 46.5, 'doctor'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 280, 10.70, 79.0, 47.0, 'parent'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 190, 11.40, 82.5, 48.0, 'doctor'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 100, 12.00, 85.0, 48.5, 'parent'),
('90000000-0000-0000-0000-000000000014', CURRENT_DATE - 5, 12.60, 87.5, 49.0, 'doctor');

-- ch15 (240 days, ~8 months): birth,1m,2m,3m,4m,6m,8m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 240, 3.05, 48.0, 33.0, 'doctor'),
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 210, 4.00, 52.0, 36.0, 'doctor'),
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 180, 4.90, 55.0, 38.0, 'parent'),
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 150, 5.60, 58.5, 39.0, 'doctor'),
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 120, 6.20, 61.0, 40.0, 'parent'),
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 60, 7.30, 65.0, 42.0, 'doctor'),
('90000000-0000-0000-0000-000000000015', CURRENT_DATE - 0, 8.10, 69.0, 43.5, 'parent');

-- ch16 (30 days, ~1 month): birth,1m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000016', CURRENT_DATE - 30, 3.20, 50.0, 34.0, 'doctor'),
('90000000-0000-0000-0000-000000000016', CURRENT_DATE - 0, 4.10, 53.5, 36.5, 'doctor');

-- ch17 (395 days, ~13 months): birth,1m,2m,3m,4m,6m,9m,12m,13m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 395, 3.50, 51.0, 34.5, 'doctor'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 365, 4.40, 54.5, 37.0, 'doctor'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 335, 5.40, 57.5, 39.0, 'parent'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 305, 6.10, 60.5, 40.0, 'doctor'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 275, 6.70, 63.0, 41.0, 'parent'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 215, 7.80, 67.0, 43.0, 'doctor'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 125, 9.00, 72.0, 45.0, 'parent'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 30, 9.90, 76.0, 46.5, 'doctor'),
('90000000-0000-0000-0000-000000000017', CURRENT_DATE - 5, 10.20, 77.0, 46.5, 'parent');

-- ch18 (30 days, ~1 month): birth,1m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000018', CURRENT_DATE - 30, 3.10, 49.0, 33.5, 'doctor'),
('90000000-0000-0000-0000-000000000018', CURRENT_DATE - 0, 3.90, 52.5, 36.0, 'doctor');

-- ch19 (90 days, ~3 months): birth,1m,2m,3m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000019', CURRENT_DATE - 90, 3.40, 51.0, 34.5, 'doctor'),
('90000000-0000-0000-0000-000000000019', CURRENT_DATE - 60, 4.20, 54.0, 37.0, 'doctor'),
('90000000-0000-0000-0000-000000000019', CURRENT_DATE - 30, 5.20, 57.5, 39.0, 'parent'),
('90000000-0000-0000-0000-000000000019', CURRENT_DATE - 0, 5.80, 60.5, 40.0, 'doctor');

-- ch20 (488 days, ~16 months): birth,1m,2m,3m,4m,6m,9m,12m,15m
INSERT INTO growth_metrics (child_id, date, weight_kg, height_cm, head_cm, measured_by) VALUES
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 488, 3.35, 51.0, 34.5, 'doctor'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 458, 4.30, 54.5, 37.0, 'doctor'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 428, 5.30, 57.5, 39.0, 'parent'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 398, 6.00, 60.5, 40.0, 'doctor'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 368, 6.70, 63.0, 41.0, 'parent'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 308, 7.70, 67.0, 43.0, 'doctor'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 218, 8.90, 72.0, 45.0, 'parent'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 123, 9.80, 75.5, 46.5, 'doctor'),
('90000000-0000-0000-0000-000000000020', CURRENT_DATE - 38, 10.60, 79.0, 47.0, 'parent');


-- =============================================================================
-- 8. MILESTONES (~80 records)
-- =============================================================================

-- ch01 (670 days, ~22 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000001', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 640, NULL),
('90000000-0000-0000-0000-000000000001', 'social', 'Социальная улыбка', CURRENT_DATE - 610, NULL),
('90000000-0000-0000-0000-000000000001', 'motor', 'Ходит самостоятельно', CURRENT_DATE - 305, 'Пошёл в 12 месяцев'),
('90000000-0000-0000-0000-000000000001', 'speech', 'Говорит отдельные слова', CURRENT_DATE - 280, 'Мама, папа, дай'),
('90000000-0000-0000-0000-000000000001', 'motor', 'Бегает', CURRENT_DATE - 120, NULL);

-- ch02 (150 days, ~5 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000002', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 120, NULL),
('90000000-0000-0000-0000-000000000002', 'social', 'Социальная улыбка', CURRENT_DATE - 90, NULL),
('90000000-0000-0000-0000-000000000002', 'speech', 'Гулит', CURRENT_DATE - 80, 'Активно гулит'),
('90000000-0000-0000-0000-000000000002', 'motor', 'Переворачивается со спины на бок', CURRENT_DATE - 40, NULL);

-- ch03 (425 days, ~14 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000003', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 395, NULL),
('90000000-0000-0000-0000-000000000003', 'motor', 'Сидит с поддержкой', CURRENT_DATE - 275, NULL),
('90000000-0000-0000-0000-000000000003', 'motor', 'Ползает', CURRENT_DATE - 185, NULL),
('90000000-0000-0000-0000-000000000003', 'motor', 'Ходит самостоятельно', CURRENT_DATE - 60, 'Пошёл в 12 месяцев'),
('90000000-0000-0000-0000-000000000003', 'speech', 'Первые слова', CURRENT_DATE - 55, NULL);

-- ch04 (42 days, ~1.5 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000004', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 12, NULL),
('90000000-0000-0000-0000-000000000004', 'social', 'Фокусирует взгляд на лице', CURRENT_DATE - 28, NULL);

-- ch05 (300 days, ~10 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000005', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 270, NULL),
('90000000-0000-0000-0000-000000000005', 'motor', 'Сидит с поддержкой', CURRENT_DATE - 150, NULL),
('90000000-0000-0000-0000-000000000005', 'motor', 'Ползает', CURRENT_DATE - 60, NULL),
('90000000-0000-0000-0000-000000000005', 'motor', 'Стоит с опорой', CURRENT_DATE - 20, NULL);

-- ch06 (335 days, ~11 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000006', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 305, NULL),
('90000000-0000-0000-0000-000000000006', 'social', 'Смеётся вслух', CURRENT_DATE - 215, NULL),
('90000000-0000-0000-0000-000000000006', 'motor', 'Ползает', CURRENT_DATE - 95, NULL),
('90000000-0000-0000-0000-000000000006', 'speech', 'Произносит слоги (ма-ма, ба-ба)', CURRENT_DATE - 65, NULL);

-- ch07 (610 days, ~20 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000007', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 580, NULL),
('90000000-0000-0000-0000-000000000007', 'motor', 'Ползает', CURRENT_DATE - 370, NULL),
('90000000-0000-0000-0000-000000000007', 'motor', 'Ходит самостоятельно', CURRENT_DATE - 245, 'Пошёл в 12 месяцев'),
('90000000-0000-0000-0000-000000000007', 'self_care', 'Ест ложкой', CURRENT_DATE - 100, NULL),
('90000000-0000-0000-0000-000000000007', 'cognitive', 'Показывает части тела', CURRENT_DATE - 60, NULL);

-- ch08 (120 days, ~4 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000008', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 90, NULL),
('90000000-0000-0000-0000-000000000008', 'social', 'Социальная улыбка', CURRENT_DATE - 60, NULL),
('90000000-0000-0000-0000-000000000008', 'speech', 'Гулит', CURRENT_DATE - 50, NULL),
('90000000-0000-0000-0000-000000000008', 'motor', 'Переворачивается со спины на бок', CURRENT_DATE - 10, NULL);

-- ch09 (270 days, ~9 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000009', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 240, NULL),
('90000000-0000-0000-0000-000000000009', 'motor', 'Хватает предметы', CURRENT_DATE - 120, NULL),
('90000000-0000-0000-0000-000000000009', 'motor', 'Ползает', CURRENT_DATE - 30, NULL),
('90000000-0000-0000-0000-000000000009', 'speech', 'Произносит слоги (ма-ма, ба-ба)', CURRENT_DATE - 10, NULL);

-- ch10 (60 days, ~2 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000010', 'social', 'Фокусирует взгляд на лице', CURRENT_DATE - 45, NULL),
('90000000-0000-0000-0000-000000000010', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 30, NULL),
('90000000-0000-0000-0000-000000000010', 'social', 'Социальная улыбка', CURRENT_DATE - 10, NULL);

-- ch11 (550 days, ~18 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000011', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 520, NULL),
('90000000-0000-0000-0000-000000000011', 'motor', 'Ползает', CURRENT_DATE - 310, NULL),
('90000000-0000-0000-0000-000000000011', 'motor', 'Первые шаги с поддержкой', CURRENT_DATE - 215, NULL),
('90000000-0000-0000-0000-000000000011', 'motor', 'Ходит самостоятельно', CURRENT_DATE - 190, 'Пошёл в 12 месяцев'),
('90000000-0000-0000-0000-000000000011', 'speech', 'Первые слова', CURRENT_DATE - 185, NULL);

-- ch12 (90 days, ~3 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000012', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 60, NULL),
('90000000-0000-0000-0000-000000000012', 'social', 'Социальная улыбка', CURRENT_DATE - 40, NULL),
('90000000-0000-0000-0000-000000000012', 'speech', 'Гулит', CURRENT_DATE - 20, NULL),
('90000000-0000-0000-0000-000000000012', 'motor', 'Переворачивается со спины на бок', CURRENT_DATE - 5, NULL);

-- ch13 (240 days, ~8 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000013', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 210, NULL),
('90000000-0000-0000-0000-000000000013', 'motor', 'Сидит с поддержкой', CURRENT_DATE - 90, NULL),
('90000000-0000-0000-0000-000000000013', 'motor', 'Хватает предметы', CURRENT_DATE - 100, NULL),
('90000000-0000-0000-0000-000000000013', 'social', 'Смеётся вслух', CURRENT_DATE - 130, NULL);

-- ch14 (730 days, ~24 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000014', 'motor', 'Ходит самостоятельно', CURRENT_DATE - 380, 'Пошёл в 11.5 месяцев'),
('90000000-0000-0000-0000-000000000014', 'speech', 'Первые слова', CURRENT_DATE - 365, NULL),
('90000000-0000-0000-0000-000000000014', 'motor', 'Бегает', CURRENT_DATE - 180, NULL),
('90000000-0000-0000-0000-000000000014', 'cognitive', 'Строит башню из кубиков', CURRENT_DATE - 90, NULL),
('90000000-0000-0000-0000-000000000014', 'speech', 'Говорит фразы из 2-3 слов', CURRENT_DATE - 30, 'Мама, дай пить');

-- ch15 (240 days, ~8 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000015', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 210, NULL),
('90000000-0000-0000-0000-000000000015', 'social', 'Социальная улыбка', CURRENT_DATE - 180, NULL),
('90000000-0000-0000-0000-000000000015', 'motor', 'Хватает предметы', CURRENT_DATE - 100, NULL),
('90000000-0000-0000-0000-000000000015', 'motor', 'Сидит с поддержкой', CURRENT_DATE - 80, NULL);

-- ch16 (30 days, ~1 month)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000016', 'social', 'Фокусирует взгляд на лице', CURRENT_DATE - 16, NULL),
('90000000-0000-0000-0000-000000000016', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 5, 'Ненадолго приподнимает');

-- ch17 (395 days, ~13 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000017', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 365, NULL),
('90000000-0000-0000-0000-000000000017', 'motor', 'Ползает', CURRENT_DATE - 155, NULL),
('90000000-0000-0000-0000-000000000017', 'motor', 'Стоит с опорой', CURRENT_DATE - 95, NULL),
('90000000-0000-0000-0000-000000000017', 'motor', 'Первые шаги с поддержкой', CURRENT_DATE - 30, 'Пока только за ручку');

-- ch18 (30 days, ~1 month)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000018', 'social', 'Фокусирует взгляд на лице', CURRENT_DATE - 14, NULL),
('90000000-0000-0000-0000-000000000018', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 7, NULL);

-- ch19 (90 days, ~3 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000019', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 60, NULL),
('90000000-0000-0000-0000-000000000019', 'social', 'Социальная улыбка', CURRENT_DATE - 40, NULL),
('90000000-0000-0000-0000-000000000019', 'speech', 'Гулит', CURRENT_DATE - 15, NULL);

-- ch20 (488 days, ~16 months)
INSERT INTO milestones (child_id, type, title, achieved_at, notes) VALUES
('90000000-0000-0000-0000-000000000020', 'motor', 'Держит голову лёжа на животе', CURRENT_DATE - 458, NULL),
('90000000-0000-0000-0000-000000000020', 'motor', 'Ползает', CURRENT_DATE - 248, NULL),
('90000000-0000-0000-0000-000000000020', 'motor', 'Ходит самостоятельно', CURRENT_DATE - 128, 'Пошёл в 12 месяцев'),
('90000000-0000-0000-0000-000000000020', 'speech', 'Первые слова', CURRENT_DATE - 118, NULL),
('90000000-0000-0000-0000-000000000020', 'self_care', 'Ест ложкой', CURRENT_DATE - 38, NULL);


-- =============================================================================
-- 9. FEEDING LOGS (~300 records via generate_series)
-- =============================================================================

-- ch01 (22mo, solid food)
INSERT INTO feeding_logs (child_id, type, details, timestamp, notes)
SELECT
  '90000000-0000-0000-0000-000000000001'::uuid,
  'solid',
  (ARRAY[
    '{"food":"суп овощной","amount_g":150}',
    '{"food":"каша гречневая","amount_g":130}',
    '{"food":"котлета из индейки","amount_g":60}',
    '{"food":"творог с фруктами","amount_g":100}',
    '{"food":"пюре картофельное","amount_g":120}'
  ])[1 + floor(random()*5)::int]::jsonb,
  (CURRENT_DATE - day_num)::date::timestamptz + (meal.hour || ' hours')::interval + (floor(random()*25) || ' minutes')::interval,
  NULL
FROM generate_series(1, 30) AS day_num
CROSS JOIN (VALUES (8), (13)) AS meal(hour)
WHERE random() > 0.12;

-- ch03 (14mo, solid food)
INSERT INTO feeding_logs (child_id, type, details, timestamp, notes)
SELECT
  '90000000-0000-0000-0000-000000000003'::uuid,
  'solid',
  (ARRAY[
    '{"food":"каша рисовая","amount_g":120}',
    '{"food":"пюре из брокколи","amount_g":100}',
    '{"food":"суп-пюре тыквенный","amount_g":130}',
    '{"food":"мясное пюре кролик","amount_g":50}',
    '{"food":"банан","amount_g":80}'
  ])[1 + floor(random()*5)::int]::jsonb,
  (CURRENT_DATE - day_num)::date::timestamptz + (meal.hour || ' hours')::interval + (floor(random()*20) || ' minutes')::interval,
  NULL
FROM generate_series(1, 30) AS day_num
CROSS JOIN (VALUES (8), (12)) AS meal(hour)
WHERE random() > 0.12;

-- ch06 (11mo, mixed feeding)
INSERT INTO feeding_logs (child_id, type, details, timestamp, duration_minutes, notes)
SELECT
  '90000000-0000-0000-0000-000000000006'::uuid,
  CASE WHEN meal.hour = 7 THEN 'breast' ELSE 'solid' END,
  CASE WHEN meal.hour = 7 THEN '{"side":"left"}'::jsonb ELSE
    (ARRAY[
      '{"food":"каша кукурузная","amount_g":80}',
      '{"food":"пюре из кабачка","amount_g":70}',
      '{"food":"яблочное пюре","amount_g":60}'
    ])[1 + floor(random()*3)::int]::jsonb
  END,
  (CURRENT_DATE - day_num)::date::timestamptz + (meal.hour || ' hours')::interval + (floor(random()*20) || ' minutes')::interval,
  CASE WHEN meal.hour = 7 THEN 12 + floor(random()*10)::int ELSE NULL END,
  NULL
FROM generate_series(1, 30) AS day_num
CROSS JOIN (VALUES (7), (12), (18)) AS meal(hour)
WHERE random() > 0.10;

-- ch09 (9mo, mixed feeding)
INSERT INTO feeding_logs (child_id, type, details, timestamp, duration_minutes, notes)
SELECT
  '90000000-0000-0000-0000-000000000009'::uuid,
  CASE WHEN meal.hour IN (7, 20) THEN 'breast' ELSE 'mixed' END,
  CASE WHEN meal.hour IN (7, 20) THEN '{"side":"right"}'::jsonb ELSE
    (ARRAY[
      '{"food":"каша рисовая","amount_g":80}',
      '{"food":"пюре из цветной капусты","amount_g":70}',
      '{"food":"пюре из груши","amount_g":50}'
    ])[1 + floor(random()*3)::int]::jsonb
  END,
  (CURRENT_DATE - day_num)::date::timestamptz + (meal.hour || ' hours')::interval + (floor(random()*20) || ' minutes')::interval,
  CASE WHEN meal.hour IN (7, 20) THEN 10 + floor(random()*15)::int ELSE NULL END,
  NULL
FROM generate_series(1, 30) AS day_num
CROSS JOIN (VALUES (7), (12), (20)) AS meal(hour)
WHERE random() > 0.12;

-- ch13 (8mo, mixed feeding)
INSERT INTO feeding_logs (child_id, type, details, timestamp, duration_minutes, notes)
SELECT
  '90000000-0000-0000-0000-000000000013'::uuid,
  CASE WHEN meal.hour IN (6, 21) THEN 'breast' ELSE 'mixed' END,
  CASE WHEN meal.hour IN (6, 21) THEN '{"side":"left"}'::jsonb ELSE
    (ARRAY[
      '{"food":"каша гречневая","amount_g":70}',
      '{"food":"пюре из моркови","amount_g":60}',
      '{"food":"пюре из тыквы","amount_g":60}'
    ])[1 + floor(random()*3)::int]::jsonb
  END,
  (CURRENT_DATE - day_num)::date::timestamptz + (meal.hour || ' hours')::interval + (floor(random()*20) || ' minutes')::interval,
  CASE WHEN meal.hour IN (6, 21) THEN 10 + floor(random()*15)::int ELSE NULL END,
  NULL
FROM generate_series(1, 30) AS day_num
CROSS JOIN (VALUES (6), (12)) AS meal(hour)
WHERE random() > 0.10;

-- ch17 (13mo, solid food)
INSERT INTO feeding_logs (child_id, type, details, timestamp, notes)
SELECT
  '90000000-0000-0000-0000-000000000017'::uuid,
  'solid',
  (ARRAY[
    '{"food":"каша овсяная","amount_g":110}',
    '{"food":"суп куриный","amount_g":130}',
    '{"food":"творог","amount_g":80}',
    '{"food":"пюре из индейки","amount_g":50}',
    '{"food":"фруктовое пюре","amount_g":70}'
  ])[1 + floor(random()*5)::int]::jsonb,
  (CURRENT_DATE - day_num)::date::timestamptz + (meal.hour || ' hours')::interval + (floor(random()*25) || ' minutes')::interval,
  NULL
FROM generate_series(1, 30) AS day_num
CROSS JOIN (VALUES (8), (13)) AS meal(hour)
WHERE random() > 0.12;


-- =============================================================================
-- 10. FOOD INTRODUCTIONS (~60 records)
-- =============================================================================

-- ch01 (22mo) — full range of foods
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000001', 'Кабачок', CURRENT_DATE - 490, NULL, 'safe', 'Первый овощ'),
('90000000-0000-0000-0000-000000000001', 'Рисовая каша', CURRENT_DATE - 480, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000001', 'Брокколи', CURRENT_DATE - 470, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000001', 'Яблоко', CURRENT_DATE - 460, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000001', 'Кролик', CURRENT_DATE - 420, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000001', 'Яйцо', CURRENT_DATE - 350, NULL, 'safe', NULL);

-- ch03 (14mo)
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000003', 'Кабачок', CURRENT_DATE - 245, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000003', 'Гречневая каша', CURRENT_DATE - 235, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000003', 'Цветная капуста', CURRENT_DATE - 225, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000003', 'Груша', CURRENT_DATE - 215, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000003', 'Индейка', CURRENT_DATE - 185, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000003', 'Яйцо', CURRENT_DATE - 130, NULL, 'safe', NULL);

-- ch05 (10mo) — allergic to egg
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000005', 'Кабачок', CURRENT_DATE - 120, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000005', 'Рисовая каша', CURRENT_DATE - 110, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000005', 'Тыква', CURRENT_DATE - 100, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000005', 'Банан', CURRENT_DATE - 90, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000005', 'Яйцо', CURRENT_DATE - 60, 'Сыпь на щеках и животе через 2 часа', 'reaction', 'IgE повышен');

-- ch06 (11mo) — fish avoid
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000006', 'Кабачок', CURRENT_DATE - 155, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000006', 'Кукурузная каша', CURRENT_DATE - 145, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000006', 'Брокколи', CURRENT_DATE - 135, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000006', 'Яблоко', CURRENT_DATE - 125, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000006', 'Кролик', CURRENT_DATE - 95, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000006', 'Рыба', CURRENT_DATE - 40, 'Рвота через 30 минут', 'avoid', 'Отложена до консультации с аллергологом');

-- ch07 (20mo)
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000007', 'Кабачок', CURRENT_DATE - 430, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000007', 'Гречневая каша', CURRENT_DATE - 420, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000007', 'Морковь', CURRENT_DATE - 400, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000007', 'Говядина', CURRENT_DATE - 340, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000007', 'Яйцо', CURRENT_DATE - 280, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000007', 'Рыба', CURRENT_DATE - 200, NULL, 'safe', NULL);

-- ch09 (9mo) — cow milk reaction
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000009', 'Кабачок', CURRENT_DATE - 90, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000009', 'Рисовая каша', CURRENT_DATE - 80, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000009', 'Цветная капуста', CURRENT_DATE - 70, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000009', 'Груша', CURRENT_DATE - 55, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000009', 'Молоко коровье', CURRENT_DATE - 30, 'Жидкий стул, вздутие живота', 'reaction', 'Непереносимость БКМ');

-- ch11 (18mo)
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000011', 'Кабачок', CURRENT_DATE - 370, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000011', 'Овсяная каша', CURRENT_DATE - 330, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000011', 'Тыква', CURRENT_DATE - 350, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000011', 'Индейка', CURRENT_DATE - 280, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000011', 'Яйцо', CURRENT_DATE - 220, NULL, 'safe', NULL);

-- ch13 (8mo) — allergic to egg
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000013', 'Кабачок', CURRENT_DATE - 60, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000013', 'Гречневая каша', CURRENT_DATE - 50, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000013', 'Брокколи', CURRENT_DATE - 40, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000013', 'Яйцо', CURRENT_DATE - 20, 'Крапивница, зуд по всему телу', 'reaction', 'Подтверждено аллергологом');

-- ch14 (24mo)
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000014', 'Кабачок', CURRENT_DATE - 550, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000014', 'Рисовая каша', CURRENT_DATE - 540, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000014', 'Морковь', CURRENT_DATE - 520, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000014', 'Кролик', CURRENT_DATE - 460, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000014', 'Рыба', CURRENT_DATE - 320, NULL, 'safe', NULL);

-- ch17 (13mo)
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000017', 'Кабачок', CURRENT_DATE - 215, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000017', 'Кукурузная каша', CURRENT_DATE - 205, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000017', 'Цветная капуста', CURRENT_DATE - 195, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000017', 'Яблоко', CURRENT_DATE - 185, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000017', 'Говядина', CURRENT_DATE - 145, NULL, 'safe', NULL);

-- ch20 (16mo)
INSERT INTO food_introductions (child_id, food, introduced_at, reaction, status, notes) VALUES
('90000000-0000-0000-0000-000000000020', 'Кабачок', CURRENT_DATE - 308, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000020', 'Гречневая каша', CURRENT_DATE - 298, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000020', 'Тыква', CURRENT_DATE - 278, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000020', 'Банан', CURRENT_DATE - 268, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000020', 'Индейка', CURRENT_DATE - 218, NULL, 'safe', NULL),
('90000000-0000-0000-0000-000000000020', 'Яйцо', CURRENT_DATE - 158, NULL, 'safe', NULL);


-- =============================================================================
-- 11. SLEEP LOGS (~250 records via generate_series)
-- =============================================================================

-- Night sleep for 6 children over 28 days
INSERT INTO sleep_logs (child_id, date, sleep_start, sleep_end, type, wake_ups, quality, notes)
SELECT
  c.id,
  (CURRENT_DATE - day_num)::date,
  ((CURRENT_DATE - day_num - 1)::date::timestamptz + interval '20 hours' + (floor(random()*60) || ' minutes')::interval),
  ((CURRENT_DATE - day_num)::date::timestamptz + interval '6 hours' + (floor(random()*90) || ' minutes')::interval),
  'night',
  floor(random() * 4)::int,
  (ARRAY['good','good','good','fair','fair','poor'])[1 + floor(random()*6)::int],
  CASE WHEN random() < 0.1 THEN 'Спал беспокойно' ELSE NULL END
FROM (VALUES
  ('90000000-0000-0000-0000-000000000001'::uuid),
  ('90000000-0000-0000-0000-000000000003'::uuid),
  ('90000000-0000-0000-0000-000000000006'::uuid),
  ('90000000-0000-0000-0000-000000000009'::uuid),
  ('90000000-0000-0000-0000-000000000011'::uuid),
  ('90000000-0000-0000-0000-000000000017'::uuid)
) AS c(id)
CROSS JOIN generate_series(1, 28) AS day_num;

-- Nap sleep for 6 children over 28 days (~50% chance of nap per day)
INSERT INTO sleep_logs (child_id, date, sleep_start, sleep_end, type, wake_ups, quality, notes)
SELECT
  c.id,
  (CURRENT_DATE - day_num)::date,
  ((CURRENT_DATE - day_num)::date::timestamptz + interval '13 hours' + (floor(random()*60) || ' minutes')::interval),
  ((CURRENT_DATE - day_num)::date::timestamptz + interval '14 hours' + (30 + floor(random()*90))::int * interval '1 minute'),
  'nap',
  0,
  (ARRAY['good','good','fair'])[1 + floor(random()*3)::int],
  NULL
FROM (VALUES
  ('90000000-0000-0000-0000-000000000001'::uuid),
  ('90000000-0000-0000-0000-000000000003'::uuid),
  ('90000000-0000-0000-0000-000000000006'::uuid),
  ('90000000-0000-0000-0000-000000000009'::uuid),
  ('90000000-0000-0000-0000-000000000011'::uuid),
  ('90000000-0000-0000-0000-000000000017'::uuid)
) AS c(id)
CROSS JOIN generate_series(1, 28) AS day_num
WHERE random() > 0.3;


-- =============================================================================
-- 12. SOS EVENTS (8 records)
-- =============================================================================

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001',
  'Высокая температура',
  ARRAY['температура 39.8','вялость','отказ от еды'],
  'urgent',
  'Дан жаропонижающий (Нурофен). Температура снизилась за 40 мин.',
  CURRENT_TIMESTAMP - interval '142 days' + interval '2 hours',
  '{"lat":43.238,"lng":76.945,"address":"Алматы, ул. Абая 150"}'::jsonb,
  CURRENT_TIMESTAMP - interval '142 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000002', '90000000-0000-0000-0000-000000000003',
  'Аллергическая реакция',
  ARRAY['сыпь по телу','зуд'],
  'urgent',
  'Дан Фенистил. Рекомендован осмотр аллерголога.',
  CURRENT_TIMESTAMP - interval '118 days' + interval '4 hours',
  '{"lat":43.240,"lng":76.950,"address":"Алматы, ул. Жандосова 25"}'::jsonb,
  CURRENT_TIMESTAMP - interval '118 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000007', '90000000-0000-0000-0000-000000000007',
  'Травма',
  ARRAY['ушиб лба','небольшая гематома'],
  'non_urgent',
  'Приложен холод. Наблюдение 24 часа.',
  CURRENT_TIMESTAMP - interval '95 days' + interval '24 hours',
  '{"lat":43.235,"lng":76.940,"address":"Алматы, ул. Розыбакиева 80"}'::jsonb,
  CURRENT_TIMESTAMP - interval '95 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000009', '90000000-0000-0000-0000-000000000009',
  'Судороги',
  ARRAY['фебрильные судороги','температура 39.5'],
  'emergency',
  'Вызвана скорая помощь 103. Госпитализация в детское отделение.',
  CURRENT_TIMESTAMP - interval '78 days' + interval '48 hours',
  '{"lat":43.245,"lng":76.955,"address":"Алматы, мкр. Орбита-2, д. 14"}'::jsonb,
  CURRENT_TIMESTAMP - interval '78 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000006', '90000000-0000-0000-0000-000000000006',
  'Удушье',
  ARRAY['попёрхнулся пищей','кашель','затруднённое дыхание'],
  'emergency',
  'Применён приём Хеймлиха. Дыхание восстановлено.',
  CURRENT_TIMESTAMP - interval '55 days' + interval '1 hour',
  '{"lat":43.230,"lng":76.935,"address":"Алматы, ул. Сатпаева 45"}'::jsonb,
  CURRENT_TIMESTAMP - interval '55 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000011', '90000000-0000-0000-0000-000000000011',
  'Рвота и диарея',
  ARRAY['многократная рвота','жидкий стул','вялость'],
  'urgent',
  'Начата регидратация. Рекомендовано обильное питьё.',
  CURRENT_TIMESTAMP - interval '32 days' + interval '12 hours',
  '{"lat":43.242,"lng":76.948,"address":"Алматы, ул. Тимирязева 72"}'::jsonb,
  CURRENT_TIMESTAMP - interval '32 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000013', '90000000-0000-0000-0000-000000000013',
  'Высокая температура',
  ARRAY['температура 38.5','насморк','кашель'],
  'non_urgent',
  'Рекомендован покой, обильное питьё, жаропонижающие при необходимости.',
  CURRENT_TIMESTAMP - interval '18 days' + interval '6 hours',
  '{"lat":43.250,"lng":76.960,"address":"Алматы, пр. Аль-Фараби 30"}'::jsonb,
  CURRENT_TIMESTAMP - interval '18 days');

INSERT INTO sos_events (family_id, child_id, category, symptoms, triage_result, actions_taken, resolved_at, location, created_at)
VALUES ('80000000-0000-0000-0000-000000000014', '90000000-0000-0000-0000-000000000014',
  'Кожная сыпь',
  ARRAY['красные пятна на щеках','шершавая кожа'],
  'non_urgent',
  'Вероятен атопический дерматит. Назначен Бепантен, направление к дерматологу.',
  CURRENT_TIMESTAMP - interval '5 days' + interval '72 hours',
  '{"lat":43.233,"lng":76.942,"address":"Алматы, ул. Гагарина 110"}'::jsonb,
  CURRENT_TIMESTAMP - interval '5 days');


-- =============================================================================
-- 13. EDUCATION CONTENT (25 records)
-- =============================================================================

-- 8 pregnancy articles
INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000001', NULL, 'article', 8, 'pregnancy',
  'Питание во время беременности',
  'Правильное питание во время беременности — основа здоровья мамы и малыша. В первом триместре важно получать достаточно фолиевой кислоты (400 мкг в день), которая содержится в зелёных овощах, бобовых и цельнозерновых продуктах.

Во втором и третьем триместрах потребность в калориях увеличивается на 300-500 ккал в день. Рацион должен включать: белки (мясо, рыба, яйца, творог), сложные углеводы (каши, хлеб из цельного зерна), полезные жиры (оливковое масло, орехи, авокадо), овощи и фрукты не менее 5 порций в день.

Следует ограничить: кофеин (не более 200 мг в день), сырую рыбу и мясо, мягкие сыры из непастеризованного молока, алкоголь полностью исключить. Пейте не менее 2 литров воды в день. При токсикозе ешьте маленькими порциями каждые 2-3 часа.',
  'Правильное питание во время беременности — основа здоровья мамы и малыша.',
  'https://cdn.umai-health.kz/thumbnails/ec01.jpg',
  ARRAY['беременность','питание','здоровье'], true, CURRENT_TIMESTAMP - interval '180 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000002', NULL, 'article', 6, 'pregnancy',
  'Токсикоз: как справиться',
  'Токсикоз (тошнота и рвота беременных) затрагивает до 80% женщин в первом триместре. Обычно он начинается на 6-8 неделе и проходит к 12-14 неделе, но у некоторых может продолжаться дольше.

Эффективные способы облегчения: ешьте сухое печенье или крекеры утром до подъёма с кровати; избегайте резких запахов и жирной пищи; пейте имбирный чай или рассасывайте имбирные леденцы; витамин B6 (пиридоксин) по 10-25 мг 3 раза в день по рекомендации врача; акупрессурные браслеты на точку P6.

Обратитесь к врачу, если: рвота более 4 раз в день, потеря веса более 5%, невозможность пить жидкость, тёмная моча, головокружение. Это может быть hyperemesis gravidarum — тяжёлая форма токсикоза, требующая лечения.',
  'Токсикоз затрагивает до 80% женщин в первом триместре.',
  'https://cdn.umai-health.kz/thumbnails/ec02.jpg',
  ARRAY['беременность','токсикоз','первый триместр'], true, CURRENT_TIMESTAMP - interval '170 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000003', NULL, 'article', 36, 'pregnancy',
  'Подготовка к родам',
  'Подготовка к родам включает физическую, психологическую и практическую составляющие. Начинать подготовку лучше с 30-й недели беременности.

Физическая подготовка: дыхательные техники (глубокое дыхание, дыхание «свечой»), упражнения Кегеля для укрепления мышц тазового дна, плавание и ходьба. Массаж промежности с 34-й недели снижает риск разрывов. Практикуйте позы для родов: на четвереньках, сидя на мяче, стоя с опорой.

Практическая подготовка: выберите роддом и врача, подготовьте план родов (обезболивание, позиции, присутствие партнёра), соберите сумку в роддом, обустройте место для малыша дома. Курсы подготовки к родам помогут справиться с тревогой и дадут практические навыки.',
  'Подготовка к родам включает физическую, психологическую и практическую составляющие.',
  'https://cdn.umai-health.kz/thumbnails/ec03.jpg',
  ARRAY['беременность','роды','подготовка'], true, CURRENT_TIMESTAMP - interval '160 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000004', NULL, 'article', 14, 'pregnancy',
  'Физические упражнения для беременных',
  'Физическая активность во время беременности полезна для мамы и малыша. ВОЗ рекомендует 150 минут умеренной аэробной активности в неделю при нормально протекающей беременности.

Безопасные виды активности: ходьба (30 минут в день), плавание и аквааэробика, йога для беременных, пилатес с модификациями, велотренажёр. Следует избегать: контактных видов спорта, упражнений с высоким риском падения, прыжков, упражнений лёжа на спине после 16 недель, горячей йоги.

Противопоказания к физической нагрузке: предлежание плаценты, угроза преждевременных родов, преэклампсия, истмико-цервикальная недостаточность. Прекратите занятия при: кровотечении, головокружении, боли в груди, одышке до начала упражнений, схваткообразных болях.',
  'Физическая активность во время беременности полезна для мамы и малыша.',
  'https://cdn.umai-health.kz/thumbnails/ec04.jpg',
  ARRAY['беременность','фитнес','упражнения'], true, CURRENT_TIMESTAMP - interval '155 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000005', NULL, 'article', 34, 'pregnancy',
  'Что взять в роддом',
  'Сумку в роддом лучше собрать к 34-36 неделе беременности. Вещи удобно разделить на три пакета: для родов, для послеродового отделения и для выписки.

Для родов: паспорт, обменная карта, полис медстрахования, удобная одежда (длинная футболка), нескользящие тапочки, вода без газа, телефон с зарядкой. Для послеродового отделения: халат, ночные рубашки с запахом для кормления, бюстгальтер для кормления, одноразовые трусы, прокладки послеродовые, вкладыши для груди, средства гигиены.

Для малыша: подгузники для новорождённых, пелёнки (тёплые и тонкие), шапочка, носочки, боди, комбинезон. Для выписки: нарядный комплект для малыша, конверт или одеяло по сезону, одежда для мамы (учтите, что живот не уходит сразу — возьмите одежду для 6-7 месяца беременности).',
  'Сумку в роддом лучше собрать к 34-36 неделе беременности.',
  'https://cdn.umai-health.kz/thumbnails/ec05.jpg',
  ARRAY['беременность','роддом','сумка'], true, CURRENT_TIMESTAMP - interval '145 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000006', NULL, 'article', 10, 'pregnancy',
  'Анализы первого триместра',
  'Первый триместр — важный период для обследования. В Казахстане программа ведения беременности включает обязательные анализы при постановке на учёт (до 12 недель).

Обязательные анализы: общий анализ крови и мочи, группа крови и резус-фактор, биохимический анализ крови (глюкоза, белок, печёночные ферменты), коагулограмма, анализы на инфекции (ВИЧ, сифилис, гепатиты B и C, TORCH), мазок на флору, ПАП-тест.

УЗИ первого триместра (11-14 недель) — это важнейшее исследование. Оно определяет: срок беременности, количество плодов, толщину воротникового пространства (скрининг на хромосомные аномалии), наличие носовой кости. Вместе с анализом крови на PAPP-A и бета-ХГЧ это составляет комбинированный скрининг первого триместра.',
  'Первый триместр — важный период для обследования.',
  'https://cdn.umai-health.kz/thumbnails/ec06.jpg',
  ARRAY['беременность','анализы','скрининг'], true, CURRENT_TIMESTAMP - interval '140 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000007', NULL, 'article', 20, 'pregnancy',
  'Развитие плода по неделям',
  'Внутриутробное развитие малыша — удивительный процесс. К концу первого триместра (12 недель) все органы уже сформированы, малыш весит около 14 г и имеет длину 6 см. Он может двигать ручками и ножками.

Во втором триместре малыш активно растёт. К 20 неделям он весит около 300 г, мама начинает чувствовать шевеления. Формируются отпечатки пальцев, малыш слышит звуки. К 24 неделям вес достигает 600 г, лёгкие начинают готовиться к дыханию.

В третьем триместре идёт набор веса и созревание органов. К 36 неделям вес 2.5-2.7 кг, лёгкие почти зрелые. К 40 неделям средний вес 3.2-3.5 кг, рост 50-52 см. Малыш полностью готов к рождению. Все органы чувств работают — он реагирует на свет, звук, вкус околоплодных вод.',
  'Внутриутробное развитие малыша — удивительный процесс.',
  'https://cdn.umai-health.kz/thumbnails/ec07.jpg',
  ARRAY['беременность','развитие плода','триместры'], true, CURRENT_TIMESTAMP - interval '135 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000008', NULL, 'article', 30, 'pregnancy',
  'Психологическая подготовка к материнству',
  'Беременность — время не только физических, но и эмоциональных перемен. Тревога, перепады настроения, страх перед родами — всё это нормальные переживания, связанные с гормональными изменениями и новой ролью.

Справиться с тревогой помогают: техники релаксации и медитации (даже 10 минут в день), физическая активность, общение с другими беременными (группы поддержки, курсы), ведение дневника, разговоры с партнёром о чувствах и ожиданиях. Не стесняйтесь обращаться к перинатальному психологу — это не слабость, а забота о себе.

Важно: если грусть, тревога или апатия длятся более двух недель и мешают повседневной жизни — обратитесь к специалисту. Перинатальная депрессия встречается у 10-15% женщин и хорошо поддаётся лечению. Раннее обращение — залог здоровья мамы и малыша.',
  'Беременность — время не только физических, но и эмоциональных перемен.',
  'https://cdn.umai-health.kz/thumbnails/ec08.jpg',
  ARRAY['беременность','психология','эмоции'], true, CURRENT_TIMESTAMP - interval '130 days');

-- 8 infant articles
INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000009', NULL, 'article', 3, 'infant',
  'Грудное вскармливание: первые дни',
  'Грудное вскармливание — лучшее питание для новорождённого. ВОЗ рекомендует исключительно грудное вскармливание первые 6 месяцев жизни. Первое прикладывание к груди должно произойти в течение часа после рождения.

В первые дни выделяется молозиво — густая желтоватая жидкость, богатая антителами и питательными веществами. Его мало по объёму (5-7 мл за кормление), но этого достаточно для новорождённого. На 3-5 день приходит «зрелое» молоко — грудь наливается, может быть болезненность.

Правильное прикладывание: ребёнок захватывает не только сосок, но и большую часть ареолы; нижняя губа вывернута наружу; подбородок прижат к груди; нет щёлкающих звуков; кормление безболезненно. Кормите по требованию — в первые недели это 8-12 раз в сутки, включая ночные кормления.',
  'Грудное вскармливание — лучшее питание для новорождённого.',
  'https://cdn.umai-health.kz/thumbnails/ec09.jpg',
  ARRAY['новорождённый','грудное вскармливание','кормление'], true, CURRENT_TIMESTAMP - interval '120 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000010', NULL, 'article', 7, 'infant',
  'Купание новорождённого',
  'Первое купание можно проводить после заживления пупочной ранки (обычно через 1-2 недели). До этого — обтирание влажной губкой. Температура воды 36-37°C, воздуха в комнате 22-24°C.

Что понадобится: детская ванночка или горка, термометр для воды, мягкая губка или рукавичка, детское мыло или средство для купания (не чаще 2-3 раз в неделю), мягкое полотенце, чистая одежда. Продолжительность купания: 5-7 минут для новорождённого, постепенно увеличивая до 15-20 минут.

Техника: поддерживайте голову и шею одной рукой, другой мойте тело сверху вниз. Особое внимание складочкам на шее, за ушами, подмышками и в паху. После купания промокните кожу (не растирайте), обработайте пупочную ранку, при сухости нанесите детский крем или масло. Лучшее время — вечером перед сном, как часть ритуала.',
  'Первое купание можно проводить после заживления пупочной ранки.',
  'https://cdn.umai-health.kz/thumbnails/ec10.jpg',
  ARRAY['новорождённый','купание','уход'], true, CURRENT_TIMESTAMP - interval '115 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000011', NULL, 'article', 30, 'infant',
  'Колики: причины и помощь',
  'Колики — это эпизоды безутешного плача у здорового ребёнка, обычно начинаются в 2-3 недели и проходят к 3-4 месяцам. Правило трёх: плач более 3 часов в день, более 3 дней в неделю, более 3 недель подряд.

Точная причина колик неизвестна. Предполагаемые факторы: незрелость пищеварительной системы, заглатывание воздуха при кормлении, повышенная чувствительность к стимулам, изменение микрофлоры кишечника. Колики НЕ связаны с плохим уходом — это не ваша вина.

Методы облегчения: выкладывание на животик, массаж живота по часовой стрелке, ношение в слинге или на руках, белый шум, тёплая ванна, «поза тигра на ветке» (ребёнок животом на предплечье), пробиотики с Lactobacillus reuteri (по рекомендации врача), симетикон для уменьшения газообразования. Главное — не оставайтесь с проблемой одни, просите помощь у близких.',
  'Колики — это эпизоды безутешного плача у здорового ребёнка.',
  'https://cdn.umai-health.kz/thumbnails/ec11.jpg',
  ARRAY['младенец','колики','плач'], true, CURRENT_TIMESTAMP - interval '110 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000012', NULL, 'article', 180, 'infant',
  'Введение прикорма: пошаговое руководство',
  'ВОЗ рекомендует вводить прикорм с 6 месяцев, сохраняя грудное вскармливание до 2 лет и дольше. Признаки готовности: ребёнок сидит с поддержкой, интересуется едой, исчез рефлекс выталкивания языком, удвоил вес при рождении.

Порядок введения продуктов: 1) Овощи: кабачок, брокколи, цветная капуста (по одному, каждые 3-5 дней). 2) Каши безмолочные безглютеновые: рисовая, гречневая. 3) Мясо: кролик, индейка (с 7 месяцев). 4) Фрукты: яблоко, груша. 5) Желток яйца (с 8 месяцев). 6) Кисломолочные: творог, кефир (с 8-9 месяцев). 7) Рыба (с 9-10 месяцев).

Начинайте с 0.5 чайной ложки, увеличивая до полной порции за 7-10 дней. Давайте прикорм в первой половине дня. Не добавляйте соль и сахар до 1 года. Текстура: сначала гомогенное пюре, к 8-9 месяцам — с кусочками, к году — мягкая общая пища. Не заставляйте есть — ребёнок сам регулирует аппетит.',
  'ВОЗ рекомендует вводить прикорм с 6 месяцев.',
  'https://cdn.umai-health.kz/thumbnails/ec12.jpg',
  ARRAY['прикорм','питание','6 месяцев'], true, CURRENT_TIMESTAMP - interval '100 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000013', NULL, 'article', 60, 'infant',
  'Сон малыша: режим и привычки',
  'Здоровый сон — основа развития ребёнка. Нормы сна: новорождённый 16-17 часов, 3 месяца 14-16 часов, 6 месяцев 14 часов (2-3 дневных сна), 12 месяцев 13-14 часов (1-2 дневных сна), 2 года 12-13 часов (1 дневной сон).

Формирование здоровых привычек сна: создайте ритуал засыпания (купание, массаж, колыбельная, книга); укладывайте в одно и то же время; разделяйте день и ночь — днём яркий свет и активность, вечером приглушённый свет и тишина; кладите сонного, но бодрствующего, чтобы ребёнок учился засыпать самостоятельно.

Безопасный сон: укладывайте на спину на ровную жёсткую поверхность; без подушек, одеял, мягких игрушек в кроватке; температура комнаты 18-22°C; не перегревайте ребёнка; совместный сон в одной комнате (но не в одной кровати) до 6-12 месяцев снижает риск СВДС.',
  'Здоровый сон — основа развития ребёнка.',
  'https://cdn.umai-health.kz/thumbnails/ec13.jpg',
  ARRAY['сон','режим','младенец'], true, CURRENT_TIMESTAMP - interval '95 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000014', NULL, 'article', 30, 'infant',
  'Массаж для грудничка',
  'Детский массаж стимулирует развитие, улучшает пищеварение и укрепляет связь между мамой и ребёнком. Начинать можно с 1 месяца жизни, когда заживёт пупочная ранка.

Основные правила: делайте массаж через 40-60 минут после кормления; температура комнаты 22-24°C; используйте детское масло; движения мягкие, без нажима; продолжительность 5-10 минут, постепенно увеличивая; если ребёнок плачет — прекратите.

Базовые приёмы: поглаживание ручек от кисти к плечу, поглаживание ножек от стопы к бедру, круговые движения по животу по часовой стрелке (помогает при коликах), поглаживание спинки снизу вверх. С 3 месяцев добавляйте лёгкие разминания. С 6 месяцев можно добавить элементы гимнастики: сгибание-разгибание ножек, перевороты.',
  'Детский массаж стимулирует развитие и улучшает пищеварение.',
  'https://cdn.umai-health.kz/thumbnails/ec14.jpg',
  ARRAY['массаж','развитие','грудничок'], true, CURRENT_TIMESTAMP - interval '90 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000015', NULL, 'article', 90, 'infant',
  'Развивающие игры 0-6 месяцев',
  'Игра — главный способ познания мира для малыша. В первые месяцы жизни важны сенсорные стимулы: зрительные, слуховые, тактильные. Не нужны дорогие игрушки — главная игрушка для ребёнка — это мама.

0-2 месяца: чёрно-белые контрастные картинки (на расстоянии 20-30 см), мобиль над кроваткой, разговоры и пение, выкладывание на животик. 2-4 месяца: погремушки, мягкие книжки с шуршащими элементами, зеркало (ребёнок любит смотреть на лица), «диалоги» — повторяйте звуки за малышом.

4-6 месяцев: игрушки разной текстуры (гладкие, шершавые, мягкие), прорезыватели, простые игры «ку-ку» и «ладушки», перекатывание мячика, чтение книг с яркими крупными картинками. Важно: не перегружайте ребёнка стимулами, следите за признаками утомления (отворачивается, хнычет, трёт глаза).',
  'Игра — главный способ познания мира для малыша.',
  'https://cdn.umai-health.kz/thumbnails/ec15.jpg',
  ARRAY['развитие','игры','0-6 месяцев'], true, CURRENT_TIMESTAMP - interval '85 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000016', NULL, 'article', 120, 'infant',
  'Закаливание ребёнка',
  'Закаливание укрепляет иммунитет и помогает ребёнку адаптироваться к перепадам температур. Начинать можно с рождения, но постепенно и мягко. Главные принципы: систематичность, постепенность, учёт индивидуальных особенностей.

Воздушные ванны: самый мягкий способ закаливания. Оставляйте ребёнка раздетым при температуре 22-24°C на 2-3 минуты, постепенно увеличивая до 15-20 минут. Совмещайте с массажем и гимнастикой. Регулярное проветривание помещения — тоже форма закаливания.

Водные процедуры: начните с умывания лица прохладной водой. Обливание после купания: начните с 36°C, снижая на 1 градус каждые 3-5 дней до 28-26°C. Контрастные обливания ног: тёплая вода 36°C — прохладная 24°C — тёплая. Прогулки на свежем воздухе в любую погоду (кроме экстремальных условий) — важнейший элемент закаливания.',
  'Закаливание укрепляет иммунитет ребёнка.',
  'https://cdn.umai-health.kz/thumbnails/ec16.jpg',
  ARRAY['закаливание','иммунитет','здоровье'], true, CURRENT_TIMESTAMP - interval '80 days');

-- 4 checklists
INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000017', NULL, 'checklist', 34, 'pregnancy',
  'Сумка в роддом: полный список',
  'Документы: паспорт, обменная карта, полис медстрахования, направление, результаты анализов, копия свидетельства о браке (если партнёрские роды).

Для мамы в родзал: удобная длинная футболка, нескользящие тапочки, эластичные носки, резинка для волос, бутылка воды, гигиеническая помада, телефон + зарядка. Для послеродового отделения: 2-3 ночные рубашки с запахом, халат, 2 бюстгальтера для кормления, послеродовые прокладки (2 упаковки), одноразовые трусы (10 шт), вкладыши в бюстгальтер, средства гигиены, крем для сосков (ланолин), молокоотсос (по желанию).

Для малыша: подгузники для новорождённых (1 упаковка), влажные салфетки без отдушки, пелёнки хлопковые (3-4 шт), боди или распашонки (3-4 шт), ползунки (2-3 шт), шапочки (2 шт), носочки, антицарапки, пустышка (по желанию). Для выписки: конверт/одеяло по сезону, нарядный комплект для малыша, одежда для мамы, автокресло-переноска.',
  'Полный список вещей в роддом для мамы и малыша.',
  'https://cdn.umai-health.kz/thumbnails/ec17.jpg',
  ARRAY['роддом','список','чек-лист'], true, CURRENT_TIMESTAMP - interval '75 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000018', NULL, 'checklist', 0, 'infant',
  'Аптечка новорождённого',
  'Средства для обработки пупочной ранки: перекись водорода 3%, хлоргексидин, ватные палочки и диски. Жаропонижающие: парацетамол в свечах (с 1 месяца) и ибупрофен в сиропе (с 3 месяцев) — в возрастной дозировке. Термометр электронный.

Средства для носа: физраствор или спрей с морской водой, назальный аспиратор. Для ушей: ватные жгутики. Для кожи: крем под подгузник (Бепантен, Судокрем), детское масло или крем, присыпка. Для пищеварения: симетикон (от вздутия), укропная вода, газоотводная трубочка.

Антисептики: раствор бриллиантовой зелени (зелёнка), мирамистин. Перевязочные: стерильные бинты, пластырь, ватные диски. Другое: пипетка, мерный шприц для лекарств, стерильная вата. Важно: не давайте ребёнку лекарства без назначения врача. Проверяйте сроки годности каждые 3 месяца.',
  'Необходимые средства для домашней аптечки новорождённого.',
  'https://cdn.umai-health.kz/thumbnails/ec18.jpg',
  ARRAY['аптечка','новорождённый','уход'], true, CURRENT_TIMESTAMP - interval '70 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000019', NULL, 'checklist', 0, 'infant',
  'Чек-лист: первая помощь ребёнку',
  'Высокая температура: до 38.5°C — обтирание тёплой водой, обильное питьё, лёгкая одежда. Выше 38.5°C — жаропонижающее (парацетамол или ибупрофен). Вызов скорой: температура выше 39.5°C не снижается, судороги, возраст до 3 месяцев с температурой выше 38°C.

Подавился: если ребёнок кашляет — не мешайте, дайте откашляться. Если не может дышать (до 1 года): положите на предплечье лицом вниз, 5 ударов основанием ладони между лопатками, затем переверните и 5 нажатий на грудину. Старше 1 года: приём Хеймлиха. Вызовите 103 немедленно.

Ожог: охладите прохладной (не ледяной) водой 10-20 минут. Не прокалывайте пузыри, не наносите масло или сметану. Накройте стерильной повязкой. При ожоге больше ладони ребёнка — вызовите скорую. Отравление: не вызывайте рвоту самостоятельно. Позвоните в скорую 103 или токсикологический центр. Сохраните упаковку вещества.',
  'Краткие инструкции по оказанию первой помощи ребёнку.',
  'https://cdn.umai-health.kz/thumbnails/ec19.jpg',
  ARRAY['первая помощь','безопасность','экстренная помощь'], true, CURRENT_TIMESTAMP - interval '65 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000020', NULL, 'checklist', 36, 'pregnancy',
  'Подготовка дома к новорождённому',
  'Спальное место: кроватка с жёстким матрасом (без подушки для ребёнка до года), непромокаемый наматрасник, 2-3 комплекта постельного белья, ночник с тёплым светом. Кроватку лучше поставить в родительской спальне.

Кормление: если ГВ — удобное кресло или подушка для кормления, бутылочки для сцеженного молока, молокоотсос. Если ИВ — бутылочки (4-6 шт), стерилизатор, подогреватель, ёршик, смесь. Пеленальное место: пеленальный столик или доска на комод, пелёнки, подгузники, влажные салфетки, крем под подгузник.

Безопасность: заглушки на розетки, замки на шкафы (пригодятся через 6 месяцев, но лучше подготовить заранее), москитная сетка на коляску, автокресло группы 0+ (обязательно!). Одежда: 5-6 боди, 4-5 ползунков, 3 шапочки, комбинезон по сезону, конверт в коляску. Прогулки: коляска, сумка для прогулок, дождевик.',
  'Чек-лист подготовки дома к появлению новорождённого.',
  'https://cdn.umai-health.kz/thumbnails/ec20.jpg',
  ARRAY['подготовка','дом','новорождённый'], true, CURRENT_TIMESTAMP - interval '60 days');

-- 5 video/infographic
INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, media_url, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000021', NULL, 'video', 3, 'infant',
  'Как правильно прикладывать к груди',
  'Видеоинструкция по правильному прикладыванию к груди. Показаны основные позиции: «колыбелька», «из-под руки», «лёжа на боку». Демонстрация правильного захвата: широко открытый рот, захват ареолы, вывернутая нижняя губа. Признаки правильного кормления: ритмичные глотательные движения, расслабленное тело ребёнка, мягкая грудь после кормления.',
  'Видеоинструкция по правильному прикладыванию к груди.',
  'https://cdn.umai-health.kz/videos/ec21.mp4',
  'https://cdn.umai-health.kz/thumbnails/ec21.jpg',
  ARRAY['грудное вскармливание','видео','кормление'], true, CURRENT_TIMESTAMP - interval '55 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, media_url, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000022', NULL, 'video', 30, 'infant',
  'Детский массаж: видеоинструкция',
  'Пошаговая видеоинструкция по проведению массажа для грудничка. Показаны основные приёмы: поглаживание рук, ног, живота и спины. Массаж живота по часовой стрелке при коликах. Элементы гимнастики: сгибание-разгибание ножек, «велосипед», перевороты. Все движения мягкие, с учётом анатомических особенностей малыша.',
  'Пошаговая видеоинструкция по проведению массажа для грудничка.',
  'https://cdn.umai-health.kz/videos/ec22.mp4',
  'https://cdn.umai-health.kz/thumbnails/ec22.jpg',
  ARRAY['массаж','видео','грудничок'], true, CURRENT_TIMESTAMP - interval '50 days');

INSERT INTO education_content (id, clinic_id, type, target_week, target_journey_type, title, body, excerpt, media_url, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000023', NULL, 'video', 14, 'pregnancy',
  'Гимнастика для беременных',
  'Комплекс упражнений для второго и третьего триместра. Включает: разминку суставов, упражнения для укрепления мышц спины, тазового дна (Кегель), дыхательные техники для родов. Каждое упражнение показано с модификациями для разных сроков. Продолжительность комплекса 20 минут. Противопоказания указаны в начале видео.',
  'Комплекс безопасных упражнений для беременных.',
  'https://cdn.umai-health.kz/videos/ec23.mp4',
  'https://cdn.umai-health.kz/thumbnails/ec23.jpg',
  ARRAY['беременность','гимнастика','видео'], true, CURRENT_TIMESTAMP - interval '45 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000024', NULL, 'infographic', 0, 'infant',
  'Календарь вакцинации РК',
  'Наглядная инфографика с национальным календарём прививок Республики Казахстан. При рождении: БЦЖ + гепатит B. 2 месяца: АКДС + ИПВ + гепатит B + Hib + пневмококк + ротавирус. 3 месяца: АКДС + ИПВ + Hib. 4 месяца: АКДС + ИПВ + гепатит B + Hib + пневмококк + ротавирус. 12-15 месяцев: КПК + ревакцинация пневмококк. 18 месяцев: АКДС ревакцинация. 6 лет: КПК ревакцинация + АДС-М. Указаны возможные побочные реакции и когда обращаться к врачу.',
  'Национальный календарь прививок Республики Казахстан.',
  'https://cdn.umai-health.kz/thumbnails/ec24.jpg',
  ARRAY['вакцинация','прививки','календарь','Казахстан'], true, CURRENT_TIMESTAMP - interval '40 days');

INSERT INTO education_content (id, clinic_id, type, target_age_days, target_journey_type, title, body, excerpt, thumbnail_url, tags, is_published, published_at)
VALUES ('aa000000-0000-0000-0000-000000000025', NULL, 'infographic', 0, 'infant',
  'Нормы роста и веса WHO',
  'Инфографика с нормами роста и веса по данным ВОЗ для детей от 0 до 2 лет. Отдельные графики для мальчиков и девочек. Показаны перцентили: 3-й, 15-й, 50-й (медиана), 85-й, 97-й. Вес мальчиков: рождение 3.3 кг, 6 мес 7.9 кг, 12 мес 9.6 кг, 24 мес 12.2 кг. Вес девочек: рождение 3.2 кг, 6 мес 7.3 кг, 12 мес 8.9 кг, 24 мес 11.5 кг. Рост мальчиков: рождение 49.9 см, 6 мес 67.6 см, 12 мес 75.7 см, 24 мес 87.1 см. Рекомендация: отслеживайте динамику, а не абсолютные значения.',
  'Нормы роста и веса ВОЗ для детей от 0 до 2 лет.',
  'https://cdn.umai-health.kz/thumbnails/ec25.jpg',
  ARRAY['рост','вес','WHO','нормы'], true, CURRENT_TIMESTAMP - interval '35 days');


-- =============================================================================
-- 14. CONTENT VIEWS (~150 records via INSERT...SELECT)
-- =============================================================================

INSERT INTO content_views (user_id, content_id, viewed_at)
SELECT
  mothers.id,
  content.id,
  CURRENT_TIMESTAMP - (random() * 180 || ' days')::interval
FROM (VALUES
  ('20000000-0000-0000-0000-000000000001'::uuid),
  ('20000000-0000-0000-0000-000000000002'::uuid),
  ('20000000-0000-0000-0000-000000000003'::uuid),
  ('20000000-0000-0000-0000-000000000004'::uuid),
  ('20000000-0000-0000-0000-000000000005'::uuid),
  ('20000000-0000-0000-0000-000000000006'::uuid),
  ('20000000-0000-0000-0000-000000000007'::uuid),
  ('20000000-0000-0000-0000-000000000008'::uuid),
  ('20000000-0000-0000-0000-000000000009'::uuid),
  ('20000000-0000-0000-0000-000000000010'::uuid),
  ('20000000-0000-0000-0000-000000000011'::uuid),
  ('20000000-0000-0000-0000-000000000012'::uuid),
  ('20000000-0000-0000-0000-000000000013'::uuid),
  ('20000000-0000-0000-0000-000000000014'::uuid),
  ('20000000-0000-0000-0000-000000000015'::uuid),
  ('20000000-0000-0000-0000-000000000016'::uuid),
  ('20000000-0000-0000-0000-000000000017'::uuid),
  ('20000000-0000-0000-0000-000000000018'::uuid),
  ('20000000-0000-0000-0000-000000000019'::uuid),
  ('20000000-0000-0000-0000-000000000020'::uuid)
) AS mothers(id)
CROSS JOIN (VALUES
  ('aa000000-0000-0000-0000-000000000001'::uuid),
  ('aa000000-0000-0000-0000-000000000002'::uuid),
  ('aa000000-0000-0000-0000-000000000003'::uuid),
  ('aa000000-0000-0000-0000-000000000004'::uuid),
  ('aa000000-0000-0000-0000-000000000005'::uuid),
  ('aa000000-0000-0000-0000-000000000006'::uuid),
  ('aa000000-0000-0000-0000-000000000007'::uuid),
  ('aa000000-0000-0000-0000-000000000008'::uuid),
  ('aa000000-0000-0000-0000-000000000009'::uuid),
  ('aa000000-0000-0000-0000-000000000010'::uuid),
  ('aa000000-0000-0000-0000-000000000011'::uuid),
  ('aa000000-0000-0000-0000-000000000012'::uuid),
  ('aa000000-0000-0000-0000-000000000013'::uuid),
  ('aa000000-0000-0000-0000-000000000014'::uuid),
  ('aa000000-0000-0000-0000-000000000015'::uuid),
  ('aa000000-0000-0000-0000-000000000016'::uuid),
  ('aa000000-0000-0000-0000-000000000017'::uuid),
  ('aa000000-0000-0000-0000-000000000018'::uuid),
  ('aa000000-0000-0000-0000-000000000019'::uuid),
  ('aa000000-0000-0000-0000-000000000020'::uuid),
  ('aa000000-0000-0000-0000-000000000021'::uuid),
  ('aa000000-0000-0000-0000-000000000022'::uuid),
  ('aa000000-0000-0000-0000-000000000023'::uuid),
  ('aa000000-0000-0000-0000-000000000024'::uuid),
  ('aa000000-0000-0000-0000-000000000025'::uuid)
) AS content(id)
WHERE random() < 0.3;
-- ============================================
-- SEED 06: Engagement, Loyalty, B2B + COMMIT
-- ============================================

-- 15 achievements
INSERT INTO achievements (id, name, icon, description, criteria_json, category, points, created_at) VALUES
('a1000000-0000-0000-0000-000000000001','Первый визит','🏥','Прошли первый приём у врача','{"type":"appointment_count","value":1}','medical',50, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000002','Неделя приёма лекарств','💊','7 дней подряд отмечали приём препарата','{"type":"dose_streak","value":7}','adherence',100, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000003','Месяц приёма лекарств','💊','30 дней подряд отмечали приём препарата','{"type":"dose_streak","value":30}','adherence',300, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000004','Все прививки вовремя','💉','Все вакцинации выполнены по календарю','{"type":"vaccination_complete","value":true}','medical',500, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000005','Первый дневник настроения','😊','Заполнили первую запись дневника настроения','{"type":"mood_log_count","value":1}','wellness',50, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000006','Активный пользователь','⭐','Зашли в приложение 30 дней подряд','{"type":"login_streak","value":30}','engagement',200, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000007','Знаток','📖','Прочитали 10 образовательных статей','{"type":"content_views","value":10}','education',150, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000008','Суперродитель','🦸','Выполнили все задачи journey','{"type":"journey_complete","value":true}','journey',1000, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000009','Первое фото','📷','Загрузили первое фото малыша','{"type":"photo_upload","value":1}','milestone',50, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000010','Друг клиники','🤝','Привели друга по реферальной программе','{"type":"referral","value":1}','referral',300, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000011','Отзывчивый','📝','Оставили 5 отзывов о визитах','{"type":"review_count","value":5}','engagement',200, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000012','Ранняя пташка','🌅','Отметили приём лекарства до 8 утра','{"type":"early_dose","value":1}','adherence',50, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000013','Первый скрининг ЭПДС','💜','Прошли первый скрининг послеродовой депрессии','{"type":"epds_screening","value":1}','wellness',100, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000014','Мастер прикорма','🥦','Ввели 10 новых продуктов','{"type":"food_intro","value":10}','nutrition',200, CURRENT_DATE - interval '730 days'),
('a1000000-0000-0000-0000-000000000015','Марафонец сна','😴','Записывали сон 14 дней подряд','{"type":"sleep_log_streak","value":14}','wellness',150, CURRENT_DATE - interval '730 days');

-- ~65 user_achievements
INSERT INTO user_achievements (user_id, achievement_id, earned_at)
SELECT m.user_id, a.id, m.joined + (random() * (CURRENT_DATE - m.joined::date)) * interval '1 day'
FROM (
  VALUES
    ('20000000-0000-0000-0000-000000000001'::uuid, CURRENT_DATE - interval '700 days'),
    ('20000000-0000-0000-0000-000000000002'::uuid, CURRENT_DATE - interval '455 days'),
    ('20000000-0000-0000-0000-000000000003'::uuid, CURRENT_DATE - interval '150 days'),
    ('20000000-0000-0000-0000-000000000004'::uuid, CURRENT_DATE - interval '72 days'),
    ('20000000-0000-0000-0000-000000000005'::uuid, CURRENT_DATE - interval '330 days'),
    ('20000000-0000-0000-0000-000000000006'::uuid, CURRENT_DATE - interval '365 days'),
    ('20000000-0000-0000-0000-000000000007'::uuid, CURRENT_DATE - interval '640 days'),
    ('20000000-0000-0000-0000-000000000008'::uuid, CURRENT_DATE - interval '120 days'),
    ('20000000-0000-0000-0000-000000000009'::uuid, CURRENT_DATE - interval '300 days'),
    ('20000000-0000-0000-0000-000000000010'::uuid, CURRENT_DATE - interval '60 days'),
    ('20000000-0000-0000-0000-000000000011'::uuid, CURRENT_DATE - interval '580 days'),
    ('20000000-0000-0000-0000-000000000013'::uuid, CURRENT_DATE - interval '270 days'),
    ('20000000-0000-0000-0000-000000000015'::uuid, CURRENT_DATE - interval '30 days'),
    ('20000000-0000-0000-0000-000000000018'::uuid, CURRENT_DATE - interval '90 days'),
    ('20000000-0000-0000-0000-000000000019'::uuid, CURRENT_DATE - interval '520 days')
) AS m(user_id, joined)
CROSS JOIN achievements a
WHERE random() < 0.3
ON CONFLICT (user_id, achievement_id) DO NOTHING;

-- ~25 streaks
INSERT INTO streaks (user_id, type, current_count, longest_count, last_date, created_at) VALUES
('20000000-0000-0000-0000-000000000001','dose_logging',47,120, CURRENT_DATE,'2024-06-01'),
('20000000-0000-0000-0000-000000000001','app_login',12,45, CURRENT_DATE,'2024-06-01'),
('20000000-0000-0000-0000-000000000002','dose_logging',23,58, CURRENT_DATE - 1,'2024-09-01'),
('20000000-0000-0000-0000-000000000002','mood_logging',5,18, CURRENT_DATE,'2024-09-01'),
('20000000-0000-0000-0000-000000000003','dose_logging',15,15, CURRENT_DATE,'2025-11-01'),
('20000000-0000-0000-0000-000000000005','dose_logging',35,67, CURRENT_DATE,'2025-06-01'),
('20000000-0000-0000-0000-000000000005','sleep_logging',8,22, CURRENT_DATE,'2025-06-01'),
('20000000-0000-0000-0000-000000000006','dose_logging',18,42, CURRENT_DATE - 2,'2025-04-01'),
('20000000-0000-0000-0000-000000000007','dose_logging',55,90, CURRENT_DATE,'2024-08-01'),
('20000000-0000-0000-0000-000000000007','app_login',30,62, CURRENT_DATE,'2024-08-01'),
('20000000-0000-0000-0000-000000000009','dose_logging',10,28, CURRENT_DATE - 3,'2025-07-01'),
('20000000-0000-0000-0000-000000000011','dose_logging',42,75, CURRENT_DATE,'2024-10-01'),
('20000000-0000-0000-0000-000000000013','dose_logging',7,20, CURRENT_DATE,'2025-08-01'),
('20000000-0000-0000-0000-000000000018','dose_logging',3,3, CURRENT_DATE,'2026-01-01'),
('20000000-0000-0000-0000-000000000019','dose_logging',0,55, CURRENT_DATE - interval '130 days','2024-12-01'),
('20000000-0000-0000-0000-000000000004','dose_logging',2,8, CURRENT_DATE - 5,'2026-02-01'),
('20000000-0000-0000-0000-000000000008','dose_logging',4,4, CURRENT_DATE,'2025-12-01'),
('20000000-0000-0000-0000-000000000010','dose_logging',6,6, CURRENT_DATE,'2026-02-01'),
('20000000-0000-0000-0000-000000000015','dose_logging',5,5, CURRENT_DATE,'2026-03-01');

-- 12 referrals
INSERT INTO referrals (referrer_family_id, referred_family_id, referral_code, status, reward, created_at) VALUES
('80000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000005','NURLAN2024','rewarded','5000 KZT бонус', CURRENT_DATE - interval '330 days'),
('80000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000009','NURLAN2025','rewarded','5000 KZT бонус', CURRENT_DATE - interval '300 days'),
('80000000-0000-0000-0000-000000000002','80000000-0000-0000-0000-000000000006','KASYM2024','rewarded','5000 KZT бонус', CURRENT_DATE - interval '365 days'),
('80000000-0000-0000-0000-000000000007','80000000-0000-0000-0000-000000000011','BOLAT2024','rewarded','5000 KZT бонус', CURRENT_DATE - interval '580 days'),
('80000000-0000-0000-0000-000000000007','80000000-0000-0000-0000-000000000013','BOLAT2025','active','Ожидает активации', CURRENT_DATE - interval '270 days'),
('80000000-0000-0000-0000-000000000005','80000000-0000-0000-0000-000000000018','AIDYN2025','active','Ожидает активации', CURRENT_DATE - interval '90 days'),
('80000000-0000-0000-0000-000000000011',NULL,'SERIK2026','pending',NULL, CURRENT_DATE - interval '30 days'),
('80000000-0000-0000-0000-000000000002',NULL,'KASYM2025','pending',NULL, CURRENT_DATE - interval '60 days'),
('80000000-0000-0000-0000-000000000006',NULL,'MARAT2025','pending',NULL, CURRENT_DATE - interval '120 days'),
('80000000-0000-0000-0000-000000000001','80000000-0000-0000-0000-000000000015','NURLAN2026','registered',NULL, CURRENT_DATE - interval '30 days'),
('80000000-0000-0000-0000-000000000019',NULL,'TALGAT2026','pending',NULL, CURRENT_DATE - interval '45 days'),
('80000000-0000-0000-0000-000000000014',NULL,'ARMAN2025','pending',NULL, CURRENT_DATE - interval '200 days');

-- ~100 loyalty_points
INSERT INTO loyalty_points (family_id, points, source, description, earned_at)
SELECT
  fam.id,
  CASE s.source
    WHEN 'appointment' THEN 100
    WHEN 'dose_streak' THEN 50
    WHEN 'referral' THEN 500
    WHEN 'nps' THEN 30
    WHEN 'content_view' THEN 10
    WHEN 'vaccination' THEN 200
  END,
  s.source,
  CASE s.source
    WHEN 'appointment' THEN 'Бонус за визит к врачу'
    WHEN 'dose_streak' THEN 'Бонус за серию приёмов лекарств'
    WHEN 'referral' THEN 'Бонус за приглашённого друга'
    WHEN 'nps' THEN 'Бонус за отзыв'
    WHEN 'content_view' THEN 'Бонус за чтение статьи'
    WHEN 'vaccination' THEN 'Бонус за вакцинацию вовремя'
  END,
  fam.created_at + (random() * (CURRENT_DATE - fam.created_at::date)) * interval '1 day'
FROM families fam
CROSS JOIN (VALUES ('appointment'),('dose_streak'),('referral'),('nps'),('content_view'),('vaccination')) AS s(source)
CROSS JOIN generate_series(1, 2) AS n(i)
WHERE random() < 0.45;

-- 30 nps_responses
INSERT INTO nps_responses (family_id, score, event_type, comment, created_at)
SELECT
  fam.id,
  CASE
    WHEN random() < 0.55 THEN 9 + floor(random() * 2)::int  -- promoters
    WHEN random() < 0.65 THEN 7 + floor(random() * 2)::int  -- passives
    ELSE 4 + floor(random() * 4)::int  -- detractors
  END,
  (ARRAY['appointment','journey_complete','monthly_check','post_vaccination'])[1 + floor(random() * 4)::int],
  CASE floor(random() * 6)::int
    WHEN 0 THEN 'Отличный сервис, спасибо!'
    WHEN 1 THEN 'Всё хорошо, но хотелось бы больше напоминаний'
    WHEN 2 THEN 'Врач очень внимательна, рекомендую'
    WHEN 3 THEN 'Удобное приложение'
    WHEN 4 THEN NULL
    ELSE 'Долго ждали на приёме'
  END,
  fam.created_at + (random() * (CURRENT_DATE - fam.created_at::date)) * interval '1 day'
FROM families fam
CROSS JOIN generate_series(1, 2) AS n(i)
WHERE fam.status != 'archived' AND random() < 0.8;

-- 6 service_packages
INSERT INTO service_packages (id, clinic_id, name, description, services_json, price, duration_months, is_active, created_at) VALUES
('a2000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Беременность Стандарт','Базовый пакет ведения беременности','[{"name":"Осмотры акушера (12)","count":12},{"name":"УЗИ (3)","count":3},{"name":"Анализы (базовый набор)","count":1}]',350000,9,true,'2024-01-01'),
('a2000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001','Беременность Премиум','Расширенный пакет с доп. специалистами','[{"name":"Осмотры акушера (16)","count":16},{"name":"УЗИ 3D/4D (5)","count":5},{"name":"Генетик","count":1},{"name":"Эндокринолог","count":2}]',650000,9,true,'2024-01-01'),
('a2000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','Первый год малыша','Наблюдение ребёнка до 1 года','[{"name":"Осмотры педиатра (12)","count":12},{"name":"Вакцинация","count":1},{"name":"Невролог (2)","count":2},{"name":"Анализы","count":4}]',450000,12,true,'2024-01-01'),
('a2000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000002','Беременность BabyBest','Пакет ведения в BabyBest Astana','[{"name":"Осмотры (14)","count":14},{"name":"УЗИ (4)","count":4},{"name":"Скрининги","count":2}]',500000,9,true,'2024-06-01'),
('a2000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000002','Малыш BabyBest','Наблюдение до 1 года в BabyBest','[{"name":"Педиатр (12)","count":12},{"name":"Вакцинация","count":1}]',380000,12,true,'2024-06-01'),
('a2000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000003','Базовый CareKids','Базовый пакет CareKids Shymkent','[{"name":"Осмотры (10)","count":10},{"name":"УЗИ (3)","count":3}]',250000,9,true,'2025-01-01');

-- 15 family_packages
INSERT INTO family_packages (family_id, package_id, purchased_at, expires_at, usage_json, status) VALUES
('80000000-0000-0000-0000-000000000001','a2000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '700 days', CURRENT_DATE - interval '430 days','{"appointments_used":12,"uzi_used":3}','expired'),
('80000000-0000-0000-0000-000000000001','a2000000-0000-0000-0000-000000000003', CURRENT_DATE - interval '650 days', CURRENT_DATE - interval '285 days','{"appointments_used":12,"vaccinations":8}','expired'),
('80000000-0000-0000-0000-000000000001','a2000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '180 days', CURRENT_DATE + interval '90 days','{"appointments_used":5,"uzi_used":2}','active'),
('80000000-0000-0000-0000-000000000002','a2000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '455 days', CURRENT_DATE - interval '185 days','{"appointments_used":12,"uzi_used":3}','expired'),
('80000000-0000-0000-0000-000000000002','a2000000-0000-0000-0000-000000000003', CURRENT_DATE - interval '383 days', CURRENT_DATE - interval '18 days','{"appointments_used":10,"vaccinations":6}','expired'),
('80000000-0000-0000-0000-000000000003','a2000000-0000-0000-0000-000000000002', CURRENT_DATE - interval '150 days', CURRENT_DATE + interval '120 days','{"appointments_used":4,"uzi_used":1}','active'),
('80000000-0000-0000-0000-000000000005','a2000000-0000-0000-0000-000000000003', CURRENT_DATE - interval '300 days', CURRENT_DATE + interval '65 days','{"appointments_used":8,"vaccinations":4}','active'),
('80000000-0000-0000-0000-000000000007','a2000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '640 days', CURRENT_DATE - interval '370 days','{"appointments_used":12,"uzi_used":3}','expired'),
('80000000-0000-0000-0000-000000000007','a2000000-0000-0000-0000-000000000003', CURRENT_DATE - interval '610 days', CURRENT_DATE - interval '245 days','{"appointments_used":11}','expired'),
('80000000-0000-0000-0000-000000000008','a2000000-0000-0000-0000-000000000004', CURRENT_DATE - interval '120 days', CURRENT_DATE + interval '150 days','{"appointments_used":3}','active'),
('80000000-0000-0000-0000-000000000011','a2000000-0000-0000-0000-000000000003', CURRENT_DATE - interval '550 days', CURRENT_DATE - interval '185 days','{"appointments_used":12}','expired'),
('80000000-0000-0000-0000-000000000012','a2000000-0000-0000-0000-000000000001', CURRENT_DATE - interval '200 days', CURRENT_DATE + interval '70 days','{"appointments_used":6,"uzi_used":2}','active'),
('80000000-0000-0000-0000-000000000013','a2000000-0000-0000-0000-000000000005', CURRENT_DATE - interval '240 days', CURRENT_DATE + interval '125 days','{"appointments_used":5}','active'),
('80000000-0000-0000-0000-000000000016','a2000000-0000-0000-0000-000000000006', CURRENT_DATE - interval '90 days', CURRENT_DATE + interval '180 days','{"appointments_used":2}','active'),
('80000000-0000-0000-0000-000000000020','a2000000-0000-0000-0000-000000000006', CURRENT_DATE - interval '80 days', CURRENT_DATE + interval '190 days','{"appointments_used":1}','active');

-- 6 outreach_scenarios
INSERT INTO outreach_scenarios (id, clinic_id, name, trigger_json, actions_json, is_active, created_at) VALUES
('a3000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Напоминание о визите','{"event":"appointment_upcoming","days_before":1}','[{"type":"sms","template":"reminder_appointment"},{"type":"push","template":"reminder_appointment"}]',true,'2024-01-01'),
('a3000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001','Пропущенный приём лекарства','{"event":"dose_missed","hours_after":4}','[{"type":"push","template":"dose_missed"}]',true,'2024-01-01'),
('a3000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','Реактивация неактивных','{"event":"no_login","days_after":14}','[{"type":"sms","template":"reactivation"},{"type":"email","template":"reactivation"}]',true,'2024-06-01'),
('a3000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','NPS после визита','{"event":"appointment_completed","hours_after":24}','[{"type":"push","template":"nps_survey"}]',true,'2024-06-01'),
('a3000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000002','Напоминание о визите (BabyBest)','{"event":"appointment_upcoming","days_before":2}','[{"type":"whatsapp","template":"reminder_appointment"}]',true,'2024-09-01'),
('a3000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000003','Приветствие новой семьи','{"event":"family_registered","days_after":0}','[{"type":"sms","template":"welcome"},{"type":"push","template":"welcome"}]',true,'2025-01-01');

-- ~40 outreach_logs
INSERT INTO outreach_logs (scenario_id, family_id, status, result, sent_at, created_at)
SELECT
  os.id,
  fam.id,
  (ARRAY['sent','delivered','opened','converted','failed'])[1 + floor(random() * 5)::int],
  CASE floor(random() * 3)::int WHEN 0 THEN 'Доставлено' WHEN 1 THEN 'Прочитано' ELSE 'Конвертировано' END,
  fam.created_at + (random() * (CURRENT_DATE - fam.created_at::date)) * interval '1 day',
  fam.created_at + (random() * (CURRENT_DATE - fam.created_at::date)) * interval '1 day'
FROM outreach_scenarios os
CROSS JOIN families fam
WHERE random() < 0.12
  AND fam.clinic_id = os.clinic_id;

-- 20 review_requests
INSERT INTO review_requests (family_id, event_type, nps_score, review_url, status, created_at)
SELECT
  fam.id,
  (ARRAY['appointment','vaccination','journey_milestone'])[1 + floor(random() * 3)::int],
  7 + floor(random() * 4)::int,
  'https://2gis.kz/almaty/firm/' || floor(random() * 9000000 + 1000000)::text,
  (ARRAY['pending','sent','completed','skipped'])[1 + floor(random() * 4)::int],
  fam.created_at + (random() * (CURRENT_DATE - fam.created_at::date)) * interval '1 day'
FROM families fam
WHERE fam.status != 'archived' AND random() < 0.6
LIMIT 20;

-- 6 training_modules
INSERT INTO training_modules (id, clinic_id, role, title, description, content, test_json, passing_score, is_published, created_at) VALUES
('a4000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','coordinator','Онбординг координатора','Как встречать новые семьи и вести коммуникации','[{"type":"text","body":"Введение в работу координатора"},{"type":"video","url":"https://vimeo.com/example1"}]','[{"q":"Через сколько часов нужно позвонить новой семье?","options":["1","4","24"],"correct":2}]',70,true,'2024-01-01'),
('a4000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001','coordinator','Работа с жалобами','Протоколы обработки жалоб родителей','[{"type":"text","body":"Алгоритм реагирования на жалобы"}]','[{"q":"Максимальное время ответа на жалобу?","options":["1 час","4 часа","24 часа"],"correct":1}]',70,true,'2024-03-01'),
('a4000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000001','doctor','Работа в платформе','Как использовать цифровую платформу для врачей','[{"type":"text","body":"Навигация по интерфейсу врача"}]','[{"q":"Где посмотреть расписание?","options":["Главная","Расписание","Профиль"],"correct":1}]',80,true,'2024-01-01'),
('a4000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','nurse','Патронаж новорожденного','Протокол первого патронажа','[{"type":"text","body":"Чек-лист патронажа"},{"type":"quiz","questions":3}]','[{"q":"На какой день первый патронаж?","options":["1","3","7"],"correct":1}]',70,true,'2024-06-01'),
('a4000000-0000-0000-0000-000000000005','10000000-0000-0000-0000-000000000002','coordinator','Онбординг BabyBest','Стандарты работы BabyBest','[{"type":"text","body":"Стандарты сервиса BabyBest"}]','[]',70,true,'2024-09-01'),
('a4000000-0000-0000-0000-000000000006','10000000-0000-0000-0000-000000000003','coordinator','Онбординг CareKids','Стандарты работы CareKids','[{"type":"text","body":"Введение в CareKids"}]','[]',70,true,'2025-03-01');

-- 12 training_progress
INSERT INTO training_progress (user_id, module_id, completed_at, score, attempts, created_at) VALUES
('50000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000001','2024-02-15',90,1,'2024-02-01'),
('50000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000002','2024-04-10',85,1,'2024-04-01'),
('50000000-0000-0000-0000-000000000002','a4000000-0000-0000-0000-000000000001','2024-03-20',75,2,'2024-03-01'),
('50000000-0000-0000-0000-000000000002','a4000000-0000-0000-0000-000000000002','2024-05-15',80,1,'2024-05-01'),
('50000000-0000-0000-0000-000000000003','a4000000-0000-0000-0000-000000000005','2024-10-15',95,1,'2024-10-01'),
('40000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000003','2024-02-10',100,1,'2024-02-01'),
('40000000-0000-0000-0000-000000000002','a4000000-0000-0000-0000-000000000003','2024-02-20',90,1,'2024-02-01'),
('40000000-0000-0000-0000-000000000003','a4000000-0000-0000-0000-000000000003',NULL,NULL,0,'2024-09-01'),
('60000000-0000-0000-0000-000000000001','a4000000-0000-0000-0000-000000000004','2024-07-20',80,1,'2024-07-01'),
('60000000-0000-0000-0000-000000000002','a4000000-0000-0000-0000-000000000004','2024-08-05',70,2,'2024-07-15'),
('60000000-0000-0000-0000-000000000003','a4000000-0000-0000-0000-000000000004',NULL,65,1,'2024-09-01'),
('60000000-0000-0000-0000-000000000004','a4000000-0000-0000-0000-000000000004','2024-10-01',85,1,'2024-09-15');

-- 1 clinic_network + 2 members
INSERT INTO clinic_networks (id, name, created_at) VALUES
('a5000000-0000-0000-0000-000000000001','MediFamily Network','2024-01-01');

INSERT INTO clinic_network_members (network_id, clinic_id, joined_at) VALUES
('a5000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','2024-01-01'),
('a5000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002','2024-06-01');

-- 4 integrations
INSERT INTO integrations (id, clinic_id, provider, type, config_encrypted, sync_status, last_sync_at, created_at) VALUES
('a6000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','МИС Медиалог','mis','enc_config_1','active', CURRENT_DATE - interval '1 day','2024-03-01'),
('a6000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000001','WhatsApp Business','whatsapp','enc_config_2','active', CURRENT_DATE - interval '2 hours','2024-06-01'),
('a6000000-0000-0000-0000-000000000003','10000000-0000-0000-0000-000000000002','1С:Медицина','1c','enc_config_3','active', CURRENT_DATE - interval '12 hours','2024-09-01'),
('a6000000-0000-0000-0000-000000000004','10000000-0000-0000-0000-000000000001','Google Calendar','calendar','enc_config_4','error', CURRENT_DATE - interval '3 days','2025-01-01');

-- 20 sync_logs
INSERT INTO sync_logs (integration_id, direction, entity, records_count, status, error_message, started_at, completed_at)
SELECT
  int_id,
  (ARRAY['inbound','outbound'])[1 + floor(random() * 2)::int],
  (ARRAY['appointments','patients','prescriptions','lab_results'])[1 + floor(random() * 4)::int],
  floor(random() * 50 + 1)::int,
  CASE WHEN random() < 0.8 THEN 'success' WHEN random() < 0.5 THEN 'partial' ELSE 'failed' END,
  CASE WHEN random() > 0.8 THEN 'Timeout при синхронизации' ELSE NULL END,
  ts,
  ts + interval '30 seconds' + (random() * interval '5 minutes')
FROM (
  SELECT
    i.id AS int_id,
    CURRENT_DATE - (floor(random() * 90)::int || ' days')::interval + (floor(random() * 24) || ' hours')::interval AS ts
  FROM integrations i
  CROSS JOIN generate_series(1, 5) AS n(i)
) sub;

-- 2 lab_integrations
INSERT INTO lab_integrations (id, clinic_id, lab_provider, api_key_encrypted, settings, is_active, created_at) VALUES
('a7000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Invitro Kazakhstan','enc_key_invitro','{"auto_import":true,"notify_doctor":true}',true,'2024-06-01'),
('a7000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','Олимп лаборатория','enc_key_olymp','{"auto_import":false,"notify_doctor":true}',true,'2025-01-01');

-- 25 lab_results
INSERT INTO lab_results (family_id, child_id, lab_provider, order_id, status, results_json, raw_pdf_url, received_at, created_at) VALUES
('80000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000001','Invitro Kazakhstan','INV-2024-001','completed','{"hemoglobin":125,"wbc":8.2,"rbc":4.5,"platelets":250}','https://storage.supabase.co/lab/inv-2024-001.pdf', CURRENT_DATE - interval '600 days', CURRENT_DATE - interval '602 days'),
('80000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000001','Invitro Kazakhstan','INV-2024-002','completed','{"hemoglobin":128,"wbc":7.8,"rbc":4.6,"platelets":260}','https://storage.supabase.co/lab/inv-2024-002.pdf', CURRENT_DATE - interval '400 days', CURRENT_DATE - interval '402 days'),
('80000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000002','Invitro Kazakhstan','INV-2025-003','completed','{"hemoglobin":115,"wbc":9.1,"rbc":4.2,"platelets":230}','https://storage.supabase.co/lab/inv-2025-003.pdf', CURRENT_DATE - interval '120 days', CURRENT_DATE - interval '122 days'),
('80000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000003','Invitro Kazakhstan','INV-2024-004','completed','{"hemoglobin":130,"wbc":7.5,"rbc":4.8}','https://storage.supabase.co/lab/inv-2024-004.pdf', CURRENT_DATE - interval '350 days', CURRENT_DATE - interval '352 days'),
('80000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000003','Invitro Kazakhstan','INV-2024-005','completed','{"hemoglobin":132,"wbc":7.2}','https://storage.supabase.co/lab/inv-2024-005.pdf', CURRENT_DATE - interval '200 days', CURRENT_DATE - interval '202 days'),
('80000000-0000-0000-0000-000000000003',NULL,'Invitro Kazakhstan','INV-2025-006','completed','{"hcg":45000,"progesterone":28.5,"tsh":1.8}','https://storage.supabase.co/lab/inv-2025-006.pdf', CURRENT_DATE - interval '140 days', CURRENT_DATE - interval '142 days'),
('80000000-0000-0000-0000-000000000003',NULL,'Invitro Kazakhstan','INV-2025-007','completed','{"hcg":85000,"hemoglobin":118,"glucose":4.5}','https://storage.supabase.co/lab/inv-2025-007.pdf', CURRENT_DATE - interval '80 days', CURRENT_DATE - interval '82 days'),
('80000000-0000-0000-0000-000000000003',NULL,'Invitro Kazakhstan','INV-2026-008','pending',NULL,NULL,NULL, CURRENT_DATE - interval '5 days'),
('80000000-0000-0000-0000-000000000004','90000000-0000-0000-0000-000000000004','Invitro Kazakhstan','INV-2026-009','completed','{"bilirubin":12.5,"hemoglobin":145}','https://storage.supabase.co/lab/inv-2026-009.pdf', CURRENT_DATE - interval '35 days', CURRENT_DATE - interval '37 days'),
('80000000-0000-0000-0000-000000000005','90000000-0000-0000-0000-000000000005','Invitro Kazakhstan','INV-2025-010','completed','{"hemoglobin":120,"ferritin":35}','https://storage.supabase.co/lab/inv-2025-010.pdf', CURRENT_DATE - interval '200 days', CURRENT_DATE - interval '202 days'),
('80000000-0000-0000-0000-000000000006','90000000-0000-0000-0000-000000000006','Invitro Kazakhstan','INV-2025-011','completed','{"hemoglobin":118,"wbc":8.5}','https://storage.supabase.co/lab/inv-2025-011.pdf', CURRENT_DATE - interval '250 days', CURRENT_DATE - interval '252 days'),
('80000000-0000-0000-0000-000000000007','90000000-0000-0000-0000-000000000007','Invitro Kazakhstan','INV-2024-012','completed','{"hemoglobin":125,"wbc":7.0,"rbc":4.4}','https://storage.supabase.co/lab/inv-2024-012.pdf', CURRENT_DATE - interval '500 days', CURRENT_DATE - interval '502 days'),
('80000000-0000-0000-0000-000000000007','90000000-0000-0000-0000-000000000008','Invitro Kazakhstan','INV-2026-013','completed','{"hemoglobin":140,"bilirubin":10.2}','https://storage.supabase.co/lab/inv-2026-013.pdf', CURRENT_DATE - interval '90 days', CURRENT_DATE - interval '92 days'),
('80000000-0000-0000-0000-000000000008',NULL,'Олимп лаборатория','OLM-2025-001','completed','{"hcg":32000,"progesterone":25.0}','https://storage.supabase.co/lab/olm-2025-001.pdf', CURRENT_DATE - interval '100 days', CURRENT_DATE - interval '102 days'),
('80000000-0000-0000-0000-000000000008',NULL,'Олимп лаборатория','OLM-2026-002','processing',NULL,NULL,NULL, CURRENT_DATE - interval '2 days'),
('80000000-0000-0000-0000-000000000009','90000000-0000-0000-0000-000000000009','Invitro Kazakhstan','INV-2025-014','completed','{"hemoglobin":122,"vitD":38}','https://storage.supabase.co/lab/inv-2025-014.pdf', CURRENT_DATE - interval '180 days', CURRENT_DATE - interval '182 days'),
('80000000-0000-0000-0000-000000000011','90000000-0000-0000-0000-000000000011','Invitro Kazakhstan','INV-2025-015','completed','{"hemoglobin":127,"wbc":7.3}','https://storage.supabase.co/lab/inv-2025-015.pdf', CURRENT_DATE - interval '300 days', CURRENT_DATE - interval '302 days'),
('80000000-0000-0000-0000-000000000011','90000000-0000-0000-0000-000000000012','Invitro Kazakhstan','INV-2026-016','completed','{"bilirubin":11.0,"hemoglobin":148}','https://storage.supabase.co/lab/inv-2026-016.pdf', CURRENT_DATE - interval '60 days', CURRENT_DATE - interval '62 days'),
('80000000-0000-0000-0000-000000000012',NULL,'Invitro Kazakhstan','INV-2025-017','completed','{"hcg":55000,"hemoglobin":120}','https://storage.supabase.co/lab/inv-2025-017.pdf', CURRENT_DATE - interval '150 days', CURRENT_DATE - interval '152 days'),
('80000000-0000-0000-0000-000000000013','90000000-0000-0000-0000-000000000013','Invitro Kazakhstan','INV-2025-018','completed','{"hemoglobin":119,"ferritin":30}','https://storage.supabase.co/lab/inv-2025-018.pdf', CURRENT_DATE - interval '160 days', CURRENT_DATE - interval '162 days'),
('80000000-0000-0000-0000-000000000014','90000000-0000-0000-0000-000000000014','Invitro Kazakhstan','INV-2024-019','completed','{"hemoglobin":130,"wbc":7.8}','https://storage.supabase.co/lab/inv-2024-019.pdf', CURRENT_DATE - interval '500 days', CURRENT_DATE - interval '502 days'),
('80000000-0000-0000-0000-000000000016',NULL,'Олимп лаборатория','OLM-2026-003','completed','{"hcg":20000,"hemoglobin":115}','https://storage.supabase.co/lab/olm-2026-003.pdf', CURRENT_DATE - interval '70 days', CURRENT_DATE - interval '72 days'),
('80000000-0000-0000-0000-000000000018','90000000-0000-0000-0000-000000000019','Invitro Kazakhstan','INV-2026-020','completed','{"hemoglobin":145,"bilirubin":9.8}','https://storage.supabase.co/lab/inv-2026-020.pdf', CURRENT_DATE - interval '70 days', CURRENT_DATE - interval '72 days'),
('80000000-0000-0000-0000-000000000019','90000000-0000-0000-0000-000000000020','Invitro Kazakhstan','INV-2025-021','completed','{"hemoglobin":126,"wbc":7.5,"vitD":42}','https://storage.supabase.co/lab/inv-2025-021.pdf', CURRENT_DATE - interval '350 days', CURRENT_DATE - interval '352 days'),
('80000000-0000-0000-0000-000000000020',NULL,'Олимп лаборатория','OLM-2026-004','pending',NULL,NULL,NULL, CURRENT_DATE - interval '3 days');

-- 6 revenue_forecasts (monthly for last 6 months)
INSERT INTO revenue_forecasts (clinic_id, period, forecast_json, created_at)
SELECT
  c.id,
  to_char(CURRENT_DATE - ((6 - s.n) || ' months')::interval, 'YYYY-MM'),
  json_build_object(
    'projected_revenue', (c.base_rev * (1 + 0.05 * s.n))::int,
    'actual_revenue', (c.base_rev * (1 + 0.05 * s.n) * (0.85 + random() * 0.3))::int,
    'new_families', (c.base_fam + floor(random() * 5))::int,
    'churn_families', floor(random() * 3)::int,
    'avg_package_value', c.avg_pkg::int
  )::jsonb,
  CURRENT_DATE - ((6 - s.n) || ' months')::interval
FROM (
  VALUES
    ('10000000-0000-0000-0000-000000000001'::uuid, 4500000, 8, 450000),
    ('10000000-0000-0000-0000-000000000002'::uuid, 2800000, 5, 420000),
    ('10000000-0000-0000-0000-000000000003'::uuid, 1200000, 3, 250000)
) AS c(id, base_rev, base_fam, avg_pkg)
CROSS JOIN generate_series(0, 5) AS s(n);

COMMIT;
