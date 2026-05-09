# Sprint 10 Progress — Rail Context UI: Service/Station Awareness

**Branch:** feat/rail-context-ui-awareness

## Tasks

- [x] BE-01: Transactional event + rail-context creation consistency fix
    * Note: src/application/events.rs — validate rail IDs before insert, wrap event+context inserts in sqlx transaction; event_repo.rs — added insert_in_tx; rail_repo.rs — added insert_rail_event_context_in_tx; tests/rail_context_test.rs — added orphan-prevention test (4/4 pass, 16/16 gate11)
- [x] BE-02: Service and station embedded context API expansion
    * Note: domain/rail.rs — StationContext struct; rail_repo.rs — get_active_events_for_station + get_staff_for_station; application/rail.rs — get_station_context with compute_status_dot; api/rail.rs — get_station_context handler; router.rs — /rail/stations/:id/context; tests — station_context 200+404 tests (6/6 pass)
- [x] BE-03: Deterministic station status-dot logic in application layer
    * Note: src/application/rail.rs — added 4 station-specific compute_status_dot unit tests; verified station context uses station-scoped staff/events; gates passed (cargo fmt, cargo clippy -- -D warnings, cargo test, /health 200, gate11 16/16)
- [x] BE-04: Dashboard handler alignment to application status logic
    * Note: src/api/rail_dashboard.rs now sources status dots via application::rail::get_service_context/get_station_context (heuristic mapper removed); templates/rail_stations.html now renders status dot column; gates passed (fmt, clippy, cargo test, dashboard routes 200)
- [x] MO-01: Rail tab selected-context app state
    * Note: shared SelectedRailContext added at app-shell level and wired into Rail + Report tabs; Rail selection updates shared state with explicit choice and fallback (first active service, then current stop or first stop). Files: mobile/lib/main.dart, mobile/lib/screens/rail_context_screen.dart, mobile/lib/state/selected_rail_context.dart, mobile/lib/models/rail_station_model.dart, mobile/lib/models/rail_service_stop_model.dart, mobile/lib/services/api_service.dart, mobile/test/screens/rail_context_screen_test.dart, mobile/lib/screens/report_event_screen.dart. Gates: flutter analyze, flutter test, cargo test, python3 tests/gate11_mobile_api.py all passed.
- [x] MO-02: Report screen auto-attach selected rail context
    * Note: report submit now forwards shared selected/fallback `rail_service_id` and `rail_station_id` via ApiService.createEvent payload (no new report picker UI). Tests added for payload inclusion + fallback-path attachment from shared context. Files: mobile/lib/screens/report_event_screen.dart, mobile/lib/services/api_service.dart, mobile/test/services/api_service_test.dart, mobile/test/screens/report_event_screen_test.dart, mobile/test/widget_test.dart. Gates: flutter pub get, flutter analyze, flutter test, cargo test, python3 tests/gate11_mobile_api.py all passed.
- [x] MO-03: Rail tab context-aware content blocks
    * Note: Rail tab now renders selected service card (status/direction/code), station context block, related events, and staff summary from `/rail/services/:id/context` + `/rail/stations/:id/context`, reusing MO-01 shared selected context; added robust context empty/error states and widget coverage for content blocks + empty/error paths. Files: mobile/lib/screens/rail_context_screen.dart, mobile/lib/services/api_service.dart, mobile/lib/models/rail_context_response_model.dart, mobile/test/screens/rail_context_screen_test.dart. Gates: flutter pub get, flutter analyze, flutter test, cargo test, python3 tests/gate11_mobile_api.py passed.
- [x] FE-01: Dashboard service detail context page
    * Note: added `/dashboard/rail/services/:id` with Askama template sections for service metadata, status dot (application-layer context), stops, related events, and staff presence summary; linked service list rows to detail; added integration tests for 200 known, 404 unknown, and content assertions (service code/status/related events).
- [x] FE-02: Dashboard station detail context page
    * Note: added `/dashboard/rail/stations/:id` with Askama station detail template (metadata, application-layer status dot, related events, staff presence summary); linked station rows from `/dashboard/rail/stations`; added integration tests for 200 known, 404 unknown, and key section/content assertions.
- [x] FE-03: Dashboard context summary enhancements on list pages
    * Note: services/stations list pages now include concise Staff Availability and Related Events summary columns sourced from application-layer service/station context in `rail_dashboard`; templates preserve existing detail links and render `-` when staff values are empty; integration tests now assert summary headers and summary values are present on both list responses.
- [x] DOC-01: README sprint-10 usage/API update
    * Note: updated README with sprint-10 rail API/context endpoints, dashboard detail routes, and a short architecture note describing rail context as a vertical layer over generic events.

## Notes

<!-- Sub-agent notes appended below as tasks complete -->
- [x] INIT: Sprint 10 checklist initialized
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
