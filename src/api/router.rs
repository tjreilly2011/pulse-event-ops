use axum::{
    routing::{get, patch, post},
    Router,
};
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::api::state::AppState;
use crate::api::{dashboard, events, health, sse};

pub fn build(state: AppState) -> Router {
    Router::new()
        .route("/health", get(health::health))
        .route("/events", post(events::create).get(events::list))
        .route("/events/stream", get(sse::stream_events))
        .route("/events/:id", get(events::get_by_id))
        .route("/events/:id/acknowledge", patch(events::acknowledge_event))
        .route(
            "/events/:id/updates",
            post(events::add_event_update).get(events::list_event_updates),
        )
        // Dashboard routes — /feed must come before /:id
        .route("/dashboard/events", get(dashboard::feed_page))
        .route("/dashboard/events/feed", get(dashboard::feed_partial))
        .route("/dashboard/events/:id", get(dashboard::detail_page))
        .route(
            "/dashboard/events/:id/acknowledge",
            patch(dashboard::acknowledge),
        )
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        )
        .layer(TraceLayer::new_for_http())
        .with_state(state)
}
