-- =============================================================================
-- Fase 0: Baseline — inventario previo a la migración
-- Ejecutar ANTES de cualquier cambio. Guardar resultados para comparar al final.
-- NO modifica datos. Soporta BD vacía (greenfield) y BD con tablas Prisma legacy.
-- =============================================================================

DROP TABLE IF EXISTS baseline_report;
CREATE TEMP TABLE baseline_report (
    check_name TEXT NOT NULL,
    value      TEXT NOT NULL
);

-- Estado general
INSERT INTO baseline_report
SELECT 'tablas_public', COUNT(*)::text
FROM information_schema.tables
WHERE table_schema = 'public';

-- Conteos legacy (dinámico para evitar error si no existen)
DO $$
DECLARE
    cnt BIGINT;
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'Candidate'
    ) THEN
        EXECUTE 'SELECT COUNT(*) FROM "Candidate"' INTO cnt;
        INSERT INTO baseline_report VALUES ('Candidate', cnt::text);
    ELSE
        INSERT INTO baseline_report VALUES ('Candidate', 'N/A — tabla no existe');
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'Education'
    ) THEN
        EXECUTE 'SELECT COUNT(*) FROM "Education"' INTO cnt;
        INSERT INTO baseline_report VALUES ('Education', cnt::text);
    ELSE
        INSERT INTO baseline_report VALUES ('Education', 'N/A — tabla no existe');
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'WorkExperience'
    ) THEN
        EXECUTE 'SELECT COUNT(*) FROM "WorkExperience"' INTO cnt;
        INSERT INTO baseline_report VALUES ('WorkExperience', cnt::text);
    ELSE
        INSERT INTO baseline_report VALUES ('WorkExperience', 'N/A — tabla no existe');
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'Resume'
    ) THEN
        EXECUTE 'SELECT COUNT(*) FROM "Resume"' INTO cnt;
        INSERT INTO baseline_report VALUES ('Resume', cnt::text);
    ELSE
        INSERT INTO baseline_report VALUES ('Resume', 'N/A — tabla no existe');
    END IF;
END $$;

SELECT * FROM baseline_report ORDER BY check_name;

-- Emails duplicados en Candidate (solo si existe)
DO $$
DECLARE
    dup_count BIGINT;
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'Candidate'
    ) THEN
        EXECUTE '
            SELECT COUNT(*) FROM (
                SELECT email FROM "Candidate"
                GROUP BY email HAVING COUNT(*) > 1
            ) d' INTO dup_count;
        RAISE NOTICE 'Emails duplicados en Candidate: % (esperado: 0)', dup_count;
    ELSE
        RAISE NOTICE 'Emails duplicados: N/A — Candidate no existe';
    END IF;
END $$;

-- Huérfanos satélites (solo si existen tablas relacionadas)
DO $$
DECLARE
    orphan_count BIGINT;
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'Education'
    ) AND EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'Candidate'
    ) THEN
        EXECUTE '
            SELECT COUNT(*) FROM "Education" e
            LEFT JOIN "Candidate" c ON c.id = e."candidateId"
            WHERE c.id IS NULL' INTO orphan_count;
        RAISE NOTICE 'Education huérfanos: % (esperado: 0)', orphan_count;
    ELSE
        RAISE NOTICE 'Education huérfanos: N/A';
    END IF;
END $$;

-- Tablas ERD pendientes de crear (esperado: 9 antes de Fase 1)
SELECT table_name AS erd_pendiente
FROM (
    VALUES
        ('company'), ('interview_flow'), ('interview_type'), ('candidate'),
        ('employee'), ('interview_step'), ('position'), ('application'), ('interview')
) AS erd(table_name)
WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.tables t
    WHERE t.table_schema = 'public' AND t.table_name = erd.table_name
)
ORDER BY table_name;
