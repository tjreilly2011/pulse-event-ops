use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::event::{CreateEventRequest, Event, EventStatus};
use crate::domain::event_update::{CreateEventUpdateRequest, EventUpdate};
use crate::infrastructure::{event_repo, update_repo};

#[derive(Debug, serde::Deserialize)]
pub struct AcknowledgeEventRequest {
    pub acknowledged_by: Uuid,
}

pub enum AcknowledgeError {
    NotFound,
    InvalidStatus,
    Db(sqlx::Error),
}

pub enum AddUpdateError {
    NotFound,
    Db(sqlx::Error),
}

pub async fn create(pool: &PgPool, req: CreateEventRequest) -> Result<Event, sqlx::Error> {
    event_repo::insert(pool, &req).await
}

pub async fn list(pool: &PgPool) -> Result<Vec<Event>, sqlx::Error> {
    event_repo::list(pool).await
}

pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Event>, sqlx::Error> {
    event_repo::get_by_id(pool, id).await
}

pub async fn acknowledge(
    pool: &PgPool,
    event_id: Uuid,
    req: AcknowledgeEventRequest,
) -> Result<Event, AcknowledgeError> {
    let event = event_repo::get_by_id(pool, event_id)
        .await
        .map_err(AcknowledgeError::Db)?
        .ok_or(AcknowledgeError::NotFound)?;

    match event.status {
        EventStatus::Created | EventStatus::Delivered => {}
        _ => return Err(AcknowledgeError::InvalidStatus),
    }

    event_repo::acknowledge_event(pool, event_id, req.acknowledged_by)
        .await
        .map_err(AcknowledgeError::Db)
}

pub async fn add_update(
    pool: &PgPool,
    event_id: Uuid,
    req: CreateEventUpdateRequest,
) -> Result<EventUpdate, AddUpdateError> {
    event_repo::get_by_id(pool, event_id)
        .await
        .map_err(AddUpdateError::Db)?
        .ok_or(AddUpdateError::NotFound)?;

    let update_type = req.update_type.as_deref().unwrap_or("NOTE").to_string();
    update_repo::insert(
        pool,
        event_id,
        Some(&update_type),
        &req.content,
        req.actor_id,
    )
    .await
    .map_err(AddUpdateError::Db)
}

pub async fn list_updates(pool: &PgPool, event_id: Uuid) -> Result<Vec<EventUpdate>, sqlx::Error> {
    update_repo::list_by_event(pool, event_id).await
}
