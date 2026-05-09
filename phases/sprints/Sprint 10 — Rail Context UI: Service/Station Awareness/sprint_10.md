# Sprint 10 — Rail Context UI: Service/Station Awareness

## Phase
PHASE 2 — Rail MVP Layer

## Goal
Expose the rail context model in the mobile app and dashboard so users can see service/station status, staff availability, and related events.

## Why This Sprint Matters
Sprint 9 added the rail context model.

This sprint makes that context visible and useful.

The goal is not to build a full rail control room. The goal is to make the current seeded service/station context understandable to a CSO, station staff member, or control user.

## Core Concept
The app should answer:

- What service am I looking at?
- What station is relevant?
- Are there active issues?
- Are staff available?
- What events are attached to this service or station?

## Wishlist

### Mobile UI

Improve the existing Rail tab.

The Rail tab should show:

- current service card
  - service code
  - direction
  - status dot
  - status label
  - active issue count if available
  - staff availability summary

- station/context section
  - current or next station placeholder
  - station status dot
  - staff availability summary

- related events section
  - events attached to the selected service
  - events attached to the selected station

The Report screen should attach new events to the current rail context where available:
- rail_service_id
- rail_station_id

Keep this simple and mostly seed-driven.

### Dashboard UI

Add basic rail context pages:

- `GET /dashboard/rail/services`
  - list services
  - show status dot
  - show staff availability summary

- `GET /dashboard/rail/services/{id}`
  - service detail
  - stops if already available
  - events attached to service
  - staff presence on service

- `GET /dashboard/rail/stations`
  - list stations
  - show status dot
  - show staff availability summary

- `GET /dashboard/rail/stations/{id}`
  - station detail
  - events attached to station
  - staff presence at station

If this is too much for one sprint, prioritise:
1. mobile Rail tab
2. dashboard services list/detail
3. dashboard stations list/detail

### Event Grouping

Implement simple queries for:

- events by service
- events by station

Optional only if easy:
- events by service + station

Do not create a generic grouping engine yet.

### Status Dots

Show simple status dots:

- green = no active issues and staff available
- amber = active issue or limited/unknown staff
- red = critical issue or no staff where staff is expected

Use the deterministic logic from Sprint 9.

### Staff Presence

Show staff presence simply:

- onboard staff for service
- station staff for station

No chat.
No direct messaging.
No roster management.

## Constraints

- Keep UI simple
- Use existing rail seed data
- Use existing rail APIs where possible
- Do not build maps
- Do not build GPS tracking
- Do not build full timetable ingestion
- Do not build messaging/chat
- Do not build complex permissions
- Do not build push notifications
- Do not overbuild event grouping

## Out of Scope

- Real-time train location
- Real timetable imports
- Staff rostering
- Free-form chat
- Map view
- Push alerts
- Emergency escalation workflows
- Contractor portal
- Control room analytics

## Success Criteria

- Mobile Rail tab shows a useful current service/station context
- Mobile-created events can attach to current rail context
- Dashboard can show services with status dots
- Dashboard can show stations with status dots
- Service detail shows related events
- Station detail shows related events
- Staff presence is visible in a basic way
- Existing event workflow still works
- Tests pass

## Deliverables

- improved mobile Rail tab
- event creation with current rail context
- dashboard rail services page
- dashboard rail service detail page
- dashboard rail stations page
- dashboard rail station detail page
- service/station event queries
- README updates

## Notes

This is the first sprint where the product should feel rail-aware.

Do not let it become a full rail operations system yet.

Keep the question simple:

“What is happening on this service or at this station right now?”