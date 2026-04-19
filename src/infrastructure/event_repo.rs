use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::event::{CreateEventRequest, Event};

pub async fn insert(pool: &PgPool, req: &CreateEventRequest) -> Result<Event, sqlx::Error> {
    let id = Uuid::new_v4();
    let priority = req.priority.as_deref().unwrap_or("normal");

    sqlx::query_as::<_, Event>(
        r#"
        INSERT INTO events (
            id, event_type, status, created_by,
            destination_location_id, source_location_id,
            title, description, priority, vertical_metadata
        )
        VALUES ($1, $2, 'CREATED', $3, $4, $5, $6, $7, $8, $9)
        RETURNING *
        "#,
    )
    .bind(id)
    .bind(&req.event_type)
    .bind(req.created_by)
    .bind(&req.destination_location_id)
    .bind(&req.source_location_id)
    .bind(&req.title)
    .bind(&req.description)
    .bind(priority)
    .bind(&req.vertical_metadata)
    .fetch_one(pool)
    .await
}

pub async fn list(pool: &PgPool) -> Result<Vec<Event>, sqlx::Error> {
    sqlx::query_as::<_, Event>("SELECT * FROM events ORDER BY created_at DESC")
        .fetch_all(pool)
        .await
}

pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Option<Event>, sqlx::Error> {
    sqlx::query_as::<_, Event>("SELECT * FROM events WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await
}
