# Sprint 11 Tasks - Realistic Rail Route Seed Data & Route Timeline UI

**Branch:** feat/realistic-rail-seed-data
**Phase:** PHASE 2 — Rail MVP Layer

---

## [BE-01] Replace Northern Line demo seed with realistic routes

### Source
Wishlist requirement: replace the old Northern Line demo seed entirely with a coherent realistic rail dataset.

### Context
The MVP should feel like a believable operational rail environment, not a mixed demo system.

Seed only the two example routes:
- Westport -> Dublin Heuston
- London Waterloo -> Kingston

The old Northern Line seed migration can be removed or replaced entirely.

Use stable demo codes where official identifiers are uncertain, and document them clearly as seed/demo codes.

### Files
- MODIFY: `migrations/0004_rail_seed.sql`
- ADD or MODIFY: `migrations/0005_realistic_rail_seed.sql` (if a separate seed migration is cleaner)
- MODIFY: `README.md`
- MODIFY: `tests/rail_context_test.rs`

### Test Strategy
1. Integration tests confirm the realistic routes/services/stops are present.
2. Integration tests confirm the Northern Line demo seed is gone or explicitly replaced.
3. Repeated test setup remains deterministic and does not duplicate seed rows.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- None

---

## [BE-02] Ordered service stop timeline API

### Source
Wishlist requirement: expose ordered route timelines clearly for the Rail tab and dashboard.

### Context
Ensure `GET /rail/services/:id/stops` returns an ordered timeline-shaped payload with station name, station code, scheduled arrival, and scheduled departure.

### Files
- MODIFY: `src/domain/rail.rs`
- MODIFY: `src/infrastructure/rail_repo.rs`
- MODIFY: `src/application/rail.rs`
- MODIFY: `src/api/rail.rs`
- MODIFY: `src/api/router.rs` (if response shape or route registration changes)
- MODIFY: `tests/rail_context_test.rs`

### Test Strategy
1. Endpoint returns ordered stops for a seeded service.
2. Response includes stop sequence, station name, station code, arrival, and departure.
3. Unknown service still returns 404.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-01]

---

## [FE-01] Dashboard service detail route timeline

### Source
Wishlist requirement: dashboard service detail should show origin, destination, and ordered stop timeline.

### Context
Update `/dashboard/rail/services/:id` so the page reads like a real service timeline rather than a generic entity detail.

### Files
- MODIFY: `src/api/rail_dashboard.rs`
- MODIFY: `templates/rail_service_detail.html`
- MODIFY: `templates/rail_services.html` (if row linking or summary text needs adjustment)
- MODIFY: `tests/rail_context_test.rs` (or dashboard integration tests)

### Test Strategy
1. Seeded service returns 200 and unknown service returns 404.
2. HTML contains service code, origin -> destination, ordered stops, related events, and staff presence.
3. Manual smoke from the services list to the detail page.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]

---

## [FE-02] Dashboard station detail service visibility

### Source
Wishlist requirement: station detail should show services stopping there when cheap to implement.

### Context
Update `/dashboard/rail/stations/:id` so the page shows the station summary plus a compact list of services that stop there, if that remains clean to implement.

### Files
- MODIFY: `src/api/rail_dashboard.rs`
- MODIFY: `templates/rail_station_detail.html`
- MODIFY: `templates/rail_stations.html` (if row linking or summary text needs adjustment)
- MODIFY: `tests/rail_context_test.rs` (or dashboard integration tests)

### Test Strategy
1. Seeded station returns 200 and unknown station returns 404.
2. HTML contains station name/code, staff presence, related events, and service-stop visibility if implemented.
3. Keep the page readable and avoid breaking the existing station context output.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]

---

## [MO-01] Mobile route timeline UI

### Source
Wishlist requirement: Rail tab should show origin, destination, current/selected station, and the next few stops by default.

### Context
Keep the Rail tab readable on small screens by showing a condensed stop timeline and an expandable full stop list.

### Files
- MODIFY: `mobile/lib/screens/rail_context_screen.dart`
- MODIFY: `mobile/lib/services/api_service.dart`
- MODIFY: `mobile/lib/models/rail_service_stop_model.dart`
- MODIFY or ADD: `mobile/lib/models/rail_timeline_model.dart` (only if needed)
- MODIFY: `mobile/test/screens/rail_context_screen_test.dart`

### Test Strategy
1. Widget test: service card shows origin, destination, and selected/current station.
2. Widget test: next few stops are visible by default.
3. Widget test: full stop list expands or collapses correctly.
4. Existing selection and fallback behavior still works.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`flutter test`)
- Static analysis passes (`flutter analyze`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]

---

## [DOC-01] README sprint-11 seed data and import note

### Source
Wishlist requirement: document curated seed data and deferred GTFS / NaPTAN import direction.

### Context
README should explain that Sprint 11 uses realistic curated routes only, the Northern Line demo seed has been replaced, and full import pipelines are deferred.

### Files
- MODIFY: `README.md`

### Test Strategy
1. Verify route examples and command snippets still match actual endpoints.
2. Verify the documentation explicitly calls out GTFS and NaPTAN as future work.

### Definition of Done
- Implementation matches requirements
- Docs reflect shipped behavior only
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-01]
- [FE-01]
- [FE-02]
- [MO-01]

---

## Execution Order (machine-readable)

1. BE-01
2. BE-02
3. FE-01
4. FE-02
5. MO-01
6. DOC-01

---

## Scope Guardrails

1. No maps, GPS, chat, push, staffing rosters, or timetable ingestion.
2. No generic grouping engine.
3. Keep modules small; avoid new modules/services when a change fits existing files.
4. Preserve deterministic and auditable behavior.
