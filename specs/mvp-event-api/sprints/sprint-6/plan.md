# Sprint 6 — Basic Web Dashboard (HTMX)

**Branch**: `feat/dashboard-events`
**Phase**: PHASE 1 — MVP Build
**Date**: 2026-04-21

---

## Executive Summary

Sprint 6 adds the first real operations-facing UI to the system.
By end of sprint, an operations user can:

- open the dashboard in a browser
- see a live feed of events, updating without page refresh
- open an event detail view with full timeline
- acknowledge an event from the dashboard

The backend (API, application layer, domain, infrastructure) is **not changed**.
All dashboard handlers call the existing `application::events` functions directly.
No new migrations, no AppState changes, no SSE endpoint changes.

Tech choices locked:
- **Askama 0.12** — Jinja2-syntax compile-time templates, Axum integration via `features = ["with-axum"]`
- **HTMX 2.x** + **DaisyUI 4.x** — loaded from CDN in base layout
- SSE live updates via `EventSource` + tiny inline JS → `htmx.ajax` partial refresh (not HTMX SSE extension)

---

## Architecture

### Backend (Rust)

#### New dashboard routes

| Method | Path | Handler | Purpose |
|---|---|---|---|
| GET | `/dashboard/events` | `dashboard::feed_page` | Full feed page (HTML) |
| GET | `/dashboard/events/feed` | `dashboard::feed_partial` | HTMX partial — event list only |
| GET | `/dashboard/events/:id` | `dashboard::detail_page` | Full detail page (HTML) |
| PATCH | `/dashboard/events/:id/acknowledge` | `dashboard::acknowledge` | Ack action — returns HX-Redirect |

**Route ordering rule**: `/dashboard/events/feed` must be registered before `/dashboard/events/:id` in the router (literal segment wins over path param — same pattern as Sprint 5 `/events/stream` before `/events/:id`).

#### New module

`src/api/dashboard.rs` — 4 handlers, all < 150 lines total.
No new application or domain modules. Handlers call existing functions:
- `application::events::list(pool)` — feed page and feed partial
- `application::events::get_by_id(pool, id)` — detail page
- `infrastructure::update_repo::list_for_event(pool, id)` — detail page timeline
- `application::events::acknowledge(pool, tx, id, req)` — acknowledge action

#### Acknowledge sentinel

`acknowledged_by` = `00000000-0000-0000-0000-000000000001` (hard-coded in dashboard handler).
No schema or application layer change. Will be replaced when auth lands.

#### No new migrations

Dashboard reads only. Existing `events` and `event_updates` tables cover all needs.

---

### Realtime — SSE live updates

**Approach**: JSON SSE → tiny inline JS → `htmx.ajax` partial refresh

The existing `GET /events/stream` endpoint is **unchanged** — it continues to emit:

```
data: {"type":"EVENT_CREATED","event":{...}}
```

The base layout (`templates/layout.html`) includes a `<script>` block:

```js
const es = new EventSource("/events/stream");
es.onmessage = function(e) {
  try {
    const msg = JSON.parse(e.data);
    if (!msg.type) return;  // ignore malformed / keep-alive non-data frames
    htmx.ajax("GET", "/dashboard/events/feed", {
      target: "#event-feed",
      swap: "innerHTML"
    });
  } catch (_) {}
};
```

Rules:
- Only refresh when `msg.type` exists — prevents noisy refresh loops
- `try/catch` silently discards JSON parse errors
- `#event-feed` is the `<div>` wrapping the event list partial inside the feed page

---

### Frontend — Templates (Askama)

All templates use Askama Jinja2 syntax. Files live in `templates/` at workspace root.

#### Templates

| File | Purpose |
|---|---|
| `templates/layout.html` | Base layout — HTMX + DaisyUI CDN, EventSource JS, nav |
| `templates/events_feed.html` | Feed page — extends layout, contains `<div id="event-feed">` |
| `templates/events_detail.html` | Detail page — extends layout |
| `templates/partials/event_list.html` | Event list partial — rendered by both feed page and feed partial handler |
| `templates/partials/timeline.html` | Update timeline partial — newest first |

#### UI rules

- Acknowledge button: **disabled + greyed out** if `event.status == ACKNOWLEDGED` (or any post-ack status); hidden is also acceptable
- Timeline: **newest updates at top** — sort by `created_at DESC`
- Status badge: coloured chip per status (CREATED=blue, ACKNOWLEDGED=green, IN_PROGRESS=yellow, RESOLVED=grey, CANCELLED=red)
- No maps, no charts, no auth, no role filtering

---

### Config Updates

None. No new environment variables or feature flags.

---

## References

### Files to modify

| File | Change |
|---|---|
| `Cargo.toml` | Add `askama = { version = "0.12", features = ["with-axum"] }` |
| `src/api/mod.rs` | Add `pub mod dashboard;` |
| `src/api/router.rs` | Register 4 `/dashboard/*` routes |
| `src/infrastructure/update_repo.rs` | Verify / add `list_for_event(pool, event_id)` if not present |
| `README.md` | Add dashboard section |
| `ralph/PROGRESS.md` | Track task completion |

### Files to create

| File | Purpose |
|---|---|
| `src/api/dashboard.rs` | All 4 dashboard handlers |
| `templates/layout.html` | Base layout |
| `templates/events_feed.html` | Feed page template |
| `templates/events_detail.html` | Detail page template |
| `templates/partials/event_list.html` | Event list partial |
| `templates/partials/timeline.html` | Timeline partial |

### Reusable modules (no changes needed to these)

- `application::events::list` — already returns `Vec<Event>` ordered by `created_at DESC`
- `application::events::get_by_id` — already returns `Option<Event>`
- `application::events::acknowledge` — already accepts `AcknowledgeEventRequest { acknowledged_by }`
- `AppState` + `FromRef<AppState> for PgPool` — dashboard handlers use `State(pool): State<PgPool>` for free
- `AppState` + `FromRef<AppState> for broadcast::Sender<SseEvent>` — acknowledge handler uses `State(tx)` to broadcast after ack

---

## Definition of Done

- [ ] `cargo build` clean
- [ ] `cargo test` — all existing tests pass, new dashboard render tests pass
- [ ] `cargo fmt` clean
- [ ] `cargo clippy` clean
- [ ] `GET /dashboard/events` renders event feed in browser
- [ ] `GET /dashboard/events/:id` renders event detail in browser
- [ ] `PATCH /dashboard/events/:id/acknowledge` transitions status to ACKNOWLEDGED
- [ ] Feed refreshes live when a new event is posted (no manual reload)
- [ ] Acknowledge button disabled/hidden when event already acknowledged
- [ ] Timeline shows newest update first
- [ ] README updated with dashboard routes and local run instructions
