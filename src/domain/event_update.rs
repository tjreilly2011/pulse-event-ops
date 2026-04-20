use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Serialize, sqlx::FromRow)]
pub struct EventUpdate {
    pub id: Uuid,
    pub event_id: Uuid,
    pub update_type: Option<String>,
    pub content: String,
    pub actor_id: Option<Uuid>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateEventUpdateRequest {
    pub content: String,
    pub actor_id: Option<Uuid>,
    pub update_type: Option<String>,
}
