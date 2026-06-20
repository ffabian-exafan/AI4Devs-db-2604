# Baseline Fase 0 — Snapshot
Fecha: 2026-06-20
Motor: PostgreSQL 18.4 (Docker: ai4devs-db-2604-db-1)
Base de datos: LTIdb

## Resultados

| Check | Valor |
|-------|-------|
| tablas_public | 0 |
| Candidate | N/A — tabla no existe |
| Education | N/A — tabla no existe |
| WorkExperience | N/A — tabla no existe |
| Resume | N/A — tabla no existe |
| Emails duplicados | N/A — Candidate no existe |
| Huérfanos satélites | N/A |

## Tablas ERD pendientes (9/9)

- application
- candidate
- company
- employee
- interview
- interview_flow
- interview_step
- interview_type
- position

## Conclusión Fase 0

- **Escenario:** BD greenfield (vacía).
- **Riesgo de pérdida de datos legacy:** NINGUNO (no hay datos previos).
- **Impacto en Fase 2:** usará escenario B (CREATE TABLE candidate) en lugar de renombrado.
- **Prisma legacy:** tablas Candidate/Education/WorkExperience/Resume aún no creadas.
  Considerar ejecutar `prisma migrate dev` antes de Fase 2 si se desea preservar el flujo Prisma original,
  o continuar con el plan ERD directamente desde Fase 1.

## Criterios Fase 0

| Criterio | Estado |
|----------|--------|
| Inventario documentado | OK |
| 0 emails duplicados | OK (N/A) |
| 0 huérfanos | OK (N/A) |
| Backup recomendado | Pendiente manual del usuario |
| Listo para Fase 1 | OK |

---

# Fase 1 — Snapshot
Fecha: 2026-06-20

## Tablas creadas (3/3)

- company (id, name, description) — ERD: COMPANY
- interview_flow (id, description) — ERD: INTERVIEW_FLOW
- interview_type (id, name, description) — ERD: INTERVIEW_TYPE

## Constraints clave

- uq_interview_type_name (FNBC)

## Verificación

| Criterio | Estado |
|----------|--------|
| 3 tablas catálogo creadas | OK |
| Columnas ERD presentes | OK |
| Legacy sin migrar aún | OK (greenfield) |
| Satélites Prisma intactos | N/A (no existen) |
| Listo para Fase 2 | OK |

---

# Fase 2 — Snapshot
Fecha: 2026-06-20

## Escenario aplicado

- **B (greenfield):** CREATE TABLE candidate (no existia legacy "Candidate")

## Tabla creada

- candidate (id, first_name, last_name, email, phone, address) — ERD: CANDIDATE

## Constraints

- uq_candidate_email

## Verificación

| Criterio | Estado |
|----------|--------|
| candidate existe | OK |
| Candidate legacy no existe | OK |
| Columnas ERD (first_name, last_name, email...) | OK |
| Conteo registros | 0 (= baseline greenfield) |
| Huérfanos satélites | N/A |
| Listo para Fase 3 | OK |

## Tablas en BD (4)

company, interview_flow, interview_type, candidate

---

# Fase 3 — Snapshot
Fecha: 2026-06-20

## Tablas creadas (3)

- employee — ERD: EMPLOYEE (FK company)
- interview_step — ERD: INTERVIEW_STEP (FK flow + type)
- position — ERD: POSITION (FK company + flow)

## Constraints ERD clave

- uq_employee_company_email
- uq_interview_step_flow_order
- uq_interview_step_type (1:1 step↔type)
- uq_position_interview_flow (1:1 position↔flow)
- fk_employee_company, fk_interview_step_flow, fk_interview_step_type
- fk_position_company, fk_position_interview_flow

## Verificación

| Criterio | Estado |
|----------|--------|
| 3 tablas operativas creadas | OK |
| FKs hacia Fase 1 | OK |
| Constraints 1:1 ERD | OK |
| Violaciones 1:1 | 0 filas |
| Listo para Fase 4 | OK |

## Tablas en BD (7)

candidate, company, employee, interview_flow, interview_step, interview_type, position

---

# Fase 4 — Snapshot
Fecha: 2026-06-20

## Tablas creadas (2)

- application — ERD: APPLICATION
- interview — ERD: INTERVIEW

## Constraints ERD

- uq_application_position_candidate
- uq_interview_application_step
- chk_interview_score
- fk_application_position, fk_application_candidate
- fk_interview_application, fk_interview_step, fk_interview_employee

## Verificación

| Criterio | Estado |
|----------|--------|
| 9/9 entidades ERD presentes | OK |
| FKs transaccionales | OK |
| Reglas de negocio | OK |
| Huérfanos | 0 |
| Listo para Fase 5 | OK |

## Tablas en BD (9/9 ERD completo)

application, candidate, company, employee, interview, interview_flow, interview_step, interview_type, position

---

# Fase 5 — Snapshot
Fecha: 2026-06-20

## Indices creados (12/12)

- idx_employee_company_id
- idx_employee_company_active (parcial)
- idx_interview_step_flow_id
- idx_position_company_id
- idx_position_company_visible_status
- idx_position_application_deadline
- idx_application_candidate_id
- idx_application_position_status
- idx_application_date
- idx_interview_interview_step_id
- idx_interview_employee_id
- idx_interview_interview_date

## Verificación

| Criterio | Estado |
|----------|--------|
| 12 indices del plan | OK |
| ERD intacto (9 tablas) | OK |
| Listo para Fase 6 (Prisma) | OK |
| Listo para Fase 7 (validacion) | OK |

---

# Fase 6 — Snapshot
Fecha: 2026-06-20

## Cambios aplicados

- schema.prisma: 12 modelos (9 ERD + 3 satélites)
- backend/.env: DATABASE_URL expandida para Prisma
- docker-compose.yml: volumen postgres_data (persistencia)
- Candidate.ts: uploadDate en nested create de resumes
- api-spec.yaml: descripción alineada al ERD

## Prisma

- `npx prisma db push` — BD sincronizada
- `npx prisma validate` — OK
- `npx prisma generate` — OK

## Tests

- 4 suites, 37 tests — OK

## Tablas finales (12)

ERD (9): application, candidate, company, employee, interview,
interview_flow, interview_step, interview_type, position

Satélites (3): education, resume, work_experience

## Nota operativa

Al reiniciar Docker sin volumen se perdió el esquema Fases 1-5;
se reaplicaron scripts 001-005 y se añadió volumen persistente.

---

# Fase 7 — Snapshot (validación final)
Fecha: 2026-06-20

## Resultados 006_validacion_erd.sql

| Check | Resultado |
|-------|-----------|
| Entidades ERD 9/9 | OK |
| Columnas clave | 35 verificadas OK |
| Huérfanos FK ERD | 0 en 10 checks |
| Violaciones cardinalidad | 0 filas |
| Huérfanos satélites | 0 |
| Constraints u/c/f | 21 activos |
| Resumen ERD | COMPLETO (9/9) |

## Corrección aplicada en Fase 7

- Re-ejecutado 005_indexes.sql (Prisma db push había dejado solo 1/12 índices)
- Índices restaurados: 12/12

## Conteos finales (greenfield)

- candidate: 0
- education: 0
- work_experience: 0
- resume: 0

## Migración global: COMPLETADA

| Fase | Estado |
|------|--------|
| 0 Baseline | OK |
| 1 Catálogos | OK |
| 2 Candidate | OK |
| 3 Operación | OK |
| 4 Transaccional | OK |
| 5 Índices | OK (restaurados en F7) |
| 6 Prisma + app | OK |
| 7 Validación | OK |
