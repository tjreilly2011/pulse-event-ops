# Tasks: Sprint 3 — Project Bootstrap & Minimal Event API

**Branch**: `feat/bootstrap-event-api`
**Phase**: PHASE 1 — Foundation & First Working Vertical Slice
**Date**: 2026-04-19

**Task taxonomy**:
- `[BE-XX]` — Backend (Rust)
- No FE or MO tasks this sprint

---

## Definition of Done

- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt -- --check`)
- Linting passes (`cargo clippy -- -D warnings`)
- App compiles and starts without errors
- `GET /health` returns `200 {"status":"ok"}`
- `POST /events` persists event with `status = CREATED` and returns `201`
- `GET /events` returns array of events
- `GET /events/{id}` returns event or `404`
- Migrations run on startup without error
- README updated with startup instructions

---

## Phase 1 — Project Bootstrap

### BE-01: Initialise Rust project at repo root

**Source**: Sprint 3 wishlist — "Bootstrap the Rust backend application"

**Context**: Create the Cargo workspace as a library + binary crate at the repo root. No nesting under `backend/`. The library exposes `create_app()` for integration testing; the binary is the runnable server.

**Files**:
- `Cargo.toml`

**Test Strategy**: `cargo build` succeeds.

**Dependencies**: None. First task.

---

### BE-02: Add configuration loading

**Source**: Sprint 3 wishlist — "Add configuration loading and environment handling"

**Context**: Load `DATABASE_URL` and `PORT` from environment (via `dotenvy`). Panic on startup if `DATABASE_URL` is missing. `PORT` defaults to `3000`.

**Files**:
- `src/config.rs`
- `.env.example`

**Test Strategy**: Covered implicitly by all other tests (config is loaded before pool is created).

**Dependencies**: BE-01

---

### BE-03: Add Docker dev environment

**Source**: Sprint 3 wishlist — "Add Docker/dev setup for backend + Postgres/TimescaleDB"

**Context**: Single `docker-compose.yml` with one service: `timescale/timescaledb-ha:pg16-latest`. Exposes port 5432. Volume for persistence. No backend container (dev runs locally, only DB in Docker).

**Files**:
- `docker-compose.yml`

**Test Strategy**: `docker compose up -d` starts cleanly; `psql` can connect with credentials from `.env.example`.

**Dependencies**: None.

---

### BE-04: Create initial database migration

**Source**: Sprint 3 wishlist — "Create the initial events table migration" + "Enable TimescaleDB extension and create hypertable"

**Context**: Single migration file. Must:
1. Enable `timescaledb` extension
2. Create `events` table with all fields from the Sprint 2 payload spec
3. Use `UNIQUE (id)` (not `PRIMARY KEY (id)`) to allow TimescaleDB hypertable partitioning on `created_at`
4. Call `create_hypertable('events', 'created_at')`
5. Add supporting indexes

`status` stored as `TEXT` (not Postgres ENUM). `vertical_metadata` as `JSONB`. `destination_location_id` as `TEXT` with comment noting future FK to `locations` table.

**Files**:
- `migrations/0001_create_events.sql`

**Test Strategy**: Migration runs on startup without error. `#[sqlx::test]` in all integration tests also validates the migration.

**Dependencies**: BE-03

---

### BE-05: Implement domain event model

**Source**: Sprint 3 wishlist — "Implement the minimum event model required for MVP"

**Context**: Define `Event` (output, implements `Serialize` + `sqlx::FromRow`), `EventStatus` (enum, implements `sqlx::Type` with TEXT storage + `SCREAMING_SNAKE_CASE` rename), and `CreateEventRequest` (input, implements `Deserialize`).

No business logic in this module. Pure data types.

**Files**:
- `src/domain/event.rs`
- `src/domain/mod.rs`

**Test Strategy**: Struct/enum used by all downstream tests; compile-time validation via `sqlx::FromRow` alignment with DB schema.

**Dependencies**: BE-01, BE-04

---

### BE-06: Implement database pool + event repository

**Source**: Sprint 3 wishlist — "Add database connection and startup validation" + "Persist events in Postgres"

**Context**: Two files:
- `infrastructure/db.rs` — `create_pool(url: &str) -> PgPool` using `PgPoolOptions`
- `infrastructure/event_repo.rs` — three functions using `sqlx::query_as::<_, Event>()`:
  - `insert(pool, req) -> Result<Event, sqlx::Error>` — hardcodes `status = 'CREATED'` in SQL
  - `list(pool) -> Result<Vec<Event>, sqlx::Error>` — orders by `created_at DESC`
  - `get_by_id(pool, id) -> Result<Option<Event>, sqlx::Error>`

Dynamic queries (no compile-time `query!` macro) to avoid build-time `DATABASE_URL` dependency.

