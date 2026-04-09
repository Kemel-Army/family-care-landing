-- Migration 013: Missing RLS Policies
-- Tables that had RLS enabled but no policies defined

-- ============================================
-- SERVICE TRANSACTIONS
-- ============================================
CREATE POLICY "Staff can manage clinic transactions"
  ON service_transactions FOR ALL USING (
    is_staff() AND clinic_id = get_user_clinic_id()
  );

CREATE POLICY "Family members can read own transactions"
  ON service_transactions FOR SELECT USING (
    is_family_member(family_id)
  );

-- ============================================
-- LAB INTEGRATIONS (admin-only, clinic-scoped)
-- ============================================
CREATE POLICY "Admin can manage clinic lab integrations"
  ON lab_integrations FOR ALL USING (
    get_user_role() IN ('admin', 'superadmin')
    AND clinic_id = get_user_clinic_id()
  );

CREATE POLICY "Staff can read clinic lab integrations"
  ON lab_integrations FOR SELECT USING (
    is_staff() AND clinic_id = get_user_clinic_id()
  );

-- ============================================
-- LAB RESULTS
-- ============================================
CREATE POLICY "Staff can manage clinic lab results"
  ON lab_results FOR ALL USING (
    is_staff() AND EXISTS(
      SELECT 1 FROM families WHERE id = lab_results.family_id AND clinic_id = get_user_clinic_id()
    )
  );

CREATE POLICY "Family members can read own lab results"
  ON lab_results FOR SELECT USING (
    is_family_member(family_id)
  );
