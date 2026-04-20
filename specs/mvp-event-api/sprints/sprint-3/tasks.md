# Tasks: Sprint 3 — Project Bootstrap & Minimal Event API

**Branch**: `feat/bootstrap-event-api`
**Phase**: PHASE 1 — Foundation & First Working Vertical Slice
**Architecture reference**: `/ralph/plan.md`
**Constitution**: `.specify/memory/constitution.md`

---

## Definition of Done

- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt -- --check`)
- Linting passes (`cargo clippy -- -D warnings`)
- App compiles and starts without errors
- `GET /health` returns `200 {"status":"ok"}`
- `POST /events` persists event with `status = CREATED` and returns `201`
- `GET /events` returns array of events with `200`
- `GET /events/{id}` returns event or `404`
- Migrations run on startup without error
- README updated with startup instructions

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
