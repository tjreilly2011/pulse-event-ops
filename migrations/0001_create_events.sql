-- Migration: 0001_create_events
-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- Events table
-- TimescaleDB hypertables cannot have unique constraints that exclude the
-- partition column (created_at). We rely on gen_random_uuid() for id
-- uniqueness (UUID v4 collision probability is negligible) and add a plain
-- index on id for lookup performance.
-- Future: destination_location_id will become a FK to a locations table.
CREATE TABLE IF NOT EXISTS events (
    id                      UUID        NOT NULL DEFAULT gen_random_uuid(),
    event_type              TEXT        NOT NULL,
    status                  TEXT        NOT NULL DEFAULT 'CREATED',
    created_by              UUID        NOT NULL,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    destination_location_id TEXT        NOT NULL,
    source_location_id      TEXT,
    title                   TEXT,
    description             TEXT,
    priority                TEXT        NOT NULL DEFAULT 'normal',
    vertical_metadata       JSONB
);

-- Convert to TimescaleDB hypertable partitioned on created_at
SELECT create_hypertable('events', 'created_at');

-- Indexes
CREATE INDEX ON events (created_at DESC);
CREATE INDEX ON events (id);
