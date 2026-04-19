use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use sqlx::PgPool;
use uuid::Uuid;

use crate::application::events as event_app;
use crate::domain::event::{CreateEventRequest, Event};

pub async fn create(
    State(pool): State<PgPool>,
    Json(req): Json<CreateEventRequest>,
) -> Result<(StatusCode, Json<Event>), (StatusCode, String)> {
    event_app::create(&pool, req)
        .await
        .map(|event| (StatusCode::CREATED, Json(event)))
        .map_err(|e| {
            tracing::error!("Failed to create event: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Internal server error".to_string(),
            )
        })
}

pub async fn list(State(pool): State<PgPool>) -> Result<Json<Vec<Event>>, (StatusCode, String)> {
    event_app::list(&pool).await.map(Json).map_err(|e| {
        tracing::error!("Failed to list events: {}", e);
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            "Internal server error".to_string(),
        )
    })
}

pub async fn get_by_id(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> Result<Json<Event>, (StatusCode, String)> {
    match event_app::get_by_id(&pool, id).await {
        Ok(Some(event)) => Ok(Json(event)),
        Ok(None) => Err((StatusCode::NOT_FOUND, "Event not found".to_string())),
        Err(e) => {
            tracing::error!("Failed to fetch event {}: {}", id, e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                "Internal server error".to_string(),
            ))
        }
    }
}
