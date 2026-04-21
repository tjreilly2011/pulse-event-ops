# Sprint 5 — Realtime (SSE)

## Phase
PHASE 1 — MVP Build

## Goal
Add server-sent events (SSE) so clients can receive live event changes without manual refresh.

## Why This Sprint Matters
Sprint 3 created the minimal event API.
Sprint 4 added acknowledgment and event updates.

This sprint makes the system feel live.

Instead of polling or phone calls asking for updates, connected clients should receive event changes as they happen.

This is the first real-time layer for the MVP and the first step toward operational visibility.

## Reference Inputs
Use prior sprint outputs as reference only, especially:
- Sprint 3 backend implementation
- Sprint 4 acknowledgment and event updates implementation
- event-lifecycle.md
- event-payload.md
- mvp-boundary.md

Do not create more discovery artifacts unless strictly needed for implementation clarity.

## Wishlist
- Add an SSE endpoint for streaming live event changes
- Implement:
  - `GET /events/stream`

- Stream relevant event activity, including:
  - new event created
  - event acknowledged
  - event update added
  - status changed (where applicable)

- Define a minimal event stream payload shape
- Ensure SSE messages are structured and predictable
- Ensure clients can connect and remain subscribed cleanly
- Ensure multiple clients can receive updates

- Publish stream events when:
  - `POST /events`
  - `PATCH /events/{id}/acknowledge`
  - `POST /events/{id}/updates`
  perform successful writes

- Keep Postgres as source of truth
- Do not move business logic into the stream layer
- Add tests or practical verification coverage for:
  - SSE endpoint connection
  - event published on create
  - event published on acknowledge
  - event published on update
  - multiple subscribers if practical
  - graceful handling of client disconnects

- Update README with:
  - how to run locally
  - how to connect to the SSE stream
  - example stream payloads

## Constraints
- Keep this sprint minimal and focused
- Use SSE only
- Do not introduce WebSockets
- Do not introduce NATS or any internal message bus
- Do not implement dashboard UI yet
- Do not implement mobile UI yet
- Do not overengineer stream infrastructure
- Reuse the existing application flow and emit events only after successful writes

## Out of Scope
- WebSockets
- NATS / JetStream
- Notifications
- Dashboard pages
- Flutter mobile app
- Auth / permissions
- Advanced filtering/subscriptions
- Replay/history over the stream
- Presence / online-user tracking

## Success Criteria
- A client can connect to `GET /events/stream`
- A new event is streamed when an event is created
- An acknowledgment is streamed when an event is acknowledged
- An update is streamed when an event update is added
- Connected clients do not require manual refresh to receive changes
- The backend remains runnable locally
- Existing API behavior is not broken
- Tests / verification pass

## Deliverables
- SSE endpoint
- minimal stream event payload shape
- stream publishing wired into create / acknowledge / update flows
- tests or verification coverage for live updates
- updated README

## Notes
Keep this sprint simple.

The SSE stream is a delivery layer, not the source of truth.

Postgres remains the source of truth.
The backend writes to Postgres first, then emits SSE events after successful persistence.

Do not solve subscriptions, fan-out infrastructure, or future scale problems in this sprint.