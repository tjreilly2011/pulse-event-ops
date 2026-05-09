# Sprint 9 Tasks — Rail Context Model

**Branch:** `feat/rail-context-model`

---

## Tasks

### BE-01 — Rail context migration (0003_rail_context.sql)

**Goal:** Create all six rail tables (rail_routes, rail_stations, rail_services, rail_service_stops, staff_presence, rail_event_context) with correct types, indexes, and FK constraints. Note: `rail_event_context.event_id` has no FK to `events` (hypertable constraint — validate at app layer).

**Files:**
- CREATE: `migrations/0003_rail_context.sql`

**Acceptance:**
- `cargo sqlx migrate run` succeeds against Docker Postgres (port 5433)
- All six tables visible in `psql -c "\dt"`

**Dependencies:** none

---

### BE-02 — Seed data migration (0004_rail_seed.sql)

**Goal:** Insert seed data: 1 route (Northern Line), 3 stations (EUS/KGX/HBI), 1 service (NL-001, southbound, ON_TIME), 3 service stops (KGX→EUS→HBI stop_sequence 1/2/3), 3 staff presence rows (conductor on NL-001, station staff at EUS, control user with no service/station).

**Files:**
- CREATE: `migrations/0004_rail_seed.sql`

**Acceptance:**
- `SELECT COUNT(*) FROM rail_services;` → 1
- `SELECT COUNT(*) FROM rail_service_stops;` → 3
- `SELECT COUNT(*) FROM staff_presence;` → 3

**Dependencies:** BE-01

---

### BE-03 — Rail domain models (src/domain/rail.rs)

**Goal:** Define all Rust domain structs with `sqlx::FromRow`, `serde::Serialize/Deserialize`. Structs: `RailRoute`, `RailStation`, `RailService`, `RailServiceStop`, `StaffPresence`, `RailEventContext`, `ServiceContext`, `StatusDot` enum (Green/Amber/Red).

**Files:**
- CREATE: `src/domain/rail.rs`
- MODIFY: `src/domain/mod.rs` — add `pub mod rail;`

**Acceptance:**
- `cargo build` passes with no new warnings

**Dependencies:** BE-01

---

### BE-04 — Rail infrastructure layer (src/infrastructure/rail_repo.rs)

**Goal:** Plain async functions on `&PgPool`. Functions: `list_services`, `get_service`, `list_service_stops`, `list_stations`, `get_station`, `list_presence`, `insert_rail_event_context`, `validate_service_exists`, `validate_station_exists`, `get_active_events_for_service`, `get_staff_for_service`.

**Files:**
- CREATE: `src/infrastructure/rail_repo.rs`
- MODIFY: `src/infrastructure/mod.rs` — add `pub mod rail_repo;`

**Acceptance:**
- `cargo build` passes
- `get_service` returns `Some` for seed service UUID

**Dependencies:** BE-01, BE-03

---

### BE-05 — Rail application layer + status dot (src/application/rail.rs)

**Goal:** Application functions: `list_services`, `get_service_context` (builds `ServiceContext` with `StatusDot`), `list_stations`, `list_presence`. Status dot logic: Red = safety_security active event OR CANCELLED; Amber = any active event OR zero ON_DUTY staff; Green = no active events AND ≥1 ON_DUTY staff.

**Files:**
- CREATE: `src/application/rail.rs`
- MODIFY: `src/application/mod.rs` — add `pub mod rail;`

**Acceptance:**
- `cargo build` passes
- `get_service_context` for seed service returns `StatusDot::Green` (no active events, 1 ON_DUTY conductor)

**Dependencies:** BE-04

---

### BE-06 — Rail API handlers + router registration (src/api/rail.rs)

**Goal:** Axum handlers for all seven `/rail/` endpoints. Return `Json(...)` or `StatusCode::NOT_FOUND`. Register routes in `src/api/router.rs`.

**Files:**
- CREATE: `src/api/rail.rs`
- MODIFY: `src/api/mod.rs` — add `pub mod rail;`
- MODIFY: `src/api/router.rs` — add all seven `/rail/*` routes

**Acceptance:**
- `GET /rail/services` → 200 with array containing seed service
- `GET /rail/services/:seed_id/context` → 200 with `status_dot: "Green"`
- `GET /rail/stations` → 200 with three seed stations
- `GET /rail/services/nonexistent-uuid/context` → 404

**Dependencies:** BE-05

---

### BE-07 — Extend POST /events with optional rail context

**Goal:** Add `rail_service_id: Option<Uuid>` and `rail_station_id: Option<Uuid>` to `CreateEventRequest`. In `application::events::create()`, after the event insert: if IDs present, validate each exists (422 if not), then call `rail_repo::insert_rail_event_context`. Return the created event (no new fields in response — context is queryable via separate endpoint).

