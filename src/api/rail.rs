use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use sqlx::PgPool;
use uuid::Uuid;

use crate::application;

pub async fn list_services(State(pool): State<PgPool>) -> impl IntoResponse {
    match application::rail::list_services(&pool).await {
        Ok(services) => (StatusCode::OK, Json(services)).into_response(),
        Err(e) => {
            tracing::error!("Failed to list rail services: {}", e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn get_service_by_id(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    match application::rail::get_service(&pool, id).await {
        Ok(Some(service)) => (StatusCode::OK, Json(service)).into_response(),
        Ok(None) => StatusCode::NOT_FOUND.into_response(),
        Err(e) => {
            tracing::error!("Failed to get rail service {}: {}", id, e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn list_service_stops(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    match application::rail::get_service(&pool, id).await {
        Ok(None) => return StatusCode::NOT_FOUND.into_response(),
        Err(e) => {
            tracing::error!("Failed to check rail service {}: {}", id, e);
            return StatusCode::INTERNAL_SERVER_ERROR.into_response();
        }
        Ok(Some(_)) => {}
    }
    match application::rail::list_service_stops(&pool, id).await {
        Ok(stops) => (StatusCode::OK, Json(stops)).into_response(),
        Err(e) => {
            tracing::error!("Failed to list stops for service {}: {}", id, e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn get_service_context(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    match application::rail::get_service_context(&pool, id).await {
        Ok(Some(ctx)) => (StatusCode::OK, Json(ctx)).into_response(),
        Ok(None) => StatusCode::NOT_FOUND.into_response(),
        Err(e) => {
            tracing::error!("Failed to get service context {}: {}", id, e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn list_stations(State(pool): State<PgPool>) -> impl IntoResponse {
    match application::rail::list_stations(&pool).await {
        Ok(stations) => (StatusCode::OK, Json(stations)).into_response(),
        Err(e) => {
            tracing::error!("Failed to list rail stations: {}", e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn get_station_by_id(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    match application::rail::get_station(&pool, id).await {
        Ok(Some(station)) => (StatusCode::OK, Json(station)).into_response(),
        Ok(None) => StatusCode::NOT_FOUND.into_response(),
        Err(e) => {
            tracing::error!("Failed to get rail station {}: {}", id, e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn list_presence(State(pool): State<PgPool>) -> impl IntoResponse {
    match application::rail::list_presence(&pool).await {
        Ok(presence) => (StatusCode::OK, Json(presence)).into_response(),
        Err(e) => {
            tracing::error!("Failed to list staff presence: {}", e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}

pub async fn get_station_context(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
) -> impl IntoResponse {
    match application::rail::get_station_context(&pool, id).await {
        Ok(Some(ctx)) => (StatusCode::OK, Json(ctx)).into_response(),
        Ok(None) => StatusCode::NOT_FOUND.into_response(),
        Err(e) => {
            tracing::error!("Failed to get station context {}: {}", id, e);
            StatusCode::INTERNAL_SERVER_ERROR.into_response()
        }
    }
}
