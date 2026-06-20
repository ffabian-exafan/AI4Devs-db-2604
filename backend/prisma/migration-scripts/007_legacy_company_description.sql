-- =============================================================================
-- Fase 8 (CONDICIONAL): Migración legacy company_description → company.description
-- Ejecutar SOLO si existía position.company_description en una BD anterior.
-- Omitir si la BD es nueva y sigue el ERD actual.
-- =============================================================================

BEGIN;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'position'
          AND column_name = 'company_description'
    ) THEN
        UPDATE company c
        SET description = sub.company_description
        FROM (
            SELECT DISTINCT ON (company_id)
                   company_id,
                   company_description
            FROM position
            WHERE company_description IS NOT NULL
            ORDER BY company_id, application_deadline DESC NULLS LAST, id DESC
        ) sub
        WHERE c.id = sub.company_id
          AND c.description IS NULL;

        ALTER TABLE position DROP COLUMN company_description;
    END IF;
END $$;

COMMIT;
