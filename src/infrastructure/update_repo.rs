use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::event_update::EventUpdate;

pub async fn insert(
    pool: &PgPool,
    event_id: Uuid,
    update_type: Option<&str>,
    content: &str,
    actor_id: Option<Uuid>,
) -> Result<EventUpdate, sqlx::Error> {
    sqlx::query_as::<_, EventUpdate>(
        "INSERT INTO event_updates (event_id, update_type, content, actor_id) VALUES ($1, $2, $3, $4) RETURNING *",
    )
    .bind(event_id)
    .bind(update_type)
    .bind(content)
    .bind(actor_id)
    .fetch_one(pool)
    .await
}

pub async fn list_by_event(pool: &PgPool, event_id: Uuid) -> Result<Vec<EventUpdate>, sqlx::Error> {
    sqlx::query_as::<_, EventUpdate>(
        "SELECT * FROM event_updates WHERE event_id = $1 ORDER BY created_at ASC",
    )
    .bind(event_id)
    .fetch_all(pool)
    .await
}

/// Returns updates for an event ordered newest first (used by dashboard timeline).
pub async fn list_for_event(
    pool: &PgPool,
    event_id: Uuid,
) -> Result<Vec<EventUpdate>, sqlx::Error> {
    sqlx::query_as::<_, EventUpdate>(
        "SELECT * FROM event_updates WHERE event_id = $1 ORDER BY created_at DESC",
    )
    .bind(event_id)
    .fetch_all(pool)
    .await
}
