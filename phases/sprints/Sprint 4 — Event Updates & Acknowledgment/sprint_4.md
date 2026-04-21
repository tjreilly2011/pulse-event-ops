# Sprint 4 — Event Updates & Acknowledgment

## Phase
PHASE 1 — MVP Build

## Goal
Extend the minimal event API so events can be acknowledged, updated, and tracked through a simple event timeline.

## Why This Sprint Matters
Sprint 3 proved that events can be created and stored.

This sprint brings the first real operational workflow to life:
- someone sees an event
- someone acknowledges it
- updates are recorded against it
- the event has a visible history

Without this, the system is just event storage.
With this, it starts becoming a real coordination tool.

## Reference Inputs
Use Sprint 1 and Sprint 2 outputs as reference only, especially:
- mvp-workflow-definition.md
- domain-language.md
- event-lifecycle.md
- event-payload.md
- role-model.md
- mvp-boundary.md

Use Sprint 3 implementation as the build foundation.

Do not create more discovery artifacts unless strictly needed for implementation clarity.

## Wishlist
- Add support for acknowledging an event
- Implement `PATCH /events/{id}/acknowledge`
- Record who acknowledged the event
- Record when the event was acknowledged
- Transition event status appropriately:
  - `CREATED` → `ACKNOWLEDGED`

- Add support for event updates / timeline entries
- Implement `POST /events/{id}/updates`
- Implement `GET /events/{id}/updates` if needed for clean testing and future UI support
- Persist event updates in a separate table

- Add simple event timeline/history support:
  - event created
  - event acknowledged
  - update added

- Ensure updates are structured and auditable
- Keep assignment implicit through acknowledgment
- Add tests for:
  - acknowledge event
  - duplicate or invalid acknowledge handling
  - add event update
  - event timeline persistence
  - invalid event id handling

- Update README with new endpoints and local run/test instructions

## Constraints
- Keep this sprint minimal and focused
- Do not implement notifications yet
- Do not implement SSE yet
- Do not implement auth yet
- Do not implement full permissions yet
- Do not implement explicit assignment model yet
- Do not build dashboard or mobile UI yet
- Do not overcomplicate lifecycle rules

## Out of Scope
- SSE / realtime streaming
- Dashboard UI
- Flutter mobile app
- Notifications
- Permissions / auth
- Explicit assignment entities
- Advanced workflow transitions
- Location model expansion
- NATS / WebSockets

## Success Criteria
- An event can be acknowledged
- The acknowledgment is stored and auditable
- An event can have updates added to it
- Updates are stored in a timeline/history model
- Event status changes are persisted correctly
- Tests pass
- The backend remains runnable locally

## Deliverables
- Updated events model and persistence
- Event updates / timeline table
- Acknowledge endpoint
- Event update endpoint
- Tests for new workflow behavior
- Updated README

## Notes
This sprint should establish the smallest useful workflow:
event created → event acknowledged → event updated

Keep assignment implicit in acknowledgment for MVP.
