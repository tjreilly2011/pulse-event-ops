# Sprint 5 — Realtime (SSE) — Tasks

**Branch**: `feat/sse-realtime-feed`
**Phase**: PHASE 1 — MVP Build
**Date**: 2026-04-20

---

## Definition of Done (applies to every task)

- Implementation matches requirements
- New logic has tests where specified
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt --check`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors (`cargo run`)
- Logging added where appropriate

---

## BE-01 — Add tokio-stream to Cargo.toml

### Source
Sprint 5 wishlist — SSE realtime feed

### Context
`tokio_stream::wrappers::BroadcastStream` is needed to adapt a `broadcast::Receiver<SseEvent>` into a `Stream` that Axum's `Sse::new()` accepts. This wrapper is gated behind the `sync` feature of the `tokio-stream` crate.

### Files
- `Cargo.toml`

### Change
Add to `[dependencies]`:
```toml
tokio-stream = { version = "0.1", features = ["sync"] }
```

### Test Strategy
`cargo build` succeeds. No dedicated test.

### Dependencies
None — do this first.

---

## BE-02 — Add SseEvent domain type

### Source
Sprint 5 wishlist — define minimal stream event payload shape

### Context
`SseEvent` is the payload published to the broadcast channel and serialised into each SSE message. It uses `#[serde(tag = "type")]` so every message carries a `type` field, making clients self-describing without extra envelope logic.

`SseEvent` must derive `Clone` because `tokio::sync::broadcast::Sender<T>` requires `T: Clone`.

`EventUpdate` currently only derives `Debug, Serialize, sqlx::FromRow` and has no `Clone`. One line must be added to `src/domain/event_update.rs`.

### Files
- `src/domain/sse_event.rs` (**new**)
- `src/domain/event_update.rs` (add `Clone` to derive)
- `src/domain/mod.rs` (add `pub mod sse_event`)

### Implementation

**`src/domain/sse_event.rs`**:
```rust
use serde::Serialize;
use crate::domain::event::Event;
use crate::domain::event_update::EventUpdate;

#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SseEvent {
    EventCreated      { event: Event },
    EventAcknowledged { event: Event },
    EventUpdateAdded  { update: EventUpdate },
}
```

**`src/domain/event_update.rs`** — change derive line:
```rust
#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
```

**`src/domain/mod.rs`** — add:
```rust
pub mod sse_event;
```

### Test Strategy
`cargo build` succeeds. Serialisation is covered implicitly by BE-11 broadcast tests.

### Dependencies
- BE-01

---

## BE-03 — Add AppState + FromRef impls

### Source
Sprint 5 architecture — Option A state shape

### Context
Axum 0.7 supports multiple state types via `axum::extract::FromRef`. By implementing `FromRef<AppState> for PgPool` and `FromRef<AppState> for broadcast::Sender<SseEvent>`, all existing handlers that extract `State(pool): State<PgPool>` continue to work unchanged when the router state is changed to `AppState`.

`broadcast::Sender<T>` is `Clone`, so `AppState` can derive `Clone`.

### Files
- `src/api/state.rs` (**new**)
- `src/api/mod.rs` (add `pub mod state`)

### Implementation

**`src/api/state.rs`**:
```rust
use axum::extract::FromRef;
use sqlx::PgPool;
use tokio::sync::broadcast;
use crate::domain::sse_event::SseEvent;

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub tx:   broadcast::Sender<SseEvent>,
}

impl FromRef<AppState> for PgPool {
    fn from_ref(state: &AppState) -> Self {
        state.pool.clone()
    }
}

impl FromRef<AppState> for broadcast::Sender<SseEvent> {
    fn from_ref(state: &AppState) -> Self {
        state.tx.clone()
    }
}
```

**`src/api/mod.rs`** — add:
```rust
pub mod state;
```

### Test Strategy
`cargo build` succeeds. Axum will enforce `FromRef` contracts at compile time.

