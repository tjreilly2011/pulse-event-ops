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

| Method | Path            | Description             |
|--------|-----------------|-------------------------|
| GET    | `/health`       | Liveness check          |
| POST   | `/events`       | Create a new event      |
| GET    | `/events`       | List all events         |
| GET    | `/events/:id`   | Fetch event by ID       |

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