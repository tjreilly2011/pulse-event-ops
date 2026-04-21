use sqlx::PgPool;
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::domain::event::{CreateEventRequest, Event, EventStatus};
use crate::domain::event_update::{CreateEventUpdateRequest, EventUpdate};
use crate::domain::sse_event::SseEvent;
use crate::infrastructure::{event_repo, update_repo};

#[derive(Debug, serde::Deserialize)]
pub struct AcknowledgeEventRequest {
    pub acknowledged_by: Uuid,
}

#[derive(Debug)]
pub enum AcknowledgeError {
    NotFound,
    InvalidStatus,
    Db(sqlx::Error),
}

#[derive(Debug)]
pub enum AddUpdateError {
    NotFound,
    Db(sqlx::Error),
}

pub async fn create(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
    req: CreateEventRequest,
) -> Result<Event, sqlx::Error> {
    let event = event_repo::insert(pool, &req).await?;
    let _ = tx.send(SseEvent::EventCreated {
        event: event.clone(),
    });
    Ok(event)
}

pub async fn list(pool: &PgPool) -> Result<Vec<Event>, sqlx::Error> {
    event_repo::list(pool).await
}

pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Event>, sqlx::Error> {
    event_repo::get_by_id(pool, id).await
}

pub async fn acknowledge(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
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

    let event = event_repo::acknowledge_event(pool, event_id, req.acknowledged_by)
        .await
        .map_err(AcknowledgeError::Db)?;
    let _ = tx.send(SseEvent::EventAcknowledged {
        event: event.clone(),
    });
    Ok(event)
}

pub async fn add_update(
    pool: &PgPool,
    tx: &broadcast::Sender<SseEvent>,
    event_id: Uuid,
    req: CreateEventUpdateRequest,
) -> Result<EventUpdate, AddUpdateError> {
    event_repo::get_by_id(pool, event_id)
        .await
        .map_err(AddUpdateError::Db)?
        .ok_or(AddUpdateError::NotFound)?;

    let update_type = req.update_type.as_deref().unwrap_or("NOTE").to_string();
    let update = update_repo::insert(
        pool,
        event_id,
        Some(&update_type),
        &req.content,
        req.actor_id,
    )
    .await
    .map_err(AddUpdateError::Db)?;
    let _ = tx.send(SseEvent::EventUpdateAdded {
        update: update.clone(),
    });
    Ok(update)
}

pub async fn list_updates(pool: &PgPool, event_id: Uuid) -> Result<Vec<EventUpdate>, sqlx::Error> {
    update_repo::list_by_event(pool, event_id).await
}