### Dependencies
- BE-02

---

## BE-04 — Update create_app to use AppState

### Source
Sprint 5 architecture — channel created inside create_app

### Context
`create_app(pool: PgPool) -> Router` signature stays unchanged so all `#[sqlx::test]` callsites compile without modification.

Inside `create_app`:
1. Create the broadcast channel: `let (tx, _rx) = broadcast::channel::<SseEvent>(128);`
   — the initial `_rx` is dropped immediately; subscribers are created on demand in the SSE handler.
2. Build `AppState { pool, tx }`.
3. Pass `AppState` to the router via `.with_state(app_state)`.

### Files
- `src/lib.rs`

### Implementation
```rust
use tokio::sync::broadcast;
use crate::domain::sse_event::SseEvent;
use crate::api::state::AppState;

pub fn create_app(pool: PgPool) -> Router {
    let (tx, _rx) = broadcast::channel::<SseEvent>(128);
    let state = AppState { pool, tx };
    api::router::build(state)
}
```

### Test Strategy
All existing `#[sqlx::test]` tests call `pulse_event_ops::create_app(pool)` — they continue to compile and pass.

### Dependencies
- BE-03

---

## BE-05 — Update router to use AppState and add /events/stream

### Source
Sprint 5 wishlist — `GET /events/stream` endpoint

### Context
The router currently uses `.with_state(pool)` where `pool: PgPool`. After BE-04 it receives `AppState`. Change `.with_state(pool)` to `.with_state(state)` and update the function signature accordingly. Add the new stream route.

### Files
- `src/api/router.rs`

### Implementation
```rust
use crate::api::state::AppState;
use crate::api::{events, health, sse};

pub fn build(state: AppState) -> Router {
    Router::new()
        .route("/health",                   get(health::health))
        .route("/events",                   post(events::create).get(events::list))
        .route("/events/stream",            get(sse::stream_events))
        .route("/events/:id",               get(events::get_by_id))
        .route("/events/:id/acknowledge",   patch(events::acknowledge_event))
        .route("/events/:id/updates",       post(events::add_event_update).get(events::list_event_updates))
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}
```

> **Route ordering note**: `/events/stream` must be registered **before** `/events/:id` so the literal path segment `stream` is not greedily captured as `:id`.

### Test Strategy
Existing tests still hit their routes. BE-11 adds an HTTP test for `GET /events/stream`.

### Dependencies
- BE-04

---

## BE-06 — Add SSE handler

### Source
Sprint 5 wishlist — SSE endpoint, multiple clients, graceful disconnect

### Context
The handler subscribes to the broadcast channel and returns a streaming response. `BroadcastStream` handles disconnects cleanly — when the client closes the connection, the Axum response body is dropped, the stream is dropped, and the broadcast receiver is dropped automatically.

Lag errors (subscriber >128 messages behind) are mapped to `None` by `filter_map` — the subscriber silently skips missed messages and remains connected.

### Files
- `src/api/sse.rs` (**new**)
- `src/api/mod.rs` (add `pub mod sse`)

### Implementation

**`src/api/sse.rs`**:
```rust
use std::convert::Infallible;
use axum::{
    extract::State,
    response::sse::{Event, KeepAlive, Sse},
};
use tokio::sync::broadcast;
use tokio_stream::wrappers::BroadcastStream;
use tokio_stream::StreamExt;
use crate::domain::sse_event::SseEvent;

pub async fn stream_events(
    State(tx): State<broadcast::Sender<SseEvent>>,
) -> Sse<impl tokio_stream::Stream<Item = Result<Event, Infallible>>> {
    let rx = tx.subscribe();
    let stream = BroadcastStream::new(rx).filter_map(|result| {
        match result {
            Ok(ev) => {
                let data = serde_json::to_string(&ev).ok()?;
                Some(Ok(Event::default().data(data)))
            }
            Err(_) => None,
        }
    });
    Sse::new(stream).keep_alive(KeepAlive::default())
}
```

