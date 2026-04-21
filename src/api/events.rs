use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use sqlx::PgPool;
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::application::events::{
    self as event_app, AcknowledgeError, AcknowledgeEventRequest, AddUpdateError,
};
use crate::domain::event::{CreateEventRequest, Event};
use crate::domain::event_update::CreateEventUpdateRequest;
use crate::domain::sse_event::SseEvent;

pub async fn create(
    State(pool): State<PgPool>,
    State(tx): State<broadcast::Sender<SseEvent>>,
    Json(req): Json<CreateEventRequest>,
) -> Result<(StatusCode, Json<Event>), (StatusCode, String)> {
    event_app::create(&pool, &tx, req)
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

pub async fn acknowledge_event(
    State(pool): State<PgPool>,
    State(tx): State<broadcast::Sender<SseEvent>>,
    Path(id): Path<Uuid>,
    Json(req): Json<AcknowledgeEventRequest>,
) -> impl IntoResponse {
    match event_app::acknowledge(&pool, &tx, id, req).await {
        Ok(event) => (StatusCode::OK, Json(event)).into_response(),
        Err(AcknowledgeError::NotFound) => {
            (StatusCode::NOT_FOUND, "Event not found").into_response()
        }
        Err(AcknowledgeError::InvalidStatus) => (
            StatusCode::CONFLICT,
            Json(
                serde_json::json!({"error": "event cannot be acknowledged in its current status"}),
            ),
        )
            .into_response(),
        Err(AcknowledgeError::Db(e)) => {
            tracing::error!("Failed to acknowledge event {}: {}", id, e);
            (StatusCode::INTERNAL_SERVER_ERROR, "Internal server error").into_response()
        }
    }
}

pub async fn add_event_update(
    State(pool): State<PgPool>,
    State(tx): State<broadcast::Sender<SseEvent>>,
    Path(id): Path<Uuid>,
    Json(req): Json<CreateEventUpdateRequest>,
) -> impl IntoResponse {
    match event_app::add_update(&pool, &tx, id, req).await {
        Ok(update) => (StatusCode::CREATED, Json(update)).into_response(),
        Err(AddUpdateError::NotFound) => (StatusCode::NOT_FOUND, "Event not found").into_response(),
        Err(AddUpdateError::Db(e)) => {
            tracing::error!("Failed to add update for event {}: {}", id, e);
            (StatusCode::INTERNAL_SERVER_ERROR, "Internal server error").into_response()
        }
    }
}

pub async fn list_event_updates(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    match event_app::list_updates(&pool, id).await {
        Ok(updates) => (StatusCode::OK, Json(updates)).into_response(),
        Err(e) => {
            tracing::error!("Failed to list updates for event {}: {}", id, e);
            (StatusCode::INTERNAL_SERVER_ERROR, "Internal server error").into_response()
        }
    }
}
