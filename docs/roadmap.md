# Roadmap — pulse-event-ops

## Product Goal
Build the smallest possible real-time operational event coordination system that solves a real rail workflow first, while keeping the core generic for later verticals.

Initial proving workflow:
- frontline user creates an event
- receiving team sees it in real time
- someone acknowledges it
- updates are recorded
- everyone works from the same event timeline instead of calls and guesswork

## Locked MVP Tech Choices
- Backend: Rust
- Database: PostgreSQL + TimescaleDB
- Realtime to clients: SSE first
- Internal messaging at MVP: none
- Optional later: WebSockets where justified
- Optional later bus: NATS + JetStream
- Dashboard: Jinja2 + HTMX + DaisyUI
- Mobile: Flutter

## Delivery Rule
From Sprint 3 onward, every sprint must produce runnable software.

No more discovery-only or doc-heavy build sprints.
Each sprint must add working capability to the project.

---

# Phase 0 — Discovery & Definition
Purpose:
- validate the real rail workflow
- define the MVP boundary
- define the minimal event model

Completed:
- Sprint 1 — Problem Discovery & MVP Workflow Definition
- Sprint 2 — MVP Core Model, Domain Language & Product Boundaries

These sprints are reference inputs only.
They should not block further coding work.

---

# Phase 1 — MVP Build
Purpose:
Get a working end-to-end system into the hands of your brother and colleagues as quickly as possible.

## Sprint 3 — Minimal Event API ✅
Outcome:
- runnable Rust backend
- Postgres/TimescaleDB connected
- minimal events table
- create event
- list events
- get event by id

## Sprint 4 — Event Updates & Acknowledgment
Outcome:
- acknowledge an event
- record updates against an event
- introduce event timeline/history
- basic workflow starts to exist

## Sprint 5 — Realtime (SSE)
Outcome:
- live stream of event changes
- receiving users no longer need to refresh
- platform begins replacing “what’s happening?” calls

## Sprint 6 — Basic Web Dashboard (HTMX)
Outcome:
- event list page
- event detail page
- live updates via SSE
- acknowledge button
- usable first operations UI

## Sprint 7 — Simple Mobile UI (Flutter MVP Stub)
Outcome:
- create event from phone
- recent events view
- quick-action-first UI
- end-to-end loop:
  mobile → backend → dashboard

### MVP Exit Criteria
MVP is complete when:
- a frontline user can create an event from mobile
- a receiving user can see it live
- a receiving user can acknowledge it
- updates can be added to the event
- the event timeline is visible
- the system runs locally and reliably

---

# Phase 2 — Pilot
Purpose:
Make the MVP usable by real people in a controlled pilot.

## Sprint 8 — Lightweight Role Awareness
Outcome:
- basic roles
- simple event visibility rules
- location/role filtering where needed

## Sprint 9 — Notifications (Basic)
Outcome:
- notify on important changes
- at minimum support event created / acknowledged
- basic reliability and logging around delivery

## Sprint 10 — Location Model
Outcome:
- locations table
- tie events to locations properly
- support basic station/location awareness
- groundwork for rail workflow quality

## Sprint 11 — Deploy & Pilot Test
Outcome:
- deploy backend + DB
- test with 1–2 real users
- collect feedback
- identify top workflow friction

### Pilot Exit Criteria
Pilot phase is complete when:
- at least one real workflow is tested with real users
- the system supports real event creation and acknowledgment
- feedback is collected and turned into changes

---

# Phase 3 — Productisation
Purpose:
Harden the product so it becomes operationally credible.

## Sprint 12 — Permissions
Outcome:
- real access control
- who can see and update what

## Sprint 13 — Audit & History Hardening
Outcome:
- complete event history
- stronger audit trail
- clearer “who did what, when”

## Sprint 14 — Workflow Hardening
Outcome:
- refine lifecycle
- improve edge-case handling
- support stronger operational consistency

### Productisation Exit Criteria
This phase is complete when:
- the product is operationally trustworthy
- actions are auditable
- visibility and permissions are reliable

---

# Phase 4 — Intelligence (Later)
Purpose:
Only after core workflow adoption is proven.

Potential additions:
- AI summaries
- prioritisation support
- operational predictions

Not a current focus.

---

# Phase 5 — Expansion
Purpose:
Generalise only after rail MVP and pilot success.

Possible next verticals:
- airports
- events / stadiums
- logistics / warehouses
- emergency services

Rule:
Do not build expansion features before the rail workflow is genuinely working.

---

# Immediate Focus
Ignore everything beyond Sprint 5 for now.

## What matters now
1. Sprint 4 — Event Updates & Acknowledgment
2. Sprint 5 — Realtime (SSE)
3. Sprint 6 — Basic Web Dashboard
4. Sprint 7 — Simple Mobile UI

That is the shortest path to a real MVP your brother can actually try.
