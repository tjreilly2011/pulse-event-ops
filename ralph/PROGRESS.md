# Sprint 11 Progress — Realistic Rail Route Seed Data & Route Timeline UI

**Branch:** feat/realistic-rail-seed-data

## Tasks

- [x] BE-01: Replace Northern Line demo seed with realistic routes
- [x] BE-02: Ordered service stop timeline API
- [x] FE-01: Dashboard service detail route timeline
- [ ] FE-02: Dashboard station detail service visibility
- [ ] MO-01: Mobile route timeline UI
- [ ] DOC-01: README sprint-11 seed data and import note

## Notes

<!-- Sub-agent notes appended below as tasks complete -->
- [x] BE-01: Replace Northern Line demo seed with realistic routes
	* Note: replaced `migrations/0004_rail_seed.sql` to remove Northern Line (`NL-001`) and seed only `IE-WPT-HST-001` (Westport -> Dublin Heuston) and `GB-WAT-KGN-001` (London Waterloo -> Kingston) with deterministic stop timelines and staff rows; updated `tests/rail_context_test.rs` with seed integrity + ordered stops endpoint coverage and adjusted legacy assertions off NL-001; updated `README.md` with Sprint 11 curated seed scope and deferred GTFS/NaPTAN note. Gates passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted BE-01 tests, and full `cargo test`.
- [x] BE-02: Ordered service stop timeline API
	* Note: added timeline response shape for `GET /rail/services/:id/stops` including `stop_sequence`, `station_name`, `station_code`, `scheduled_arrival`, and `scheduled_departure` via joined stop/station query while preserving existing service-context stop model. Files changed: `src/domain/rail.rs`, `src/infrastructure/rail_repo.rs`, `src/application/rail.rs`, `tests/rail_context_test.rs`, `ralph/PROGRESS.md`. Verification passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted `cargo test -q service_stops_endpoint_returns_` (2 passed), full `cargo test` (all passed).
- [x] FE-01: Dashboard service detail route timeline
	* Note: updated dashboard service detail to render route semantics (`origin -> destination`) and an ordered stop timeline using station names/codes instead of station UUIDs; handler now sources timeline stop rows from the service stop timeline query and maps first/last stops into the summary. Files changed: `src/api/rail_dashboard.rs`, `templates/rail_service_detail.html`, `tests/rail_context_test.rs`, `ralph/PROGRESS.md`. Verification passed: `cargo fmt`, `cargo clippy -- -D warnings`, targeted `cargo test dashboard_service_detail_` (3 passed), and full `cargo test` (all passed).
