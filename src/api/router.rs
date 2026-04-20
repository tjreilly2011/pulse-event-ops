use axum::{
    routing::{get, patch, post},
    Router,
};
use tower_http::trace::TraceLayer;

use crate::api::{events, health, state::AppState};

pub fn build(state: AppState) -> Router {
    Router::new()
        .route("/health", get(health::health))
        .route("/events", post(events::create).get(events::list))
        .route("/events/:id", get(events::get_by_id))
        .route("/events/:id/acknowledge", patch(events::acknowledge_event))
        .route(
            "/events/:id/updates",
            post(events::add_event_update).get(events::list_event_updates),
        )
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}
