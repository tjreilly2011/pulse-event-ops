use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use uuid::Uuid;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, sqlx::Type)]
#[sqlx(type_name = "text", rename_all = "SCREAMING_SNAKE_CASE")]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum EventStatus {
    Created,
    Delivered,
    Acknowledged,
    InProgress,
    Resolved,
    Cancelled,
}

#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct Event {
    pub id: Uuid,
    pub event_type: String,
    pub status: EventStatus,
    pub created_by: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub destination_location_id: String,
    pub source_location_id: Option<String>,
    pub title: Option<String>,
    pub description: Option<String>,
    pub priority: String,
    pub vertical_metadata: Option<Value>,
}

#[derive(Debug, Deserialize)]
pub struct CreateEventRequest {
    pub event_type: String,
    pub created_by: Uuid,
    pub destination_location_id: String,
    pub source_location_id: Option<String>,
    pub title: Option<String>,
    pub description: Option<String>,
    pub priority: Option<String>,
    pub vertical_metadata: Option<Value>,
}
