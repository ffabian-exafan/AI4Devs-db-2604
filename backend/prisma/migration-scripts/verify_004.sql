-- Verificación post Fase 4 — ejecutar tras 004_transaccional.sql
-- Criterio: 9 entidades ERD completas; FKs transaccionales activas

SELECT erd.table_name,
       CASE WHEN t.table_name IS NOT NULL THEN 'CREADA' ELSE 'FALTA' END AS estado
FROM (
    VALUES
        ('company'), ('interview_flow'), ('interview_type'),
        ('candidate'), ('employee'), ('interview_step'),
        ('position'), ('application'), ('interview')
) AS erd(table_name)
LEFT JOIN information_schema.tables t
    ON t.table_schema = 'public' AND t.table_name = erd.table_name
ORDER BY erd.table_name;

-- FKs transaccionales
SELECT conname, conrelid::regclass AS tabla, confrelid::regclass AS referencia
FROM pg_constraint
WHERE conrelid IN ('application'::regclass, 'interview'::regclass)
  AND contype = 'f'
ORDER BY conrelid::regclass::text, conname;

-- Reglas de negocio ERD
SELECT conname, conrelid::regclass AS tabla
FROM pg_constraint
WHERE conname IN (
    'uq_application_position_candidate',
    'uq_interview_application_step',
    'chk_interview_score'
)
ORDER BY conname;

-- Huérfanos (esperado: 0)
SELECT 'application->candidate' AS check_name, COUNT(*) AS huerfanos
FROM application a LEFT JOIN candidate c ON c.id = a.candidate_id WHERE c.id IS NULL
UNION ALL
SELECT 'application->position', COUNT(*)
FROM application a LEFT JOIN "position" p ON p.id = a.position_id WHERE p.id IS NULL;
