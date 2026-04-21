# Sprint 5 — Realtime (SSE) — Progress

**Branch**: `feat/sse-realtime-feed`
**Started**: 2026-04-20

## Tasks

- [x] BE-01 — Add tokio-stream to Cargo.toml
  * Note: Added tokio-stream 0.1 with sync feature to Cargo.toml
- [x] BE-02 — Add SseEvent domain type
  * Note: Created src/domain/sse_event.rs with EventCreated/EventAcknowledged/EventUpdateAdded; added Clone to EventUpdate; added pub mod sse_event to domain/mod.rs
- [x] BE-03 — Add AppState + FromRef impls
  * Note: Created src/api/state.rs with AppState, FromRef<AppState> for PgPool and Sender; added pub mod state to api/mod.rs
- [x] BE-04 — Update create_app to use AppState
  * Note: create_app now creates broadcast::channel + AppState; router::build updated to accept AppState; existing tests pass unchanged
- [x] BE-05 — Update router (AppState + /events/stream route)
  * Note: Added GET /events/stream route before /events/:id; created sse.rs stub; pub mod sse added to api/mod.rs
- [x] BE-06 — Add SSE handler
  * Note: Real BroadcastStream + filter_map SSE handler implemented; KeepAlive default; lag errors silently skipped
- [x] BE-07 — Update application::create to emit SSE
  * Note: create gains tx param; emits EventCreated after insert; let _ = tx.send discards no-subscriber error
- [x] BE-08 — Update application::acknowledge to emit SSE
  * Note: acknowledge gains tx param; emits EventAcknowledged after successful ack; best-effort send
- [x] BE-09 — Update application::add_update to emit SSE
  * Note: add_update gains tx param; emits EventUpdateAdded after insert; best-effort send
- [x] BE-10 — Update API handlers to extract tx
  * Note: Batched with BE-07/08/09; create/acknowledge_event/add_event_update now extract State(tx): State<broadcast::Sender<SseEvent>> and pass &tx to app functions
- [x] BE-11 — Add SSE tests
  * Note: 4 new tests added (SSE HTTP 200, EventCreated broadcast, EventAcknowledged broadcast, EventUpdateAdded broadcast); 16/16 tests pass
- [x] BE-12 — Update README
  * Note: Added Realtime SSE section with curl example and 3 event payload shapes; GET /events/stream added to endpoint table

## Notes
