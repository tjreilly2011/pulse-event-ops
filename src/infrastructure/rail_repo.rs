use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::event::Event;
use crate::domain::rail::{
    RailEventContext, RailRoute, RailService, RailServiceStop, RailStation, StaffPresence,
};

pub async fn list_routes(pool: &PgPool) -> Result<Vec<RailRoute>, sqlx::Error> {
    sqlx::query_as::<_, RailRoute>("SELECT * FROM rail_routes ORDER BY name ASC")
        .fetch_all(pool)
        .await
}

pub async fn list_services(pool: &PgPool) -> Result<Vec<RailService>, sqlx::Error> {
    sqlx::query_as::<_, RailService>("SELECT * FROM rail_services ORDER BY created_at DESC")
        .fetch_all(pool)
        .await
}

pub async fn get_service(pool: &PgPool, id: Uuid) -> Result<Option<RailService>, sqlx::Error> {
    sqlx::query_as::<_, RailService>("SELECT * FROM rail_services WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await
}

pub async fn list_service_stops(
    pool: &PgPool,
    service_id: Uuid,
) -> Result<Vec<RailServiceStop>, sqlx::Error> {
    sqlx::query_as::<_, RailServiceStop>(
        "SELECT * FROM rail_service_stops WHERE service_id = $1 ORDER BY stop_sequence ASC",
    )
    .bind(service_id)
    .fetch_all(pool)
    .await
}

pub async fn list_stations(pool: &PgPool) -> Result<Vec<RailStation>, sqlx::Error> {
    sqlx::query_as::<_, RailStation>("SELECT * FROM rail_stations ORDER BY name ASC")
        .fetch_all(pool)
        .await
}

pub async fn get_station(pool: &PgPool, id: Uuid) -> Result<Option<RailStation>, sqlx::Error> {
    sqlx::query_as::<_, RailStation>("SELECT * FROM rail_stations WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await
}

pub async fn list_presence(pool: &PgPool) -> Result<Vec<StaffPresence>, sqlx::Error> {
    sqlx::query_as::<_, StaffPresence>("SELECT * FROM staff_presence ORDER BY last_seen_at DESC")
        .fetch_all(pool)
        .await
}

pub async fn insert_rail_event_context(
    pool: &PgPool,
    event_id: Uuid,
    service_id: Option<Uuid>,
    station_id: Option<Uuid>,
) -> Result<RailEventContext, sqlx::Error> {
    sqlx::query_as::<_, RailEventContext>(
        r#"
        INSERT INTO rail_event_context (event_id, rail_service_id, rail_station_id)
        VALUES ($1, $2, $3)
        RETURNING *
        "#,
    )
    .bind(event_id)
    .bind(service_id)
    .bind(station_id)
    .fetch_one(pool)
    .await
}

pub async fn insert_rail_event_context_in_tx(
    tx: &mut sqlx::Transaction<'_, sqlx::Postgres>,
    event_id: Uuid,
    service_id: Option<Uuid>,
    station_id: Option<Uuid>,
) -> Result<RailEventContext, sqlx::Error> {
    sqlx::query_as::<_, RailEventContext>(
        r#"
        INSERT INTO rail_event_context (event_id, rail_service_id, rail_station_id)
        VALUES ($1, $2, $3)
        RETURNING *
        "#,
    )
    .bind(event_id)
    .bind(service_id)
    .bind(station_id)
    .fetch_one(&mut **tx)
    .await
}

pub async fn get_rail_event_context_for_event(
    pool: &PgPool,
    event_id: Uuid,
) -> Result<Option<RailEventContext>, sqlx::Error> {
    sqlx::query_as::<_, RailEventContext>("SELECT * FROM rail_event_context WHERE event_id = $1")
        .bind(event_id)
        .fetch_optional(pool)
        .await
}

pub async fn validate_service_exists(pool: &PgPool, id: Uuid) -> Result<bool, sqlx::Error> {
    let row: Option<(Uuid,)> = sqlx::query_as("SELECT id FROM rail_services WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await?;
    Ok(row.is_some())
}

pub async fn validate_station_exists(pool: &PgPool, id: Uuid) -> Result<bool, sqlx::Error> {
    let row: Option<(Uuid,)> = sqlx::query_as("SELECT id FROM rail_stations WHERE id = $1")
        .bind(id)
        .fetch_optional(pool)
        .await?;
    Ok(row.is_some())
}

pub async fn get_active_events_for_service(
    pool: &PgPool,
    service_id: Uuid,
) -> Result<Vec<Event>, sqlx::Error> {
    sqlx::query_as::<_, Event>(
        r#"
        SELECT e.*
        FROM events e
        JOIN rail_event_context rec ON e.id = rec.event_id
        WHERE rec.rail_service_id = $1
          AND e.status IN ('CREATED', 'IN_PROGRESS')
        ORDER BY e.created_at DESC
        "#,
    )
    .bind(service_id)
    .fetch_all(pool)
    .await
}

pub async fn get_staff_for_service(
    pool: &PgPool,
    service_id: Uuid,
) -> Result<Vec<StaffPresence>, sqlx::Error> {
    sqlx::query_as::<_, StaffPresence>(
        "SELECT * FROM staff_presence WHERE current_service_id = $1 ORDER BY last_seen_at DESC",
    )
    .bind(service_id)
    .fetch_all(pool)
    .await
}
