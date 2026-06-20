-- =============================================================================
-- Fase 5: Índices de rendimiento
-- Prerequisitos: Fase 4 completada
-- NOTA: En producción ejecutar fuera de transacción con CONCURRENTLY
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_employee_company_id
    ON employee (company_id);

CREATE INDEX IF NOT EXISTS idx_employee_company_active
    ON employee (company_id, is_active)
    WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_interview_step_flow_id
    ON interview_step (interview_flow_id);

CREATE INDEX IF NOT EXISTS idx_position_company_id
    ON position (company_id);

CREATE INDEX IF NOT EXISTS idx_position_company_visible_status
    ON position (company_id, is_visible, status);

CREATE INDEX IF NOT EXISTS idx_position_application_deadline
    ON position (application_deadline);

CREATE INDEX IF NOT EXISTS idx_application_candidate_id
    ON application (candidate_id);

CREATE INDEX IF NOT EXISTS idx_application_position_status
    ON application (position_id, status);

CREATE INDEX IF NOT EXISTS idx_application_date
    ON application (application_date);

CREATE INDEX IF NOT EXISTS idx_interview_interview_step_id
    ON interview (interview_step_id);

CREATE INDEX IF NOT EXISTS idx_interview_employee_id
    ON interview (employee_id);

CREATE INDEX IF NOT EXISTS idx_interview_interview_date
    ON interview (interview_date);
