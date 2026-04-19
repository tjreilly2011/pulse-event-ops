# Tasks: Sprint 1 — Problem Discovery & Rail Workflow Validation

**Branch**: `phase-0/sprint-1-discovery`  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  
**Sprint folder**: `phases/sprints/Sprint 1 — Problem Discovery & Rail Workflow Validation/`

**Task taxonomy**: `[DOC-XX]` — all tasks are document production or validation tasks.  
No BE/FE/MO tasks. No code. No migrations. No tests.

---

## Definition of Done (Discovery Sprint)

- Each deliverable document exists in the sprint folder
- Content is grounded in real operational scenarios (not invented)
- No premature architecture or implementation detail has been introduced
- Content is clear enough that Sprint 2 (domain language sprint) can consume it directly
- All documents committed to sprint branch

---

## Phase 1: Setup

- [x] DOC-01 Create sprint branch `phase-0/sprint-1-discovery` from `main`
- [x] DOC-02 Confirm sprint folder location: `phases/sprints/Sprint 1 — Problem Discovery & Rail Workflow Validation/`

---

## Phase 2: Scenario Capture (Input from Domain Owner)

- [x] DOC-03 Capture Scenario 1 — Passenger Wheelchair Assistance  
  _Input: guard identifies need → calls station (often no answer) → no confirmation → random outcome_

- [x] DOC-04 Capture Scenario 2 — Onboard Medical Emergency  
  _Input: guard splits attention between emergency and incoming management calls → inconsistent updates → no source of truth_

- [x] DOC-05 Capture Scenario 3 — Service Issue (Aircon / No Water / Shop)  
  _Input: no consistent reporting channel → engineers not informed → no status tracking → repeated update calls_

- [x] DOC-06 Select MVP scenario  
  _Decision: Scenario 1 (Wheelchair Assistance) — highest frequency, clearest workflow, lowest complexity, directly solvable_

---

## Phase 3: Deliverable Document Production

- [x] DOC-07 Write `problem-statement.md`  
  _Files_: `phases/sprints/Sprint 1 — .../problem-statement.md`  
  _Content_: Core failure, failure pattern diagram, hypothesis  
  _Dependencies_: DOC-03, DOC-04, DOC-05

- [x] DOC-08 Write `user-roles.md`  
  _Files_: `phases/sprints/Sprint 1 — .../user-roles.md`  
  _Content_: Guard/CSO, Station Staff, Ops/Control — responsibilities, pain points, platform needs  
  _Dependencies_: DOC-06

- [x] DOC-09 Write `current-state-workflow.md`  
  _Files_: `phases/sprints/Sprint 1 — .../current-state-workflow.md`  
  _Content_: Step-by-step broken workflow, failure modes, friction table. All 3 scenarios captured.  
  _Dependencies_: DOC-03, DOC-04, DOC-05, DOC-06

- [x] DOC-10 Write `desired-state-workflow.md`  
  _Files_: `phases/sprints/Sprint 1 — .../desired-state-workflow.md`  
  _Content_: Step-by-step desired workflow, before/after table, constitution compliance notes  
  _Dependencies_: DOC-09

- [x] DOC-11 Write `mvp-workflow-definition.md`  
  _Files_: `phases/sprints/Sprint 1 — .../mvp-workflow-definition.md`  
  _Content_: Selected use case, actors, event lifecycle states, step-by-step workflow, minimum payload, failure handling, Sprint 2 feed  
  _Dependencies_: DOC-08, DOC-10

---

## Phase 4: Sprint Artifacts

- [x] DOC-12 Write `plan.md`  
  _Files_: `phases/sprints/Sprint 1 — .../plan.md`  
  _Content_: Executive summary, architecture (N/A), deliverables list, Sprint 2 feed  
  _Dependencies_: DOC-07 through DOC-11

- [x] DOC-13 Write `tasks.md` (this file)  
  _Files_: `phases/sprints/Sprint 1 — .../tasks.md`  
  _Dependencies_: DOC-12

---

## Phase 5: Commit

- [ ] DOC-14 Commit all sprint deliverables to `phase-0/sprint-1-discovery`  
  _Command_: `git add phases/sprints/Sprint\ 1\ */ && git commit -m "docs(sprint-1): complete discovery deliverables — problem statement, user roles, workflows, MVP definition"`

- [ ] DOC-15 Push branch to origin  
  _Command_: `git push -u origin phase-0/sprint-1-discovery`

---

## Sprint 2 Handoff

The following items are explicitly out of scope for this sprint and are the input for Sprint 2:

| Item | Sprint 2 Task |
|---|---|
| Domain vocabulary | Define: event, incident, update, location, reporter, assignee, queue, status |
| Event lifecycle | Define states and valid transitions |
| Minimum event payload | Define fields required for MVP |
| Permissions model | Define role-based access at high level |
| Notification triggers | Define what triggers notifications and to whom |
| Product boundary | Produce explicit MVP in/out-of-scope document |
