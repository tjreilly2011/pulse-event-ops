# Tasks: Sprint 4 — Event Acknowledgment & Updates

**Branch**: `feat/event-acknowledgment-and-updates`
**Phase**: PHASE 1 — MVP Build
**Architecture reference**: `/ralph/plan.md`
**Constitution**: `.specify/memory/constitution.md`

---

## Definition of Done

- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt -- --check`)
- Linting passes (`cargo clippy -- -D warnings`)
- App compiles and starts without errors
- `PATCH /events/:id/acknowledge` transitions status and persists acknowledgment + auto timeline entry
- `POST /events/:id/updates` persists a timeline entry and returns 201
- `GET /events/:id/updates` returns ordered timeline entries
- 409 returned for duplicate acknowledge attempt
- 404 returned for unknown event IDs
- README updated with new endpoints
- No `ralph/` files committed

---

## Tasks

---

### [BE-01] Write migration: extend events + create event_updates table

#### Source
Sprint 4 wishlist — event acknowledgment storage, event updates table

#### Context
Create `migrations/0002_acknowledge_and_updates.sql`.

1. Extend `events` table:
```sql
ALTER TABLE events
    ADD COLUMN acknowledged_by  UUID,
    ADD COLUMN acknowledged_at  TIMESTAMPTZ;
```

2. Create `event_updates` table (plain Postgres, **not** a hypertable):
```sql
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

**No FK from `event_updates.event_id` → `events.id`** — `events.id` has no UNIQUE constraint (TimescaleDB TS103). Existence validated at application layer.

#### Files
- `migrations/0002_acknowledge_and_updates.sql`

#### Test Strategy
Migration runs automatically via `sqlx::migrate!` on startup and in `#[sqlx::test]`. Verified implicitly by all BE-04+ tests.

#### Dependencies
None

---

### [BE-02] Extend domain Event model

#### Source
Sprint 4 wishlist — persist acknowledged_by / acknowledged_at

#### Context
In `src/domain/event.rs`, add two new optional fields to the `Event` struct (must match migration column names exactly for `sqlx::FromRow`):

```rust
pub acknowledged_by: Option<Uuid>,
pub acknowledged_at: Option<DateTime<Utc>>,
```

No changes to `EventStatus` variants — they already include `Acknowledged`.

#### Files
- `src/domain/event.rs`

#### Test Strategy
Compile-time: `sqlx::FromRow` alignment verified on first test run. Runtime: acknowledged fields present in GET /events/:id response after acknowledge.

#### Dependencies
BE-01

---

### [BE-03] Create EventUpdate domain model

#### Source
Sprint 4 wishlist — event timeline / history

#### Context
Create `src/domain/event_update.rs`:

```rust
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct EventUpdate {
    pub id: Uuid,
    pub event_id: Uuid,
    pub update_type: Option<String>,
    pub content: String,
    pub actor_id: Option<Uuid>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateEventUpdateRequest {
    pub content: String,
    pub actor_id: Option<Uuid>,
    pub update_type: Option<String>,
}
```

Add `pub mod event_update;` to `src/domain/mod.rs`.

#### Files
- `src/domain/event_update.rs`
- `src/domain/mod.rs`

#### Test Strategy
Compile-time: `sqlx::FromRow` verified by BE-06/07 tests.

#### Dependencies
BE-01

---

### [BE-04] Create update_repo infrastructure

#### Source
Sprint 4 wishlist — persist and list event updates

#### Context
Create `src/infrastructure/update_repo.rs` with two public async functions:

```rust
pub async fn insert(
    pool: &PgPool,
    event_id: Uuid,
    update_type: Option<&str>,
    content: &str,
    actor_id: Option<Uuid>,
) -> Result<EventUpdate, sqlx::Error>
```
SQL: `INSERT INTO event_updates (event_id, update_type, content, actor_id) VALUES ($1, $2, $3, $4) RETURNING *`

```rust
pub async fn list_by_event(
    pool: &PgPool,
    event_id: Uuid,
) -> Result<Vec<EventUpdate>, sqlx::Error>
```
SQL: `SELECT * FROM event_updates WHERE event_id = $1 ORDER BY created_at ASC`

Add `pub mod update_repo;` to `src/infrastructure/mod.rs`.

#### Files
- `src/infrastructure/update_repo.rs`
- `src/infrastructure/mod.rs`

#### Test Strategy
Exercised via `#[sqlx::test]` integration tests in BE-07+.

#### Dependencies
BE-03

---

### [BE-05] Implement acknowledge_event in event_repo (transactional)

