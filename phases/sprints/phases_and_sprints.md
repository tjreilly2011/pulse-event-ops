# phases_and_sprints.md

## Recommended Working Structure

Use the roadmap for phase-level direction.
Use individual sprint files for execution.

```text
phases/
  sprint_1.md
  sprint_2.md
  sprint_3.md
  sprint_4.md
  sprint_5.md
  sprint_6.md
  sprint_7.md
  sprint_8.md
  sprint_9.md
  sprint_10.md
  sprint_11.md
  sprint_12.md
  sprint_13.md
  sprint_14.md
```

This keeps execution simple.
You can still group sprints by phase in the roadmap without creating too much folder complexity.

---

## Phase Mapping

### Phase 0 — Discovery & Definition
- Sprint 1 — Problem Discovery & MVP Workflow Definition
- Sprint 2 — MVP Core Model, Domain Language & Product Boundaries

### Phase 1 — MVP Build
- Sprint 3 — Minimal Event API
- Sprint 4 — Event Updates & Acknowledgment
- Sprint 5 — Realtime (SSE)
- Sprint 6 — Basic Web Dashboard (HTMX)
- Sprint 7 — Simple Mobile UI (Flutter MVP Stub)

### Phase 2 — Pilot
- Sprint 8 — Lightweight Role Awareness
- Sprint 9 — Notifications (Basic)
- Sprint 10 — Location Model
- Sprint 11 — Deploy & Pilot Test

### Phase 3 — Productisation
- Sprint 12 — Permissions
- Sprint 13 — Audit & History Hardening
- Sprint 14 — Workflow Hardening

### Phase 4 — Intelligence
- Later only

### Phase 5 — Expansion
- After rail pilot success only

---

## Build-First Rule

From Sprint 3 onward:
- every sprint must produce working code
- every sprint must leave the project runnable
- every sprint must extend the previous one
- discovery documents must not multiply unless absolutely necessary

---

## Short Sprint Summaries

### Sprint 3 — Minimal Event API
- create event
- list events
- get event by id

### Sprint 4 — Event Updates & Acknowledgment
- acknowledge event
- add event updates
- create event timeline/history

### Sprint 5 — Realtime (SSE)
- stream event changes live
- no manual refresh

### Sprint 6 — Basic Web Dashboard (HTMX)
- event list page
- event detail page
- live event updates
- acknowledge button

### Sprint 7 — Simple Mobile UI
- create event from phone
- recent events
- simple quick-action UX

### Sprint 8 — Lightweight Role Awareness
- basic role visibility
- simple filtering

### Sprint 9 — Notifications (Basic)
- created / acknowledged notifications
- basic delivery logging

### Sprint 10 — Location Model
- locations table
- proper event-to-location linkage

### Sprint 11 — Deploy & Pilot Test
- deploy app
- test with real users
- collect pilot feedback

### Sprint 12 — Permissions
- proper access control

### Sprint 13 — Audit & History Hardening
- stronger event history and auditability

### Sprint 14 — Workflow Hardening
- lifecycle refinement
- edge cases