**Files:**
- MODIFY: `src/domain/event.rs` — extend `CreateEventRequest`
- MODIFY: `src/application/events.rs` — call rail context insert

**Acceptance:**
- `POST /events` with valid `rail_service_id` → 201, row in `rail_event_context`
- `POST /events` without rail IDs → 201, no row in `rail_event_context` (unchanged)
- `POST /events` with invalid `rail_service_id` → 422

**Dependencies:** BE-01, BE-03, BE-04

---

### FE-01 — Dashboard rail context page (HTMX)

**Goal:** Two new dashboard pages: service list (`GET /dashboard/rail/services`) and station list (`GET /dashboard/rail/stations`). Each renders status dot using inline Tailwind `bg-green-500`/`bg-amber-500`/`bg-red-500` rounded-full span. Add "Rail" link to `templates/layout.html` nav. New handler file `src/api/rail_dashboard.rs`.

**Files:**
- CREATE: `templates/rail_services.html`
- CREATE: `templates/rail_stations.html`
- CREATE: `src/api/rail_dashboard.rs`
- MODIFY: `src/api/mod.rs` — add `pub mod rail_dashboard;`
- MODIFY: `src/api/router.rs` — add two `/dashboard/rail/*` routes
- MODIFY: `templates/layout.html` — add Rail nav link

**Acceptance:**
- `GET /dashboard/rail/services` → 200 HTML containing seed service code "NL-001"
- `GET /dashboard/rail/stations` → 200 HTML containing "Euston"
- Green status dot visible for NL-001

**Dependencies:** BE-06

---

### MO-01 — Mobile: Rail tab + ApiService rail methods + model

**Goal:**
1. Create `lib/models/rail_service_model.dart` with `RailServiceModel { id, serviceCode, routeId, direction, status }` and `fromJson` factory.
2. Add `listRailServices()` to `lib/services/api_service.dart`.
3. Create `lib/screens/rail_context_screen.dart` — ListView of service cards with status dot badge, pull-to-refresh, empty state.
4. Add "Rail" tab (`Icons.train`) to `AppShell` in `lib/main.dart`.

**Files:**
- CREATE: `mobile/lib/models/rail_service_model.dart`
- CREATE: `mobile/lib/screens/rail_context_screen.dart`
- MODIFY: `mobile/lib/services/api_service.dart`
- MODIFY: `mobile/lib/main.dart`

**Acceptance:**
- App launches with three bottom-nav tabs (Report, Recent, Rail)
- Rail tab shows NL-001 service card with green dot against live backend
- Pull-to-refresh triggers re-fetch

**Dependencies:** BE-06

---

## Dependency Order

```
BE-01
├── BE-02
├── BE-03
│   ├── BE-04
│   │   ├── BE-05
│   │   │   └── BE-06
│   │   │       ├── FE-01
│   │   │       └── MO-01
│   │   └── BE-07 (also needs BE-01, BE-03)
```

**Recommended implementation order:** BE-01 → BE-02 → BE-03 → BE-04 → BE-05 → BE-06 → BE-07 → FE-01 → MO-01

---

## Done Criteria

- [ ] `cargo build` passes with zero warnings
- [ ] `cargo test` passes
- [ ] `sqlx migrate run` applies both new migrations cleanly
- [ ] All 7 `/rail/*` API endpoints return correct data from seed
- [ ] `POST /events` with rail IDs creates `rail_event_context` row
- [ ] Dashboard rail pages render with status dots
- [ ] Flutter Rail tab shows seed services against live backend
- [ ] `tests/gate11_mobile_api.py` still 16/16 (regression)
# Sprint 8 Tasks — Mobile UX Polish & Operational Feed Clarity

## Task Prefix Key
- [MO-XX] Mobile (Flutter)
- [FE-XX] Frontend Dashboard (HTMX templates)

---

## [MO-01] Apply operational theme to MaterialApp

### Source
Wishlist: "Use a consistent Material theme" / "feel professional and operational"

### Context
Current theme uses `ColorScheme.fromSeed(Colors.blue)` which produces a consumer-grade blue palette. Replace with a hand-tuned light theme using deep navy primary and amber accent. This is the single change that uplifts the entire app's visual register.

### Files
- `mobile/lib/main.dart`

### Implementation
Replace the `theme:` block in `PulseOpsApp.build`:
```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0A2342),
    onPrimary: Colors.white,
    secondary: Color(0xFFFFB300),
    onSecondary: Colors.black,
    surface: Color(0xFFF5F7FA),
    onSurface: Color(0xFF1A1A2E),
    error: Color(0xFFD32F2F),
    onError: Colors.white,
  ),
),
```

