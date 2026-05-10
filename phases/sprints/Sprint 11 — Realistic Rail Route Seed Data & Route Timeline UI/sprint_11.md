# Sprint 11 — Realistic Rail Route Seed Data & Route Timeline UI

## Phase
PHASE 2 — Rail MVP Layer

## Goal
Replace dummy rail seed data with two realistic example routes and expose their stops clearly in the mobile Rail tab and dashboard.

## Why This Sprint Matters
Sprint 9 and Sprint 10 proved the rail context layer works, but the current data is too artificial.

This sprint makes the product feel closer to a real rail operations tool by using realistic train routes, stops, and service timelines.

The goal is not full GTFS/NaPTAN integration yet.
The goal is realistic, deterministic seed data that lets users understand how the product would work on actual services.

---

## Example Routes

### Route 1 — Ireland
Westport → Dublin Heuston

Stops:
1. Westport
2. Castlebar
3. Manulla Junction
4. Claremorris
5. Ballyhaunis
6. Castlerea
7. Roscommon
8. Athlone
9. Clara
10. Tullamore
11. Portarlington
12. Monasterevin
13. Kildare
14. Newbridge
15. Dublin Heuston

Example service:
- service_code: IE-WPT-HST-001
- direction: eastbound
- origin: Westport
- destination: Dublin Heuston
- status: ON_TIME

---

### Route 2 — Great Britain
London Waterloo → Kingston

Stops:
1. London Waterloo
2. Vauxhall
3. Clapham Junction
4. Earlsfield
5. Wimbledon
6. Raynes Park
7. New Malden
8. Norbiton
9. Kingston

Example service:
- service_code: GB-WAT-KGN-001
- direction: outbound
- origin: London Waterloo
- destination: Kingston
- status: ON_TIME

---

## Wishlist

### 1. Replace Dummy Rail Seed Data

Replace or extend the current seed migration with realistic route data.

Create deterministic seed records for:

- rail_routes
- rail_stations
- rail_services
- rail_service_stops
- staff_presence

Keep seed data idempotent if practical.

Avoid duplicate records on repeated migration/test setup.

---

### 2. Add Station Codes

Add practical station codes/slugs for display and lookup.

Examples:

Ireland:
- Westport: WPT
- Castlebar: CBR
- Manulla Junction: MNJ
- Claremorris: CLR
- Ballyhaunis: BHS
- Castlerea: CLA
- Roscommon: RSC
- Athlone: ATH
- Clara: CLA2 or CLRA
- Tullamore: TUL
- Portarlington: PTL
- Monasterevin: MON
- Kildare: KIL
- Newbridge: NBR
- Dublin Heuston: HST

GB:
- London Waterloo: WAT
- Vauxhall: VXH
- Clapham Junction: CLJ
- Earlsfield: EAD
- Wimbledon: WIM
- Raynes Park: RAY
- New Malden: NEM
- Norbiton: NBT
- Kingston: KGN

If exact official codes are uncertain, use stable internal codes and mark them as seed/demo codes.

---

### 3. Add Route Timeline Support

Ensure each rail service can return ordered stops.

Add or verify endpoint:

- `GET /rail/services/{id}/stops`

Response should include:

- stop_sequence
- station name
- station code
- scheduled arrival
- scheduled departure
- status dot if available

---

### 4. Improve Mobile Rail Tab

The Rail tab should show:

- route/service card
- origin → destination
- direction
- status dot
- selected/current station
- stop list/timeline

For selected service, show the stops in order.

The UI should make it obvious:

- where the service starts
- where it ends
- which station is selected/current
- what events are related to selected service/station

Keep interaction simple.

---

### 5. Improve Dashboard Rail Pages

Dashboard service detail should show:

- service code
- origin → destination
- status
- ordered stop timeline
- related events
- staff presence

Dashboard station detail should show:

- station name/code
- staff presence
- related events
- services stopping at that station if cheap to implement

---

### 6. Keep GTFS / NaPTAN Import Deferred

Do not implement full GTFS or NaPTAN ingestion in this sprint.

However, create a short note in README or docs explaining future import direction:

- GTFS can populate stops/routes/trips/stop_times later
- NaPTAN can populate GB station/access-point reference data later
- MVP uses curated seed data first to avoid import complexity

---

## Constraints

- Do not ingest live realtime rail APIs
- Do not implement full GTFS parser yet
- Do not implement NaPTAN parser yet
- Do not add maps
- Do not add GPS tracking
- Do not add complex timetable logic
- Do not add official data refresh jobs
- Keep route data deterministic and easy to understand

---

## Out of Scope

- Realtime train running data
- Full timetable import
- External API integration
- Staff rostering
- Live train location
- Delay prediction
- Route planning
- Passenger-facing journey planner functionality

---

## Success Criteria

- Dummy Northern Line-only seed data is replaced or supplemented with:
  - Westport → Dublin Heuston
  - London Waterloo → Kingston

- Rail tab can show realistic services and stop lists
- Dashboard service detail can show realistic ordered stops
- Events can still attach to selected service/station
- Existing event creation, acknowledge, update, and SSE behavior still works
- Tests pass
- README explains seed data and future import approach

---

## Deliverables

- updated seed migration or seed script
- realistic rail route/station/service/stop data
- service stops endpoint verified or added
- mobile Rail tab route timeline display
- dashboard service detail route timeline display
- README update explaining:
  - seed data
  - future GTFS/NaPTAN import
  - why full import is deferred

---

## Notes

This sprint should make the rail MVP feel real without drowning the project in transport-data ingestion.

Use curated example routes first.

Full GTFS/NaPTAN import is valuable later, but only after the app workflow proves useful.