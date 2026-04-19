# Sprint Plan: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries

**Branch**: `phase-0/sprint-2-domain-model`  
**Date**: 2026-04-19  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Sprint folder**: `phases/sprints/Sprint 2 — MVP Scope, Domain Language & Product Boundaries/`

---

## Executive Summary

Sprint 1 established the real operational problem and selected the first workflow to solve. This sprint turns that discovery into a clean, unambiguous product definition.

The output is a set of locked definitions — domain vocabulary, event lifecycle, minimum payload, role model, notification triggers, and a hard MVP boundary — that the implementation sprints can consume without inventing domain concepts on the fly.

No code is written in this sprint. No architecture is decided. The work is definitional.

---

## Architecture

**Not applicable.** PHASE 0 — definition sprint.

### Constitution compliance

| Constraint | Status |
|---|---|
| Generic event core — rail is vertical, not core | ✅ Enforced in `domain-language.md` core/vertical boundary section |
| No AI/LLM | ✅ Explicitly excluded in `mvp-boundary.md` |
| Mobile-first payload | ✅ All required fields completable in < 10 seconds |
| Deterministic, auditable lifecycle | ✅ Defined in `event-lifecycle.md` — append-only timeline |
| SOLID / composition | ✅ Role model is flat, not hierarchical; lifecycle is explicit state machine |
| No WASM | ✅ Deferred in `mvp-boundary.md` |
| No message bus | ✅ Deferred in `mvp-boundary.md` |
| SSE first for realtime | ✅ Noted in `notification-triggers.md` and `mvp-boundary.md` |

---

## Deliverables Produced

| File | Description |
|---|---|
| `domain-language.md` | Core vocabulary: event, update, location, actor, role, assignment, status, acknowledgment, notification. Platform core vs rail vertical boundary. |
| `event-lifecycle.md` | Lifecycle states (CREATED → DELIVERED → ACKNOWLEDGED → RESOLVED/CANCELLED), valid transitions, acknowledgment model, event update model, failure handling. |
| `event-payload.md` | Core required fields, optional core fields, vertical metadata envelope. Rail vertical metadata for all three event types. Field immutability rules. |
| `role-model.md` | Three platform roles, permissions matrix, rail job title mapping. |
| `notification-triggers.md` | Five MVP notification triggers (NT-01 through NT-05), recipient sets, deferred capabilities. |
| `mvp-boundary.md` | Hard in/out-of-scope list, single validation test, Sprint 3 artifact recommendations. |

---

## Config Updates

None. Pre-code sprint.

---

## References

### Sprint 1 inputs consumed
- `phases/sprints/Sprint 1 — .../mvp-workflow-definition.md` — lifecycle, actors, payload seed
- `phases/sprints/Sprint 1 — .../user-roles.md` — role definitions
- `phases/sprints/Sprint 1 — .../problem-statement.md` — validation test framing
- `.specify/memory/constitution.md` — all constraints enforced

### Feeds directly into Sprint 3
- DB schema: `events`, `event_timeline`, `actors`, `locations`, `vertical_metadata`
- API contract: `POST /events`, `GET /events/:id`, `POST /events/:id/acknowledge`, etc.
- Rust workspace layout (domain boundaries known: event, actor, location, role, notification)
- Flutter app (three screens minimum: create event, event list, event detail)
- HTMX dashboard (one primary view: live event feed with status)
