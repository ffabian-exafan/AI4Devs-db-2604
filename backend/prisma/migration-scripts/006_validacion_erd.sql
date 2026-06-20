-- =============================================================================
-- Fase 7: Validación integral alineada al ERD
-- Ejecutar tras completar Fases 1-6.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Presencia de las 9 entidades ERD
-- ---------------------------------------------------------------------------
SELECT erd.table_name,
       CASE WHEN t.table_name IS NOT NULL THEN 'OK' ELSE 'FALTA' END AS estado
FROM (
    VALUES
        ('company'), ('interview_flow'), ('interview_type'),
        ('candidate'), ('employee'), ('interview_step'),
        ('position'), ('application'), ('interview')
) AS erd(table_name)
LEFT JOIN information_schema.tables t
    ON t.table_schema = 'public' AND t.table_name = erd.table_name
ORDER BY erd.table_name;

-- ---------------------------------------------------------------------------
-- 2. Columnas clave por entidad (muestra representativa)
-- ---------------------------------------------------------------------------
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'company', 'employee', 'position', 'interview_flow',
      'interview_step', 'interview_type', 'candidate',
      'application', 'interview'
  )
  AND column_name IN (
      'id', 'name', 'description', 'company_id', 'interview_flow_id',
      'interview_type_id', 'first_name', 'last_name', 'email',
      'position_id', 'candidate_id', 'application_id', 'interview_step_id',
      'employee_id', 'order_index', 'status', 'title'
  )
ORDER BY table_name, column_name;

-- ---------------------------------------------------------------------------
-- 3. Integridad referencial — huerfanos (esperado: 0 en todos)
-- ---------------------------------------------------------------------------
SELECT 'employee->company' AS check_name, COUNT(*) AS huerfanos
FROM employee e LEFT JOIN company c ON c.id = e.company_id WHERE c.id IS NULL
UNION ALL
SELECT 'position->company', COUNT(*)
FROM "position" p LEFT JOIN company c ON c.id = p.company_id WHERE c.id IS NULL
UNION ALL
SELECT 'position->interview_flow', COUNT(*)
FROM "position" p LEFT JOIN interview_flow f ON f.id = p.interview_flow_id WHERE f.id IS NULL
UNION ALL
SELECT 'interview_step->flow', COUNT(*)
FROM interview_step s LEFT JOIN interview_flow f ON f.id = s.interview_flow_id WHERE f.id IS NULL
UNION ALL
SELECT 'interview_step->type', COUNT(*)
FROM interview_step s LEFT JOIN interview_type t ON t.id = s.interview_type_id WHERE t.id IS NULL
UNION ALL
SELECT 'application->position', COUNT(*)
FROM application a LEFT JOIN "position" p ON p.id = a.position_id WHERE p.id IS NULL
UNION ALL
SELECT 'application->candidate', COUNT(*)
FROM application a LEFT JOIN candidate c ON c.id = a.candidate_id WHERE c.id IS NULL
UNION ALL
SELECT 'interview->application', COUNT(*)
FROM interview i LEFT JOIN application a ON a.id = i.application_id WHERE a.id IS NULL
UNION ALL
SELECT 'interview->step', COUNT(*)
FROM interview i LEFT JOIN interview_step s ON s.id = i.interview_step_id WHERE s.id IS NULL
UNION ALL
SELECT 'interview->employee', COUNT(*)
FROM interview i LEFT JOIN employee e ON e.id = i.employee_id WHERE e.id IS NULL;

-- ---------------------------------------------------------------------------
-- 4. Cardinalidades ERD (esperado: 0 filas = sin violaciones)
-- ---------------------------------------------------------------------------
SELECT 'position-flow 1:1' AS regla, interview_flow_id::text, COUNT(*)::text AS veces
FROM "position" GROUP BY interview_flow_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'step-type 1:1', interview_type_id::text, COUNT(*)::text
FROM interview_step GROUP BY interview_type_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'candidato no repite vacante', position_id::text, COUNT(*)::text
FROM application GROUP BY position_id, candidate_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'entrevista por paso/postulacion', application_id::text, COUNT(*)::text
FROM interview GROUP BY application_id, interview_step_id HAVING COUNT(*) > 1;

-- ---------------------------------------------------------------------------
-- 5. Conteos actuales + satélites Prisma (snake_case)
-- ---------------------------------------------------------------------------
SELECT 'candidate' AS tabla, COUNT(*)::text AS registros FROM candidate
UNION ALL
SELECT 'education', COUNT(*)::text FROM education
UNION ALL
SELECT 'work_experience', COUNT(*)::text FROM work_experience
UNION ALL
SELECT 'resume', COUNT(*)::text FROM resume;

SELECT 'education->candidate' AS check_name, COUNT(*) AS huerfanos
FROM education e LEFT JOIN candidate c ON c.id = e.candidate_id WHERE c.id IS NULL
UNION ALL
SELECT 'work_experience->candidate', COUNT(*)
FROM work_experience w LEFT JOIN candidate c ON c.id = w.candidate_id WHERE c.id IS NULL
UNION ALL
SELECT 'resume->candidate', COUNT(*)
FROM resume r LEFT JOIN candidate c ON c.id = r.candidate_id WHERE c.id IS NULL;

-- ---------------------------------------------------------------------------
-- 6. Constraints de normalización e integridad
-- ---------------------------------------------------------------------------
SELECT conname, contype, conrelid::regclass AS tabla
FROM pg_constraint
WHERE conrelid IN (
    'company'::regclass,
    'interview_type'::regclass,
    'candidate'::regclass,
    'employee'::regclass,
    'interview_step'::regclass,
    'position'::regclass,
    'application'::regclass,
    'interview'::regclass
)
AND contype IN ('u', 'c', 'f')
ORDER BY conrelid::regclass::text, conname;

-- ---------------------------------------------------------------------------
-- 7. Índices del plan (esperado: 12)
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS indices_plan
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
    'idx_employee_company_id', 'idx_employee_company_active',
    'idx_interview_step_flow_id', 'idx_position_company_id',
    'idx_position_company_visible_status', 'idx_position_application_deadline',
    'idx_application_candidate_id', 'idx_application_position_status',
    'idx_application_date', 'idx_interview_interview_step_id',
    'idx_interview_employee_id', 'idx_interview_interview_date'
  );

-- ---------------------------------------------------------------------------
-- 8. Resumen ERD: relaciones modeladas como FK
-- ---------------------------------------------------------------------------
SELECT
    CASE
        WHEN COUNT(*) FILTER (WHERE estado = 'FALTA') = 0 THEN 'ERD COMPLETO (9/9)'
        ELSE 'ERD INCOMPLETO'
    END AS resumen_erd
FROM (
    SELECT erd.table_name,
           CASE WHEN t.table_name IS NOT NULL THEN 'OK' ELSE 'FALTA' END AS estado
    FROM (
        VALUES
            ('company'), ('interview_flow'), ('interview_type'),
            ('candidate'), ('employee'), ('interview_step'),
            ('position'), ('application'), ('interview')
    ) AS erd(table_name)
    LEFT JOIN information_schema.tables t
        ON t.table_schema = 'public' AND t.table_name = erd.table_name
) sub;
