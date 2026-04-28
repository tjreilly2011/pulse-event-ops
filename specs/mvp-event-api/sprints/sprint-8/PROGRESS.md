# Sprint 8 Progress — Mobile UX Polish & Operational Feed Clarity

**Branch**: `feat/mobile-ux-polish`
**Phase**: PHASE 1 — MVP Build

---

## Tasks

### Mobile
- [x] MO-01: Apply operational theme to MaterialApp
    * Note: replaced ColorScheme.fromSeed with ColorScheme.light(navy primary, amber secondary)
- [x] MO-02: Polish Report Event category cards
    * Note: larger icons (36), strong selected border+fill, removed Selected label text
- [x] MO-03: Add loading state to Submit button
    * Note: CircularProgressIndicator.adaptive shown while _isSubmitting; test 5 verifies spinner present
- [x] MO-04: Polish Recent Events list
    * Note: Card layout, _statusBadge with colour-coded Container, improved empty state (Icons.inbox_outlined)
- [x] MO-05: Add pull-to-refresh on Recent Events
    * Note: _refresh() resets _eventsFuture; ListView wrapped in RefreshIndicator

### Dashboard
- [x] FE-01: Show title first in dashboard event list
    * Note: event_list.html — if title present, show title primary + event_type secondary; else event_type only
- [x] FE-02: Hide disabled Acknowledge button on detail page
    * Note: events_detail.html — only render Acknowledge for Created/Delivered; hidden for all other statuses

---

## Gates
- [x] `flutter test` all pass — 21/21
- [x] `cargo test` all pass — 21/21
- [x] `cargo fmt` clean
- [x] `cargo clippy` clean
- [ ] Manual smoke test (Chrome + dashboard)
- [x] `ralph/` NOT committed
