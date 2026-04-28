# Sprint 7 — Tasks

**Branch**: `feat/mobile-reporting`
**Phase**: PHASE 1 — MVP Build

---

## Definition of Done (all tasks)

- Implementation matches requirements
- New logic has tests (widget or unit as appropriate)
- `flutter analyze` passes (no warnings)
- `flutter test` passes
- App builds and runs on simulator/emulator without crashes
- `POST /events` creates an event that appears in the HTMX dashboard SSE feed
- `GET /events` populates the Recent Events list
- Logging added where meaningful

---

## Tasks

---

### [MO-01] Bootstrap Flutter project

**Source**: Phase 2 — Architecture / Mobile

**Context**: Create the `mobile/` Flutter project at the workspace root using `flutter create`. Minimal scaffold only. Remove boilerplate counter app code.

**Files**:
- `mobile/` (new directory — `flutter create mobile`)
- `mobile/pubspec.yaml` — add `http` and `intl` dependencies
- `mobile/lib/main.dart` — replace boilerplate with `MaterialApp` shell + `BottomNavigationBar` (2 tabs, index 0 = Report Event)
- `mobile/lib/constants.dart` — create with `kApiBaseUrl`, `kCreatedByStub`, `kLocationPlaceholder`

**Test Strategy**:
- `flutter create` completes without error
- `flutter pub get` resolves dependencies
- `flutter analyze` passes on empty scaffold
- App launches to Report Event screen (manual verify on simulator)

**Dependencies**: None — first task

---

### [MO-02] Create EventModel

**Source**: Phase 2 — Mobile / models

**Context**: Dart model that mirrors the JSON returned by `GET /events` and `POST /events`. Used by both the API service and the Recent Events screen.

**Files**:
- `mobile/lib/models/event_model.dart` (new)

**Spec**:
```dart
class EventModel {
  final String id;
  final String eventType;   // from "event_type"
  final String status;
  final String? title;
  final String? description;
  final String createdAt;   // ISO8601 string
  final String destinationLocationId;

  factory EventModel.fromJson(Map<String, dynamic> json);
}
```

Display rule: `title ?? eventType` — always prefer `title` if non-null.

**Test Strategy**:
- Unit test in `test/models/event_model_test.dart`
- Test `fromJson` with a full JSON object
- Test `fromJson` with `title: null` — confirm fallback display string is `eventType`

**Dependencies**: MO-01

---

### [MO-03] Create ApiService

**Source**: Phase 2 — Mobile / services

**Context**: Thin HTTP wrapper using `dart:http`. Two methods only. No DI, no abstractions. Called directly by screens.

**Files**:
- `mobile/lib/services/api_service.dart` (new)

**Spec**:
```dart
class ApiService {
  Future<EventModel> createEvent({
    required String eventType,
    required String title,
    String? description,
  }) // POST /events → 201 → EventModel

  Future<List<EventModel>> listEvents()
  // GET /events → 200 → List<EventModel>
}
```

Payload for `createEvent`:
```json
{
  "event_type": "<eventType>",
  "title": "<title>",
  "description": "<description or null>",
  "created_by": "<kCreatedByStub>",
  "destination_location_id": "<kLocationPlaceholder>"
}
```

Throws `Exception` on non-2xx. Caller shows snackbar.

**Test Strategy**:
- Unit test in `test/services/api_service_test.dart` using `http` mock or manual stub
- Test successful `createEvent` response parses to `EventModel`
- Test `listEvents` response parses to `List<EventModel>`
- Test non-2xx throws `Exception`

**Dependencies**: MO-01, MO-02

---

### [MO-04] Build Report Event screen

**Source**: Phase 2 — Mobile / Screen 1

**Context**: The primary screen and default landing page. Must feel fast and usable under stress. Category selection → optional note → submit. No complex form.

**Files**:
- `mobile/lib/screens/report_event_screen.dart` (new)

**Layout spec** (single scrollable `Column` inside `Scaffold`):
1. `AppBar` — title: `"Pulse Operations"`, subtitle line: `kLocationPlaceholder`
2. `GridView.count(crossAxisCount: 2, shrinkWrap: true)` — 4 category `Card`/`InkWell` items with label + icon
3. Selected summary text: `"Selected: <label>"` (empty `SizedBox` if none selected)
4. `TextField(maxLines: 3)` — optional note, placeholder: `"Optional note"`
5. Full-width `ElevatedButton("Send Event")` — `onPressed: null` until category selected
6. Snackbar on success (`"Event sent"`) or error (`"Failed to send event"`)
7. On success: reset `_selectedCategory` and `_noteController`

