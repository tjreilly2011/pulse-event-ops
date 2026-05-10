# Sprint 11 Progress — Realistic Rail Route Seed Data & Route Timeline UI

**Branch:** feat/realistic-rail-seed-data

## Tasks

- [x] BE-01: Replace Northern Line demo seed with realistic routes
- [x] BE-02: Ordered service stop timeline API
- [x] FE-01: Dashboard service detail route timeline
- [x] FE-02: Dashboard station detail service visibility
- [x] MO-01: Mobile route timeline UI
- [x] DOC-01: README sprint-11 seed data and import note

## Notes

<!-- Sub-agent notes appended below as tasks complete -->
- [x] BE-01: Replace Northern Line demo seed with realistic routes
	* Note: replaced `migrations/0004_rail_seed.sql` to remove Northern Line (`NL-001`) and seed only `IE-WPT-HST-001` (Westport -> Dublin Heuston) and `GB-WAT-KGN-001` (London Waterloo -> Kingston) with deterministic stop timelines and staff rows; updated `tests/rail_context_test.rs` with seed integrity + ordered stops endpoint coverage and adjusted legacy assertions off NL-001; updated `README.md` with Sprint 11 curated seed scope and deferred GTFS/NaPTAN note. Gates passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted BE-01 tests, and full `cargo test`.
- [x] BE-02: Ordered service stop timeline API
	* Note: added timeline response shape for `GET /rail/services/:id/stops` including `stop_sequence`, `station_name`, `station_code`, `scheduled_arrival`, and `scheduled_departure` via joined stop/station query while preserving existing service-context stop model. Files changed: `src/domain/rail.rs`, `src/infrastructure/rail_repo.rs`, `src/application/rail.rs`, `tests/rail_context_test.rs`, `ralph/PROGRESS.md`. Verification passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted `cargo test -q service_stops_endpoint_returns_` (2 passed), full `cargo test` (all passed).
- [x] FE-01: Dashboard service detail route timeline
	* Note: updated dashboard service detail to render route semantics (`origin -> destination`) and an ordered stop timeline using station names/codes instead of station UUIDs; handler now sources timeline stop rows from the service stop timeline query and maps first/last stops into the summary. Files changed: `src/api/rail_dashboard.rs`, `templates/rail_service_detail.html`, `tests/rail_context_test.rs`, `ralph/PROGRESS.md`. Verification passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted `cargo test dashboard_service_detail_` (3 passed), and full `cargo test` (all passed).
- [x] FE-02: Dashboard station detail service visibility
	* Note: updated station detail stopping-services UI to a compact linked list (service code -> service detail) while preserving existing station context sections; threaded service IDs through the dashboard station detail view model; strengthened station detail integration assertions for service visibility link plus station/staff/events sections. Files changed: `src/api/rail_dashboard.rs`, `templates/rail_station_detail.html`, `tests/rail_context_test.rs`, `ralph/PROGRESS.md`. Verification passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted `cargo test dashboard_station_detail_` (3 passed), full `cargo test` (all passed), and startup/endpoint smoke (`/health` and `/dashboard/rail/stations` returned 200 in local compose run).
- [x] MO-01: Mobile route timeline UI
	* Note: enhanced Rail tab service context to show origin, destination, and selected/current station; default station chips and "Next stops" now show a condensed upcoming subset; added expandable "Full stop list" timeline with tap-to-select station and preserved existing fallback/current-station selection logic. Files changed: `mobile/lib/screens/rail_context_screen.dart`, `mobile/test/screens/rail_context_screen_test.dart`, `ralph/PROGRESS.md`. Verification passed: `flutter analyze`, `flutter test`, `cargo fmt -- --check`, `cargo clippy -- -D warnings`, `cargo test`, and backend/mobile API smoke (`python3 tests/gate11_mobile_api.py`: 16/16 pass, `/health` 200).
- [x] DOC-01: README sprint-11 seed data and import note
	* Note: clarified Sprint 11 seed scope as curated realistic routes only, explicitly stated Northern Line demo seed replacement, and documented GTFS/NaPTAN import as deferred future work while keeping route examples and command snippets aligned. Files changed: `README.md`, `ralph/PROGRESS.md`. Verification passed: `cargo fmt`, `cargo clippy -- -D warnings`, `cargo test`.
