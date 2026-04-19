use axum::{
    routing::{get, post},
    Router,
};
use sqlx::PgPool;
use tower_http::trace::TraceLayer;

use crate::api::{events, health};

pub fn build(pool: PgPool) -> Router {
    Router::new()
        .route("/health", get(health::health))
        .route("/events", post(events::create).get(events::list))
        .route("/events/:id", get(events::get_by_id))
        .layer(TraceLayer::new_for_http())
        .with_state(pool)
}
