# PROGRESS: Sprint 4 — Event Acknowledgment & Updates

**Branch**: `feat/event-acknowledgment-and-updates`
**Initialised**: 2026-04-20

---

- [x] [BE-01] Write migration: extend events + create event_updates table
  * Note: migrations/0002_acknowledge_and_updates.sql created; events extended with acknowledged_by/acknowledged_at; event_updates table created as plain Postgres table (no FK, no hypertable)
- [x] [BE-02] Extend domain Event model
  * Note: src/domain/event.rs — acknowledged_by: Option<Uuid>, acknowledged_at: Option<DateTime<Utc>> added to Event struct
- [x] [BE-03] Create EventUpdate domain model
  * Note: src/domain/event_update.rs created (EventUpdate, CreateEventUpdateRequest); src/domain/mod.rs updated
- [x] [BE-04] Create update_repo infrastructure
  * Note: src/infrastructure/update_repo.rs created (insert, list_by_event); src/infrastructure/mod.rs updated
- [x] [BE-05] Implement acknowledge_event in event_repo (transactional)
  * Note: src/infrastructure/event_repo.rs — acknowledge_event added using pool.begin()/tx.commit(); atomic UPDATE events + INSERT event_updates
- [x] [BE-06] Add use-case functions to application layer
  * Note: src/application/events.rs — acknowledge, add_update, list_updates added; AcknowledgeError, AddUpdateError enums added; AcknowledgeEventRequest defined
- [x] [BE-07] Add API handlers
  * Note: src/api/events.rs — acknowledge_event, add_event_update, list_event_updates handlers added; 404/409/500 responses correct
- [x] [BE-08] Wire new routes in router
  * Note: src/api/router.rs — PATCH /events/:id/acknowledge, POST/GET /events/:id/updates wired
- [x] [BE-09] Write integration tests
  * Note: tests/events_test.rs — 7 new tests added (acknowledge, duplicate, timeline, add_update, list_updates, 2x 404); all 12 tests pass
- [x] [BE-10] Update README
  * Note: README.md — 3 new endpoints added to API table; smoke gates 7 and 8 added
- [x] [BE-11] Update PROGRESS.md
  * Note: All 11 tasks complete; 12/12 tests pass; sprint ready for PR
