# Sprint 11 Plan - Realistic Rail Route Seed Data & Route Timeline UI

**Branch:** feat/realistic-rail-seed-data  
**Phase:** PHASE 2 — Rail MVP Layer

---

## Executive Summary

Sprint 11 replaces the artificial Northern Line seed with a coherent realistic rail dataset that feels like a believable operational environment.

We will:
1. Replace the old Northern Line demo seed entirely with curated realistic routes.
2. Seed only the two example services:
   - Westport -> Dublin Heuston
   - London Waterloo -> Kingston
3. Keep the rail context layer deterministic and auditable while exposing ordered stop timelines and coherent event attachment.
4. Update the mobile Rail tab and dashboard to show origin, destination, selected/current station, and route timelines.
5. Document that the dataset is seed-driven and that GTFS / NaPTAN import is deferred until a later sprint.
---

## Architecture

### Backend (Rust)

#### API Endpoints

Keep the current rail API and make the stop/timeline responses more useful for the UI:

1. `GET /rail/services/:id/stops`
   - ordered stop list
   - station name and station code for each stop
   - scheduled arrival and departure
   - stable stop sequence ordering

2. `GET /rail/services/:id/context`
   - service summary payload used by dashboard and mobile
   - route/timeline details derived from the stop list where practical

3. `GET /rail/stations/:id/context`
   - station summary payload
   - related active events
   - staff presence summary
   - optionally the services stopping there if this remains cheap

#### Domain Models

Reuse the current rail domain and add only small timeline DTOs if needed:

1. `RailRoute`
2. `RailStation`
3. `RailService`
4. `RailServiceStop`
5. Optional `RailServiceStopTimelineItem` DTO if the stop endpoint needs station name/code snapshots

Keep the generic event core unchanged.

#### Application Layer

Extend `application::rail` as the single source of truth for route/timeline assembly:

1. Service context assembler (existing) should derive origin and destination from ordered stops and keep event attachment consistent.
2. Service stop timeline assembler should return ordered stop records for dashboard/mobile.
3. Station context assembler remains deterministic and should continue to reuse the existing status logic.
4. Keep all timeline derivation deterministic and testable.

#### Infrastructure Layer

Extend `rail_repo` queries without introducing a new engine:

1. ordered stops by service (existing path, extended if needed)
2. station lookup by code/name for timeline display
3. route/service seed lookup helpers only if required for tests or assembly

#### Seed Data

Replace the old Northern Line demo seed entirely.

Sprint 11 should establish the first coherent realistic rail dataset for the MVP:

1. Westport -> Dublin Heuston
2. London Waterloo -> Kingston

Remove or replace the old Northern Line seed migration contents so the active dataset is coherent and not mixed with demo data.

Use stable demo codes where official station identifiers are uncertain, and document clearly that they are seed/demo codes rather than guaranteed CRS/GTFS/NaPTAN identifiers.

### Realtime

No new realtime transport is required.

1. Keep `/events/stream` as-is.
2. Route/timeline views are request/response driven.

### Frontend — Dashboard (HTMX + Askama)

#### Views

1. Existing list pages remain:
   - `/dashboard/rail/services`
   - `/dashboard/rail/stations`

2. Existing detail pages should show richer route/timeline data:
   - `/dashboard/rail/services/:id`
   - `/dashboard/rail/stations/:id`

#### Components

1. Origin -> destination summary.
2. Ordered stop timeline table/list.
3. Staff presence summary block.
4. Related events table/list block.

#### Data source rule

Dashboard handlers must consume application-layer outputs only.
No duplicate status or timeline derivation in handlers/templates.

### Mobile (Flutter)

#### Context source

1. Rail tab keeps selected service/station context.
2. Rail tab shows origin, destination, selected/current station, and the next few stops by default.
3. Full stop list is hidden behind an expandable "Show all stops" section.
4. Keep the interaction simple for frontline use.

#### Screens / State handling

1. Improve Rail tab content:
   - route/service card
   - origin -> destination
   - selected/current station
   - next few stops
   - expandable full stop list
2. Keep state simple (setState + lifted state in app shell/shared holder), no new state-management package.

### Database / Migrations

No schema migration is required by default, but a new seed migration is expected.

1. Replace the old Northern Line seed migration contents.
2. Seed the realistic routes, services, stations, and stops deterministically.
3. Keep repeated test setup idempotent if practical.

### Config Updates

No required env vars.

Prefer hardcoded deterministic MVP behavior over new config surface unless required.

### References

#### Existing files to modify

Backend:
1. `migrations/0004_rail_seed.sql`
2. `src/application/rail.rs`
3. `src/infrastructure/rail_repo.rs`
4. `src/domain/rail.rs`
5. `src/api/rail.rs`
6. `src/api/rail_dashboard.rs`
7. `src/api/router.rs`
8. `tests/rail_context_test.rs`

Dashboard templates:
1. `templates/rail_services.html`
2. `templates/rail_service_detail.html`
3. `templates/rail_stations.html`
4. `templates/rail_station_detail.html`

Mobile:
1. `mobile/lib/main.dart`
2. `mobile/lib/screens/rail_context_screen.dart`
3. `mobile/lib/services/api_service.dart`
4. `mobile/lib/models/rail_service_stop_model.dart`
5. `mobile/test/screens/rail_context_screen_test.dart`

Docs:
1. `README.md`

#### Reusable modules/patterns

1. `application::rail::compute_status_dot` pattern for deterministic status handling.
2. Existing Askama dashboard handlers and templates.
3. Existing Flutter Rail tab selected-context flow.
4. Existing `list_service_stops` infrastructure path as the basis for ordered timeline data.