**Category list** (hardcoded `const`):
```dart
const categories = [
  {'label': 'Delay',         'type': 'delay'},
  {'label': 'Overcrowding',  'type': 'overcrowding'},
  {'label': 'Assistance',    'type': 'passenger_assistance'},
  {'label': 'Safety',        'type': 'safety_security'},
];
```

**Title rule**: `title = category['label']` — no note concatenation.

**State**: `setState` only — `String? _selectedCategory`, `String? _selectedType`, `TextEditingController _noteController`.

**Test Strategy**:
- Widget test in `test/screens/report_event_screen_test.dart`
- Verify Submit button is disabled on initial render
- Verify button enables after tapping a category
- Verify snackbar text `"Event sent"` appears on mocked success response
- Verify form resets after success

**Dependencies**: MO-01, MO-02, MO-03

---

### [MO-05] Build Recent Events screen

**Source**: Phase 2 — Mobile / Screen 2

**Context**: Secondary screen. Shows a chronological (newest-first) list of events. Pulls from `GET /events` on mount.

**Files**:
- `mobile/lib/screens/recent_events_screen.dart` (new)

**Layout spec**:
- `Scaffold` + `AppBar` ("Recent Events")
- `FutureBuilder<List<EventModel>>` wrapping `ApiService().listEvents()`
- `ListView.builder` — one `ListTile` per event:
  - `title`: `event.title ?? event.eventType`
  - `subtitle`: formatted timestamp (e.g. `"21 Apr 19:58"`) + `"\n$kLocationPlaceholder"`
  - `trailing`: `Chip(label: Text(event.status))`
- Loading state: `CircularProgressIndicator`
- Error state: `Text("Failed to load events")`
- Empty state: `Text("No events yet")`
- Tap → no-op

**Test Strategy**:
- Widget test in `test/screens/recent_events_screen_test.dart`
- Verify loading indicator renders before future resolves
- Verify list renders correct number of items from mocked response
- Verify `title` is preferred over `eventType`
- Verify fallback to `eventType` when `title` is null

**Dependencies**: MO-01, MO-02, MO-03

---

### [MO-06] Wire navigation in main.dart

**Source**: Phase 2 — Mobile / Navigation

**Context**: Assemble the two screens into the app shell with `BottomNavigationBar`. Report Event must be the default (index 0).

**Files**:
- `mobile/lib/main.dart` (update scaffold from MO-01)

**Spec**:
- `StatefulWidget` (`_AppState`) with `int _currentIndex = 0`
- `BottomNavigationBar` items: `[BottomNavigationBarItem(icon: ..., label: 'Report'), BottomNavigationBarItem(icon: ..., label: 'Recent')]`
- `body`: `IndexedStack` or `[ReportEventScreen(), RecentEventsScreen()][_currentIndex]`
- Tab switch triggers `setState`

**Test Strategy**:
- Widget test: app renders Report Event screen at launch (index 0)
- Tapping Recent tab renders Recent Events screen

**Dependencies**: MO-04, MO-05

---

### [MO-07] Integration smoke test (manual)

**Source**: Sprint 7 wishlist — Success Criteria + Validation Step

**Context**: End-to-end manual verification of the core loop. Run with the Rust server and Docker DB running.

**Steps**:
1. Start backend: `cargo run` (server on port 3000)
2. Update `kApiBaseUrl` to device/emulator-reachable address
3. Launch Flutter app on simulator
4. Open Report Event screen
5. Tap "Assistance"
6. Enter note: `"Wheelchair required"`
7. Tap "Send Event"
8. Verify: snackbar shows `"Event sent"`
9. Verify: form resets
10. Switch to Recent Events tab
11. Verify: "Assistance" event appears at top of list with `CREATED` status
12. Open HTMX dashboard (`http://localhost:3000/dashboard/events`)
13. Verify: event appears in live feed (SSE broadcast received)

**Pass criteria**:
- All 13 steps complete without error
- Event visible in dashboard within 1 second of submission

**Dependencies**: MO-01 → MO-06 complete

---

## Task Summary

| ID | Title | Depends On |
|---|---|---|
| MO-01 | Bootstrap Flutter project | — |
| MO-02 | Create EventModel | MO-01 |
| MO-03 | Create ApiService | MO-01, MO-02 |
| MO-04 | Build Report Event screen | MO-01, MO-02, MO-03 |
| MO-05 | Build Recent Events screen | MO-01, MO-02, MO-03 |
| MO-06 | Wire navigation in main.dart | MO-04, MO-05 |
| MO-07 | Integration smoke test (manual) | MO-01 → MO-06 |
# Sprint 6 — Tasks

