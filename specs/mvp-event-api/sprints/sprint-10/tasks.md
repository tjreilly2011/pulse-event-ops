# Sprint 10 Tasks — Rail Context UI: Service/Station Awareness

**Branch:** feat/rail-context-ui-awareness
**Phase:** PHASE 2 — Rail MVP Layer

---

## [BE-01] Transactional event + rail-context creation consistency fix

### Source
Wishlist + architecture fix requirement: no orphaned intent for event/context association.

### Context
Current flow can insert event before rail ID validation. This must be fixed for deterministic/auditable behavior.

### Files
- MODIFY: `src/application/events.rs`
- MODIFY: `src/infrastructure/event_repo.rs` (only if transaction helper needed)
- MODIFY: `src/api/events.rs` (only if error mapping needs adjustment)
- MODIFY: `tests/rail_context_test.rs`

### Test Strategy
1. Integration test: invalid rail_service_id returns 422 and does not persist event row.
2. Integration test: valid rail_service_id persists event + rail_event_context atomically.
3. Regression: `tests/gate11_mobile_api.py` still passes.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- None

---

## [BE-02] Service and station embedded context API expansion

### Source
Wishlist API preference: embedded context endpoints for fewer round trips.

### Context
Need service/station context payloads including entity details, status summary, staff summary, related events.

### Files
- MODIFY: `src/domain/rail.rs`
- MODIFY: `src/infrastructure/rail_repo.rs`
- MODIFY: `src/application/rail.rs`
- MODIFY: `src/api/rail.rs`
- MODIFY: `src/api/router.rs` (if route addition needed)
- MODIFY: `tests/rail_context_test.rs`

### Test Strategy
1. Add tests for `GET /rail/services/:id/context` related event inclusion.
2. Add tests for `GET /rail/stations/:id/context` payload structure + 404 behavior.
3. Verify status summary and staff summary fields are present and consistent.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-01]

---

## [BE-03] Deterministic station status-dot logic in application layer

### Source
Confirmed station rule set + no duplication rule.

### Context
Station status must follow deterministic green/amber/red logic using active events + station staff presence.

### Files
- MODIFY: `src/application/rail.rs`
- MODIFY: `src/infrastructure/rail_repo.rs`
- MODIFY: `src/domain/rail.rs` (if station status DTO changes)
- MODIFY: `tests/rail_context_test.rs`

### Test Strategy
1. Unit tests for station status cases:
   - green: no active + staff present
   - amber: non-critical active or unknown staff
   - red: critical active or zero staff for seeded station
2. Integration test for station context endpoint status output.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]

---

## [BE-04] Dashboard handler alignment to application status logic

### Source
Architecture fix requirement: no heuristic status mapping in dashboard handlers.

### Context
`rail_dashboard` must consume application-layer context/status outputs, not duplicate mapping.

### Files
- MODIFY: `src/api/rail_dashboard.rs`
- MODIFY: `src/application/rail.rs` (if helper exposure needed)
- MODIFY: `tests/rail_context_test.rs` (or add dashboard integration test)

### Test Strategy
1. Handler test: dashboard service list/detail uses app-derived status class.
2. Manual smoke: `/dashboard/rail/services` and detail pages show expected dot colors for seed scenario.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-03]

---

## [MO-01] Rail tab selected-context app state

### Source
Confirmed Option B: Rail tab holds selected service/station context.

### Context
Need shared app state so Rail tab selection drives Report event attachment without adding report picker.

### Files
- MODIFY: `mobile/lib/main.dart`
- MODIFY: `mobile/lib/screens/rail_context_screen.dart`
- CREATE or MODIFY: `mobile/lib/models/rail_context_model.dart` (if needed)
- CREATE or MODIFY: `mobile/lib/services/context_state.dart` (only if truly needed and <150 lines cannot fit existing files)
- MODIFY: `mobile/test/screens/rail_context_screen_test.dart` (or create)

### Test Strategy
1. Widget test: selecting service/station updates shared context state.
2. Widget test: fallback selection resolves first active seeded service and first/current stop when no explicit selection.

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

## [MO-02] Report screen auto-attach selected rail context

### Source
Wishlist: reporting should carry rail_service_id/rail_station_id from selected context, with fallback.

### Context
Keep Report fast and uncluttered; no picker. Attach context from app state/fallback during create event call.

### Files
- MODIFY: `mobile/lib/screens/report_event_screen.dart`
- MODIFY: `mobile/lib/services/api_service.dart`
- MODIFY: `mobile/test/services/api_service_test.dart` (or create)
- MODIFY: `mobile/test/screens/report_event_screen_test.dart` (or create)

