# Tasks: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries

**Branch**: `phase-0/sprint-2-domain-model`  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  
**Sprint folder**: `phases/sprints/Sprint 2 — MVP Scope, Domain Language & Product Boundaries/`

**Task taxonomy**: `[DOC-XX]` — all tasks are definition and document production tasks.  
No BE/FE/MO tasks. No code. No migrations. No schema.

---

## Definition of Done (Definition Sprint)

- Each deliverable document is complete and internally consistent
- Domain vocabulary is unambiguous — no term has two meanings
- Platform core and rail vertical concepts are clearly separated
- Event lifecycle is agreed with valid transitions specified
- Permissions matrix is complete for all three roles
- MVP boundary is explicit — in-scope and out-of-scope lists exist
- Sprint 3 artifact recommendations are documented
- All documents committed to sprint branch

---

## Phase 1: Setup

- [x] DOC-01 Confirm Sprint 1 outputs are complete and consumable as inputs
- [x] DOC-02 Resolve domain question: assignment model at MVP
  - _Decision: assignment is implicit in acknowledgment — no explicit assignment step at MVP_
- [x] DOC-03 Create branch `phase-0/sprint-2-domain-model` from `main`
- [x] DOC-04 Confirm sprint folder: `phases/sprints/Sprint 2 — MVP Scope, Domain Language & Product Boundaries/`

---

## Phase 2: Core Domain Definition

- [x] DOC-05 Write `domain-language.md`
  - _Files_: `sprint-2-folder/domain-language.md`
  - _Content_: All nine core vocabulary terms defined. Platform core vs rail vertical boundary table. The rule enforcing separation.
  - _Dependencies_: DOC-01, DOC-02

- [x] DOC-06 Write `event-lifecycle.md`
  - _Files_: `sprint-2-folder/event-lifecycle.md`
  - _Content_: Five states defined. Valid transition table. Acknowledgment model. Event update model. Timeline rules. Failure handling.
  - _Dependencies_: DOC-05

- [x] DOC-07 Write `event-payload.md`
  - _Files_: `sprint-2-folder/event-payload.md`
  - _Content_: Core required fields. Optional core fields. Vertical metadata envelope. Rail vertical metadata for `passenger_assistance`, `service_issue`, `onboard_incident`. Field immutability rules.
  - _Dependencies_: DOC-05, DOC-06

---

## Phase 3: Role and Notification Model

- [x] DOC-08 Write `role-model.md`
  - _Files_: `sprint-2-folder/role-model.md`
  - _Content_: Three platform roles. Full permissions matrix. Deferred capabilities. Rail job title mapping.
  - _Dependencies_: DOC-05

- [x] DOC-09 Write `notification-triggers.md`
  - _Files_: `sprint-2-folder/notification-triggers.md`
  - _Content_: NT-01 through NT-05. Recipient sets. Deferred capabilities. Implementation guidance.
  - _Dependencies_: DOC-06, DOC-08

---

## Phase 4: MVP Boundary

- [x] DOC-10 Write `mvp-boundary.md`
  - _Files_: `sprint-2-folder/mvp-boundary.md`
  - _Content_: In-scope list. Out-of-scope list. Single validation test. Sprint 3 artifact recommendations.
  - _Dependencies_: DOC-05 through DOC-09

---

## Phase 5: Sprint Artifacts

- [x] DOC-11 Write `plan.md`
  - _Files_: `sprint-2-folder/plan.md`
  - _Content_: Executive summary. Constitution compliance table. Deliverables list. Sprint 3 feed.
  - _Dependencies_: DOC-10

- [x] DOC-12 Write `tasks.md` (this file)
  - _Dependencies_: DOC-11

---

## Phase 6: Commit

- [ ] DOC-13 Commit all sprint deliverables to `phase-0/sprint-2-domain-model`
  - _Command_: `git add "phases/sprints/Sprint 2 — ..."/ && git commit -m "docs(sprint-2): domain language, event lifecycle, payload, roles, notifications, MVP boundary"`

- [ ] DOC-14 Push branch to origin
  - _Command_: `git push -u origin phase-0/sprint-2-domain-model`

---

## Sprint 3 Handoff

These items are explicitly out of scope here and are the direct input for Sprint 3:

| Item | Sprint 3 Task |
|---|---|
| Rust workspace layout | Create `Cargo.toml`, domain/api/infra structure |
| DB schema | `events`, `event_timeline`, `actors`, `locations`, `vertical_metadata` |
| API contract | First-pass routes and request/response shapes |
| ADRs | Five architecture decision records |
| Flutter project scaffold | `mobile/` directory and first screen wiring |
| HTMX dashboard scaffold | `dashboard/` templates and live event feed view |
| Docker-compose | Postgres + TimescaleDB local dev environment |