## Definition of Done (all tasks)

- Implementation matches requirements
- New logic has tests (render tests for HTML handlers)
- All tests pass (`cargo test`)
- Formatting passes (`cargo fmt`)
- Linting passes (`cargo clippy`)
- App runs without errors
- Dashboard renders in browser without error

---

## [BE-01] Add askama to Cargo.toml

### Source
`plan.md` — Config Updates

### Context
Askama is the Jinja2-compatible compile-time template engine for Rust with Axum 0.7 support.
Add it as a dependency so the compiler can locate and check templates at build time.

### Files
- `Cargo.toml`

### Implementation
Add to `[dependencies]`:
```toml
askama = { version = "0.12", features = ["with-axum"] }
```

### Test Strategy
`cargo build` succeeds after adding the dependency.

### Dependencies
None.

---

## [BE-02] Verify / add `list_for_event` in update_repo

### Source
`plan.md` — References → Files to modify

### Context
The dashboard detail page needs to load all `EventUpdate` rows for a given event, newest first.
The existing `update_repo` may already have this function (it was needed by the API handler for
`GET /events/:id/updates`). Read `src/infrastructure/update_repo.rs` first.

If `list_for_event(pool, event_id)` already exists and returns `Vec<EventUpdate>` ordered by
`created_at DESC` → no change needed, just verify and document.

If it orders ASC, add an alternative or change the ORDER BY to DESC.
If it does not exist, add it.

### Files
- `src/infrastructure/update_repo.rs`

### Implementation
```rust
pub async fn list_for_event(pool: &PgPool, event_id: Uuid) -> Result<Vec<EventUpdate>, sqlx::Error> {
    sqlx::query_as::<_, EventUpdate>(
        "SELECT * FROM event_updates WHERE event_id = $1 ORDER BY created_at DESC"
    )
    .bind(event_id)
    .fetch_all(pool)
    .await
}
```

### Test Strategy
- Existing `cargo test` suite passes (no regression).
- The function will be exercised by the dashboard detail page smoke test.

### Dependencies
BE-01 (cargo build must work).

---

## [BE-03] Create `src/api/dashboard.rs` — all 4 handlers

### Source
`plan.md` — New module: `src/api/dashboard.rs`

### Context
Four handlers, all in one file (< 150 lines total). Reuse existing application functions.
No new application or domain logic.

Route → handler mapping:
- `GET /dashboard/events` → `feed_page` — full HTML page
- `GET /dashboard/events/feed` → `feed_partial` — HTMX-swappable event list only
- `GET /dashboard/events/:id` → `detail_page` — full HTML page
- `PATCH /dashboard/events/:id/acknowledge` → `acknowledge` — returns HX-Redirect

**Acknowledge sentinel**: hard-code `acknowledged_by = Uuid::parse_str("00000000-0000-0000-0000-000000000001").unwrap()`

**Acknowledge error handling**:
- `AcknowledgeError::NotFound` → 404
- `AcknowledgeError::InvalidStatus` (already acknowledged) → redirect back to detail page anyway (the button will be disabled, but handle gracefully)
- `AcknowledgeError::Db` → 500

**Askama template structs** (defined in this file):
```rust
#[derive(Template)]
#[template(path = "events_feed.html")]
struct FeedPageTemplate { events: Vec<Event> }

#[derive(Template)]
#[template(path = "partials/event_list.html")]
struct EventListTemplate { events: Vec<Event> }

#[derive(Template)]
#[template(path = "events_detail.html")]
struct DetailPageTemplate { event: Event, updates: Vec<EventUpdate> }
```

Handler signatures use `State(pool): State<PgPool>` (via `FromRef`) and
`State(tx): State<broadcast::Sender<SseEvent>>` only where needed (acknowledge handler).

### Files
- `src/api/dashboard.rs` (CREATE)

### Test Strategy
- `cargo build` succeeds (templates compile).
- Integration test: `GET /dashboard/events` returns 200 with `content-type: text/html`.
- Integration test: `GET /dashboard/events/:id` returns 200 for existing event, 404 for unknown.
- Integration test: `PATCH /dashboard/events/:id/acknowledge` returns redirect (3xx) or 200 with `HX-Redirect` header.

### Dependencies
BE-01, BE-02.

---

## [BE-04] Register dashboard routes in `src/api/router.rs`

### Source
`plan.md` — Modified files

### Context
Add 4 new routes under `/dashboard`. Critical ordering: `/dashboard/events/feed` MUST be
registered before `/dashboard/events/:id` so the literal "feed" segment is not captured
as an `:id` path parameter (same rule as Sprint 5 `/events/stream` before `/events/:id`).

