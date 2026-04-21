# Sprint 6 — Basic Web Dashboard (HTMX)

## Phase
PHASE 1 — MVP Build

## Goal
Create the first usable web dashboard so operations users can view live events, inspect event details, and acknowledge events from the browser.

## Why This Sprint Matters
Sprint 5 made the backend live through SSE.

This sprint gives that live data a usable interface.

By the end of this sprint, the system should no longer be “API only” — it should have a basic operations dashboard that:
- shows incoming events
- updates live without refresh
- lets a user open event details
- lets a user acknowledge an event

This is the first real operations-facing UI and the first moment the product starts to feel like a usable tool.

## Reference Inputs
Use prior sprint outputs as implementation context only, especially:
- Sprint 3 backend implementation
- Sprint 4 event acknowledgment and updates
- Sprint 5 SSE implementation
- event-lifecycle.md
- event-payload.md
- role-model.md
- mvp-boundary.md

Do not create new discovery or architecture artifacts unless strictly needed for implementation clarity.

## Wishlist
- Create a basic dashboard page for viewing events
- Implement an event feed page:
  - list recent events
  - show key fields clearly
  - order by newest / most recent activity

- Create an event detail page:
  - show full event information
  - show current status
  - show timeline / updates
  - show acknowledgment information if present

- Add live updates to the dashboard using existing SSE
- Ensure the event feed updates without manual refresh
- Ensure newly acknowledged events or updates are reflected live where practical

- Add acknowledge action from the dashboard
- Allow user to acknowledge an event from the feed and/or detail page
- Ensure successful acknowledgment updates the UI correctly

- Use HTMX for:
  - partial rendering
  - form/action handling
  - live updates integration where appropriate

- Keep UI minimal and operational:
  - readable
  - fast
  - no decorative complexity

- Add basic filtering if simple and low-cost, such as:
  - status filter
  - event type filter
  Only if it fits cleanly in this sprint without slowing delivery

- Add tests or practical verification coverage for:
  - dashboard page renders
  - event detail page renders
  - acknowledge action works from UI
  - SSE-driven updates are visible in the UI flow
  - no full page reload required for basic live updates

- Update README with:
  - how to run backend + dashboard locally
  - key dashboard routes
  - basic usage flow

## Constraints
- Keep this sprint minimal and focused
- Build only the first usable dashboard
- Use HTMX + server-rendered templates
- Reuse existing API/backend logic where possible
- Do not build advanced dashboard widgets
- Do not build maps yet
- Do not build role-aware UI yet
- Do not build auth yet
- Do not overengineer frontend structure
- Prefer one simple event feed page and one detail page

## Out of Scope
- Flutter mobile app
- Push notifications
- Maps / geospatial UI
- Rich search
- Advanced filtering
- Role-aware permissions
- Admin pages
- Settings screens
- Presence / online-user tracking
- WebSockets
- NATS / internal bus
- Visual analytics / charts

## Success Criteria
- A user can open the dashboard in the browser
- A user can see a list of events
- A user can open an event detail view
- A user can acknowledge an event from the dashboard
- Event changes appear live without manual refresh
- The dashboard is usable locally with the current backend
- Existing backend behavior is not broken
- Tests / verification pass

## Deliverables
- dashboard event feed page
- dashboard event detail page
- HTMX partials where needed
- acknowledge action wired into the UI
- live SSE-driven dashboard updates
- updated README

## Notes
Keep this sprint focused on operational usefulness, not polish.

The dashboard should feel like:
- a live operational feed
- a place to inspect event state
- a place to take the single most important action: acknowledge

Do not try to make it beautiful yet.
Do not turn it into a full admin portal.

Use Sprint 3, 4, and 5 outputs as implementation context only.

Sprint 6 must produce working UI, not more design artifacts.

Keep the dashboard minimal:
- one event feed page
- one event detail page
- acknowledge button
- live updates via existing SSE

Prefer simple server-rendered templates + HTMX partials.
Do not add maps, auth, roles, or advanced filtering in this sprint unless they come almost for free.

A practical suggestion for Sprint 6 implementation shape:

* /dashboard/events → feed page
* /dashboard/events/{id} → detail page
* partial for event row/card
* partial for timeline block
* HTMX POST/PATCH action for acknowledge
* SSE updates trigger refresh of feed and maybe detail panel if open