#### Source
Sprint 4 wishlist — atomic acknowledge: update event + auto-insert timeline entry

#### Context
Add `pub async fn acknowledge_event` to `src/infrastructure/event_repo.rs`:

```rust
pub async fn acknowledge_event(
    pool: &PgPool,
    event_id: Uuid,
    acknowledged_by: Uuid,
) -> Result<Event, sqlx::Error>
```

Implementation must run inside a **single transaction**:
1. `UPDATE events SET status='ACKNOWLEDGED', acknowledged_by=$1, acknowledged_at=NOW(), updated_at=NOW() WHERE id=$2 RETURNING *`
2. `INSERT INTO event_updates (event_id, update_type, content, actor_id) VALUES ($event_id, 'ACKNOWLEDGED', 'Acknowledged', $acknowledged_by)`

Use `pool.begin()` / `tx.commit()`. Return the updated `Event`.

#### Files
- `src/infrastructure/event_repo.rs`

#### Test Strategy
Verified by BE-07/08 integration tests — after acknowledge, both the event row and a corresponding event_update row must exist.

#### Dependencies
BE-02, BE-04

---

### [BE-06] Add use-case functions to application layer

#### Source
Architecture — application layer owns business rules

#### Context
Extend `src/application/events.rs` with three new public async functions:

**`acknowledge`**:
```rust
pub async fn acknowledge(
    pool: &PgPool,
    event_id: Uuid,
    req: AcknowledgeEventRequest,
) -> Result<Event, AcknowledgeError>
```
- Fetch event via `event_repo::get_by_id` — return `AcknowledgeError::NotFound` if absent
- Check status: only `CREATED` and `DELIVERED` are valid. All others → `AcknowledgeError::InvalidStatus`
- Call `event_repo::acknowledge_event` → return updated `Event`

Define a simple error enum in the same file:
```rust
pub enum AcknowledgeError {
    NotFound,
    InvalidStatus,
    Db(sqlx::Error),
}
```

**`add_update`**:
```rust
pub async fn add_update(
    pool: &PgPool,
    event_id: Uuid,
    req: CreateEventUpdateRequest,
) -> Result<EventUpdate, AddUpdateError>
```
- Verify event exists via `event_repo::get_by_id` — return `AddUpdateError::NotFound` if absent
- Default `update_type` to `"NOTE"` if `req.update_type` is `None`
- Call `update_repo::insert`

Define:
```rust
pub enum AddUpdateError {
    NotFound,
    Db(sqlx::Error),
}
```

**`list_updates`**:
```rust
pub async fn list_updates(
    pool: &PgPool,
    event_id: Uuid,
) -> Result<Vec<EventUpdate>, sqlx::Error>
```
- Delegates directly to `update_repo::list_by_event`

#### Files
- `src/application/events.rs`

#### Test Strategy
Business rule (status guard) tested directly in BE-08 integration tests via HTTP layer.

#### Dependencies
BE-04, BE-05

---

### [BE-07] Add API handlers

#### Source
Sprint 4 wishlist — PATCH /events/:id/acknowledge, POST /events/:id/updates, GET /events/:id/updates

#### Context
Extend `src/api/events.rs` with three new async handler functions:

**`acknowledge_event`**:
```rust
pub async fn acknowledge_event(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
    Json(req): Json<AcknowledgeEventRequest>,
) -> impl IntoResponse
```
- Calls `application::events::acknowledge`
- `NotFound` → 404
- `InvalidStatus` → 409 with body `{"error":"event cannot be acknowledged in its current status"}`
- `Db(_)` → 500
- Success → 200 with `Json<Event>`

**`add_event_update`**:
```rust
pub async fn add_event_update(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
    Json(req): Json<CreateEventUpdateRequest>,
) -> impl IntoResponse
```
- Calls `application::events::add_update`
- `NotFound` → 404
- `Db(_)` → 500
- Success → 201 with `Json<EventUpdate>`

**`list_event_updates`**:
```rust
pub async fn list_event_updates(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse
```
- Calls `application::events::list_updates`
- Error → 500
- Success → 200 with `Json<Vec<EventUpdate>>`

Add `tracing::error!` on all error branches.

#### Files
- `src/api/events.rs`

#### Test Strategy
Covered by BE-08 integration tests.

#### Dependencies
BE-06

---

### [BE-08] Wire new routes in router

#### Source
Sprint 4 wishlist — 3 new routes

#### Context
In `src/api/router.rs`, add to the existing `build()` function:

```rust
.route("/events/:id/acknowledge", routing::patch(handlers::acknowledge_event))
.route("/events/:id/updates",     routing::post(handlers::add_event_update)
                                         .get(handlers::list_event_updates))
```

