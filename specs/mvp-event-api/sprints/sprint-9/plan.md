# Sprint 9 Plan — Rail Context Model: Services, Stations, Routes & Staff Presence

**Branch:** `feat/rail-context-model`
**Phase:** PHASE 2 — Rail MVP Layer

---

## Executive Summary

This sprint introduces the minimum rail-specific context layer on top of the existing generic event engine. We add five new tables (`rail_routes`, `rail_stations`, `rail_services`, `rail_service_stops`, `staff_presence`), a `rail_event_context` join table that optionally links events to rail context without modifying the core `events` table, seed data, seven read-only API endpoints, and two dashboard views (service list + station list with status dots). The Flutter mobile app gains a read-only Rail tab showing current services.

The generic `events` table is **unchanged**. Rail IDs are NOT added to `events` directly — they live in `rail_event_context`. `vertical_metadata` JSONB remains for non-queryable vertical extras.

---

## Architecture

### Backend (Rust)

#### New Tables — migration `0003_rail_context.sql`

```sql
rail_routes          — id UUID PK, name TEXT NOT NULL, created_at TIMESTAMPTZ DEFAULT NOW()
rail_stations        — id UUID PK, name TEXT NOT NULL, code TEXT UNIQUE NOT NULL, region TEXT, created_at TIMESTAMPTZ DEFAULT NOW()
rail_services        — id UUID PK, service_code TEXT NOT NULL, route_id UUID REFERENCES rail_routes(id), direction TEXT NOT NULL, scheduled_start_time TIMESTAMPTZ, scheduled_end_time TIMESTAMPTZ, status TEXT NOT NULL DEFAULT 'ON_TIME'
rail_service_stops   — id UUID PK, service_id UUID REFERENCES rail_services(id), station_id UUID REFERENCES rail_stations(id), scheduled_arrival TIMESTAMPTZ, scheduled_departure TIMESTAMPTZ, stop_sequence INT NOT NULL
staff_presence       — id UUID PK, actor_id UUID NOT NULL, role_label TEXT NOT NULL, presence_type TEXT NOT NULL, current_service_id UUID REFERENCES rail_services(id), current_station_id UUID REFERENCES rail_stations(id), status TEXT NOT NULL DEFAULT 'ON_DUTY', last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
rail_event_context   — event_id UUID NOT NULL, rail_service_id UUID REFERENCES rail_services(id), rail_station_id UUID REFERENCES rail_stations(id), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

> `rail_event_context.event_id` has **no FK** to `events` — `events` is a TimescaleDB hypertable (same pattern as existing codebase). IDs are validated at application layer before insert.

#### Seed Data — migration `0004_rail_seed.sql`
- 1 route: "Northern Line"
- 3 stations: Euston (EUS), King's Cross (KGX), Highbury & Islington (HBI)
- 1 service: NL-001, southbound, ON_TIME
- 3 service stops: KGX(1) → EUS(2) → HBI(3)
- 3 staff presence rows: train conductor on NL-001, station staff at EUS, control user (no service/station)

#### New Domain Models — `src/domain/rail.rs`
- `RailRoute { id, name, created_at }`
- `RailStation { id, name, code, region, created_at }`
- `RailService { id, service_code, route_id, direction, scheduled_start_time, scheduled_end_time, status }`
- `RailServiceStop { id, service_id, station_id, scheduled_arrival, scheduled_departure, stop_sequence }`
- `StaffPresence { id, actor_id, role_label, presence_type, current_service_id, current_station_id, status, last_seen_at }`
- `RailEventContext { event_id, rail_service_id, rail_station_id, created_at }`
- `ServiceContext { service: RailService, stops: Vec<RailServiceStop>, staff: Vec<StaffPresence>, status_dot: StatusDot }`
- `StatusDot` enum: `Green | Amber | Red`

#### Status Dot Logic — `src/application/rail.rs`
Deterministic, pure function `compute_status_dot(active_events: &[Event], staff: &[StaffPresence], service_status: &str) -> StatusDot`:
- **Red**: any event with `event_type == "safety_security"` and status in `[CREATED, IN_PROGRESS]`, OR service status `CANCELLED`
- **Amber**: any active event (CREATED/IN_PROGRESS) without safety type, OR zero ON_DUTY staff
- **Green**: no active events AND at least one ON_DUTY staff

#### New Infrastructure — `src/infrastructure/rail_repo.rs`
Plain async functions on `&PgPool`:
- `list_services(pool) -> Vec<RailService>`
- `get_service(pool, id) -> Option<RailService>`
- `list_service_stops(pool, service_id) -> Vec<RailServiceStop>`
- `list_stations(pool) -> Vec<RailStation>`
- `get_station(pool, id) -> Option<RailStation>`
- `list_presence(pool) -> Vec<StaffPresence>`
- `insert_rail_event_context(pool, event_id, service_id, station_id)`
- `validate_service_exists(pool, id) -> bool`
- `validate_station_exists(pool, id) -> bool`
- `get_active_events_for_service(pool, service_id) -> Vec<Event>` (for status dot)
- `get_staff_for_service(pool, service_id) -> Vec<StaffPresence>` (for status dot)

#### New Application — `src/application/rail.rs`
- `list_services(pool) -> Result<Vec<RailService>, sqlx::Error>`
- `get_service_context(pool, id) -> Result<Option<ServiceContext>, sqlx::Error>`
- `list_stations(pool) -> Result<Vec<RailStation>, sqlx::Error>`
- `list_presence(pool) -> Result<Vec<StaffPresence>, sqlx::Error>`

#### New API Handlers — `src/api/rail.rs`
```
GET  /rail/services              → 200 Vec<RailService>
GET  /rail/services/:id          → 200 RailService | 404
GET  /rail/services/:id/stops    → 200 Vec<RailServiceStop>
GET  /rail/services/:id/context  → 200 ServiceContext | 404
GET  /rail/stations              → 200 Vec<RailStation>
GET  /rail/stations/:id          → 200 RailStation | 404
GET  /rail/presence              → 200 Vec<StaffPresence>
```

#### Modified: `POST /events`
`CreateEventRequest` in `src/domain/event.rs` gains:
```rust
pub rail_service_id: Option<Uuid>,
pub rail_station_id: Option<Uuid>,
```
`application::events::create()` — after inserting the event, if either ID is present, validate each exists (return 422 if not), then call `rail_repo::insert_rail_event_context` inside the same logical flow (not the same DB transaction — hypertable constraint).

#### Modified Files
- `src/domain/event.rs` — extend `CreateEventRequest`
- `src/domain/mod.rs` — `pub mod rail`
- `src/application/events.rs` — call rail context insert when IDs provided
- `src/application/mod.rs` — `pub mod rail`
- `src/infrastructure/mod.rs` — `pub mod rail_repo`
- `src/api/router.rs` — register `/rail/*` routes

### Realtime
No SSE changes. Rail data is read-only reference data.

---

### Frontend — Dashboard (HTMX)

#### New Templates
- `templates/rail_services.html` — full page, extends `layout.html`, lists services with status dot
- `templates/rail_stations.html` — full page, extends `layout.html`, lists stations with status dot

#### New Routes
- `GET /dashboard/rail/services` → renders `rail_services.html`
- `GET /dashboard/rail/stations` → renders `rail_stations.html`

#### Status Dot Component
Inline coloured circle: green (`#22c55e`), amber (`#f59e0b`), red (`#ef4444`) — rendered as a `<span class="inline-block w-3 h-3 rounded-full">` with bg colour via DaisyUI/Tailwind.

#### Modified Templates
- `templates/layout.html` — add "Rail" nav link pointing to `/dashboard/rail/services`

#### New Dashboard Handler File
- `src/api/rail_dashboard.rs` — handlers for the two dashboard views (separate from JSON API handlers in `rail.rs`)

---

### Mobile (Flutter)

#### New Screen: `lib/screens/rail_context_screen.dart`
- Fetches `GET /rail/services` via `ApiService.listRailServices()`
- Renders `ListView` of service cards: service code, direction, status dot badge
- Pull-to-refresh (same `RefreshIndicator` pattern as `RecentEventsScreen`)
- Empty state with `Icons.train` icon

#### New Model: `lib/models/rail_service_model.dart`
```dart
class RailServiceModel {
  final String id;
  final String serviceCode;
  final String? routeId;
  final String direction;
  final String status;
}
```

#### New API Method: `ApiService.listRailServices()`
Returns `Future<List<RailServiceModel>>` from `GET /rail/services`.

#### Modified: `lib/main.dart` — AppShell
Add third tab to `BottomNavigationBar`: "Rail" / `Icons.train`.
Add `RailContextScreen` to `_screens` list.

#### Modified: `lib/services/api_service.dart`
Add `listRailServices()` method.

#### Note on CreateEventRequest
`rail_service_id` / `rail_station_id` fields will be added to the Flutter model this sprint but the report screen UI does not expose a picker — that is Sprint 10 scope.

---

## Config Updates
None. No new environment variables.

---

## References

| Pattern to reuse | Source |
|---|---|
| Repo function style | `src/infrastructure/event_repo.rs` |
| Application layer style | `src/application/events.rs` |
| Axum handler style | `src/api/events.rs` |
| Status badge Flutter widget | `mobile/lib/screens/recent_events_screen.dart` `_statusBadge` |
| Pull-to-refresh Flutter | `mobile/lib/screens/recent_events_screen.dart` `_refresh` |
| Dashboard list template | `templates/partials/event_list.html` |
| Dashboard layout | `templates/layout.html` |
# Sprint 8 Plan — Mobile UX Polish & Operational Feed Clarity

## Executive Summary

Sprint 8 polishes the existing Flutter mobile app and HTMX dashboard templates to make the product feel credible, fast, and trustworthy for real frontline use. No backend schema changes. No new features. No new packages. All work is confined to `mobile/lib/`, `mobile/test/`, and `templates/`.

The sprint delivers:
- A professionally styled Flutter app with a strong dark-navy operational theme (light background, dark primary)
- Larger, clearer category cards with a strong selected state
- Explicit loading, success, and error states on the Report screen
- A polished Recent Events list: coloured status badges, location chip, pull-to-refresh
- Low-cost dashboard feed polish: title-first event list, hidden disabled Acknowledge button
- All existing 17 Flutter tests still passing; new tests added for changed behaviour

---

## Architecture

### Backend (Rust)
**No changes.** The existing API contract fully satisfies the UI requirements:
- `POST /events` → 201 + full event JSON
- `GET /events` → 200 + array sorted newest-first
- `GET /events/:id` → 200 + single event
- `PATCH /events/:id/acknowledge` → redirect

No new endpoints. No migrations. No Rust file changes.

### Realtime
SSE feed unchanged. `GET /events/stream` unmodified.

### Dashboard (HTMX + Askama templates)

**`templates/partials/event_list.html`**
- Show `title` (if set) as primary heading instead of `event_type`
- Show `event_type` as secondary sub-label
- Keep status badge, priority badge, location, timestamp

**`templates/events_detail.html`**
- Remove the `btn-disabled` acknowledge button for non-actionable statuses
- Only render the Acknowledge button when status is `Created` or `Delivered`
- For all other statuses: render nothing (button hidden entirely)

### Mobile (Flutter)

**`mobile/lib/main.dart`**
- Replace `ColorScheme.fromSeed(Colors.blue)` with a hand-tuned `ColorScheme.light` using:
  - `primary: Color(0xFF0A2342)` (deep navy)
  - `onPrimary: Colors.white`
  - `secondary: Color(0xFFFFB300)` (amber — warning/accent only)
  - `surface: Color(0xFFF5F7FA)` (light grey-white)
  - `error: Color(0xFFD32F2F)`
- Keep `useMaterial3: true`

**`mobile/lib/screens/report_event_screen.dart`**
- Category cards: icon size 36, label bold, `childAspectRatio: 1.1`
- Selected state: navy border (3px) + light navy tint (`primary.withOpacity(0.08)`) + navy icon/label colour
- Remove `Text('Selected: $_selectedLabel')` — redundant with strong selected state
- Submit button: show `CircularProgressIndicator.adaptive(strokeWidth: 2)` inside button while `_isSubmitting`

**`mobile/lib/screens/recent_events_screen.dart`**
- Wrap `ListView.builder` in `RefreshIndicator`
- Status badge: colour-coded `Container` with rounded corners
  - `CREATED` → navy background, white text
  - `ACKNOWLEDGED` → amber background, dark text
  - `IN_PROGRESS` → orange background, dark text
  - `RESOLVED` → green background, white text
  - `CANCELLED` → grey background, white text
- Each row uses a `Card` with subtle shadow instead of bare `ListTile`
- Improved empty state: `Icon(Icons.inbox_outlined)` + "No events yet"

### Config Updates
None required.

### State Handling
`setState` only. No state management framework introduced.

---

## References

### Files to modify
| File | Change |
|---|---|
| `mobile/lib/main.dart` | Theme colour scheme |
| `mobile/lib/screens/report_event_screen.dart` | Card polish, loading state, layout |
| `mobile/lib/screens/recent_events_screen.dart` | Status badges, refresh, card layout |
| `templates/partials/event_list.html` | Title-first rendering |
| `templates/events_detail.html` | Hide disabled acknowledge button |

### Files to update (tests)
| File | Change |
|---|---|
| `mobile/test/screens/report_event_screen_test.dart` | Update for loading spinner, removed selected-label text |
| `mobile/test/screens/recent_events_screen_test.dart` | Update for new status badge widget, card layout, refresh |
| `mobile/test/widget_test.dart` | Smoke — verify AppBar title still present |

### Reusable / unchanged
- `mobile/lib/models/event_model.dart` — no changes
- `mobile/lib/services/api_service.dart` — no changes
- `mobile/lib/constants.dart` — no changes
- All `src/` Rust files — no changes
- All migrations — no changes
