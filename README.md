# Pulse Ops

Real-time frontline intelligence platform for operational environments.

## Vision
Enable frontline staff to communicate issues, incidents, and operational data in real time.

## Initial Focus
Rail industry:
- Incident reporting
- Passenger flow visibility
- Coordination during disruptions

## Architecture

- Mobile App: Flutter
- Dashboard: Jinja2 + HTMX + DaisyUI
- Backend: Rust
- Database: PostgreSQL
- Realtime: WebSockets / SSE

## Roadmap

See `/docs/roadmap.md`

## Getting Started

### Prerequisites

- [Rust](https://rustup.rs/) (stable)
- [Docker](https://www.docker.com/) + Docker Compose
- `sqlx-cli` (optional, for manual migration management): `cargo install sqlx-cli`

### Development Setup

**1. Start the database**

```bash
docker compose up -d
```

**2. Configure environment**

```bash
cp .env.example .env
```

Edit `.env` if your local Postgres differs from the defaults.

**3. Run the backend**

```bash
cargo run
```

Migrations run automatically on startup. The server listens on `http://localhost:3000`.

### API

| Method  | Path                        | Status | Description                                                   |
|---------|-----------------------------|--------|---------------------------------------------------------------|
| GET     | `/health`                   | 200    | Liveness check                                                |
| POST    | `/events`                   | 201    | Create a new event                                            |
| GET     | `/events`                   | 200    | List all events                                               |
| GET     | `/events/:id`               | 200    | Fetch event by ID                                             |
| `PATCH` | `/events/:id/acknowledge`   | 200    | Acknowledge event (CREATED or DELIVERED → ACKNOWLEDGED)       |
| `POST`  | `/events/:id/updates`       | 201    | Add a timeline entry to an event                              |
| `GET`   | `/events/:id/updates`       | 200    | List all timeline entries for an event (ordered oldest first) |
| `GET`   | `/events/stream`            | 200    | Subscribe to the realtime SSE event stream                    |

### Realtime — SSE Stream

The `GET /events/stream` endpoint streams server-sent events (SSE) to any connected client. Connect with:

```bash
curl -N http://localhost:3000/events/stream
```

The `-N` flag disables curl's output buffering so events appear as they arrive.

### Dashboard

A basic operations dashboard is available at `http://localhost:3000/dashboard/events`. It provides a live-updating event feed and detail view powered by HTMX + DaisyUI, with no page reloads needed for new events.

**Start the server and open the dashboard:**

```bash
docker compose up -d
cargo run
open http://localhost:3000/dashboard/events
```

**Dashboard routes:**

| Method  | Path                                    | Description                                              |
|---------|-----------------------------------------|----------------------------------------------------------|
| GET     | `/dashboard/events`                     | Full event feed page (auto-refreshes via SSE)            |
| GET     | `/dashboard/events/feed`                | HTMX partial — event list swap target                    |
| GET     | `/dashboard/events/:id`                 | Event detail page with timeline                          |
| PATCH   | `/dashboard/events/:id/acknowledge`     | Acknowledge event from dashboard (returns HX-Redirect)   |

### Mobile App (Flutter)

The `mobile/` directory contains the Flutter app for frontline staff to submit events.

**Prerequisites**:
- [Flutter](https://docs.flutter.dev/get-started/install) 3.x (stable)
- Backend running on `http://localhost:3000` (or your device's LAN IP)

**Run on simulator / emulator**:

```bash
cd mobile
flutter pub get
flutter run
```

**Run on a real device** — update the base URL first:

```dart
// mobile/lib/constants.dart
const String kApiBaseUrl = 'http://192.168.x.x:3000'; // ← your Mac's LAN IP
```

**Run Flutter tests**:

```bash
cd mobile
flutter test
```

**App structure**:

| Screen | Default | Description |
|---|---|---|
| Report Event | ✅ Landing screen | Category grid → optional note → Send Event |
| Recent Events | Tab 2 | Newest-first list of submitted events |

**Event categories (hardcoded MVP)**:

| Display | `event_type` sent to API |
|---|---|
| Delay | `delay` |
| Overcrowding | `overcrowding` |
| Assistance | `passenger_assistance` |
| Safety | `safety_security` |

**Mobile → Dashboard loop**:

```bash
# 1. Start DB + backend
docker compose up -d
cargo run

# 2. Run Flutter app
cd mobile && flutter run

# 3. Open dashboard in browser — events submitted from mobile appear live
open http://localhost:3000/dashboard/events
```

### Smoke Tests

Automated smoke test scripts live in `/tmp/` (generated at sprint end):

| Script | Sprint | Coverage |
|---|---|---|
| `python3 /tmp/gate9.py` | Sprint 5 | SSE stream regression |
| `python3 /tmp/gate10.py` | Sprint 6 | Dashboard routes (feed, detail, acknowledge) |
| `python3 /tmp/gate11.py` | Sprint 7 | Mobile API contract (POST /events, GET /events) |

Run all gates:

```bash
python3 /tmp/gate9.py && python3 /tmp/gate10.py && python3 /tmp/gate11.py
```

**Live updates:** The feed page connects to `/events/stream` via `EventSource`. When a new event or update is broadcast, the event list partial is automatically refreshed without a full page reload.

The stream emits three event types:

**`EVENT_CREATED`** — emitted when `POST /events` succeeds:
```json
data: {"type":"EVENT_CREATED","event":{"id":"...","event_type":"passenger_assistance","status":"CREATED","created_by":"...","created_at":"...","updated_at":"...","acknowledged_by":null,"acknowledged_at":null,"destination_location_id":"station-euston","source_location_id":null,"title":null,"description":null,"priority":"normal","vertical_metadata":null}}
```

**`EVENT_ACKNOWLEDGED`** — emitted when `PATCH /events/:id/acknowledge` succeeds:
```json
data: {"type":"EVENT_ACKNOWLEDGED","event":{"id":"...","status":"ACKNOWLEDGED","acknowledged_by":"...","acknowledged_at":"..."}}
```

**`EVENT_UPDATE_ADDED`** — emitted when `POST /events/:id/updates` succeeds:
```json
data: {"type":"EVENT_UPDATE_ADDED","update":{"id":"...","event_id":"...","update_type":"NOTE","content":"Train delayed at platform 3","actor_id":"...","created_at":"..."}}
```

> **Note:** The stream is best-effort. Messages are broadcast in-process over a `tokio::broadcast` channel and are not persisted or replayed. Postgres remains the source of truth — clients that need a guaranteed view should poll the REST endpoints.

**Example — create event:**

```bash
curl -X POST http://localhost:3000/events \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "passenger_assistance",
    "created_by": "00000000-0000-0000-0000-000000000001",
    "destination_location_id": "station-euston",
    "vertical_metadata": {
      "assistance_type": "wheelchair_ramp",
      "coach_number": "C"
    }
  }'
```

### Running Tests

Tests use `#[sqlx::test]` — each test gets a fresh database and tears it down on completion. Requires `DATABASE_URL` to be set and the database to be running.

```bash
docker compose up -d
cp .env.example .env
cargo test
```

### Code Quality

```bash
cargo fmt
cargo clippy -- -D warnings
```

### Smoke Tests

Run these against a live server (`cargo run`) to verify all endpoints and key failure paths. Requires the database to be running and `.env` to be configured.

**Gate 1 — Health check**
```bash
curl -s http://localhost:3000/health
# expected: {"status":"ok"}  HTTP 200
```

**Gate 2 — Create event (happy path)**
```bash
EVENT=$(curl -s -X POST http://localhost:3000/events \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "passenger_assistance",
    "created_by": "00000000-0000-0000-0000-000000000001",
    "destination_location_id": "station-euston",
    "vertical_metadata": {
      "assistance_type": "wheelchair_ramp",
      "coach_number": "C"
    }
  }')
echo $EVENT
# expected: JSON body with "status":"CREATED"  HTTP 201
```

**Gate 3 — List events (happy path)**
```bash
curl -s http://localhost:3000/events
# expected: JSON array, HTTP 200
```

**Gate 4 — Get event by ID (happy path)**
```bash
# substitute a real UUID from Gate 2
EVENT_ID=$(echo $EVENT | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
curl -s http://localhost:3000/events/$EVENT_ID
# expected: JSON event body, HTTP 200
```

**Gate 5 — Get event by ID (failure path — not found)**
```bash
curl -s -o /dev/null -w "%{http_code}" \
  http://localhost:3000/events/00000000-0000-0000-0000-000000000000
# expected: 404
```

**Gate 6 — Create event with invalid body (failure path)**
```bash
curl -s -o /dev/null -w "%{http_code}" \
  -X POST http://localhost:3000/events \
  -H "Content-Type: application/json" \
  -d '{"bad": "payload"}'
# expected: 422
```

**Gate 7: Acknowledge an event**
```bash
# First create an event and capture its id
EVENT_ID=$(curl -s -X POST http://localhost:3000/events \
  -H "Content-Type: application/json" \
  -d '{"event_type":"test","created_by":"00000000-0000-0000-0000-000000000001","destination_location_id":"station-x"}' \
  | jq -r '.id')

curl -s -X PATCH http://localhost:3000/events/$EVENT_ID/acknowledge \
  -H "Content-Type: application/json" \
  -d '{"acknowledged_by":"00000000-0000-0000-0000-000000000002"}'
# Expected: 200 with status == "ACKNOWLEDGED"
```

**Gate 8: Add an event update**
```bash
curl -s -X POST http://localhost:3000/events/$EVENT_ID/updates \
  -H "Content-Type: application/json" \
  -d '{"content":"Train diverted to platform 3","update_type":"NOTE"}'
# Expected: 201 with event_id and content in response
```

### Database Checks

All commands run inside the Docker container — no local `psql` required.

**Open an interactive psql session**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db
```

Then run any SQL below at the `pulse_event_ops_db=#` prompt. Or run one-liners directly:

**Check events table schema**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "\d events"
```

**Confirm TimescaleDB hypertable is set up**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT hypertable_name, num_dimensions
FROM timescaledb_information.hypertables
WHERE hypertable_name = 'events';"
# expected: 1 row, num_dimensions = 1
```

**Check TimescaleDB chunks (confirms partitioning is active)**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT chunk_name, range_start, range_end
FROM timescaledb_information.chunks
WHERE hypertable_name = 'events'
ORDER BY range_start DESC;"
```

**Count all events**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT COUNT(*) FROM events;"
```

**View all events (most recent first)**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT id, event_type, status, created_by, destination_location_id, created_at
FROM events
ORDER BY created_at DESC;"
```

**View full event record including JSONB metadata**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT * FROM events ORDER BY created_at DESC LIMIT 1;"
```

**Check events by status**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT status, COUNT(*) FROM events GROUP BY status;"
```

**Verify indexes are present**
```bash
docker exec -it pulse-event-ops-db-1 psql -U pulse_event_ops_user -d pulse_event_ops_db -c "
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'events';"
# expected: index on created_at DESC and index on id
```