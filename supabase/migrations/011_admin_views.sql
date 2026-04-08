-- Migration 011: Admin Analytics Views & Missing Tables
-- Creates views required by admin dashboard pages + webhooks table

-- ============================================
-- REVENUE VIEW
-- ============================================
CREATE OR REPLACE VIEW v_clinic_revenue AS
SELECT
  c.id AS clinic_id,
  COALESCE(SUM(st.amount) FILTER (WHERE st.date >= date_trunc('month', CURRENT_DATE)), 0) AS mrr,
  COALESCE(
    ROUND(
      (SUM(st.amount) FILTER (WHERE st.date >= date_trunc('month', CURRENT_DATE)) -
       SUM(st.amount) FILTER (WHERE st.date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
                                 AND st.date < date_trunc('month', CURRENT_DATE)))
      / NULLIF(SUM(st.amount) FILTER (WHERE st.date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
                                          AND st.date < date_trunc('month', CURRENT_DATE)), 0) * 100
    , 1), 0
  ) AS mrr_growth,
  COALESCE(
    ROUND(
      SUM(st.amount) FILTER (WHERE st.date >= date_trunc('month', CURRENT_DATE))::NUMERIC /
      NULLIF(COUNT(DISTINCT f.id) FILTER (WHERE f.status = 'active'), 0)
    , 0), 0
  ) AS arpu,
  COALESCE(
    ROUND(
      SUM(st.amount)::NUMERIC / NULLIF(COUNT(DISTINCT f.id), 0)
    , 0), 0
  ) AS avg_ltv,
  COALESCE(
    ROUND(
      COUNT(DISTINCT f.id) FILTER (WHERE f.status = 'archived'
        AND f.updated_at >= date_trunc('month', CURRENT_DATE))::NUMERIC /
      NULLIF(COUNT(DISTINCT f.id), 0) * 100
    , 1), 0
  ) AS churn_rate
FROM clinics c
LEFT JOIN families f ON f.clinic_id = c.id
LEFT JOIN service_transactions st ON st.clinic_id = c.id
GROUP BY c.id;

-- ============================================
-- CAPACITY VIEW
-- ============================================
CREATE OR REPLACE VIEW v_clinic_capacity AS
SELECT
  c.id AS clinic_id,
  COUNT(DISTINCT j.id) FILTER (WHERE j.status = 'active') AS active_journeys,
  COUNT(DISTINCT asl.id) FILTER (
    WHERE asl.date >= CURRENT_DATE
      AND asl.date < CURRENT_DATE + 7
  ) AS weekly_slots,
  COALESCE(
    ROUND(
      COUNT(DISTINCT a.id) FILTER (
        WHERE a.appointment_date >= CURRENT_DATE - 7 AND a.status IN ('confirmed','completed')
      )::NUMERIC /
      NULLIF(COUNT(DISTINCT asl.id) FILTER (
        WHERE asl.date >= CURRENT_DATE - 7 AND asl.date < CURRENT_DATE
      ), 0) * 100
    , 0), 0
  ) AS utilization_pct,
  COUNT(DISTINCT d.id) FILTER (
    WHERE (
      SELECT COUNT(*) FROM appointment_slots s
      WHERE s.doctor_id = d.id
        AND s.date >= CURRENT_DATE AND s.date < CURRENT_DATE + 7
        AND s.is_available = true
    ) = 0
  ) AS bottleneck_count
FROM clinics c
LEFT JOIN families f ON f.clinic_id = c.id
LEFT JOIN journeys j ON j.family_id = f.id
LEFT JOIN doctors d ON d.clinic_id = c.id
LEFT JOIN appointment_slots asl ON asl.doctor_id = d.id
LEFT JOIN appointments a ON a.doctor_id = d.id
GROUP BY c.id;

-- ============================================
-- APPOINTMENT HEATMAP VIEW
-- ============================================
CREATE OR REPLACE VIEW v_appointment_heatmap AS
SELECT
  d.clinic_id,
  EXTRACT(DOW FROM a.appointment_date)::INT AS day_of_week,
  EXTRACT(HOUR FROM a.start_time)::INT AS hour_of_day,
  COUNT(*) AS appointment_count
FROM appointments a
JOIN doctors d ON d.id = a.doctor_id
WHERE a.appointment_date >= CURRENT_DATE - 30
  AND a.status IN ('confirmed', 'completed')
GROUP BY d.clinic_id, EXTRACT(DOW FROM a.appointment_date), EXTRACT(HOUR FROM a.start_time);

-- ============================================
-- COMPLIANCE VIEWS
-- ============================================
CREATE OR REPLACE VIEW v_compliance_overview AS
SELECT
  c.id AS clinic_id,
  COALESCE(
    ROUND(
      COUNT(DISTINCT je.id) FILTER (WHERE je.status = 'completed' AND je.is_mandatory)::NUMERIC /
      NULLIF(COUNT(DISTINCT je.id) FILTER (WHERE je.is_mandatory), 0) * 100
    , 0), 0
  ) AS compliance_pct,
  COUNT(DISTINCT je.id) FILTER (WHERE je.status = 'completed') AS completed_count,
  COUNT(DISTINCT je.id) FILTER (WHERE je.status = 'overdue') AS overdue_count,
  COUNT(DISTINCT je.id) FILTER (WHERE je.status = 'pending'
    AND je.due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 7) AS upcoming_count
