-- Migration: 0004_rail_seed
-- Insert deterministic seed data into rail context tables.

-- 1. Route
INSERT INTO rail_routes (name)
VALUES ('Northern Line');

-- 2. Stations
INSERT INTO rail_stations (name, code, region)
VALUES
    ('Euston',                 'EUS', 'London'),
    ('King''s Cross',          'KGX', 'London'),
    ('Highbury & Islington',   'HBI', 'London');

-- 3. Service
INSERT INTO rail_services (service_code, direction, status, route_id, scheduled_start_time, scheduled_end_time)
VALUES (
    'NL-001',
    'southbound',
    'ON_TIME',
    (SELECT id FROM rail_routes WHERE name = 'Northern Line'),
    NOW(),
    NOW() + INTERVAL '4 hours'
);

-- 4. Service stops (KGX=1, EUS=2, HBI=3)
INSERT INTO rail_service_stops (service_id, station_id, stop_sequence, scheduled_arrival, scheduled_departure)
VALUES
    (
        (SELECT id FROM rail_services WHERE service_code = 'NL-001'),
        (SELECT id FROM rail_stations WHERE code = 'KGX'),
        1,
        NOW(),
        NOW() + INTERVAL '5 minutes'
    ),
    (
        (SELECT id FROM rail_services WHERE service_code = 'NL-001'),
        (SELECT id FROM rail_stations WHERE code = 'EUS'),
        2,
        NOW() + INTERVAL '15 minutes',
        NOW() + INTERVAL '20 minutes'
    ),
    (
        (SELECT id FROM rail_services WHERE service_code = 'NL-001'),
        (SELECT id FROM rail_stations WHERE code = 'HBI'),
        3,
        NOW() + INTERVAL '30 minutes',
        NOW() + INTERVAL '35 minutes'
    );

-- 5. Staff presence
INSERT INTO staff_presence (actor_id, role_label, presence_type, current_service_id, current_station_id, status)
VALUES
    (
        gen_random_uuid(),
        'Train Conductor',
        'TRAIN',
        (SELECT id FROM rail_services WHERE service_code = 'NL-001'),
        NULL,
        'ON_DUTY'
    ),
    (
        gen_random_uuid(),
        'Station Staff',
        'STATION',
        NULL,
        (SELECT id FROM rail_stations WHERE code = 'EUS'),
        'ON_DUTY'
    ),
    (
        gen_random_uuid(),
        'Control Operator',
        'CONTROL',
        NULL,
        NULL,
        'ON_DUTY'
    );