### Test Strategy
- `widget_test.dart`: smoke test still finds "Pulse Operations" AppBar title
- Visual: `flutter run -d chrome` confirms navy AppBar, light surface

### Dependencies
None

---

## [MO-02] Polish Report Event category cards

### Source
Wishlist: "larger icons, clearer labels, stronger selected state, consistent spacing"

### Context
Current cards use default `Icon()` (24px), plain `Text(label)`, and only a `primaryContainer` background fill for selected state. The selected state is weak — no border, no colour on icon/label. Cards need to feel tappable and show clear selection.

### Files
- `mobile/lib/screens/report_event_screen.dart`

### Implementation
- Set `crossAxisSpacing: 12`, `mainAxisSpacing: 12`, `childAspectRatio: 1.1`
- Wrap card in `AnimatedContainer` or plain `Container` with:
  - selected: border `Border.all(color: primary, width: 3)` + fill `primary.withOpacity(0.08)`
  - unselected: border `Border.all(color: Colors.grey.shade300, width: 1)`
- Icon: `Icon(icon, size: 36, color: isSelected ? primary : Colors.grey.shade600)`
- Label: `Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? primary : Colors.grey.shade800))`
- Remove `Text('Selected: $_selectedLabel')` line — selection is now self-evident from card state
- Keep existing `_selectedType` / `_selectedLabel` state logic unchanged

### Test Strategy
- `report_event_screen_test.dart`:
  - existing "button disabled initially" test still passes
  - existing "enables after category tap" test still passes
  - existing "form resets on success" test still passes
  - update: remove assertion on `'Selected: Delay'` text if present
  - existing "snackbar shows Event sent" still passes

### Dependencies
MO-01 (theme must be in place so `primary` colour resolves correctly in tests)

---

## [MO-03] Add loading state to Submit button

### Source
Wishlist: "Add loading, success, and error states"

### Context
Current submit button shows `Text('Send Event')` and simply disables via `onPressed: null` while submitting. No visual loading indicator. Under slow network the button looks frozen. Replace button content with a spinner during submission.

### Files
- `mobile/lib/screens/report_event_screen.dart`

### Implementation
Change the button `child:` to:
```dart
child: _isSubmitting
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      )
    : const Text('Send Event'),
```
Keep `onPressed: (_selectedType == null || _isSubmitting) ? null : _onSubmit` unchanged.

### Test Strategy
- `report_event_screen_test.dart`:
  - add test: after tapping a category and tapping Submit on a fake slow service, a `CircularProgressIndicator` is present
  - existing success/failure snackbar tests still pass (fake service resolves immediately so spinner is transient)

### Dependencies
MO-02

---

## [MO-04] Polish Recent Events list

### Source
Wishlist: "show title first, show status badge clearly, show destination/location, show timestamp in readable format, show newest first"

### Context
Current list uses bare `ListTile` with a plain `Chip` for status. No colour on status. Location shown in subtitle mixed with timestamp. Visual hierarchy is flat — hard to scan quickly. Needs Card-based rows with clear status colour, location clearly labelled, and better typographic hierarchy.

### Files
- `mobile/lib/screens/recent_events_screen.dart`

### Implementation
- Replace bare `ListTile` with a `Card(margin: ..., child: Padding(...))` containing a `Column`:
  - Row: `Text(event.displayTitle, style: titleMedium bold)` + spacer + `_statusBadge(event.status)`
  - `Text('#${event.destinationLocationId}', style: bodySmall, color: grey)` 
  - `Text(_formatDate(event.createdAt), style: bodySmall, color: grey)`
- `_statusBadge(String status)` — private method returning a `Container` with rounded corners (`borderRadius: 4`) and colour-coded background:
  - `'CREATED'` → `Color(0xFF0A2342)` bg, white text
  - `'ACKNOWLEDGED'` → `Color(0xFFFFB300)` bg, black text
  - `'IN_PROGRESS'` → `Colors.orange` bg, black text
  - `'RESOLVED'` → `Colors.green.shade700` bg, white text
  - `'CANCELLED'` → `Colors.grey.shade600` bg, white text
  - default → grey
- Improved empty state: `Column(children: [Icon(Icons.inbox_outlined, size: 64, color: grey), SizedBox(height: 12), Text('No events yet')])`
- Keep `_formatDate` unchanged
- `destinationLocationId` is available on `EventModel` — already mapped from JSON