FROM clinics c
LEFT JOIN families f ON f.clinic_id = c.id
LEFT JOIN journeys j ON j.family_id = f.id
LEFT JOIN journey_events je ON je.journey_id = j.id
GROUP BY c.id;

CREATE OR REPLACE VIEW v_compliance_gaps AS
SELECT
  c.id AS clinic_id,
  je.type AS event_type,
  je.type AS id,
  je.type AS title,
  'Пропущено обязательное мероприятие' AS description,
  COUNT(DISTINCT f.id) AS affected_families
FROM clinics c
JOIN families f ON f.clinic_id = c.id
JOIN journeys j ON j.family_id = f.id
JOIN journey_events je ON je.journey_id = j.id
WHERE je.status = 'overdue' AND je.is_mandatory = true
GROUP BY c.id, je.type
ORDER BY COUNT(DISTINCT f.id) DESC;

CREATE OR REPLACE VIEW v_protocol_completion AS
SELECT
  c.id AS clinic_id,
  je.type AS event_type,
  COALESCE(
    ROUND(
      COUNT(*) FILTER (WHERE je.status = 'completed')::NUMERIC /
      NULLIF(COUNT(*), 0) * 100
    , 0), 0
  ) AS completion_rate
FROM clinics c
JOIN families f ON f.clinic_id = c.id
JOIN journeys j ON j.family_id = f.id
JOIN journey_events je ON je.journey_id = j.id
WHERE je.is_mandatory = true
GROUP BY c.id, je.type;

-- ============================================
-- NETWORK BRANCHES VIEW
-- ============================================
CREATE OR REPLACE VIEW v_network_branches AS
SELECT
  cnm.network_id,
  c.id AS branch_id,
  c.name,
  c.address AS city,
  COUNT(DISTINCT f.id) FILTER (WHERE f.status = 'active') AS active_families,
  COALESCE(
    ROUND(
      COUNT(DISTINCT je.id) FILTER (WHERE je.status = 'completed' AND je.is_mandatory)::NUMERIC /
      NULLIF(COUNT(DISTINCT je.id) FILTER (WHERE je.is_mandatory), 0) * 100
    , 0), 0
  ) AS completion_rate,
  COALESCE(ROUND(AVG(nr.score), 1), 0) AS nps_score
FROM clinic_network_members cnm
JOIN clinics c ON c.id = cnm.clinic_id
LEFT JOIN families f ON f.clinic_id = c.id
LEFT JOIN journeys j ON j.family_id = f.id
LEFT JOIN journey_events je ON je.journey_id = j.id
LEFT JOIN nps_responses nr ON nr.family_id = f.id
GROUP BY cnm.network_id, c.id, c.name, c.address;

-- ============================================
-- NPS VIEW
-- ============================================
CREATE OR REPLACE VIEW v_clinic_nps AS
SELECT
  c.id AS clinic_id,
  COALESCE(
    ROUND(
      (COUNT(*) FILTER (WHERE nr.score >= 9)::NUMERIC -
       COUNT(*) FILTER (WHERE nr.score <= 6)::NUMERIC) /
      NULLIF(COUNT(*), 0) * 100
    , 0), 0
  ) AS nps_score,
  COUNT(*) AS total_responses,
  COALESCE(ROUND(COUNT(*) FILTER (WHERE nr.score >= 9)::NUMERIC / NULLIF(COUNT(*), 0) * 100, 0), 0) AS promoters_pct,
  COALESCE(ROUND(COUNT(*) FILTER (WHERE nr.score BETWEEN 7 AND 8)::NUMERIC / NULLIF(COUNT(*), 0) * 100, 0), 0) AS passives_pct,
  COALESCE(ROUND(COUNT(*) FILTER (WHERE nr.score <= 6)::NUMERIC / NULLIF(COUNT(*), 0) * 100, 0), 0) AS detractors_pct
FROM clinics c
LEFT JOIN families f ON f.clinic_id = c.id
LEFT JOIN nps_responses nr ON nr.family_id = f.id
GROUP BY c.id;

-- ============================================
-- WEBHOOKS TABLE
-- ============================================
CREATE TABLE webhooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id UUID NOT NULL REFERENCES clinics(id),
  event TEXT NOT NULL,
  url TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_webhooks_clinic ON webhooks(clinic_id);

ALTER TABLE webhooks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can manage webhooks"
  ON webhooks FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND clinic_id = webhooks.clinic_id AND role = 'admin')
  );

-- ============================================
-- UNIQUE CONSTRAINT FOR INTEGRATIONS UPSERT
-- ============================================
CREATE UNIQUE INDEX idx_integrations_clinic_provider ON integrations(clinic_id, provider);

-- ============================================
-- DEMO REQUESTS TABLE (Landing CTA submissions)
-- ============================================
CREATE TABLE demo_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact TEXT NOT NULL,
  clinic_name TEXT,
  email TEXT,
  phone TEXT,
  families_count TEXT,
  source TEXT DEFAULT 'landing',
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'demo_scheduled', 'converted', 'rejected')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Service role can insert (from server API), admins can read
ALTER TABLE demo_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Superadmin can manage demo requests"
  ON demo_requests FOR ALL USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'superadmin')
  );
