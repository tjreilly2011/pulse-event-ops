use sqlx::PgPool;
use uuid::Uuid;

use crate::domain::event::EventStatus;
use crate::domain::rail::StationContext;
use crate::domain::rail::{
    RailService, RailServiceStopTimelineItem, RailStation, ServiceContext, StaffPresence,
    StationServiceStopSummary, StatusDot,
};
use crate::infrastructure::rail_repo;

pub async fn list_services(pool: &PgPool) -> Result<Vec<RailService>, sqlx::Error> {
    rail_repo::list_services(pool).await
}

pub async fn list_stations(pool: &PgPool) -> Result<Vec<RailStation>, sqlx::Error> {
    rail_repo::list_stations(pool).await
}

pub async fn list_presence(pool: &PgPool) -> Result<Vec<StaffPresence>, sqlx::Error> {
    rail_repo::list_presence(pool).await
}

pub async fn get_service(pool: &PgPool, id: Uuid) -> Result<Option<RailService>, sqlx::Error> {
    rail_repo::get_service(pool, id).await
}

pub async fn list_service_stops(
    pool: &PgPool,
    service_id: Uuid,
) -> Result<Vec<RailServiceStopTimelineItem>, sqlx::Error> {
    rail_repo::list_service_stop_timeline(pool, service_id).await
}

pub async fn get_station(pool: &PgPool, id: Uuid) -> Result<Option<RailStation>, sqlx::Error> {
    rail_repo::get_station(pool, id).await
}

pub async fn list_services_for_station(
    pool: &PgPool,
    station_id: Uuid,
) -> Result<Vec<StationServiceStopSummary>, sqlx::Error> {
    rail_repo::list_services_for_station(pool, station_id).await
}

pub async fn get_service_context(
    pool: &PgPool,
    id: Uuid,
) -> Result<Option<ServiceContext>, sqlx::Error> {
    let Some(service) = rail_repo::get_service(pool, id).await? else {
        return Ok(None);
    };

    let stops = rail_repo::list_service_stops(pool, id).await?;
    let staff = rail_repo::get_staff_for_service(pool, id).await?;
    let active_events = rail_repo::get_active_events_for_service(pool, id).await?;

    let status_dot = compute_status_dot(&active_events, &staff, &service.status);

    Ok(Some(ServiceContext {
        service,
        stops,
        staff,
        status_dot,
        active_event_count: active_events.len() as i64,
        active_events,
    }))
}

pub async fn get_station_context(
    pool: &PgPool,
    id: Uuid,
) -> Result<Option<StationContext>, sqlx::Error> {
    let Some(station) = rail_repo::get_station(pool, id).await? else {
        return Ok(None);
    };

    let staff = rail_repo::get_staff_for_station(pool, id).await?;
    let active_events = rail_repo::get_active_events_for_station(pool, id).await?;

    let status = compute_status_dot(&active_events, &staff, "");
    let active_event_count = active_events.len() as i64;
    let staff_on_duty = staff.iter().filter(|s| s.status == "ON_DUTY").count() as i64;

    Ok(Some(StationContext {
        station,
        status,
        active_event_count,
        staff_on_duty,
        active_events,
        staff,
    }))
}

pub(crate) fn compute_status_dot(
    active_events: &[crate::domain::event::Event],
    staff: &[StaffPresence],
    service_status: &str,
) -> StatusDot {
    // Red: critical safety_security event active, OR service CANCELLED
    let has_critical = active_events.iter().any(|e| {
        e.event_type == "safety_security"
            && matches!(e.status, EventStatus::Created | EventStatus::InProgress)
    });

    if has_critical || service_status == "CANCELLED" {
        return StatusDot::Red;
    }

    // Amber: any active event OR zero ON_DUTY staff
    let has_active_event = !active_events.is_empty();
    let on_duty_count = staff.iter().filter(|s| s.status == "ON_DUTY").count();

    if has_active_event || on_duty_count == 0 {
        return StatusDot::Amber;
    }

    StatusDot::Green
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::Utc;
    use uuid::Uuid;

    use crate::domain::event::{Event, EventStatus};
    use crate::domain::rail::StaffPresence;

    fn make_event(event_type: &str, status: EventStatus) -> Event {
        Event {
            id: Uuid::new_v4(),
            event_type: event_type.to_string(),
            status,
            created_by: Uuid::new_v4(),
            created_at: Utc::now(),
            updated_at: Utc::now(),
            acknowledged_by: None,
            acknowledged_at: None,
            destination_location_id: "loc1".to_string(),
            source_location_id: None,
            title: None,
            description: None,
            priority: "NORMAL".to_string(),
            vertical_metadata: None,
        }
    }

    fn make_staff(status: &str) -> StaffPresence {
        StaffPresence {
            id: Uuid::new_v4(),
            actor_id: Uuid::new_v4(),
            role_label: "Guard".to_string(),
            presence_type: "ON_TRAIN".to_string(),
            current_service_id: None,
            current_station_id: None,
            status: status.to_string(),
            last_seen_at: Utc::now(),
            created_at: Utc::now(),
        }
    }

    #[test]
    fn test_green_no_events_one_on_duty_staff() {
        let staff = vec![make_staff("ON_DUTY")];
        let dot = compute_status_dot(&[], &staff, "ON_TIME");
        assert!(matches!(dot, StatusDot::Green));
    }

    #[test]
    fn test_amber_no_events_zero_staff() {
        let dot = compute_status_dot(&[], &[], "ON_TIME");
        assert!(matches!(dot, StatusDot::Amber));
    }

    #[test]
    fn test_red_safety_security_created_event() {
        let events = vec![make_event("safety_security", EventStatus::Created)];
        let staff = vec![make_staff("ON_DUTY")];
        let dot = compute_status_dot(&events, &staff, "ON_TIME");
        assert!(matches!(dot, StatusDot::Red));
    }

    #[test]
    fn test_red_cancelled_service_no_events_no_staff() {
        let dot = compute_status_dot(&[], &[], "CANCELLED");
        assert!(matches!(dot, StatusDot::Red));
    }

    #[test]
    fn station_status_green() {
        let staff = vec![make_staff("ON_DUTY")];
        let dot = compute_status_dot(&[], &staff, "");
        assert!(matches!(dot, StatusDot::Green));
    }

    #[test]
    fn station_status_amber_no_staff() {
        let dot = compute_status_dot(&[], &[], "");
        assert!(matches!(dot, StatusDot::Amber));
    }

    #[test]
    fn station_status_amber_non_critical_event() {
        let events = vec![make_event("delay", EventStatus::InProgress)];
        let staff = vec![make_staff("ON_DUTY")];
        let dot = compute_status_dot(&events, &staff, "");
        assert!(matches!(dot, StatusDot::Amber));
    }

    #[test]
    fn station_status_red_critical_event() {
        let events = vec![make_event("safety_security", EventStatus::InProgress)];
        let staff = vec![make_staff("ON_DUTY")];
        let dot = compute_status_dot(&events, &staff, "");
        assert!(matches!(dot, StatusDot::Red));
    }
}