### Test Strategy
- `recent_events_screen_test.dart`:
  - update: find status badge by its text content (same strings, different widget type)
  - add test: status `'RESOLVED'` badge has green background
  - add test: status `'ACKNOWLEDGED'` badge has amber background
  - existing loading/error/empty state tests still pass
  - existing title-preferred / null-title-fallback tests still pass

### Dependencies
MO-01

---

## [MO-05] Add pull-to-refresh on Recent Events

### Source
Phase 2 decision: include pull-to-refresh — low cost, high utility

### Context
`RecentEventsScreen` uses `FutureBuilder` with `_eventsFuture` set once in `initState`. To refresh, user must navigate away and back. `RefreshIndicator` wraps the `ListView` and resets `_eventsFuture` on drag.

### Files
- `mobile/lib/screens/recent_events_screen.dart`

### Implementation
Add `_refresh()` method:
```dart
Future<void> _refresh() async {
  setState(() {
    _eventsFuture = widget.apiService.listEvents();
  });
}
```
Wrap the `ListView.builder` (inside the `FutureBuilder` success branch) with:
```dart
RefreshIndicator(
  onRefresh: _refresh,
  child: ListView.builder(...),
)
```

### Test Strategy
- `recent_events_screen_test.dart`:
  - add test: `RefreshIndicator` widget is present in the tree
  - existing list/error/empty tests unaffected

### Dependencies
MO-04

---

## [FE-01] Show title first in dashboard event list

### Source
Wishlist: "show title before event type"

### Context
`templates/partials/event_list.html` renders `{{ event.event_type }}` as the primary heading. Events created via mobile have `title` set (e.g. "Delay", "Assistance"). Showing `title` first makes the feed immediately readable without knowing the `event_type` code. `event.title` is `Option<String>` in the Askama template context — the existing template already uses it on the detail page.

### Files
- `templates/partials/event_list.html`

### Implementation
Change the card body from:
```html
<span class="font-semibold truncate">{{ event.event_type }}</span>
```
to:
```html
{% if let Some(t) = event.title.as_ref() %}
  <span class="font-semibold truncate">{{ t }}</span>
  <span class="text-xs text-base-content/50">{{ event.event_type }}</span>
{% else %}
  <span class="font-semibold truncate">{{ event.event_type }}</span>
{% endif %}
```

### Test Strategy
- Existing `cargo test` and `tests/gate9.py` / `gate10.py` still pass (no API change)
- Manual: `open http://localhost:3000/dashboard/events` — events with titles show title first

### Dependencies
None (template-only change)

---

## [FE-02] Hide disabled Acknowledge button on detail page

### Source
Wishlist: "hide or disable acknowledge when not applicable"

### Context
`templates/events_detail.html` renders a `btn-disabled` button for Acknowledged, InProgress, Resolved, and Cancelled states. This is visual clutter — a disabled action button creates confusion about whether it's interactive. Remove the button entirely for non-actionable states.

### Files
- `templates/events_detail.html`

### Implementation
Replace the `{% match event.status %}` block in `card-actions` with:
```html
{% match event.status %}
{% when EventStatus::Created %}
  <button
    class="btn btn-warning"
    hx-patch="/dashboard/events/{{ event.id }}/acknowledge"
    hx-target="body"
    hx-push-url="true">
    Acknowledge
  </button>
{% when EventStatus::Delivered %}
  <button
    class="btn btn-warning"
    hx-patch="/dashboard/events/{{ event.id }}/acknowledge"
    hx-target="body"
    hx-push-url="true">
    Acknowledge
  </button>
{% when _ %}
{% endmatch %}
```

### Test Strategy
- `cargo test` passes
- Manual: open a CREATED event → Acknowledge button visible; open an ACKNOWLEDGED event → button absent

### Dependencies
None (template-only change)

---

## Definition of Done (Sprint 8)

- [ ] `flutter test` — 17 existing tests pass + new tests added in MO-02/MO-03/MO-04/MO-05 pass
- [ ] `cargo test` — all backend tests pass
- [ ] `cargo fmt` — no formatting issues
- [ ] `cargo clippy` — zero warnings on changed files
- [ ] App runs in Chrome (`flutter run -d chrome`) without errors
- [ ] AppBar is deep navy, cards are visually distinct selected/unselected
- [ ] Submit button shows spinner during submission
- [ ] Recent Events shows colour-coded status badges
- [ ] Pull-to-refresh works on Recent Events
- [ ] Dashboard event list shows title first (where set)
- [ ] Dashboard detail page hides Acknowledge button for non-actionable statuses
- [ ] `ralph/` is NOT committed
- [ ] README updated if any run instructions changed (expected: none needed)