#### Files
- `src/api/router.rs`

#### Test Strategy
Routes reachable from integration tests.

#### Dependencies
BE-07

---

### [BE-09] Write integration tests

#### Source
Sprint 4 wishlist — test all new workflow behaviour

#### Context
Append to `tests/events_test.rs`. All tests use `#[sqlx::test]` with `app.oneshot()` pattern.

**Test 1: `acknowledge_event_transitions_status`**
- Create event → PATCH acknowledge → expect 200
- Re-fetch event → status == "ACKNOWLEDGED", acknowledged_by set, acknowledged_at set

**Test 2: `acknowledge_event_duplicate_returns_409`**
- Create event → PATCH acknowledge → 200
- PATCH acknowledge again → expect 409

**Test 3: `acknowledge_auto_creates_timeline_entry`**
- Create event → PATCH acknowledge → 200
- GET /events/:id/updates → expect 200, array contains one entry with `update_type == "ACKNOWLEDGED"`

**Test 4: `add_event_update_returns_201`**
- Create event → POST /events/:id/updates with `{ content: "Train diverted", update_type: "NOTE", actor_id: <uuid> }` → expect 201
- Response body contains `event_id`, `content`, `update_type`

**Test 5: `list_event_updates_returns_ordered_entries`**
- Create event → PATCH acknowledge → POST update → GET /events/:id/updates
- Expect 2 entries ordered by `created_at ASC`, first is ACKNOWLEDGED

**Test 6: `acknowledge_unknown_event_returns_404`**
- PATCH /events/<random_uuid>/acknowledge → expect 404

**Test 7: `add_update_unknown_event_returns_404`**
- POST /events/<random_uuid>/updates → expect 404

#### Files
- `tests/events_test.rs`

#### Test Strategy
These ARE the tests. `cargo test` must be green.

#### Dependencies
BE-08

---

### [BE-10] Update README

#### Source
Sprint 4 wishlist — README reflects new endpoints

#### Context
Add Sprint 4 endpoints to the existing API reference table in `README.md`:

| Method  | Path                       | Status | Description                         |
|---------|----------------------------|--------|-------------------------------------|
| `PATCH` | `/events/:id/acknowledge`  | 200    | Acknowledge event (CREATED/DELIVERED → ACKNOWLEDGED) |
| `POST`  | `/events/:id/updates`      | 201    | Add a timeline entry                |
| `GET`   | `/events/:id/updates`      | 200    | List timeline entries for event     |

Update the smoke test section with two new gates:
- Acknowledge an event and verify 200
- Add an update and verify 201

#### Files
- `README.md`

#### Test Strategy
Manual verification — follow the README from a clean checkout.

#### Dependencies
BE-09

---

### [BE-11] Update PROGRESS.md

#### Source
Orchestrator tracking

#### Context
Reset `ralph/PROGRESS.md` for Sprint 4. Mark items as complete as tasks land.

#### Files
- `ralph/PROGRESS.md`

#### Test Strategy
N/A — orchestrator artifact only.

#### Dependencies
None

---

## Tasks

- [ ] [BE-01] Initialise Rust project at repo root

### Source
Sprint 3 wishlist — project bootstrap

### Context
Cargo.toml with `[lib]` (path `src/lib.rs`) and `[[bin]]` (path `src/main.rs`). Library exposes `create_app()` for integration testing. Dependencies: axum 0.7, tokio full, sqlx (postgres/uuid/chrono/json/migrate), serde, serde_json, uuid v4, chrono, dotenvy, tracing, tracing-subscriber, tower-http trace. Dev deps: tower util.

### Files
- `Cargo.toml`

### Test Strategy
`cargo build` succeeds.

### Dependencies
None

---

- [ ] [BE-02] Add configuration loading

### Source
Sprint 3 wishlist — environment handling

### Context
`src/config.rs` — `Config` struct with `database_url: String` and `port: u16`. `Config::from_env()` calls `dotenvy::dotenv().ok()`, reads `DATABASE_URL` (panics if missing), reads `PORT` defaulting to `"3000"`. `.env.example` with `DATABASE_URL=postgres://pulse:pulse@localhost:5432/pulse_dev`, `PORT=3000`, `RUST_LOG=pulse_event_ops=debug,tower_http=debug`.

### Files
- `src/config.rs`
- `.env.example`

### Test Strategy
Covered implicitly — config loads before pool is created in all integration tests.

### Dependencies
BE-01

---

- [ ] [BE-03] Add Docker dev environment

