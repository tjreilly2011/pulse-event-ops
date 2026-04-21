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

impl std::fmt::Display for EventStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = match self {
            EventStatus::Created => "CREATED",
            EventStatus::Delivered => "DELIVERED",
            EventStatus::Acknowledged => "ACKNOWLEDGED",
            EventStatus::InProgress => "IN_PROGRESS",
            EventStatus::Resolved => "RESOLVED",
            EventStatus::Cancelled => "CANCELLED",
        };
        write!(f, "{s}")
    }
}

impl EventStatus {
    /// Returns the DaisyUI badge CSS class for this status.
    pub fn badge_class(&self) -> &'static str {
        match self {
            EventStatus::Created => "badge-info",
            EventStatus::Delivered => "badge-secondary",
            EventStatus::Acknowledged => "badge-success",
            EventStatus::InProgress => "badge-warning",
            EventStatus::Resolved => "badge-neutral",
            EventStatus::Cancelled => "badge-error",
        }
    }
}

#[derive(Debug, Clone, Serialize, sqlx::FromRow)]
pub struct Event {
    pub id: Uuid,
    pub event_type: String,
    pub status: EventStatus,
    pub created_by: Uuid,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub acknowledged_by: Option<Uuid>,
    pub acknowledged_at: Option<DateTime<Utc>>,
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
