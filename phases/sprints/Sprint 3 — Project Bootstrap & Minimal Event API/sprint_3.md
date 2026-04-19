# Sprint 3 — Project Bootstrap & Minimal Event API

## Phase
PHASE 1 — Foundation & First Working Vertical Slice

## Goal
Create the initial project structure and the smallest possible working backend that can create and list events using Rust + Postgres/TimescaleDB.

## Why This Sprint Matters
Sprint 1 and Sprint 2 established the real workflow, the MVP boundaries, and the core event model.

This sprint turns that into a working software foundation.

By the end of this sprint, the project should no longer be just documents — it should be a runnable backend with a real database connection and a minimal event flow.

## Reference Inputs
Use the outputs of Sprint 1 and Sprint 2 as reference only, especially:
- problem-statement.md
- current-state-workflow.md
- desired-state-workflow.md
- mvp-workflow-definition.md
- domain-language.md
- event-lifecycle.md
- event-payload.md
- role-model.md
- mvp-boundary.md

Do not create more discovery artifacts unless strictly needed for implementation clarity.

## Wishlist

- Create the initial project/repo structure for pulse-event-ops
- Bootstrap the Rust backend application
- Add configuration loading and environment handling
- Add Docker/dev setup for backend + Postgres/TimescaleDB if not already present
- Add health check endpoint
- Add database connection and startup validation
- Create the initial events table migration

- Implement the minimum event model required for MVP:
  - id
  - event_type
  - status
  - created_at
  - created_by
  - origin_location
  - target_location (if present)
  - payload / metadata

- Implement:
  - `POST /events`
  - `GET /events`
  - `GET /events/{id}`

- Validate create-event input against the minimal MVP payload
- Persist events in Postgres
- Return stored events cleanly via API
- Add basic tests for:
  - health endpoint
  - create event
  - list events
  - fetch event by id

- Ensure the backend starts cleanly and runs locally

## Constraints

- Keep this sprint as small as possible
- Build only the minimal working backend vertical slice
- Do not implement acknowledgment yet unless it naturally falls out of minimal status handling
- Do not implement notifications yet
- Do not implement SSE yet
- Do not implement auth yet
- Do not implement mobile or dashboard yet
- Do not introduce NATS, WebSockets, or other extra infrastructure
- Do not overengineer the domain model

## Out of Scope

- Full permissions model
- Assignment model
- Notifications
- SSE / live streaming
- Dashboard UI
- Flutter mobile app
- Vertical-specific UI terminology/config
- Advanced workflow state transitions
- Analytics
- AI features

## Success Criteria

- The project has a real runnable backend
- The backend can connect to Postgres/TimescaleDB
- The events table exists and migrations run successfully
- A client can create an event via API
- A client can list events via API
- A client can fetch an event by id
- Tests pass
- The project is now in a state where the next sprint can add acknowledgment and status updates

## Deliverables

- Runnable Rust backend project
- Initial DB migration(s)
- Minimal event model
- Minimal event API
- Basic automated tests
- Updated README with startup instructions

## Notes

This is the first code-producing sprint.

Prefer the simplest possible implementation that proves the event model and establishes the development foundation.

Sprint 1 and Sprint 2 are reference material, not blockers.