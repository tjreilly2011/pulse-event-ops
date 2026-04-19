pub mod api;
pub mod application;
pub mod config;
pub mod domain;
pub mod infrastructure;

use axum::Router;
use sqlx::PgPool;

pub fn create_app(pool: PgPool) -> Router {
    api::router::build(pool)
}
