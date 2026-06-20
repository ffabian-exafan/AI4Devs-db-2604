-- Verificación post Fase 3 — ejecutar tras 003_operacion.sql
-- Criterio: employee, interview_step, position con FKs y constraints 1:1

SELECT e.table_name,
       CASE WHEN t.table_name IS NOT NULL THEN 'CREADA' ELSE 'FALTA' END AS estado
FROM (VALUES ('employee'), ('interview_step'), ('position')) AS e(table_name)
LEFT JOIN information_schema.tables t
    ON t.table_schema = 'public' AND t.table_name = e.table_name;

-- FKs hacia catálogos Fase 1
SELECT conname, conrelid::regclass AS tabla, confrelid::regclass AS referencia
FROM pg_constraint
WHERE conrelid IN ('employee'::regclass, 'interview_step'::regclass, 'position'::regclass)
  AND contype = 'f'
ORDER BY conrelid::regclass::text, conname;

-- Constraints 1:1 del ERD
SELECT conname, conrelid::regclass AS tabla
FROM pg_constraint
WHERE conname IN (
    'uq_position_interview_flow',
    'uq_interview_step_type',
    'uq_interview_step_flow_order',
    'uq_employee_company_email'
)
ORDER BY conname;

-- Violaciones 1:1 (esperado: 0 filas si hay datos)
SELECT 'position↔flow' AS regla, interview_flow_id, COUNT(*)
FROM position GROUP BY interview_flow_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'step↔type', interview_type_id, COUNT(*)
FROM interview_step GROUP BY interview_type_id HAVING COUNT(*) > 1;
