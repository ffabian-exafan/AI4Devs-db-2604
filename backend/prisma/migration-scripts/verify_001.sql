-- Verificación post Fase 1 — ejecutar tras 001_catalogos_base.sql
-- Criterio: 3 tablas ERD presentes; legacy intacto

SELECT e.table_name,
       CASE WHEN t.table_name IS NOT NULL THEN 'CREADA' ELSE 'FALTA' END AS estado
FROM (VALUES ('company'), ('interview_flow'), ('interview_type')) AS e(table_name)
LEFT JOIN information_schema.tables t
    ON t.table_schema = 'public' AND t.table_name = e.table_name;

-- Columnas ERD esperadas
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND (
    (table_name = 'company' AND column_name IN ('id', 'name', 'description'))
    OR (table_name = 'interview_flow' AND column_name IN ('id', 'description'))
    OR (table_name = 'interview_type' AND column_name IN ('id', 'name', 'description'))
  )
ORDER BY table_name, column_name;

-- Legacy no debe haberse tocado (conteos = baseline Fase 0)
SELECT 'Candidate_legacy_exists' AS check_name,
       EXISTS (
           SELECT 1 FROM information_schema.tables
           WHERE table_schema = 'public' AND table_name = 'Candidate'
       ) AS candidate_sin_migrar;

-- Satélites Prisma (si existen; greenfield = N/A)
DO $$
DECLARE cnt BIGINT;
BEGIN
    IF to_regclass('"Education"') IS NOT NULL THEN
        EXECUTE 'SELECT COUNT(*) FROM "Education"' INTO cnt;
        RAISE NOTICE 'Education: % registros', cnt;
    ELSE
        RAISE NOTICE 'Education: N/A — no existe';
    END IF;
    IF to_regclass('"WorkExperience"') IS NOT NULL THEN
        EXECUTE 'SELECT COUNT(*) FROM "WorkExperience"' INTO cnt;
        RAISE NOTICE 'WorkExperience: % registros', cnt;
    ELSE
        RAISE NOTICE 'WorkExperience: N/A — no existe';
    END IF;
    IF to_regclass('"Resume"') IS NOT NULL THEN
        EXECUTE 'SELECT COUNT(*) FROM "Resume"' INTO cnt;
        RAISE NOTICE 'Resume: % registros', cnt;
    ELSE
        RAISE NOTICE 'Resume: N/A — no existe';
    END IF;
END $$;
