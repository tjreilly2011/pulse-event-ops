use axum::extract::FromRef;
use sqlx::PgPool;
use tokio::sync::broadcast;

use crate::domain::sse_event::SseEvent;

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub tx: broadcast::Sender<SseEvent>,
}

impl FromRef<AppState> for PgPool {
    fn from_ref(state: &AppState) -> Self {
        state.pool.clone()
    }
}

impl FromRef<AppState> for broadcast::Sender<SseEvent> {
    fn from_ref(state: &AppState) -> Self {
        state.tx.clone()
    }
}
