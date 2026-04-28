# Sprint 7 — Mobile Reporting (Flutter MVP)

## Phase
PHASE 1 — MVP Build

## Goal
Enable a frontline user to create and submit a structured event from a mobile device in under 5 seconds.

## Why This Sprint Matters
This sprint tests the single most important assumption of the product:

Will frontline staff actually use a simple mobile interface instead of calling or messaging?

If this fails, the product fails.
If this works, everything else becomes valuable.

This is the first real user interaction point.

---

## Core Principle

Speed > completeness

The mobile app is NOT a feature-rich tool.
It is a **fast input device for operational events**.

---

## Wishlist (STRICT MVP ONLY)

### 1. Create Event Screen (Primary & Only Critical Flow)

User must be able to:

- open app
- tap one category
- optionally add a note
- submit

### Event Categories (hardcoded for MVP)

- Delay
- Overcrowding
- Passenger Assistance
- Safety / Security

UI should be:

- large tap targets
- minimal text
- usable under stress

---

### 2. Minimal Event Payload

On submit, send:

- event_type (from category)
- title (auto-generated or derived from category + note)
- optional description (user note)

Auto-filled:

- timestamp (backend authoritative)
- created_by (temporary static UUID)
- destination_location_id (temporary/manual or placeholder)
- location (optional — stubbed or basic GPS if easy)

NO complex validation required.

---

### 3. “Recent Events” Screen (Secondary)

Simple list showing:

- event title (NOT just type)
- status (CREATED / ACKNOWLEDGED)
- timestamp

This mirrors the dashboard feed.

No filters.
No pagination complexity.

---

### 4. Submission Feedback

On submit:

- show immediate success confirmation
- clear/reset form
- optional navigation to recent events

Must feel instant and reliable.

---

## Ideal Flutter UI Layout (MANDATORY DIRECTION)

### App Structure

Keep the app to **2 screens only** for this sprint:

1. **Report Event**
2. **Recent Events**

Use a very simple navigation pattern:
- top app bar
- bottom navigation with 2 tabs, or a simple tab switch if quicker

No drawer.
No settings page.
No profile page.

---

### Screen 1 — Report Event (Primary Screen)

This screen is the MVP.

#### Layout order

1. **Header**
   - App title: `Pulse Operations`
   - Small subtitle: current location placeholder if available
   - Example:
     - `Pulse Operations`
     - `Location: station-euston` or `Location unavailable`

2. **Quick Category Grid**
   - 4 large tap cards/buttons
   - 2 x 2 grid
   - Each card must be easily tappable with one thumb
   - Recommended labels:
     - `Delay`
     - `Overcrowding`
     - `Assistance`
     - `Safety`

3. **Selected Event Summary**
   - Once a category is tapped, show a short summary line
   - Example:
     - `Selected: Passenger Assistance`

4. **Optional Note Field**
   - Single multiline text field
   - Placeholder examples:
     - `Optional note`
     - `Wheelchair required at next stop`
     - `Heavy crowd in coach B`

5. **Primary Submit Button**
   - Full width
   - Clear label:
     - `Send Event`
   - Disabled until category selected

6. **Success/Error Feedback**
   - Snackbar or inline status
   - Keep simple:
     - `Event sent`
     - `Failed to send event`

#### UX requirements

- Category tap should be the main interaction
- Form must work comfortably with one hand
- User should be able to submit with:
  - 1 tap category + 1 tap submit
- Note must be optional
- Avoid dropdowns, radios, or long forms

---

### Screen 2 — Recent Events

Simple chronological list of recently created events.

Each item should show:

- title (human-readable)
- status badge
- timestamp
- optional location line

#### Example item layout

- `Passenger assistance required`
- `CREATED`
- `21 Apr 19:58`
- `station-euston`

#### Rules

- Show newest first
- No filters in this sprint
- No detail page in mobile yet unless it comes almost for free
- Tapping an item may be no-op for now, or open a minimal read-only view if trivial

---

## UI Design Rules (MANDATORY)

### 1. No Overdesign
Use standard Flutter Material components.
Do not spend sprint time on custom design systems.

### 2. Large Touch Targets
Buttons/cards must be easy to hit quickly.

### 3. Minimal Cognitive Load
The user should understand the app in under 5 seconds.

### 4. Human-readable Labels
Do not expose backend-style labels like:
- `signal_fault`
- `passenger_assistance`

Display friendly text instead:
- `Passenger Assistance`
- `Safety / Security`

### 5. Fast Happy Path
The ideal flow is:

- open app
- tap category
- optional note
- send

Nothing else.

---

## Suggested Flutter Widget Structure (GUIDANCE)

### Report Event Screen
- `Scaffold`
- `AppBar`
- `Padding`
- `Column`
  - location/status text
  - `GridView.count` or `Wrap` for category cards
  - selected category summary
  - `TextField` for optional note
  - `SizedBox`
  - full-width `ElevatedButton`

### Recent Events Screen
- `Scaffold`
- `AppBar`
- `ListView.builder`
  - simple card/list tile per event

### Category Card
Preferred:
- `Card` or `InkWell`
- icon + label
- selected state clearly visible

---

## Architecture / Integration

### Backend (already exists)

Use existing endpoints:

- POST /events
- GET /events

No backend changes required unless minor payload tweaks are needed.

---

### Mobile Stack

- Flutter
- Simple HTTP client (Dio or http)
- No state management complexity required (setState is fine)

---

### Config

- Base API URL configurable
- Hardcoded test user UUID

---

## Constraints

- No authentication (stub only)
- No offline sync
- No push notifications
- No role handling
- No media uploads
- No maps UI

Keep it brutally simple.

---

## Out of Scope

- Event updates from mobile
- Acknowledge from mobile
- Complex location handling
- Background sync
- Caching layer
- UI polish beyond usability
- Admin/config pages
- Rich navigation

---

## Success Criteria

Sprint is successful when:

- A user can create an event from mobile in under 5 seconds
- Event appears in dashboard feed immediately (via SSE)
- Event title is human-readable (not just type)
- Flow feels faster than sending a WhatsApp message
- No crashes or blocking errors in happy path

---

## Validation Step (MANDATORY)

After implementation:

Test with your brother (or equivalent user):

Ask:

- “Would you use this instead of calling?”
- “What’s annoying?”
- “What’s missing?”

Do NOT guess.
Capture real feedback.

---

## Notes

This sprint completes the core loop:

mobile → backend → realtime → dashboard

This is your first real MVP.

Do not expand scope.

Do not add features.

Ship fast, test fast.

Follow the UI layout in sprint_7.md closely.

Important:
- prioritize the Report Event screen over everything else
- the app must feel like a fast operational tool, not a generic CRUD app
- do not replace the category grid with a long form
- do not add extra screens beyond Report Event and Recent Events unless they are essentially free
- use standard Flutter Material widgets and keep implementation simple

Make the Report Event screen the default landing screen, not Recent Events. That keeps the app aligned with the core value: fast input under pressure.