### Files
- `src/api/router.rs`

### Implementation
Add to `Router::new()` chain:
```rust
.route("/dashboard/events", get(dashboard::feed_page))
.route("/dashboard/events/feed", get(dashboard::feed_partial))
.route("/dashboard/events/:id", get(dashboard::detail_page))
.route("/dashboard/events/:id/acknowledge", patch(dashboard::acknowledge))
```

Add `dashboard` to the use imports at the top of router.rs.

### Test Strategy
`cargo build` succeeds. Existing route tests unaffected.

### Dependencies
BE-03.

---

## [BE-05] Add `pub mod dashboard` to `src/api/mod.rs`

### Source
`plan.md` — Modified files

### Context
Expose the new dashboard module through the api module tree.

### Files
- `src/api/mod.rs`

### Implementation
Add `pub mod dashboard;`

### Test Strategy
`cargo build` succeeds.

### Dependencies
BE-03.

---

## [FE-01] Create base layout template `templates/layout.html`

### Source
`plan.md` — Templates

### Context
Askama base layout. All pages extend this.

Must include:
- `<html>` with `lang="en"`
- HTMX 2.x from CDN: `https://unpkg.com/htmx.org@2`
- DaisyUI 4.x + Tailwind from CDN: `https://cdn.jsdelivr.net/npm/daisyui@4/dist/full.min.css`
  and `https://cdn.tailwindcss.com`
- A `<nav>` bar with "Pulse Operations" title and link to `/dashboard/events`
- A `{% block content %}{% endblock %}` body block
- The `EventSource` JS block (only on pages that extend this layout — include it in the base):

```html
<script>
  const es = new EventSource("/events/stream");
  es.onmessage = function(e) {
    try {
      const msg = JSON.parse(e.data);
      if (!msg.type) return;
      htmx.ajax("GET", "/dashboard/events/feed", {
        target: "#event-feed",
        swap: "innerHTML"
      });
    } catch (_) {}
  };
</script>
```

### Files
- `templates/layout.html` (CREATE — directory must exist)

### Test Strategy
Pages extending this layout render without errors in `cargo build`.
Browser: nav bar visible, DaisyUI styles applied.

### Dependencies
BE-01 (askama must be in Cargo.toml before templates are created).

---

## [FE-02] Create event list partial `templates/partials/event_list.html`

### Source
`plan.md` — Templates

### Context
Rendered by both `feed_page` and `feed_partial`. This is the HTMX swap target content.
Receives `events: Vec<Event>`.

Each event row/card must show:
- `event_type`
- `status` as a coloured DaisyUI badge:
  - CREATED → `badge-info`
  - ACKNOWLEDGED → `badge-success`
  - IN_PROGRESS → `badge-warning`
  - RESOLVED → `badge-neutral`
  - CANCELLED → `badge-error`
  - DELIVERED → `badge-secondary`
- `destination_location_id`
- `created_at` (formatted: `%Y-%m-%d %H:%M UTC`)
- Link to `/dashboard/events/{{ event.id }}` — clicking the row opens detail

Show "No events yet." if the list is empty.

### Files
- `templates/partials/event_list.html` (CREATE)
- `templates/partials/` directory must exist

### Test Strategy
Feed page renders without error. At least one event row visible with correct badge colour.

### Dependencies
FE-01.

---

## [FE-03] Create feed page template `templates/events_feed.html`

### Source
`plan.md` — Templates

### Context
Full feed page. Extends layout. Contains the `<div id="event-feed">` that the SSE JS targets.

Structure:
```html
{% extends "layout.html" %}
{% block content %}
<div class="container mx-auto p-4">
  <h1 class="text-2xl font-bold mb-4">Live Event Feed</h1>
  <div id="event-feed">
    {% include "partials/event_list.html" %}
  </div>
</div>
{% endblock %}
```

The `id="event-feed"` div is the HTMX swap target — the EventSource JS replaces its
`innerHTML` with the response from `GET /dashboard/events/feed`.

### Files
- `templates/events_feed.html` (CREATE)

### Test Strategy
`GET /dashboard/events` returns 200 HTML containing `id="event-feed"`.

### Dependencies
FE-01, FE-02.

---

## [FE-04] Create timeline partial `templates/partials/timeline.html`

### Source
`plan.md` — Templates

### Context
Renders the list of `EventUpdate` items for the detail page. Newest first (already guaranteed
by `ORDER BY created_at DESC` in `list_for_event`). Receives `updates: Vec<EventUpdate>`.