### Source
Sprint 3 wishlist — Docker/dev setup

### Context
`docker-compose.yml` with a single `db` service using image `timescale/timescaledb-ha:pg16-latest`. Env: `POSTGRES_USER=pulse`, `POSTGRES_PASSWORD=pulse`, `POSTGRES_DB=pulse_dev`. Port `5432:5432`. Named volume `pgdata`.

### Files
- `docker-compose.yml`

### Test Strategy
`docker compose up -d` starts cleanly; psql connects with credentials from `.env.example`.

### Dependencies
None

---

- [ ] [BE-04] Create initial database migration

### Source
Sprint 3 wishlist — events table + TimescaleDB hypertable

### Context
`migrations/0001_create_events.sql`. Steps:
1. `CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE`
2. Create `events` table. Use `UNIQUE (id)` not `PRIMARY KEY (id)` — required for TimescaleDB hypertable partitioning on `created_at`. Fields: `id UUID NOT NULL DEFAULT gen_random_uuid()`, `event_type TEXT NOT NULL`, `status TEXT NOT NULL DEFAULT 'CREATED'`, `created_by UUID NOT NULL`, `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, `destination_location_id TEXT NOT NULL` (comment: future FK to locations), `source_location_id TEXT`, `title TEXT`, `description TEXT`, `priority TEXT NOT NULL DEFAULT 'normal'`, `vertical_metadata JSONB`.
3. `SELECT create_hypertable('events', 'created_at')`
4. Indexes on `created_at DESC` and `id`.

### Files
- `migrations/0001_create_events.sql`

### Test Strategy
Migration runs on startup without error. `#[sqlx::test]` in integration tests also validates migration against a real DB.

### Dependencies
BE-03

---

- [ ] [BE-05] Implement domain event model

### Source
Sprint 3 wishlist — minimum event model

### Context
`src/domain/event.rs`. Three types:
- `EventStatus` — enum, `#[sqlx(type_name = "text", rename_all = "SCREAMING_SNAKE_CASE")]`, `Serialize/Deserialize` with `rename_all = "SCREAMING_SNAKE_CASE"`. Variants: `Created`, `Delivered`, `Acknowledged`, `InProgress`, `Resolved`, `Cancelled`.
- `Event` — struct, `Serialize + sqlx::FromRow`. Fields match migration columns exactly.
- `CreateEventRequest` — struct, `Deserialize`. Fields: `event_type`, `created_by: Uuid`, `destination_location_id`, `source_location_id?`, `title?`, `description?`, `priority?`, `vertical_metadata?: serde_json::Value`.

`src/domain/mod.rs` — `pub mod event;`

### Files
- `src/domain/event.rs`
- `src/domain/mod.rs`

### Test Strategy
Compile-time: `sqlx::FromRow` alignment with DB schema validated at test time. Runtime: used by all integration tests.

### Dependencies
BE-01, BE-04

---

- [ ] [BE-06] Implement database pool and event repository

### Source
Sprint 3 wishlist — database connection + persist events

### Context
`src/infrastructure/db.rs` — `pub async fn create_pool(url: &str) -> PgPool` using `PgPoolOptions::new().max_connections(5).connect(url).await`.

`src/infrastructure/event_repo.rs` — three public async functions using `sqlx::query_as::<_, Event>()` (dynamic queries, no compile-time macro):
- `insert(pool, req) -> Result<Event, sqlx::Error>` — generates UUID, hardcodes `status = 'CREATED'` in SQL, binds all fields, `RETURNING *`
- `list(pool) -> Result<Vec<Event>, sqlx::Error>` — `SELECT * FROM events ORDER BY created_at DESC`
- `get_by_id(pool, id: Uuid) -> Result<Option<Event>, sqlx::Error>` — `SELECT * FROM events WHERE id = $1`, `fetch_optional`

`src/infrastructure/mod.rs` — `pub mod db; pub mod event_repo;`

### Files
- `src/infrastructure/db.rs`
- `src/infrastructure/event_repo.rs`
- `src/infrastructure/mod.rs`

### Test Strategy
Exercised via `#[sqlx::test]` integration tests.

### Dependencies
BE-05

---

- [ ] [BE-07] Implement application use-case layer

### Source
Architecture — separation of api / application / infrastructure

### Context
`src/application/events.rs` — three public async functions delegating directly to `event_repo`:
- `create(pool, req: CreateEventRequest) -> Result<Event, sqlx::Error>`
- `list(pool) -> Result<Vec<Event>, sqlx::Error>`
- `get_by_id(pool, id: Uuid) -> Result<Option<Event>, sqlx::Error>`

