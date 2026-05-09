use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::domain::event::Event;

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct RailRoute {
    pub id: Uuid,
    pub name: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct RailStation {
    pub id: Uuid,
    pub name: String,
    pub code: String,
    pub region: Option<String>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct RailService {
    pub id: Uuid,
    pub service_code: String,
    pub route_id: Option<Uuid>,
    pub direction: String,
    pub scheduled_start_time: Option<DateTime<Utc>>,
    pub scheduled_end_time: Option<DateTime<Utc>>,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct RailServiceStop {
    pub id: Uuid,
    pub service_id: Option<Uuid>,
    pub station_id: Option<Uuid>,
    pub scheduled_arrival: Option<DateTime<Utc>>,
    pub scheduled_departure: Option<DateTime<Utc>>,
    pub stop_sequence: i32,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct StaffPresence {
    pub id: Uuid,
    pub actor_id: Uuid,
    pub role_label: String,
    pub presence_type: String,
    pub current_service_id: Option<Uuid>,
    pub current_station_id: Option<Uuid>,
    pub status: String,
    pub last_seen_at: DateTime<Utc>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct RailEventContext {
    pub event_id: Uuid,
    pub rail_service_id: Option<Uuid>,
    pub rail_station_id: Option<Uuid>,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum StatusDot {
    Green,
    Amber,
    Red,
}

#[derive(Debug, Clone, Serialize)]
pub struct ServiceContext {
    pub service: RailService,
    pub stops: Vec<RailServiceStop>,
    pub staff: Vec<StaffPresence>,
    pub status_dot: StatusDot,
    pub active_event_count: i64,
    pub active_events: Vec<Event>,
}

#[derive(Debug, Clone, Serialize)]
pub struct StationContext {
    pub station: RailStation,
    pub status: StatusDot,
    pub active_event_count: i64,
    pub staff_on_duty: i64,
    pub active_events: Vec<Event>,
    pub staff: Vec<StaffPresence>,
}
