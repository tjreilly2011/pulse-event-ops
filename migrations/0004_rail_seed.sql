-- Migration: 0004_rail_seed
-- Insert deterministic seed data into rail context tables.

-- 1. Routes
INSERT INTO rail_routes (name)
VALUES
    ('Westport - Dublin Heuston'),
    ('London Waterloo - Kingston');

-- 2. Stations
INSERT INTO rail_stations (name, code, region)
VALUES
    ('Westport',             'WPT',  'Mayo'),
    ('Castlebar',            'CBR',  'Mayo'),
    ('Manulla Junction',     'MNJ',  'Mayo'),
    ('Claremorris',          'CLM',  'Mayo'),
    ('Ballyhaunis',          'BHS',  'Mayo'),
    ('Castlerea',            'CST',  'Roscommon'),
    ('Roscommon',            'RSC',  'Roscommon'),
    ('Athlone',              'ATH',  'Westmeath'),
    ('Clara',                'CLA',  'Offaly'),
    ('Tullamore',            'TUL',  'Offaly'),
    ('Portarlington',        'PTL',  'Laois'),
    ('Monasterevin',         'MON',  'Kildare'),
    ('Kildare',              'KIL',  'Kildare'),
    ('Newbridge',            'NBR',  'Kildare'),
    ('Dublin Heuston',       'HST',  'Dublin'),
    ('London Waterloo',      'WAT',  'London'),
    ('Vauxhall',             'VXH',  'London'),
    ('Clapham Junction',     'CLJ',  'London'),
    ('Earlsfield',           'EAD',  'London'),
    ('Wimbledon',            'WIM',  'London'),
    ('Raynes Park',          'RAY',  'London'),
    ('New Malden',           'NMD',  'London'),
    ('Norbiton',             'NBT',  'London'),
    ('Kingston',             'KGN',  'London');

-- 3. Services
INSERT INTO rail_services (service_code, direction, status, route_id, scheduled_start_time, scheduled_end_time)
VALUES
    (
        'IE-WPT-HST-001',
        'eastbound',
        'ON_TIME',
        (SELECT id FROM rail_routes WHERE name = 'Westport - Dublin Heuston'),
        TIMESTAMPTZ '2026-05-10 07:00:00+00',
        TIMESTAMPTZ '2026-05-10 11:35:00+00'
    ),
    (
        'GB-WAT-KGN-001',
        'outbound',
        'ON_TIME',
        (SELECT id FROM rail_routes WHERE name = 'London Waterloo - Kingston'),
        TIMESTAMPTZ '2026-05-10 08:15:00+01',
        TIMESTAMPTZ '2026-05-10 08:55:00+01'
    );

