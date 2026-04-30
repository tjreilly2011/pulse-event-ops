-- Migration: 0003_rail_context
-- Create rail context tables: routes, stations, services, service stops,
-- staff presence, and event context linkage.

-- 1. rail_routes
CREATE TABLE IF NOT EXISTS rail_routes (
    id          UUID        NOT NULL DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 2. rail_stations
CREATE TABLE IF NOT EXISTS rail_stations (
    id          UUID        NOT NULL DEFAULT gen_random_uuid(),
    name        TEXT        NOT NULL,
    code        TEXT        NOT NULL,
    region      TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id),
    UNIQUE (code)
);

-- 3. rail_services
CREATE TABLE IF NOT EXISTS rail_services (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    service_code            TEXT        NOT NULL,
    route_id                UUID        REFERENCES rail_routes(id),
    direction               TEXT        NOT NULL,
    scheduled_start_time    TIMESTAMPTZ,
    scheduled_end_time      TIMESTAMPTZ,
    status                  TEXT        NOT NULL DEFAULT 'ON_TIME',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 4. rail_service_stops
CREATE TABLE IF NOT EXISTS rail_service_stops (
    id                   UUID        NOT NULL DEFAULT gen_random_uuid(),
    service_id           UUID        REFERENCES rail_services(id),
    station_id           UUID        REFERENCES rail_stations(id),
    scheduled_arrival    TIMESTAMPTZ,
    scheduled_departure  TIMESTAMPTZ,
    stop_sequence        INT         NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 5. staff_presence
CREATE TABLE IF NOT EXISTS staff_presence (
    id                  UUID        NOT NULL DEFAULT gen_random_uuid(),
    actor_id            UUID        NOT NULL,
    role_label          TEXT        NOT NULL,
    presence_type       TEXT        NOT NULL CHECK (presence_type IN ('TRAIN', 'STATION', 'CONTROL')),
    current_service_id  UUID        REFERENCES rail_services(id),
    current_station_id  UUID        REFERENCES rail_stations(id),
    status              TEXT        NOT NULL DEFAULT 'ON_DUTY',
    last_seen_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 6. rail_event_context
-- event_id has NO FK constraint to events — events is a TimescaleDB hypertable
-- and cannot be the target of FK references (TS103 restriction). Event
-- existence is validated at the application layer. Same pattern as
-- event_updates.event_id in migration 0002.
CREATE TABLE IF NOT EXISTS rail_event_context (
    event_id         UUID        NOT NULL,
    rail_service_id  UUID        REFERENCES rail_services(id),
    rail_station_id  UUID        REFERENCES rail_stations(id),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index on event_id for lookup performance
CREATE INDEX ON rail_event_context (event_id);
