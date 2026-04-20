# Sprint Plan: Sprint 3 — Project Bootstrap & Minimal Event API

**Branch**: `feat/bootstrap-event-api`
**Date**: 2026-04-19
**Phase**: PHASE 1 — Foundation & First Working Vertical Slice

---

## Executive Summary

First code-producing sprint. Produces a runnable Rust backend (Axum + sqlx + Tokio) with a real TimescaleDB connection, database migrations, and a minimal event API.

By the end of this sprint a client can create, list, and fetch events. All new events are persisted with `status = CREATED`. The `vertical_metadata` field is stored as JSONB and returned as-is — not interpreted.

---

## Architecture

### Style: Layered Monolith (repo root)

```
pulse-event-ops/
├── src/
│   ├── lib.rs                     — exposes create_app(pool) for integration tests
│   ├── main.rs                    — startup, config, migrations, serve
│   ├── config.rs                  — DATABASE_URL + PORT from env
│   ├── domain/event.rs            — Event, EventStatus enum, CreateEventRequest
│   ├── application/events.rs      — use-case layer (create, list, get_by_id)
│   ├── infrastructure/
│   │   ├── db.rs                  — PgPool creation
│   │   └── event_repo.rs          — SQL queries via sqlx::query_as
│   └── api/
│       ├── router.rs              — Axum router, TraceLayer, state
│       ├── health.rs              — GET /health
│       └── events.rs              — POST /events, GET /events, GET /events/:id
├── migrations/
│   └── 0001_create_events.sql     — events table + TimescaleDB hypertable
├── tests/
│   ├── health_test.rs
│   └── events_test.rs
├── Cargo.toml
├── docker-compose.yml             — TimescaleDB pg16
├── .env.example
└── README.md
```

**Layer contract:**
- `api/` → `application/` → `infrastructure/` → `domain/`
- Domain has no external dependencies — pure data types only

---

## API Endpoints

| Method | Path          | Status on success | Description         |
|--------|---------------|-------------------|---------------------|
| GET    | `/health`     | 200               | Liveness check      |
| POST   | `/events`     | 201               | Create event        |
| GET    | `/events`     | 200               | List all events     |
| GET    | `/events/:id` | 200 / 404         | Fetch event by ID   |

---

## Domain Model

**EventStatus** (stored as TEXT, SCREAMING_SNAKE_CASE)
```
CREATED | DELIVERED | ACKNOWLEDGED | IN_PROGRESS | RESOLVED | CANCELLED
```
All inserts hardcode `status = 'CREATED'`. No other transitions this sprint.

**Event core fields**: `id` (UUID), `event_type`, `status`, `created_by` (UUID), `created_at`, `updated_at`, `destination_location_id` (TEXT), `source_location_id?`, `title?`, `description?`, `priority` (default `normal`), `vertical_metadata` (JSONB)

---

## Database

- TimescaleDB extension enabled in migration
- `events` table uses `UNIQUE (id)` not `PRIMARY KEY` to allow hypertable partitioning on `created_at`
- `SELECT create_hypertable('events', 'created_at')` in initial migration
- `destination_location_id` is TEXT — FK to `locations` table deferred to Sprint 4

---

## Config

| Env var        | Required | Default | Description              |
|----------------|----------|---------|--------------------------|
| `DATABASE_URL` | Yes      | —       | Postgres connection URL   |
| `PORT`         | No       | `3000`  | HTTP bind port            |
| `RUST_LOG`     | No       | —       | Tracing filter            |

---

## References

- `src/` — all new files, created this sprint
- `migrations/0001_create_events.sql` — created this sprint
- `tests/` — integration tests using `#[sqlx::test]`
- Sprint 2 inputs: `event-payload.md`, `event-lifecycle.md`, `domain-language.md`, `role-model.md`

---

## Out of Scope This Sprint

- Auth (`created_by` is passed in request body — UUID only)
- `DELIVERED` / acknowledgment status transitions
- Notifications, SSE, WebSockets
- Dashboard or mobile
- `locations` table / FK
- NATS / message bus
