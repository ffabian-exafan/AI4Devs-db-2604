# Migración manual ERD — Guía de ejecución

Scripts SQL numerados para implementar el [ERD](../ERD) paso a paso **sin pérdida de datos**.

> **Importante:** Cada fase requiere tu aprobación explícita antes de ejecutarse.
> Tras cada fase, ejecutar el script `verify_XXX.sql` correspondiente.

## Ubicación

```
backend/prisma/migration-scripts/
├── 000_baseline.sql
├── 001_catalogos_base.sql
├── 002_migrate_candidate.sql
├── 003_operacion.sql
├── 004_transaccional.sql
├── 005_indexes.sql
├── 006_validacion_erd.sql
├── 007_legacy_company_description.sql  (condicional)
├── verify_001.sql … verify_005.sql
└── README.md
```

## Prerequisitos

1. Backup completo antes de Fase 0:
   ```bash
   pg_dump -h <host> -U <user> -d <db> -F c -f backup_pre_erd.dump
   ```
2. Variable `DATABASE_URL` configurada en `.env`.
3. Ejecutar contra **staging** primero, luego producción.

## Comando de ejecución (PowerShell)

Desde la raíz del proyecto, con `psql` disponible:

```powershell
# Ejemplo Fase 1
psql $env:DATABASE_URL -f backend/prisma/migration-scripts/001_catalogos_base.sql
psql $env:DATABASE_URL -f backend/prisma/migration-scripts/verify_001.sql
```

## Orden de fases

| Fase | Script | Entidades ERD | Aprobación |
|------|--------|---------------|------------|
| 0 | `000_baseline.sql` | Inventario | Requerida |
| 1 | `001_catalogos_base.sql` | COMPANY, INTERVIEW_FLOW, INTERVIEW_TYPE | Requerida |
| 2 | `002_migrate_candidate.sql` | CANDIDATE | Requerida |
| 3 | `003_operacion.sql` | EMPLOYEE, INTERVIEW_STEP, POSITION | Requerida |
| 4 | `004_transaccional.sql` | APPLICATION, INTERVIEW | Requerida |
| 5 | `005_indexes.sql` | Índices | Requerida |
| 6 | Prisma + código | schema.prisma, API | Requerida |
| 7 | `006_validacion_erd.sql` | Validación integral | Requerida |
| 8 | `007_legacy_…sql` | Solo si BD previa con `company_description` | Opcional |

## Mapa ERD → Fases

```
Fase 1: company, interview_flow, interview_type
Fase 2: candidate  (+ preserva Education, WorkExperience, Resume)
Fase 3: employee, interview_step, position
Fase 4: application, interview
```

## Criterios de éxito por fase

- **Fase 0:** conteos guardados; 0 emails duplicados.
- **Fase 1:** 3 tablas creadas; legacy sin cambios.
- **Fase 2:** `candidate` existe; conteos = baseline; 0 huérfanos en satélites.
- **Fase 3:** FKs y constraints 1:1 (`position↔flow`, `step↔type`).
- **Fase 4:** 9 entidades ERD presentes.
- **Fase 5:** 12 índices del plan creados.
- **Fase 7:** validación integral sin huérfanos ni violaciones de cardinalidad.

## Rollback

| Fase fallida | Acción |
|--------------|--------|
| 1–3 | `pg_restore backup_pre_erd.dump` |
| 2 parcial | Restaurar desde backup |
| 4–5 | Restaurar backup o DROP tablas nuevas en orden inverso |

## Siguiente paso

Cuando apruebes, comenzamos con **Fase 0** (baseline): ejecuto `000_baseline.sql`, te muestro resultados y espero tu OK para Fase 1.