-- 4. Service stops (Westport -> Dublin Heuston)
INSERT INTO rail_service_stops (service_id, station_id, stop_sequence, scheduled_arrival, scheduled_departure)
VALUES
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'WPT'), 1, TIMESTAMPTZ '2026-05-10 07:00:00+00', TIMESTAMPTZ '2026-05-10 07:05:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'CBR'), 2, TIMESTAMPTZ '2026-05-10 07:32:00+00', TIMESTAMPTZ '2026-05-10 07:34:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'MNJ'), 3, TIMESTAMPTZ '2026-05-10 07:46:00+00', TIMESTAMPTZ '2026-05-10 07:48:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'CLM'), 4, TIMESTAMPTZ '2026-05-10 08:00:00+00', TIMESTAMPTZ '2026-05-10 08:02:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'BHS'), 5, TIMESTAMPTZ '2026-05-10 08:16:00+00', TIMESTAMPTZ '2026-05-10 08:18:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'CST'), 6, TIMESTAMPTZ '2026-05-10 08:31:00+00', TIMESTAMPTZ '2026-05-10 08:33:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'RSC'), 7, TIMESTAMPTZ '2026-05-10 08:45:00+00', TIMESTAMPTZ '2026-05-10 08:47:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'ATH'), 8, TIMESTAMPTZ '2026-05-10 09:05:00+00', TIMESTAMPTZ '2026-05-10 09:07:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'CLA'), 9, TIMESTAMPTZ '2026-05-10 09:19:00+00', TIMESTAMPTZ '2026-05-10 09:21:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'TUL'), 10, TIMESTAMPTZ '2026-05-10 09:34:00+00', TIMESTAMPTZ '2026-05-10 09:36:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'PTL'), 11, TIMESTAMPTZ '2026-05-10 09:50:00+00', TIMESTAMPTZ '2026-05-10 09:52:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'MON'), 12, TIMESTAMPTZ '2026-05-10 10:07:00+00', TIMESTAMPTZ '2026-05-10 10:09:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'KIL'), 13, TIMESTAMPTZ '2026-05-10 10:22:00+00', TIMESTAMPTZ '2026-05-10 10:24:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'NBR'), 14, TIMESTAMPTZ '2026-05-10 10:38:00+00', TIMESTAMPTZ '2026-05-10 10:40:00+00'),
    ((SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), (SELECT id FROM rail_stations WHERE code = 'HST'), 15, TIMESTAMPTZ '2026-05-10 11:30:00+00', TIMESTAMPTZ '2026-05-10 11:35:00+00');

-- 5. Service stops (London Waterloo -> Kingston)
INSERT INTO rail_service_stops (service_id, station_id, stop_sequence, scheduled_arrival, scheduled_departure)
VALUES
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'WAT'), 1, TIMESTAMPTZ '2026-05-10 08:15:00+01', TIMESTAMPTZ '2026-05-10 08:18:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'VXH'), 2, TIMESTAMPTZ '2026-05-10 08:20:00+01', TIMESTAMPTZ '2026-05-10 08:21:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'CLJ'), 3, TIMESTAMPTZ '2026-05-10 08:27:00+01', TIMESTAMPTZ '2026-05-10 08:28:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'EAD'), 4, TIMESTAMPTZ '2026-05-10 08:33:00+01', TIMESTAMPTZ '2026-05-10 08:34:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'WIM'), 5, TIMESTAMPTZ '2026-05-10 08:38:00+01', TIMESTAMPTZ '2026-05-10 08:39:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'RAY'), 6, TIMESTAMPTZ '2026-05-10 08:43:00+01', TIMESTAMPTZ '2026-05-10 08:44:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'NMD'), 7, TIMESTAMPTZ '2026-05-10 08:47:00+01', TIMESTAMPTZ '2026-05-10 08:48:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'NBT'), 8, TIMESTAMPTZ '2026-05-10 08:51:00+01', TIMESTAMPTZ '2026-05-10 08:52:00+01'),
    ((SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), (SELECT id FROM rail_stations WHERE code = 'KGN'), 9, TIMESTAMPTZ '2026-05-10 08:55:00+01', TIMESTAMPTZ '2026-05-10 08:55:00+01');

-- 6. Staff presence
INSERT INTO staff_presence (actor_id, role_label, presence_type, current_service_id, current_station_id, status)
VALUES
    (gen_random_uuid(), 'Train Conductor', 'TRAIN', (SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'), NULL, 'ON_DUTY'),
    (gen_random_uuid(), 'Station Staff', 'STATION', NULL, (SELECT id FROM rail_stations WHERE code = 'HST'), 'ON_DUTY'),
    (gen_random_uuid(), 'Train Conductor', 'TRAIN', (SELECT id FROM rail_services WHERE service_code = 'GB-WAT-KGN-001'), NULL, 'ON_DUTY'),
    (gen_random_uuid(), 'Station Staff', 'STATION', NULL, (SELECT id FROM rail_stations WHERE code = 'KGN'), 'ON_DUTY'),
    (gen_random_uuid(), 'Control Operator', 'CONTROL', NULL, NULL, 'ON_DUTY');
