# PROGRESS: Sprint 3 — Project Bootstrap & Minimal Event API

**Branch**: `feat/bootstrap-event-api`
**Initialised**: 2026-04-19

---

- [x] [BE-01] Initialise Rust project at repo root
  * Note: Cargo.toml with [lib]+[[bin]], all deps verified
- [x] [BE-02] Add configuration loading
  * Note: src/config.rs + .env.example; .env.example updated with correct creds (pulse_event_ops_user, port 5433)
- [x] [BE-03] Add Docker dev environment
  * Note: docker-compose.yml fixed — image changed to timescale/timescaledb:latest-pg16 (public), port 5433, credentials aligned with .env.example
- [x] [BE-04] Create initial database migration
  * Note: migrations/0001_create_events.sql — removed UNIQUE(id) (TimescaleDB TS103 incompatible with hypertable partition column); plain index on id retained; all tests pass
- [x] [BE-05] Implement domain event model
  * Note: src/domain/event.rs — EventStatus, Event (FromRow), CreateEventRequest verified
- [x] [BE-06] Implement database pool and event repository
  * Note: src/infrastructure/{db,event_repo,mod}.rs — insert/list/get_by_id verified
- [x] [BE-07] Implement application use-case layer
  * Note: src/application/{events,mod}.rs — thin delegation layer verified
- [x] [BE-08] Implement API handlers and router
  * Note: src/api/{health,events,router,mod}.rs — all 4 endpoints verified
- [x] [BE-09] Implement crate root and binary entry point
  * Note: src/lib.rs + src/main.rs — create_app() export, migrations on startup verified
- [x] [BE-10] Write integration tests
  * Note: 5 tests pass (health_returns_ok, create_event_returns_created, list_events_returns_ok, get_event_by_id_returns_event, get_event_by_id_not_found)
- [x] [BE-11] Update README with startup instructions
  * Note: README already complete from initial scaffold; no changes required
- [x] [BE-12] Commit and push sprint branch
  * Note: fix(sprint-3) commit 503d289 pushed to feat/bootstrap-event-api
