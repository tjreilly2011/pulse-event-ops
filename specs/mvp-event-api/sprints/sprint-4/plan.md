# Sprint Plan: Sprint 4 — Event Acknowledgment & Updates

**Branch**: `feat/event-acknowledgment-and-updates`
**Date**: 2026-04-20
**Phase**: PHASE 1 — MVP Build

---

## Executive Summary

Sprint 4 extends the minimal event API to support the first real operational workflow:

1. An event can be **acknowledged** — transitioning from `CREATED` or `DELIVERED` → `ACKNOWLEDGED`, recording who acknowledged it and when, and automatically inserting a timeline entry.
2. An event can receive **updates** — free-text timeline entries persisted in a separate `event_updates` table, with an optional `update_type` field for classification.
3. An event's **update history** can be fetched — listing all timeline entries for a given event.

By the end of this sprint the system has the smallest useful coordination loop:
**event created → acknowledged → updated / tracked**

---

## Architecture

### Style: Layered Monolith (unchanged)

```
pulse-event-ops/
├── src/
│   ├── domain/
│   │   ├── event.rs              — extend Event with acknowledged_by, acknowledged_at
│   │   └── event_update.rs       — NEW: EventUpdate struct, CreateEventUpdateRequest
│   ├── application/
│   │   └── events.rs             — acknowledge(), add_update(), list_updates() use-cases
│   ├── infrastructure/
│   │   ├── event_repo.rs         — acknowledge_event() SQL, plus update_repo functions
│   │   └── update_repo.rs        — NEW: insert_update(), list_updates()
│   └── api/
│       ├── events.rs             — 3 new handlers
│       └── router.rs             — 3 new routes wired
├── migrations/
│   └── 0002_acknowledge_and_updates.sql  — NEW
├── tests/
│   └── events_test.rs            — 5 new test cases appended
└── README.md                     — updated with new endpoints
```

**Layer contract: unchanged**
`api/` → `application/` → `infrastructure/` → `domain/`

---

## API Endpoints

### New this sprint

| Method  | Path                    | Status on success | Description                         |
|---------|-------------------------|-------------------|-------------------------------------|
| `PATCH` | `/events/:id/acknowledge` | 200             | Acknowledge event, auto-insert timeline entry |
| `POST`  | `/events/:id/updates`   | 201               | Add a timeline entry to an event    |
| `GET`   | `/events/:id/updates`   | 200               | List all timeline entries for event |

### Existing (unchanged)

| Method | Path          | Status | Description        |
|--------|---------------|--------|--------------------|
| GET    | `/health`     | 200    | Liveness check     |
| POST   | `/events`     | 201    | Create event       |
| GET    | `/events`     | 200    | List all events    |
| GET    | `/events/:id` | 200/404| Fetch event by ID  |

---

## Domain Model Changes

### `Event` (modified)

Add two optional columns:

```rust
pub acknowledged_by: Option<Uuid>,
pub acknowledged_at: Option<DateTime<Utc>>,
```

### `EventUpdate` (new)

```rust
pub struct EventUpdate {
    pub id: Uuid,
    pub event_id: Uuid,
    pub update_type: Option<String>,   // e.g. "ACKNOWLEDGED", "NOTE", "STATUS_CHANGE"
    pub content: String,
    pub actor_id: Option<Uuid>,
    pub created_at: DateTime<Utc>,
}
```

### `CreateEventUpdateRequest` (new)

```rust
pub struct CreateEventUpdateRequest {
    pub content: String,
    pub actor_id: Option<Uuid>,
    pub update_type: Option<String>,   // defaults to "NOTE" if absent
}
```

### `AcknowledgeEventRequest` (new)

```rust
pub struct AcknowledgeEventRequest {
    pub acknowledged_by: Uuid,
}
```

### `EventStatus` (existing — no change to variants)

Valid input states for acknowledge: `CREATED`, `DELIVERED`
Blocked states (return 409 Conflict): `ACKNOWLEDGED`, `IN_PROGRESS`, `RESOLVED`, `CANCELLED`

---

## Database Schema Changes

### Migration: `0002_acknowledge_and_updates.sql`

```sql
-- Extend events table
ALTER TABLE events
    ADD COLUMN acknowledged_by  UUID,
    ADD COLUMN acknowledged_at  TIMESTAMPTZ;

-- New event_updates table (plain Postgres, not a hypertable)
-- Queries are by event_id lookup, not time-range scans.
-- No FK on event_id — TimescaleDB hypertable events.id has no UNIQUE constraint.
-- Event existence validated at application layer.
CREATE TABLE event_updates (
    id          UUID        NOT NULL DEFAULT gen_random_uuid(),
    event_id    UUID        NOT NULL,
    update_type TEXT,
    content     TEXT        NOT NULL,
    actor_id    UUID,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

CREATE INDEX ON event_updates (event_id);
CREATE INDEX ON event_updates (created_at DESC);
```

**Key design decisions:**
- `event_updates` is a **plain Postgres table** (not a hypertable). Access pattern is
  `WHERE event_id = $1 ORDER BY created_at ASC` — no time-range scans needed.
- No FK from `event_updates.event_id` → `events.id` because `events.id` has no UNIQUE constraint
  (TimescaleDB TS103 restriction). Event existence is validated at the application layer before insert.
- `update_type` is `TEXT`, unconstrained — keeps it simple, avoids enum migration friction.

---

## Acknowledge Workflow (Atomic)

```
PATCH /events/:id/acknowledge
  body: { acknowledged_by: UUID }

1. Fetch event by id  →  404 if not found
2. Check status:
     CREATED | DELIVERED  →  proceed
     anything else        →  409 Conflict
3. UPDATE events SET
       status = 'ACKNOWLEDGED',
       acknowledged_by = $1,
       acknowledged_at = NOW(),
       updated_at = NOW()
   WHERE id = $2
4. INSERT INTO event_updates
       (event_id, update_type, content, actor_id, created_at)
   VALUES ($event_id, 'ACKNOWLEDGED', 'Acknowledged', $acknowledged_by, NOW())
5. Return updated Event (200)
```

Steps 3 + 4 run inside a **single DB transaction** to prevent partial state.

---

## Realtime / Frontend / Mobile

Not applicable this sprint:
- No SSE
- No dashboard
- No mobile
- No notifications

---

## Config Updates

None. No new environment variables required.

---

## References

### Files to modify
- `src/domain/event.rs` — add `acknowledged_by`, `acknowledged_at` fields
- `src/domain/mod.rs` — expose `event_update` module
- `src/application/events.rs` — add `acknowledge`, `add_update`, `list_updates`
- `src/infrastructure/event_repo.rs` — add `acknowledge_event` (transactional)
- `src/infrastructure/mod.rs` — expose `update_repo` module
- `src/api/events.rs` — add 3 handlers
- `src/api/router.rs` — wire 3 new routes
- `tests/events_test.rs` — append 5 new test cases
- `README.md` — add new endpoints table

### New files
- `src/domain/event_update.rs`
- `src/infrastructure/update_repo.rs`
- `migrations/0002_acknowledge_and_updates.sql`

---

## Out of Scope This Sprint

- SSE / realtime streaming
- Dashboard UI
- Flutter mobile app
- Notifications
- Auth / permissions
- Explicit assignment entities
- Advanced lifecycle transitions beyond CREATED/DELIVERED → ACKNOWLEDGED
- Location model expansion
- NATS / WebSockets