**`src/api/mod.rs`** — add:
```rust
pub mod sse;
```

### Test Strategy
BE-11: HTTP test confirms `GET /events/stream` returns `200` with `content-type: text/event-stream`.

### Dependencies
- BE-05

---

## BE-07 — Update application::events::create to emit SSE

### Source
Sprint 5 wishlist — publish stream event when POST /events succeeds

### Context
After the successful `event_repo::insert`, send `SseEvent::EventCreated { event: event.clone() }` to the broadcast channel. Use `let _ = tx.send(...)` so a send failure (no subscribers) does not propagate an error. The DB write has already succeeded.

### Files
- `src/application/events.rs`

### Change
Update signature:
```rust
pub async fn create(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
    req: CreateEventRequest,
) -> Result<Event, sqlx::Error>
```

After the repo call succeeds:
```rust
let _ = tx.send(SseEvent::EventCreated { event: event.clone() });
Ok(event)
```

### Test Strategy
BE-11: application-layer test creates a broadcast channel, calls `application::events::create(&pool, &tx, req)`, then asserts `rx.try_recv()` yields `SseEvent::EventCreated`.

### Dependencies
- BE-06

---

## BE-08 — Update application::events::acknowledge to emit SSE

### Source
Sprint 5 wishlist — publish stream event when PATCH /events/:id/acknowledge succeeds

### Context
Same pattern as BE-07. After `event_repo::acknowledge_event` returns `Ok(event)`, send `SseEvent::EventAcknowledged { event: event.clone() }`.

### Files
- `src/application/events.rs`

### Change
Update signature:
```rust
pub async fn acknowledge(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
    event_id: Uuid,
    req: AcknowledgeEventRequest,
) -> Result<Event, AcknowledgeError>
```

After the repo call succeeds:
```rust
let _ = tx.send(SseEvent::EventAcknowledged { event: event.clone() });
Ok(event)
```

### Test Strategy
BE-11: application-layer test acknowledges an event and asserts `rx.try_recv()` yields `SseEvent::EventAcknowledged`.

### Dependencies
- BE-07

---

## BE-09 — Update application::events::add_update to emit SSE

### Source
Sprint 5 wishlist — publish stream event when POST /events/:id/updates succeeds

### Context
After `update_repo::insert` returns `Ok(update)`, send `SseEvent::EventUpdateAdded { update: update.clone() }`.

### Files
- `src/application/events.rs`

### Change
Update signature:
```rust
pub async fn add_update(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
    event_id: Uuid,
    req: CreateEventUpdateRequest,
) -> Result<EventUpdate, AddUpdateError>
```

After the repo call succeeds:
```rust
let _ = tx.send(SseEvent::EventUpdateAdded { update: update.clone() });
Ok(update)
```

### Test Strategy
BE-11: application-layer test adds an update and asserts `rx.try_recv()` yields `SseEvent::EventUpdateAdded`.

### Dependencies
- BE-08

---

## BE-10 — Update API handlers to extract tx and pass to application layer

### Source
Sprint 5 architecture — write handlers forward sender to application layer

### Context
Three handlers need to extract `State(tx): State<broadcast::Sender<SseEvent>>` and pass `&tx` to the updated application functions. No other handlers change.

`list`, `get_by_id`, and `list_event_updates` are read-only — zero changes.
`health` has no state — zero changes.

### Files
- `src/api/events.rs`

### Changes

**`create` handler** — add `State(tx)` extractor:
```rust
pub async fn create(
    State(pool): State<PgPool>,
    State(tx):   State<broadcast::Sender<SseEvent>>,
    Json(req):   Json<CreateEventRequest>,
) -> Result<(StatusCode, Json<Event>), (StatusCode, String)> {
    event_app::create(&pool, &tx, req).await
        .map(|event| (StatusCode::CREATED, Json(event)))
        .map_err(|e| { ... })
}
```

