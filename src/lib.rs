pub mod api;
pub mod application;
pub mod config;
pub mod domain;
pub mod infrastructure;

use axum::Router;
use sqlx::PgPool;
use tokio::sync::broadcast;

use crate::api::state::AppState;
use crate::domain::sse_event::SseEvent;

pub fn create_app(pool: PgPool) -> Router {
    let (tx, _rx) = broadcast::channel::<SseEvent>(128);
    let state = AppState { pool, tx };
    api::router::build(state)
}