**Files**:
- `src/infrastructure/db.rs`
- `src/infrastructure/event_repo.rs`
- `src/infrastructure/mod.rs`

**Test Strategy**: Exercised via `#[sqlx::test]` in `tests/events_test.rs`.

**Dependencies**: BE-05

---

### BE-07: Implement application use case layer

**Source**: Sprint 3 wishlist — architecture — application layer separation

**Context**: Thin layer between API handlers and the repository. Three functions that delegate directly to `event_repo`. Exists to enforce constitution separation (api → application → infrastructure) and to give future sprints a place to add domain logic (validation, routing decisions) without touching HTTP handlers.

**Files**:
- `src/application/events.rs`
- `src/application/mod.rs`

**Test Strategy**: Covered by integration tests via the API handlers.

**Dependencies**: BE-06

---

### BE-08: Implement API handlers and router

**Source**: Sprint 3 wishlist — `POST /events`, `GET /events`, `GET /events/{id}`, `GET /health`

**Context**: Four files:
- `api/health.rs` — returns `200 {"status":"ok"}`
- `api/events.rs` — handlers for create (201), list (200), get_by_id (200/404); all errors return 500 with plain text
- `api/router.rs` — Axum router with `TraceLayer`, all routes, `.with_state(pool)`
- `api/mod.rs` — module declarations

Handlers return typed `Json<Event>` / `Json<Vec<Event>>` using `Result<T, (StatusCode, String)>`. No custom error type at MVP.

**Files**:
- `src/api/health.rs`
- `src/api/events.rs`
- `src/api/router.rs`
- `src/api/mod.rs`

**Test Strategy**: Full HTTP-level integration tests in `tests/`.

**Dependencies**: BE-07

---

### BE-09: Implement crate root and binary entry point

**Source**: Sprint 3 wishlist — "Ensure the backend starts cleanly and runs locally"

**Context**:
- `src/lib.rs` — declares all modules as `pub`; exports `create_app(pool: PgPool) -> Router`
- `src/main.rs` — initialises tracing, loads config, creates pool, runs migrations, serves

Migrations executed via `sqlx::migrate!("./migrations")` on startup. Binary panics on migration failure.

**Files**:
- `src/lib.rs`
- `src/main.rs`

**Test Strategy**: `cargo run` starts without error with Docker Postgres running.

**Dependencies**: BE-08

---

### BE-10: Write integration tests

**Source**: Sprint 3 wishlist — "Add basic tests for health, create event, list events, fetch event by id"

**Context**: All tests use `#[sqlx::test]` which creates a fresh database per test, runs `./migrations`, passes the pool, and tears down on completion. Tests operate at HTTP layer via `app.oneshot(request)` using `tower::ServiceExt`. No mocking.

Tests:
- `health_returns_ok` — GET /health → 200
- `create_event_returns_created` — POST /events with valid body → 201
- `list_events_returns_ok` — GET /events → 200 with array
- `get_event_by_id_returns_event` — create then fetch → 200
- `get_event_by_id_not_found` — GET /events/{random_uuid} → 404

**Files**:
- `tests/health_test.rs`
- `tests/events_test.rs`

**Test Strategy**: These ARE the tests.

**Dependencies**: BE-09

**Note**: Requires `DATABASE_URL` set in environment. `docker compose up -d` must be running.

---

### BE-11: Update README with startup instructions

**Source**: Sprint 3 wishlist — "Updated README with startup instructions"

**Context**: Add "Development Setup" and "Running Locally" sections to existing README.md covering: prerequisites, docker compose, env setup, `cargo run`, `cargo test`.

**Files**:
- `README.md`

**Test Strategy**: Manual — follow the instructions from a clean state.

**Dependencies**: BE-09, BE-10

---

### BE-12: Commit and push sprint branch

**Source**: Sprint workflow

**Context**: Stage all new files, commit with sprint message, push to origin.

**Files**: All files created in BE-01 through BE-11.

**Test Strategy**: `git push` succeeds. CI passes.

**Dependencies**: BE-10, BE-11

---

## Sprint Handoff to Sprint 4

The following are explicitly out of scope for Sprint 3 and are inputs for Sprint 4:

| Item | Sprint 4 |
|---|---|
| `DELIVERED` status transition | Route event to destination after creation |
| Acknowledgment endpoint (`POST /events/{id}/acknowledge`) | Recipient acknowledges → `ACKNOWLEDGED` |
| Status update endpoint | `IN_PROGRESS`, `RESOLVED`, `CANCELLED` transitions |
| Notification layer | Push notification on delivery/acknowledgment |
| SSE live feed | Real-time event broadcast to ops dashboard |
| Auth / session | `created_by` from authenticated session, not request body |
| `locations` table + FK | Proper location registry with `destination_location_id` FK |
