-- Migration: 0002_acknowledge_and_updates
-- Extend events with acknowledgment columns and create event_updates table.

-- Extend events table with acknowledgment fields
ALTER TABLE events
    ADD COLUMN acknowledged_by  UUID,
    ADD COLUMN acknowledged_at  TIMESTAMPTZ;

-- event_updates: plain Postgres table (NOT a hypertable — queries are by
-- event_id lookup, not time-range scans).
-- No FK from event_id → events.id: events.id has no UNIQUE constraint due to
-- TimescaleDB TS103 restriction. Event existence is validated at the
-- application layer.
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