Each timeline entry shows:
- `content`
- `update_type` if present (as a small label)
- `actor_id` if present
- `created_at` formatted as `%Y-%m-%d %H:%M UTC`

Show "No updates yet." if list is empty.

Use DaisyUI `timeline` or a simple vertical list with `divider` — keep it readable.

### Files
- `templates/partials/timeline.html` (CREATE)

### Test Strategy
Detail page renders without error when updates list is empty and when it has items.

### Dependencies
FE-01.

---

## [FE-05] Create detail page template `templates/events_detail.html`

### Source
`plan.md` — Templates

### Context
Full event detail page. Extends layout. Receives `event: Event` and `updates: Vec<EventUpdate>`.

Must show:
- `event_type`, `status` badge, `priority`
- `destination_location_id`, `source_location_id` (if present)
- `title`, `description` (if present)
- `created_by`, `created_at`, `updated_at`
- `acknowledged_by` + `acknowledged_at` (if present)
- Acknowledge button:
  - If `event.status` is NOT `ACKNOWLEDGED`, `IN_PROGRESS`, `RESOLVED`, or `CANCELLED`:
    render a `<button>` with:
    ```html
    hx-patch="/dashboard/events/{{ event.id }}/acknowledge"
    hx-target="body"
    hx-push-url="true"
    ```
  - Otherwise: render the button as `disabled` with text "Acknowledged" (greyed out)
- Timeline section below: `{% include "partials/timeline.html" %}`

Back link to `/dashboard/events`.

### Files
- `templates/events_detail.html` (CREATE)

### Test Strategy
`GET /dashboard/events/:id` returns 200 HTML.
For a CREATED event: acknowledge button is active.
For an ACKNOWLEDGED event: acknowledge button is disabled.

### Dependencies
FE-01, FE-04.

---

## [BE-06] Add integration tests for dashboard handlers

### Source
`plan.md` — Definition of Done

### Context
Add tests to `tests/events_test.rs` (existing integration test file that already uses
`#[sqlx::test]` + `tower::ServiceExt`).

Tests to add:
1. `dashboard_feed_page_returns_200` — `GET /dashboard/events` → 200, `content-type` contains `text/html`
2. `dashboard_feed_partial_returns_200` — `GET /dashboard/events/feed` → 200, `text/html`
3. `dashboard_detail_page_returns_200` — create an event, `GET /dashboard/events/{id}` → 200, `text/html`
4. `dashboard_detail_page_returns_404` — `GET /dashboard/events/00000000-0000-0000-0000-000000000000` → 404
5. `dashboard_acknowledge_redirects` — create event, `PATCH /dashboard/events/{id}/acknowledge` → response has `HX-Redirect` header or is a 3xx

### Files
- `tests/events_test.rs`

### Test Strategy
`cargo test` — all 5 new tests pass alongside existing 16.

### Dependencies
BE-03, BE-04, BE-05, FE-01, FE-02, FE-03, FE-04, FE-05.

---

## [BE-07] Update README.md

### Source
`plan.md` — Definition of Done

### Context
Add a "Dashboard" section to the README describing:
- How to run backend + dashboard locally
- Key dashboard routes
- Basic usage flow (open feed, click event, acknowledge)

### Files
- `README.md`

### Implementation
Add after the existing API endpoints section:

```markdown
## Dashboard

The web dashboard is served by the same Rust binary — no separate process needed.

### Dashboard routes

| Route | Purpose |
|---|---|
| `GET /dashboard/events` | Live event feed |
| `GET /dashboard/events/:id` | Event detail + timeline |
| `PATCH /dashboard/events/:id/acknowledge` | Acknowledge event (HTMX action) |

### Running locally

```bash
# 1. Start the database
docker compose up -d

# 2. Start the backend (serves API + dashboard)
cargo run

# 3. Open dashboard
open http://localhost:3000/dashboard/events
```

### Live updates

The dashboard uses Server-Sent Events (SSE) to update the event feed without page refresh.
When a new event is created (via API or another client), the feed updates automatically.
```

### Test Strategy
README renders correctly on GitHub. Local run instructions are accurate.

### Dependencies
BE-04.

---

## [BE-08] `cargo fmt` + `cargo clippy` + final `cargo test`

### Source
`plan.md` — Definition of Done

### Context
Final polish pass before commit.

### Files
All modified/created Rust source files.

### Implementation
```bash
cargo fmt
cargo clippy -- -D warnings
cargo test
```

All must pass with zero warnings.

### Test Strategy
Exit codes must all be 0.

### Dependencies
All previous tasks complete.
