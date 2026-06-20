-- Verificación post Fase 5 — ejecutar tras 005_indexes.sql
-- Criterio: índices clave presentes

SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
    'idx_employee_company_id',
    'idx_employee_company_active',
    'idx_interview_step_flow_id',
    'idx_position_company_id',
    'idx_position_company_visible_status',
    'idx_position_application_deadline',
    'idx_application_candidate_id',
    'idx_application_position_status',
    'idx_application_date',
    'idx_interview_interview_step_id',
    'idx_interview_employee_id',
    'idx_interview_interview_date'
  )
ORDER BY tablename, indexname;

-- Resumen: cuántos índices del plan existen (esperado: 12)
SELECT COUNT(*) AS indices_creados
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%';