**`acknowledge_event` handler** — add `State(tx)` extractor, update app call.

**`add_event_update` handler** — add `State(tx)` extractor, update app call.

### Test Strategy
Existing tests (which drive these handlers via HTTP through `create_app`) continue to pass. `FromRef` ensures pool extraction still works alongside the new `tx` extraction.

### Dependencies
- BE-09

---

## BE-11 — Add SSE tests

### Source
Sprint 5 wishlist — tests for SSE connection, broadcast on create/acknowledge/update

### Context
Four tests:

1. **HTTP**: `GET /events/stream` returns `200` with `content-type: text/event-stream` (uses `create_app` via `#[sqlx::test]`)
2. **Application layer**: `create` broadcasts `EventCreated`
3. **Application layer**: `acknowledge` broadcasts `EventAcknowledged`
4. **Application layer**: `add_update` broadcasts `EventUpdateAdded`

Application-layer tests create their own `broadcast::channel(16)` and call application functions directly — no HTTP round-trip needed. `rx.try_recv()` is used since the send is synchronous (broadcast channel is unbounded in practice for small N).

### Files
- `tests/events_test.rs`

### Test Strategy

```rust
// Test 1 — HTTP
#[sqlx::test]
async fn sse_endpoint_returns_200_text_event_stream(pool: sqlx::PgPool) {
    // GET /events/stream → 200, content-type contains "text/event-stream"
}

// Test 2 — application layer
#[sqlx::test]
async fn create_event_broadcasts_sse_event_created(pool: sqlx::PgPool) {
    // channel(16) → create(&pool, &tx, req) → rx.try_recv() == EventCreated
}

// Test 3 — application layer
#[sqlx::test]
async fn acknowledge_event_broadcasts_sse_event_acknowledged(pool: sqlx::PgPool) {
    // create event first, then acknowledge → rx.try_recv() after ack == EventAcknowledged
    // (also consume the EventCreated that was sent on create)
}

// Test 4 — application layer
#[sqlx::test]
async fn add_update_broadcasts_sse_event_update_added(pool: sqlx::PgPool) {
    // create event, add_update → rx.try_recv() after update == EventUpdateAdded
}
```

### Dependencies
- BE-10

---

## BE-12 — Update README

### Source
Sprint 5 wishlist — how to connect, example payloads

### Context
Add a "Realtime (SSE)" section to the README covering:
- how to start the stack
- `curl` example to connect
- the three event payload shapes (JSON examples)

### Files
- `README.md`

### Change
Add section after existing endpoint table:

```
## Realtime — SSE Stream

GET /events/stream

Connect with:
    curl -N http://localhost:3000/events/stream

Example payloads:

    data: {"type":"EVENT_CREATED","event":{...}}
    data: {"type":"EVENT_ACKNOWLEDGED","event":{...}}
    data: {"type":"EVENT_UPDATE_ADDED","update":{...}}
```

### Test Strategy
Human-verified. No automated test.

### Dependencies
- BE-11

---

## Task Summary

| ID | Title | Depends on |
|---|---|---|
| BE-01 | Add tokio-stream to Cargo.toml | — |
| BE-02 | Add SseEvent domain type | BE-01 |
| BE-03 | Add AppState + FromRef impls | BE-02 |
| BE-04 | Update create_app to use AppState | BE-03 |
| BE-05 | Update router (AppState + /events/stream route) | BE-04 |
| BE-06 | Add SSE handler | BE-05 |
| BE-07 | Update application::create to emit SSE | BE-06 |
| BE-08 | Update application::acknowledge to emit SSE | BE-07 |
| BE-09 | Update application::add_update to emit SSE | BE-08 |
| BE-10 | Update API handlers to extract tx | BE-09 |
| BE-11 | Add SSE tests | BE-10 |
| BE-12 | Update README | BE-11 |
