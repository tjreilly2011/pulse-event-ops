# Roadmap — pulse-event-ops (Aligned MVP Build)

## Product Goal
Build the simplest possible real-time operational system that allows frontline staff to report issues instantly and share live situational awareness across teams.

The system must:
- be fast to use under pressure
- provide immediate shared visibility
- replace fragmented communication (calls, WhatsApp, guesswork)

---

## Core MVP Features (Non-Negotiable)

1. One-tap event reporting
2. Live activity feed (real-time)
3. Passenger load indicator (simple but powerful)
4. Basic location awareness
5. Simple dashboard for visibility

No overengineering.
No unnecessary abstraction.
No integrations yet.

---

## Locked MVP Tech Choices
- Backend: Rust
- Database: PostgreSQL + TimescaleDB
- Realtime: SSE
- Mobile: Flutter
- Dashboard: HTMX + Jinja2 + DaisyUI

---

## Delivery Rule
Every sprint must produce working software.

No doc-only sprints beyond Phase 0.

---

# Phase 1 — MVP Build (YOU ARE HERE)

Goal:
Get a working system into real users’ hands ASAP.

---

## Sprint 3 — Minimal Event API ✅
- create event
- list events
- get event

---

## Sprint 4 — Event Updates & Acknowledgment ✅
- acknowledge events
- add updates
- event timeline exists

---

## Sprint 5 — Realtime Feed (SSE) ✅
- stream events live
- no refresh required
- replaces “what’s happening?” calls

---

## Sprint 6 — Basic Dashboard (HTMX)
- event feed page
- live updates via SSE
- event detail view
- acknowledge button

👉 This becomes your “Slack/Twitter for operations”

---

## Sprint 7 — Mobile Reporting (Flutter MVP)
- create event screen
- minimal inputs:
  - event type (Delay / Overcrowding / Assistance / Safety)
  - optional note
- auto:
  - timestamp
  - location (basic for now)
- submit to backend

👉 This is your “one-tap reporting”

---

## Sprint 8 — Passenger Load Indicator 🔥 (HIGH VALUE)
- add simple input to events:
  - 🟢 Low
  - 🟠 Medium
  - 🔴 High
- display on:
  - dashboard feed
  - event detail

👉 This alone creates immediate operational value

---

## Sprint 9 — Location Awareness (Basic)
- introduce locations table
- attach events to locations
- simple filtering:
  - by station / area
- prepare for:
  - “what’s happening ahead”

---

### MVP Exit Criteria
MVP is DONE when:

- a frontline user can report an event in seconds
- other users see it instantly (SSE)
- events can be acknowledged
- updates can be added
- passenger load is visible
- events are tied to a location
- dashboard shows live operational state

👉 If this works, you already have something valuable

---

# Phase 2 — Pilot

Goal:
Use with real users (your brother + colleagues)

---

## Sprint 10 — Notifications (Basic)
- notify on:
  - new events
  - acknowledgements
- simple delivery (keep it basic)

---

## Sprint 11 — Role Awareness (Light)
- roles:
  - frontline
  - management
- filter visibility

---

## Sprint 12 — Deploy & Pilot
- deploy backend
- run with real users
- collect feedback

---

# Phase 3 — Productisation

## Sprint 13 — Permissions
- who can see/update what

## Sprint 14 — Audit Hardening
- full timeline clarity
- stronger traceability

## Sprint 15 — Workflow Improvements
- refine lifecycle
- edge cases

---

# Phase 4 — Intelligence (Later)
- summaries
- pattern detection
- predictions

---

# Phase 5 — Expansion
Only AFTER MVP works.

Targets:
- airports
- events/stadiums
- logistics
- emergency services

---

# 🔥 Immediate Focus (CRITICAL)

Ignore everything beyond:

1. Sprint 5 (Realtime)
2. Sprint 6 (Dashboard)
3. Sprint 7 (Mobile)
4. Sprint 8 (Passenger Load)

---

# Core Principle

This is NOT a messaging system.

This is:
→ a real-time operational visibility system

Events are the source of truth.