### Test Strategy
1. Service test: createEvent sends `rail_service_id` + `rail_station_id` when context exists.
2. Service test: fallback IDs sent when no explicit selection.
3. Integration smoke: create event from app and verify attached context via API.

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
- [MO-01]
- [BE-01]

---

## [MO-03] Rail tab context-aware content blocks

### Source
Wishlist mobile UI: selected service card, station context block, related events, staff summary.

### Context
Rail tab should answer “what is happening on this service/station right now?” with concise operational context.

### Files
- MODIFY: `mobile/lib/screens/rail_context_screen.dart`
- MODIFY: `mobile/lib/services/api_service.dart`
- CREATE or MODIFY: `mobile/lib/models/rail_context_response_model.dart`
- MODIFY: `mobile/test/screens/rail_context_screen_test.dart`

### Test Strategy
1. Widget tests for rendering service card, station block, related events list, staff summary.
2. Empty/error state tests.
3. Manual emulator smoke against seeded data.

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
- [BE-03]
- [MO-01]

---

## [FE-01] Dashboard service detail context page

### Source
Priority order confirmed: dashboard service detail before station detail.

### Context
Add `/dashboard/rail/services/:id` page with service metadata, stops, related events, staff presence, status dot.

### Files
- CREATE: `templates/rail_service_detail.html`
- MODIFY: `src/api/rail_dashboard.rs`
- MODIFY: `src/api/router.rs`
- MODIFY: `templates/rail_services.html` (link rows to detail)
- MODIFY: `tests/rail_context_test.rs` (or dashboard integration test)

### Test Strategy
1. Endpoint returns 200 for seeded service and 404 for unknown.
2. Template contains service code, status indicator, related events section.
3. Manual smoke from dashboard list to detail navigation.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]
- [BE-03]
- [BE-04]

---

## [FE-02] Dashboard station detail context page

### Source
Wishlist dashboard station detail page.

### Context
Add `/dashboard/rail/stations/:id` page with station metadata, related events, staff presence, status dot.

### Files
- CREATE: `templates/rail_station_detail.html`
- MODIFY: `src/api/rail_dashboard.rs`
- MODIFY: `src/api/router.rs`
- MODIFY: `templates/rail_stations.html` (link rows to detail)
- MODIFY: `tests/rail_context_test.rs` (or dashboard integration test)

### Test Strategy
1. Endpoint returns 200 for seeded station and 404 for unknown.
2. Template contains station code/name, status indicator, related events section.
3. Manual smoke from station list to detail navigation.

### Definition of Done
- Implementation matches requirements
- New logic has tests
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]
- [BE-03]
- [BE-04]

---

## [FE-03] Dashboard context summary enhancements on list pages

### Source
Wishlist: services/stations list should show staff availability summary.

### Context
Improve existing list pages with concise staff/event context while keeping simple table layout.

### Files
- MODIFY: `templates/rail_services.html`
- MODIFY: `templates/rail_stations.html`
- MODIFY: `src/api/rail_dashboard.rs`

### Test Strategy
1. Template render check for summary fields.
2. Manual visual validation for seeded rows.

### Definition of Done
- Implementation matches requirements
- New logic has tests (or template assertions where applicable)
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-04]
- [FE-01]
- [FE-02]

---

## [DOC-01] README sprint-10 usage/API update

### Source
Confirmed README scope: usage docs + new API examples + short architecture note.

### Context
Documentation must explain rail context as vertical layer over generic events and how to use new context endpoints/views.

### Files
- MODIFY: `README.md`

### Test Strategy
1. Verify command snippets run locally.
2. Verify endpoint examples match actual routes and sample payload shape.

### Definition of Done
- Implementation matches requirements
- Docs reflect shipped behavior only
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy -- -D warnings`)
- App runs without errors
- API endpoints respond correctly
- Dashboard renders without error
- Mobile endpoints callable
- Logging added

### Dependencies
- [BE-02]
- [FE-01]
- [FE-02]
- [MO-03]

---

## Execution Order (machine-readable)

1. BE-01
2. BE-02
3. BE-03
4. BE-04
5. MO-01
6. MO-02
7. MO-03
8. FE-01
9. FE-02
10. FE-03
11. DOC-01

---

## Scope Guardrails

1. No maps, GPS, chat, push, staffing rosters, or timetable ingestion.
2. No generic grouping engine.
3. Keep modules small; avoid new modules/services when a change fits existing files.
4. Preserve deterministic and auditable behavior.
