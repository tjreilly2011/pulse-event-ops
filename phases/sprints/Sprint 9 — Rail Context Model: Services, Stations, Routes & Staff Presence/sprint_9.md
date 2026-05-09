# Sprint 9 — Rail Context Model: Services, Stations, Routes & Staff Presence

## Phase
PHASE 2 — Rail MVP Layer

## Goal
Add the first rail-specific context layer on top of the generic event core so events can be attached to train services, stations, and staff presence.

## Why This Sprint Matters
The generic event engine works, but the first real MVP is rail.

Rail staff need context:
- which train/service is involved
- which station is relevant
- who is available on a train or at a station
- whether a train/station has active issues

This sprint introduces the minimum rail layer without polluting the generic core.

## Core Principle
Keep platform core generic.

Rail-specific concepts must live in a rail context layer and must not replace the core event model.

Core event remains:
- event
- status
- update
- actor
- location
- timeline

Rail layer adds:
- train service
- route
- station
- timetable stop
- staff presence

## Wishlist

### Rail Data Model
Add minimal tables/models for:

- `rail_routes`
  - id
  - name

- `rail_stations`
  - id
  - name
  - code/slug
  - region optional

- `rail_services`
  - id
  - service_code
  - route_id
  - direction
  - scheduled_start_time
  - scheduled_end_time
  - status

- `rail_service_stops`
  - id
  - service_id
  - station_id
  - scheduled_arrival
  - scheduled_departure
  - stop_sequence

- `staff_presence`
  - id
  - actor_id
  - role_label
  - presence_type
  - current_service_id nullable
  - current_station_id nullable
  - status
  - last_seen_at

### Event Attachment
Allow an event to optionally reference rail context:
- service_id
- station_id
- route_id where useful
- service_stop_id where useful

Keep these as rail extension fields or related tables.
Do not force all generic events to have rail fields.

### Seed Data
Add minimal seed/test data:
- one route
- a few stations
- one running service
- several service stops
- sample staff presence:
  - one train staff member on service
  - one station staff member at station
  - one control/management user placeholder if useful

### API Endpoints
Add minimal read endpoints:

- `GET /rail/services`
- `GET /rail/services/{id}`
- `GET /rail/services/{id}/stops`
- `GET /rail/stations`
- `GET /rail/stations/{id}`
- `GET /rail/presence`

Optional if low-cost:
- `GET /rail/services/{id}/context`

### Status Dots
Compute simple status indicators:
- green = no active issue and staff available
- amber = active issue or limited staff
- red = critical issue or no required staff

For this sprint, the status can be basic and deterministic.
Do not overbuild rules.

## Constraints
- Keep rail layer thin
- Do not rewrite core event model
- Do not add auth
- Do not add complex scheduling/timetable imports
- Do not integrate with real rail APIs
- Do not implement live GPS
- Do not implement full staffing system
- Use seed/static data for now

## Out of Scope
- Real timetable integration
- GPS train tracking
- Complex staff rostering
- Push notifications
- Maps
- External systems
- Advanced permissions

## Success Criteria
- The app has a minimal rail context model
- Seed data creates at least one route/service/station sequence
- Staff presence can be represented for train and station users
- Events can be associated with rail context without breaking generic event behavior
- Simple status dots can be calculated for service/station context
- API endpoints return usable rail context data
- Tests pass

## Deliverables
- rail context database migration(s)
- rail domain models
- rail repository/application/API layer
- seed/test data
- basic status indicator calculation
- tests for rail context endpoints
- README updates

## Notes
This sprint should make the product start to feel rail-aware without becoming a rail-only system.

The goal is context, not full timetable accuracy.
