# Sprint 5 — Realtime (SSE) — Plan

## Executive Summary

Sprint 5 adds the first realtime delivery layer to `pulse-event-ops`.

A `GET /events/stream` SSE endpoint is wired into the running server. Any connected HTTP client receives live event changes without polling. Events are published to an in-process `tokio::sync::broadcast` channel **after a successful Postgres write**. The broadcast channel fans out to all active SSE subscribers.

Three observable write paths emit stream events this sprint:

| Write path | SSE event type |
|---|---|
| `POST /events` | `EVENT_CREATED` |
| `PATCH /events/:id/acknowledge` | `EVENT_ACKNOWLEDGED` |
| `POST /events/:id/updates` | `EVENT_UPDATE_ADDED` |

No external message bus. No WebSockets. Postgres remains the source of truth. SSE is a delivery mechanism only.

---

## Architecture

### Backend (Rust)

#### New endpoint

| Method | Path | Response |
|---|---|---|
| `GET` | `/events/stream` | `200 text/event-stream` (long-lived) |

#### State shape

Current state is a bare `PgPool`. Sprint 5 introduces `AppState`:

```rust
// src/api/state.rs
#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub tx:   broadcast::Sender<SseEvent>,
}

impl FromRef<AppState> for PgPool { ... }
impl FromRef<AppState> for broadcast::Sender<SseEvent> { ... }
```

`create_app(pool: PgPool) -> Router` signature is **unchanged**. The broadcast channel is created inside `create_app` and embedded in `AppState`. All existing test callsites remain valid.

Because `FromRef<AppState> for PgPool` is implemented, every existing handler extracting `State(pool): State<PgPool>` continues to compile **without modification**.

Only the three write handlers (`create`, `acknowledge_event`, `add_event_update`) and the new `stream_events` handler extract the sender.

#### New domain type

```rust
// src/domain/sse_event.rs
#[derive(Debug, Clone, Serialize)]
#[serde(tag = "type", rename_all = "SCREAMING_SNAKE_CASE")]
pub enum SseEvent {
    EventCreated     { event: Event },
    EventAcknowledged{ event: Event },
    EventUpdateAdded { update: EventUpdate },
}
```

`SseEvent` is `Clone` (required by `broadcast::channel`).
This forces `EventUpdate` to derive `Clone` — one-line change to `src/domain/event_update.rs`.

#### Broadcast model

```
create_app()
  └── broadcast::channel::<SseEvent>(128) → tx (Sender), initial rx dropped
  └── AppState { pool, tx }
         │
         ├── write handlers forward &tx to application layer
         │       application fn writes to DB → let _ = tx.send(event)
         │       (send error = no subscribers → ignored, write still succeeds)
         │
         └── GET /events/stream handler
                 rx = tx.subscribe()
                 BroadcastStream::new(rx)
                   .filter_map(|r| serialize to sse::Event)
                 Sse::new(stream).keep_alive(KeepAlive::default())
```

Channel capacity: **128 messages**. `BroadcastStream` converts lag errors to `None` (subscriber silently skips missed messages rather than crashing). This is acceptable at MVP scale; the database is the authoritative state.

#### Application layer changes

`create`, `acknowledge`, and `add_update` in `src/application/events.rs` gain one new parameter:

```rust
pub async fn create(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
    req: CreateEventRequest,
) -> Result<Event, sqlx::Error>
```

Emit pattern after every successful write:

```rust
let _ = tx.send(SseEvent::EventCreated { event: event.clone() });
```

The `let _ =` discard means zero subscribers is never an error.

#### SSE handler

```rust
// src/api/sse.rs
pub async fn stream_events(
    State(tx): State<broadcast::Sender<SseEvent>>,
) -> Sse<impl Stream<Item = Result<sse::Event, Infallible>>> {
    let rx = tx.subscribe();
    let stream = BroadcastStream::new(rx).filter_map(|result| async move {
        match result {
            Ok(ev) => {
                let data = serde_json::to_string(&ev).ok()?;
                Some(Ok(sse::Event::default().data(data)))
            }
            Err(_) => None, // lagged — skip, don't crash stream
        }
    });
    Sse::new(stream).keep_alive(KeepAlive::default())
}
```

#### Database changes

**None.** No new tables, no new migration.

---

### Realtime

- **Transport**: SSE (`text/event-stream`)
- **Channel**: `tokio::sync::broadcast::channel::<SseEvent>(128)` — created once per process
- **Fan-out**: one sender, N subscribers (each `tx.subscribe()` call creates an independent receiver)
- **Keep-alive**: `KeepAlive::default()` (Axum sends a comment ping every 15s — prevents proxy timeouts)
- **Client disconnect**: when the response body is dropped, the `BroadcastStream` and its receiver are dropped automatically — no explicit cleanup needed

---

### Frontend / Mobile

Out of scope this sprint.

---

## Config Updates

No new environment variables or feature flags required.

---

## New Cargo dependency

```toml
tokio-stream = { version = "0.1", features = ["sync"] }
```

`features = ["sync"]` enables `tokio_stream::wrappers::BroadcastStream`.

---

## File Map

### New files

| File | Purpose |
|---|---|
| `src/domain/sse_event.rs` | `SseEvent` enum |
| `src/api/state.rs` | `AppState` struct + `FromRef` impls |
| `src/api/sse.rs` | `stream_events` Axum handler |

### Modified files

| File | Change summary |
|---|---|
| `Cargo.toml` | Add `tokio-stream` |
| `src/domain/mod.rs` | `pub mod sse_event` |
| `src/domain/event_update.rs` | Add `Clone` to `EventUpdate` derive |
| `src/api/mod.rs` | `pub mod state`, `pub mod sse` |
| `src/lib.rs` | Create channel, build `AppState`, pass to router |
| `src/api/router.rs` | State type → `AppState`; add `GET /events/stream` |
| `src/application/events.rs` | `create`, `acknowledge`, `add_update` gain `tx` param, emit after write |
| `src/api/events.rs` | `create`, `acknowledge_event`, `add_event_update` extract `State(tx)` and pass to app layer |
| `tests/events_test.rs` | Add SSE connection test + 3 application-layer broadcast tests |
| `README.md` | Document SSE endpoint, curl connection, example payloads |

### Unchanged files

| File | Reason |
|---|---|
| `src/api/health.rs` | No state dependency |
| `src/api/events.rs` `list`, `get_by_id`, `list_event_updates` | Read-only; no broadcast |
| `src/infrastructure/event_repo.rs` | No change needed |
| `src/infrastructure/update_repo.rs` | No change needed |
| `src/domain/event.rs` | No change needed |
| `migrations/` | No schema change |

---

## Risk & Notes

- `broadcast::Sender::send` returns `Err` when there are no receivers. This is **not** treated as a failure — `let _ = tx.send(...)` intentionally discards this error. The DB write has already succeeded.
- Lagged receivers (subscriber falls behind by >128 messages) receive a `BroadcastStreamRecvError::Lagged` from `BroadcastStream`. The `filter_map` maps this to `None` — the message is silently skipped for that subscriber. The subscriber remains connected.
- The initial receiver returned by `broadcast::channel(128)` is dropped immediately because we only need the sender in `AppState`. This is intentional — subscribers are created on demand via `tx.subscribe()` in the handler.
