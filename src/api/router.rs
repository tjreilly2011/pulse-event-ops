use axum::{
    routing::{get, patch, post},
    Router,
};
use tower_http::cors::{Any, CorsLayer};
use tower_http::trace::TraceLayer;

use crate::api::state::AppState;
use crate::api::{dashboard, events, health, rail, rail_dashboard, sse};

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
        // Rail routes
        .route("/rail/services", get(rail::list_services))
        .route("/rail/services/:id", get(rail::get_service_by_id))
        .route("/rail/services/:id/stops", get(rail::list_service_stops))
        .route("/rail/services/:id/context", get(rail::get_service_context))
        .route("/rail/stations", get(rail::list_stations))
        .route("/rail/stations/:id", get(rail::get_station_by_id))
        .route("/rail/presence", get(rail::list_presence))
        // Rail dashboard routes
        .route(
            "/dashboard/rail/services",
            get(rail_dashboard::services_page),
        )
        .route(
            "/dashboard/rail/stations",
            get(rail_dashboard::stations_page),
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
