# Sprint 7 — PROGRESS.md

**Branch**: `feat/mobile-reporting`
**Started**: 2026-04-21

---

## Checklist

- [x] [MO-01] Bootstrap Flutter project
  * Note: mobile/ created with pulse_ops project, http + intl deps added, clean AppShell scaffold, constants.dart created, flutter analyze + flutter test pass
- [x] [MO-02] Create EventModel
  * Note: mobile/lib/models/event_model.dart created, fromJson + displayTitle getter, unit tests pass
- [x] [MO-03] Create ApiService
  * Note: mobile/lib/services/api_service.dart created, http.Client injected for testability, 4 unit tests pass
- [x] [MO-04] Build Report Event screen
  * Note: mobile/lib/screens/report_event_screen.dart created, 4 widget tests pass
- [x] [MO-05] Build Recent Events screen
  * Note: mobile/lib/screens/recent_events_screen.dart created, FutureBuilder + ListView, 5 widget tests pass
- [x] [MO-06] Wire navigation in main.dart
  * Note: main.dart AppShell now uses ReportEventScreen + RecentEventsScreen, widget_test.dart smoke test passes
- [ ] [MO-07] Integration smoke test (manual)

---

## Notes

- No backend changes required for this sprint
- `kApiBaseUrl` must be changed to LAN IP for real-device testing
- GPS is stubbed — `kLocationPlaceholder = 'station-euston'`