`src/application/mod.rs` — `pub mod events;`

This layer exists to enforce api → application → infrastructure separation and to give Sprint 4 a place to add routing/validation logic without touching HTTP handlers.

### Files
- `src/application/events.rs`
- `src/application/mod.rs`

### Test Strategy
Covered by API integration tests.

### Dependencies
BE-06

---

- [ ] [BE-08] Implement API handlers and router

### Source
Sprint 3 wishlist — POST /events, GET /events, GET /events/{id}, GET /health

### Context
`src/api/health.rs` — `pub async fn health() -> impl IntoResponse` returns `(StatusCode::OK, Json(json!({"status":"ok"})))`.

`src/api/events.rs` — three handlers:
- `create(State(pool), Json(req)) -> Result<(StatusCode::CREATED, Json<Event>), (StatusCode, String)>`
- `list(State(pool)) -> Result<Json<Vec<Event>>, (StatusCode, String)>`
- `get_by_id(State(pool), Path(id: Uuid)) -> Result<Json<Event>, (StatusCode, String)>` — returns 404 if `None`

All errors return `(StatusCode::INTERNAL_SERVER_ERROR, "Internal server error")` with `tracing::error!` logging. No custom error type.

`src/api/router.rs` — `pub fn build(pool: PgPool) -> Router`. Routes: `GET /health`, `POST /events`, `GET /events`, `GET /events/:id`. `TraceLayer::new_for_http()`. `.with_state(pool)`.

`src/api/mod.rs` — `pub mod events; pub mod health; pub mod router;`

### Files
- `src/api/health.rs`
- `src/api/events.rs`
- `src/api/router.rs`
- `src/api/mod.rs`

### Test Strategy
Full HTTP-level integration tests in `tests/`.

### Dependencies
BE-07

---

- [ ] [BE-09] Implement crate root and binary entry point

### Source
Sprint 3 wishlist — app starts cleanly

### Context
`src/lib.rs` — declares all modules as `pub`, exports `pub fn create_app(pool: PgPool) -> Router` calling `api::router::build(pool)`.

`src/main.rs`:
1. Init tracing via `tracing_subscriber` with `EnvFilter`
2. `Config::from_env()`
3. `create_pool(&config.database_url).await`
4. `sqlx::migrate!("./migrations").run(&pool).await` — panics on failure
5. `create_app(pool)` → `axum::serve(TcpListener::bind(addr), app).await`

### Files
- `src/lib.rs`
- `src/main.rs`

### Test Strategy
`cargo run` starts without error with Docker Postgres running.

### Dependencies
BE-08

---

- [ ] [BE-10] Write integration tests

### Source
Sprint 3 wishlist — tests for health, create, list, get by id

### Context
All tests use `#[sqlx::test]` — fresh DB per test, migrations applied automatically, torn down after. Tests use `app.oneshot(request)` via `tower::ServiceExt`. No mocking.

`tests/health_test.rs`:
- `health_returns_ok` — GET /health → 200

`tests/events_test.rs`:
- `create_event_returns_created` — POST /events with valid body → 201
- `list_events_returns_ok` — GET /events → 200
- `get_event_by_id_returns_event` — create then GET /events/{id} → 200
- `get_event_by_id_not_found` — GET /events/{random_uuid} → 404

Test body uses `event_type: "passenger_assistance"`, `created_by: "00000000-0000-0000-0000-000000000001"`, `destination_location_id: "station-euston"`, `vertical_metadata: {assistance_type, coach_number}`.

### Files
- `tests/health_test.rs`
- `tests/events_test.rs`

### Test Strategy
These ARE the tests. Requires `DATABASE_URL` in env and Postgres running.

### Dependencies
BE-09

---

- [ ] [BE-11] Update README with startup instructions

### Source
Sprint 3 wishlist — README with startup instructions

### Context
Add "Development Setup" and "Running Locally" sections covering: prerequisites (Rust stable, Docker), `docker compose up -d`, `cp .env.example .env`, `cargo run`. API reference table. `cargo test` instructions. `cargo fmt` and `cargo clippy` commands.

### Files
- `README.md`

### Test Strategy
Manual — follow the instructions from a clean checkout.

### Dependencies
BE-09, BE-10

---

- [ ] [BE-12] Commit and push sprint branch

### Source
Sprint workflow

### Context
Stage all files, commit with descriptive message, push `feat/bootstrap-event-api` to origin.

### Files
All files from BE-01 through BE-11.

### Test Strategy
`git push` succeeds. `cargo build` clean on fresh clone.

### Dependencies
BE-10, BE-11
