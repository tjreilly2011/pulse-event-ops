# Sprint 10 Plan — Rail Context UI: Service/Station Awareness

**Branch:** feat/rail-context-ui-awareness  
**Phase:** PHASE 2 — Rail MVP Layer

---

## Executive Summary

Sprint 10 makes the product rail-aware in day-to-day operation views without overbuilding a control-room system.

We will:
1. Make the mobile Rail tab the source of selected service/station context.
2. Auto-attach selected context to event creation from the mobile Report flow.
3. Add dashboard service/station detail context pages with related events and staff presence.
4. Extend rail context APIs to return embedded context payloads for simple mobile/dashboard consumption.
5. Fix two architectural issues from Sprint 9:
   - transactionally consistent event + rail-context creation
   - status-dot logic single source of truth in application layer (no dashboard heuristic duplication)

---

## Architecture

### Backend (Rust)

#### API Endpoints

Keep existing routes and extend with embedded context responses:

1. `GET /rail/services/:id/context` (extend)
   - service details
   - stops
   - service status dot + summary
   - staff presence summary for service
   - related events for service

2. `GET /rail/stations/:id/context` (new)
   - station details
   - station status dot + summary
   - staff presence summary for station
   - related events for station

No separate `/events` subresources unless implementation remains near-zero overhead.

#### Domain Models

Reuse existing generic + rail domain models; add small response DTOs only where needed:

1. `StationContext` response model (domain rail layer)
2. `RelatedEventSummary` response model (if needed to avoid overfetch)
3. `StatusSummary` string/enum wrapper (optional) for simple UI rendering

Keep generic event core untouched; rail remains a vertical layer via rail context association.

#### Application Layer

Extend `application::rail` as single source of truth for status and context assembly:

1. Service context assembler (existing) enhanced to include related events + staff summary.
2. Station context assembler (new) with deterministic station status logic:
   - green: no active open/critical events + at least one active station staff row
   - amber: active non-critical event OR staff unknown
   - red: active safety/critical event OR zero active staff where station exists in seed
3. Status-dot logic lives in application only; dashboard and API reuse application output.

#### Infrastructure Layer

Extend `rail_repo` queries (no new engine):

1. events by service (existing/extended summary)
2. events by station (new)
3. staff presence by station (new)
4. station existence/seed expectation helper (new simple query)

#### Transactional Consistency Fix (Critical)

Current flow inserts event before rail ID validation, which can produce orphaned intent.

Sprint 10 fix:
1. Validate rail IDs before insert OR execute validation + event insert + rail_context insert within one SQL transaction.
2. Commit only when both event and optional rail context are valid.
3. Preserve existing API behavior (`422` on bad rail IDs).

### Realtime

No new SSE channels required this sprint.

1. Keep `/events/stream` as-is.
2. Context pages rely on request/response reads.
3. If needed later, reuse existing SSE event updates rather than introducing websocket complexity.

### Frontend — Dashboard (HTMX + Askama)

#### Views

1. Existing list pages remain:
   - `/dashboard/rail/services`
   - `/dashboard/rail/stations`

2. Add detail pages:
   - `/dashboard/rail/services/:id`
   - `/dashboard/rail/stations/:id`

#### Components

1. Shared status dot partial/component style reuse.
2. Staff presence summary block.
3. Related events table/list block.

#### Data source rule

Dashboard handlers must consume application-layer context/status outputs only.
No duplicate status mapping in handlers/templates.

### Mobile (Flutter)

#### Context source (confirmed Option B)

1. Rail tab owns selected service/station context in app state.
2. Report screen reads that selected context and auto-attaches it on event create.
3. Fallback when no user selection:
   - first active seeded service
   - first/current station from that service
4. No Report picker in this sprint.

#### Screens / State handling

1. Improve Rail tab content:
   - selected service card
   - station context block
   - related events block
   - staff summary
2. Keep state simple (setState + lifted state in app shell/shared holder), no new state-management package.

### Database / Migrations

No schema migration expected by default.

If query performance requires, allow minimal indexes only:
1. index `rail_event_context(rail_station_id)` if missing
2. optional composite index on active-event lookup paths

Only add migration if proven needed during implementation.

---

## Config Updates

No required env vars.

Optional (only if needed):
1. `RAIL_CONTEXT_FALLBACK_ENABLED=true` (default true in code path)

Prefer hardcoded deterministic MVP behavior over new config surface unless required.

---

## References

### Existing files to modify

Backend:
1. `src/application/events.rs`
2. `src/api/events.rs`
3. `src/application/rail.rs`
4. `src/infrastructure/rail_repo.rs`
5. `src/domain/rail.rs`
6. `src/api/rail.rs`
7. `src/api/rail_dashboard.rs`
8. `src/api/router.rs`
9. `src/api/mod.rs`

Dashboard templates:
1. `templates/rail_services.html`
2. `templates/rail_stations.html`
3. `templates/layout.html`
4. `templates/partials/*` (if adding shared status/event blocks)

Mobile:
1. `mobile/lib/main.dart`
2. `mobile/lib/screens/rail_context_screen.dart`
3. `mobile/lib/screens/report_event_screen.dart`
4. `mobile/lib/services/api_service.dart`
5. `mobile/lib/models/*` (add context models if needed)

Docs:
1. `README.md`

### Reusable modules/patterns

1. `application::rail::compute_status_dot` pattern for deterministic status.
2. Existing event status badges in mobile and dashboard.
3. Existing `/events` create flow and validation/error mapping.
4. Existing Askama template + dashboard handler pattern.
