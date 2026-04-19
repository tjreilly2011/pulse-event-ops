# Sprint Plan: Sprint 1 — Problem Discovery & Rail Workflow Validation

**Branch**: `phase-0/sprint-1-discovery`  
**Date**: 2026-04-19  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Sprint folder**: `phases/sprints/Sprint 1 — Problem Discovery & Rail Workflow Validation/`

---

## Executive Summary

This sprint is a pre-code discovery and definition sprint. No implementation. No architecture. No database design.

The goal is to validate the core operational problem, select the single highest-value workflow to solve first, and produce the foundational product documents that Sprint 2 (domain language, event model, product boundary) will build on.

The selected MVP use case is **Passenger Wheelchair Assistance Coordination** — a guard creates a structured mobile event, station staff receive and acknowledge it, operations observe in real time, and a full audit record is persisted. This replaces the current mode of phone calls that fail silently with no record.

All five deliverable documents have been produced on this sprint branch.

---

## Architecture

**Not applicable.** This is a PHASE 0 documentation sprint. No code, no schema, no APIs.

Technical architecture is deferred until Sprint 2 (domain model) and Sprint 3+ (implementation planning).

### Constitution compliance

All decisions made in this sprint comply with the project constitution:

- No AI/LLM introduced
- No premature architecture
- Core event model kept generic (`passenger_assistance` is a type, not a hardcoded concept)
- Rail is treated as the first vertical, not the core identity
- Mobile-first, degraded-environment tolerant design requirement preserved
- Workflow is deterministic and auditable by design

---

## Deliverables Produced

| File | Description |
|---|---|
| `problem-statement.md` | The core operational problem, the failure pattern, and the hypothesis |
| `user-roles.md` | Guard/CSO, Station Staff, Operations/Control — roles, needs, pain points |
| `current-state-workflow.md` | How the wheelchair assistance scenario is handled today and where it fails |
| `desired-state-workflow.md` | What the workflow looks like with the platform in place (before vs after) |
| `mvp-workflow-definition.md` | The selected MVP use case, actors, event lifecycle, minimum payload, failure modes |

---

## Config Updates

None. Pre-code sprint.

---

## References

### Existing files referenced
- `.specify/memory/constitution.md` — governing constraints
- `phases/sprints/Sprint 2 — MVP Scope, Domain Language & Product Boundaries/sprint_2.md` — next sprint scope (domain model, lifecycle, boundaries)
- `docs/mvp-spec.md` — stub, to be updated in Sprint 2

### Feeds directly into Sprint 2
- Domain vocabulary (event, incident, update, location, reporter, assignee, queue, status)
- Event lifecycle state machine
- Minimum event payload for MVP
- Permissions model (high level)
- Notification trigger rules
- Product boundary document
