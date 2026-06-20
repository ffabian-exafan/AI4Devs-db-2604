-- Verificación post Fase 6 — Prisma sincronizado con ERD
-- Ejecutar tras prisma db push + prisma generate

-- 9 entidades ERD + 3 satélites Prisma
SELECT table_name,
       CASE
           WHEN table_name IN (
               'company','interview_flow','interview_type','candidate',
               'employee','interview_step','position','application','interview'
           ) THEN 'ERD'
           WHEN table_name IN ('education','work_experience','resume') THEN 'SATELITE'
           ELSE 'OTRO'
       END AS origen
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY origen, table_name;

-- Mapeo candidate snake_case (Fase 2 + Prisma @map)
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'candidate'
ORDER BY ordinal_position;

-- FK satélites -> candidate
SELECT conname, conrelid::regclass AS tabla, confrelid::regclass AS referencia
FROM pg_constraint
WHERE conrelid IN (
    'education'::regclass,
    'work_experience'::regclass,
    'resume'::regclass
) AND contype = 'f'
ORDER BY conrelid::regclass::text;
