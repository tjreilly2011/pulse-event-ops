# MVP Boundary & Non-Goals

**Sprint**: Sprint 2 — MVP Core Model, Domain Language & Product Boundaries  
**Phase**: PHASE 0 — Discovery & Product Definition  
**Date**: 2026-04-19  

---

## Purpose

This document fixes the boundary of the MVP. What is in scope defines what gets built first. What is out of scope defines what does not get built, discussed in architecture, or speculated on — until the MVP is validated.

---

## MVP In Scope

### Core Platform

- [ ] Event creation by `frontline_operator` via mobile app
- [ ] Event routing to `support_role` actors at destination location
- [ ] Push notification to recipient on event delivery
- [ ] Event acknowledgment by `support_role` (single action, timestamped)
- [ ] Implicit self-assignment on acknowledgment (recorded in timeline)
- [ ] Push notification to creator on acknowledgment
- [ ] Event status progression: `CREATED → DELIVERED → ACKNOWLEDGED → RESOLVED | CANCELLED`
- [ ] `IN_PROGRESS` state available but not required for first use case
- [ ] Full event timeline — every transition stored with actor and timestamp
- [ ] Unacknowledged event flag on ops dashboard (timeout-based)
- [ ] Critical priority event notification to `management_control`
- [ ] Status change notifications to creator and `management_control`
- [ ] Real-time ops dashboard with live event feed (`management_control`)
- [ ] Three platform roles: `frontline_operator`, `support_role`, `management_control`
- [ ] Role-based visibility and permissions as defined in `role-model.md`

### Rail Vertical (First Workflow)

- [ ] Event type: `passenger_assistance` (wheelchair ramp)
- [ ] Event type: `service_issue` (aircon, water, facility)
- [ ] Event type: `onboard_incident` (medical, security)
- [ ] Rail-specific vertical metadata payload (coach, assistance type, incident type)
- [ ] Location model: station as destination

---

## MVP Out of Scope

### Features Explicitly Deferred

| Feature | Reason |
|---|---|
| Explicit assignment to a named actor or team | Acknowledgment serves as implicit self-assignment — sufficient for MVP |
| Schedule / timetable integration | Complex external dependency; destination entered manually |
| GPS / live train position | MVP routing uses `destination_location_id` (station identifier), which is sufficient for station-based recipients. Routing to train-based staff (guards or supervisors on moving services) requires live position tracking — deferred pending routing requirements for that recipient type |
| Passenger-facing interface | No public-facing surface at MVP |
| Attachments / photos on events | Adds mobile UX complexity; not needed for MVP workflows |
| Event re-routing (change destination after creation) | Deferred — management/control escalation path TBD |
| `support_role` creating events | Not required for MVP workflow |
| `management_control` creating events | Not required for MVP workflow |
| Event templates / quick-create presets | Deferred — nice-to-have, not needed |
| SLA timers / breach alerts | Operational rules layer; deferred |
| Analytics / reporting dashboards | Deferred — event lifecycle data is the foundation |
| Export / data download | Deferred |
| AI / prediction / smart routing | Permanently out of scope for the operational path |
| Message bus / NATS | Not needed at MVP — no async distributed processing required |

### Infrastructure / Architecture Deferred

| Area | Deferred until |
|---|---|
| Full auth implementation (OAuth, SSO) | Sprint 3 / bootstrap — basic auth sufficient for pilot |
| Multi-tenancy | Post-pilot — single organisation at MVP |
| Multi-vertical support (airports, logistics) | Post-MVP — rail is the only vertical |
| WASM modules | Post-MVP — only if isolated performance-critical need is proven |
| WebSockets | Post-MVP — SSE is sufficient for dashboard realtime |
| Email / SMS notifications | Post-MVP — push notification is sufficient |
| Full DB schema | Sprint 3 — first pass in architecture sprint |
| API contract design | Sprint 3 — first endpoints defined in architecture sprint |
| Complex routing logic | Post-MVP — location-based routing is sufficient |
| Staging / production infrastructure | Post-pilot |

---

## The Single Validation Test

> If a guard on a real train can create a "passenger needs wheelchair assistance at next station" event in under 10 seconds — the right station staff receive it — and they can acknowledge with one tap — and the guard sees the confirmation on their phone — **the MVP is validated.**

Everything else is future work.

---

## Recommended Artifacts for Sprint 3

Sprint 3 should produce the first technical artifacts based on this definition. Recommended scope:

### Project Bootstrap
- [ ] Rust workspace: `Cargo.toml`, workspace layout (`api/`, `domain/`, `infra/`)
- [ ] Flutter project scaffold: `mobile/`
- [ ] HTMX dashboard scaffold: `dashboard/` (Jinja2 templates)
- [ ] `.env.example` with required environment variables
- [ ] `docker-compose.yml` for local development (Postgres + TimescaleDB)
- [ ] `README.md` — updated with project structure and setup instructions

### Architecture Decision Records
- [ ] ADR-001: Rust + Axum as backend
- [ ] ADR-002: PostgreSQL + TimescaleDB as persistence
- [ ] ADR-003: SSE for realtime dashboard updates
- [ ] ADR-004: Flutter for frontline mobile app
- [ ] ADR-005: Generic event core with vertical extension model

### First-Pass DB Schema
- [ ] `events` table (core fields)
- [ ] `event_timeline` table (append-only transitions log)
- [ ] `actors` table (users / roles)
- [ ] `locations` table (stations, abstract locations)
- [ ] `vertical_metadata` table or JSON column strategy decision

### First-Pass API Contract
- [ ] `POST /events` — create event
- [ ] `GET /events/:id` — fetch event with timeline
- [ ] `POST /events/:id/acknowledge` — acknowledge event
- [ ] `POST /events/:id/resolve` — resolve event
- [ ] `POST /events/:id/cancel` — cancel event
- [ ] `GET /events` — list events (filtered by role / location)
- [ ] `GET /events/stream` — SSE endpoint for ops dashboard
