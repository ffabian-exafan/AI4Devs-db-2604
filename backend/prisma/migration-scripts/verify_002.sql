-- Verificación post Fase 2 — ejecutar tras 002_migrate_candidate.sql
-- Criterio: candidate existe; Candidate legacy no; conteos = baseline; 0 huérfanos

SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'candidate'
) AS candidate_existe;

SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'Candidate'
) AS candidate_legacy_debe_ser_false;

-- Columnas ERD en candidate
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'candidate'
ORDER BY ordinal_position;

-- Unicidad email
SELECT conname FROM pg_constraint
WHERE conrelid = 'candidate'::regclass AND contype = 'u';

-- Conteo (comparar con baseline)
SELECT COUNT(*) AS total_candidates FROM candidate;

-- Huérfanos satélites (esperado: 0 o N/A en greenfield)
DO $$
DECLARE orphan_count BIGINT;
BEGIN
    IF to_regclass('"Education"') IS NOT NULL THEN
        EXECUTE '
            SELECT COUNT(*) FROM "Education" e
            LEFT JOIN candidate c ON c.id = e.candidate_id
            WHERE c.id IS NULL' INTO orphan_count;
        RAISE NOTICE 'Education huerfanos: % (esperado: 0)', orphan_count;
    ELSE
        RAISE NOTICE 'Education huerfanos: N/A — no existe';
    END IF;

    IF to_regclass('"WorkExperience"') IS NOT NULL THEN
        EXECUTE '
            SELECT COUNT(*) FROM "WorkExperience" w
            LEFT JOIN candidate c ON c.id = w.candidate_id
            WHERE c.id IS NULL' INTO orphan_count;
        RAISE NOTICE 'WorkExperience huerfanos: % (esperado: 0)', orphan_count;
    ELSE
        RAISE NOTICE 'WorkExperience huerfanos: N/A — no existe';
    END IF;

    IF to_regclass('"Resume"') IS NOT NULL THEN
        EXECUTE '
            SELECT COUNT(*) FROM "Resume" r
            LEFT JOIN candidate c ON c.id = r.candidate_id
            WHERE c.id IS NULL' INTO orphan_count;
        RAISE NOTICE 'Resume huerfanos: % (esperado: 0)', orphan_count;
    ELSE
        RAISE NOTICE 'Resume huerfanos: N/A — no existe';
    END IF;
END $$;
