# Sprint 8 — Mobile UX Polish & Operational Feed Clarity

## Phase
PHASE 1 — MVP Build

## Goal
Make the current Flutter mobile app look and feel like a credible operational tool while keeping the flow simple and fast.

## Why This Sprint Matters
The first mobile app proves the backend works, but the UI is too rudimentary for real frontline feedback.

Before adding rail-specific complexity, the app must feel professional, trustworthy, and fast enough for a train/station staff member to use under pressure.

This sprint improves presentation and usability without changing the core backend model.

## Wishlist
- Redesign the Flutter Report Event screen to look professional and operational
- Keep the same core flow:
  - select category
  - optional note
  - submit
- Make category cards visually stronger:
  - larger icons
  - clearer labels
  - stronger selected state
  - consistent spacing
- Add loading, success, and error states
- Improve Recent Events:
  - show title first
  - show status badge clearly
  - show destination/location
  - show timestamp in readable format
  - show newest first
- If low-cost, polish dashboard feed:
  - show title before event type
  - improve status/priority clarity
  - improve empty states
  - hide or disable acknowledge when not applicable
- Use a consistent Material theme
- Keep the app simple and fast

## Constraints
- No backend schema changes unless absolutely necessary
- No auth
- No maps
- No GPS permissions
- No rail-specific data model yet
- No push notifications
- No complex state management
- No new design system package unless clearly justified
- Keep Flutter implementation simple

## Out of Scope
- Rail service model
- Staff presence
- Train/station route logic
- Real-time mobile feed
- Location tracking
- Role-based permissions
- Offline sync

## Success Criteria
- Mobile app feels professional enough to show to a real user
- A user can still create an event in under 5 seconds
- Event categories are easy to tap
- Recent Events list is readable
- No existing backend behavior is broken
- App runs on:
  - Chrome
  - iOS simulator
  - Android emulator
- README includes updated mobile run instructions where needed

## Deliverables
- polished Flutter Report screen
- improved Recent Events screen
- improved mobile theme/styling
- any low-cost dashboard feed polish
- updated README if commands or config changed

## Notes
This sprint is about credibility and usability, not new features.

The product must feel faster than WhatsApp and simple enough to use while moving.
