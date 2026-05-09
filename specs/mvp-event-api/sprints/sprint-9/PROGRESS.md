# Sprint 9 Progress — Rail Context Model

## Tasks

- [x] BE-01: Rail context migration (0003_rail_context.sql)
    * Note: created migrations/0003_rail_context.sql — 6 tables (rail_routes, rail_stations, rail_services, rail_service_stops, staff_presence, rail_event_context)
- [x] BE-02: Seed data migration (0004_rail_seed.sql)
    * Note: 1 route, 3 stations, 1 service NL-001, 3 stops, 3 staff presence rows
- [x] BE-03: Rail domain models (src/domain/rail.rs)
    * Note: src/domain/rail.rs created — RailRoute, RailStation, RailService, RailServiceStop, StaffPresence, RailEventContext, StatusDot, ServiceContext
- [x] BE-04: Rail infrastructure layer (src/infrastructure/rail_repo.rs)
    * Note: rail_repo.rs — 13 functions; sqlx offline cache not needed (live DB compile-time check)
- [x] BE-05: Rail application layer + status dot (src/application/rail.rs)
    * Note: rail.rs application layer — 4 functions + compute_status_dot; 4 unit tests for status dot logic
- [x] BE-06: Rail API handlers + router registration (src/api/rail.rs)
    * Note: 7 rail endpoints registered; smoke tests passed
- [x] BE-07: Extend POST /events with optional rail context
    * Note: src/domain/event.rs + src/application/events.rs extended; tests/rail_context_test.rs — 3 integration tests pass (valid ID, no ID, invalid 422)
- [x] FE-01: Dashboard rail context page
    * Files: templates/rail_services.html, templates/rail_stations.html, src/api/rail_dashboard.rs, src/api/mod.rs, src/api/router.rs, templates/layout.html
    * Status dots derived from service.status in handler; 200 on both routes; NL-001 and Euston verified in responses
- [x] MO-01: Mobile Rail tab + ApiService rail methods + model
    * Files: mobile/lib/models/rail_service_model.dart (new), mobile/lib/screens/rail_context_screen.dart (new), mobile/lib/services/api_service.dart (listRailServices added), mobile/lib/main.dart (Rail tab index 2), mobile/test/models/rail_service_model_test.dart (new)
    * flutter test: 23 passed; flutter analyze: no issues; flutter build web: ✓

## Notes
# Sprint 8 Progress — Mobile UX Polish & Operational Feed Clarity

**Branch**: `feat/mobile-ux-polish`
**Phase**: PHASE 1 — MVP Build

---

## Tasks

### Mobile
- [x] MO-01: Apply operational theme to MaterialApp
    * Note: replaced ColorScheme.fromSeed with ColorScheme.light(navy primary, amber secondary)
- [x] MO-02: Polish Report Event category cards
    * Note: larger icons (36), strong selected border+fill, removed Selected label text
- [x] MO-03: Add loading state to Submit button
    * Note: CircularProgressIndicator.adaptive shown while _isSubmitting; test 5 verifies spinner present
- [x] MO-04: Polish Recent Events list
    * Note: Card layout, _statusBadge with colour-coded Container, improved empty state (Icons.inbox_outlined)
- [x] MO-05: Add pull-to-refresh on Recent Events
    * Note: _refresh() resets _eventsFuture; ListView wrapped in RefreshIndicator

### Dashboard
- [x] FE-01: Show title first in dashboard event list
    * Note: event_list.html — if title present, show title primary + event_type secondary; else event_type only
- [x] FE-02: Hide disabled Acknowledge button on detail page
    * Note: events_detail.html — only render Acknowledge for Created/Delivered; hidden for all other statuses

---

## Gates
- [x] `flutter test` all pass — 21/21
- [x] `cargo test` all pass — 21/21
- [x] `cargo fmt` clean
- [x] `cargo clippy` clean
- [ ] Manual smoke test (Chrome + dashboard)
- [x] `ralph/` NOT committed
