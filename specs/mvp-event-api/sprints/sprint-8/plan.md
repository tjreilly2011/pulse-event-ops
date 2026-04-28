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
