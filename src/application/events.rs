use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::event::{CreateEventRequest, Event};
use crate::infrastructure::event_repo;

pub async fn create(pool: &PgPool, req: CreateEventRequest) -> Result<Event, sqlx::Error> {
    event_repo::insert(pool, &req).await
}

pub async fn list(pool: &PgPool) -> Result<Vec<Event>, sqlx::Error> {
    event_repo::list(pool).await
}

pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Event>, sqlx::Error> {
    event_repo::get_by_id(pool, id).await
}
