use askama::Template;
use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{Html, IntoResponse, Response},
};
use sqlx::PgPool;
use uuid::Uuid;

use crate::application::rail;
use crate::domain::event::Event;
use crate::domain::rail::StaffPresence;
use crate::domain::rail::StatusDot;

// ─── View models ─────────────────────────────────────────────────────────────

struct ServiceRow {
    id: String,
    service_code: String,
    direction: String,
    status: String,
    dot_class: String,
}

struct StationRow {
    id: String,
    name: String,
    code: String,
    region: String,
    dot_class: String,
}

struct EventRow {
    id: String,
    event_type: String,
    status: String,
    priority: String,
    title: String,
}

struct StaffRow {
    actor_id: String,
    role_label: String,
    presence_type: String,
    status: String,
    last_seen_at: String,
}

struct StopRow {
    stop_sequence: i32,
    station_id: String,
    scheduled_arrival: String,
    scheduled_departure: String,
}

// ─── Template structs ────────────────────────────────────────────────────────

#[derive(Template)]
#[template(path = "rail_services.html")]
struct RailServicesTemplate {
    services: Vec<ServiceRow>,
}

#[derive(Template)]
#[template(path = "rail_stations.html")]
struct RailStationsTemplate {
    stations: Vec<StationRow>,
}

#[derive(Template)]
#[template(path = "rail_service_detail.html")]
struct RailServiceDetailTemplate {
    service_id: String,
    service_code: String,
    direction: String,
    status: String,
    dot_class: String,
    route_id: String,
    scheduled_start_time: String,
    scheduled_end_time: String,
    active_event_count: i64,
    staff_total_count: usize,
    staff_on_duty_count: usize,
    stops: Vec<StopRow>,
    events: Vec<EventRow>,
    staff: Vec<StaffRow>,
}

#[derive(Template)]
#[template(path = "rail_station_detail.html")]
struct RailStationDetailTemplate {
    station_id: String,
    station_name: String,
    station_code: String,
    station_region: String,
    dot_class: String,
    active_event_count: i64,
    staff_total_count: usize,
    staff_on_duty_count: i64,
    events: Vec<EventRow>,
    staff: Vec<StaffRow>,
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

fn render<T: Template>(tpl: T) -> Response {
    match tpl.render() {
        Ok(html) => Html(html).into_response(),
        Err(e) => {
            tracing::error!("Template render error: {e}");
            (StatusCode::INTERNAL_SERVER_ERROR, "Template error").into_response()
        }
    }
}

fn status_dot_class(dot: &StatusDot) -> &'static str {
    match dot {
        StatusDot::Green => "bg-green-500",
        StatusDot::Amber => "bg-amber-400",
        StatusDot::Red => "bg-red-500",
    }
}

fn format_optional_time(ts: Option<chrono::DateTime<chrono::Utc>>) -> String {
    ts.map(|t| t.format("%Y-%m-%d %H:%M UTC").to_string())
        .unwrap_or_else(|| "-".to_string())
}

fn map_event_row(event: Event) -> EventRow {
    EventRow {
        id: event.id.to_string(),
        event_type: event.event_type,
        status: event.status.to_string(),
        priority: event.priority,
        title: event.title.unwrap_or_else(|| "-".to_string()),
    }
}

fn map_staff_row(staff: StaffPresence) -> StaffRow {
    StaffRow {
        actor_id: staff.actor_id.to_string(),
        role_label: staff.role_label,
        presence_type: staff.presence_type,
        status: staff.status,
        last_seen_at: staff.last_seen_at.format("%Y-%m-%d %H:%M UTC").to_string(),
    }
}

fn context_not_found_response(kind: &str, id: &uuid::Uuid) -> Response {
    tracing::error!("Missing {kind} context for dashboard row: {id}");
    (
        StatusCode::INTERNAL_SERVER_ERROR,
        "Failed to load dashboard context",
    )
        .into_response()
}

fn context_error_response(kind: &str, id: &uuid::Uuid, err: &sqlx::Error) -> Response {
    tracing::error!("Could not get {kind} context for {id}: {err}");
    (
        StatusCode::INTERNAL_SERVER_ERROR,
        "Failed to load dashboard context",
    )
        .into_response()
}

// ─── Handlers ────────────────────────────────────────────────────────────────

/// GET /dashboard/rail/services
pub async fn services_page(State(pool): State<PgPool>) -> Response {
    let services = match rail::list_services(&pool).await {
        Ok(s) => s,
        Err(e) => {
            tracing::error!("rail services_page error: {e}");
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to load rail services",
            )
                .into_response();
        }
    };

    let mut rows = Vec::with_capacity(services.len());
    for svc in services {
        let id = svc.id;
        let dot = match rail::get_service_context(&pool, id).await {
            Ok(Some(ctx)) => ctx.status_dot,
            Ok(None) => return context_not_found_response("service", &id),
            Err(e) => return context_error_response("service", &id, &e),
        };
        rows.push(ServiceRow {
            id: id.to_string(),
            dot_class: status_dot_class(&dot).to_string(),
            service_code: svc.service_code,
            direction: svc.direction,
            status: svc.status,
        });
    }

    render(RailServicesTemplate { services: rows })
}

/// GET /dashboard/rail/stations
pub async fn stations_page(State(pool): State<PgPool>) -> Response {
    let stations = match rail::list_stations(&pool).await {
        Ok(s) => s,
        Err(e) => {
            tracing::error!("rail stations_page error: {e}");
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to load rail stations",
            )
                .into_response();
        }
    };

    let mut rows = Vec::with_capacity(stations.len());
    for station in stations {
        let id = station.id;
        let dot = match rail::get_station_context(&pool, id).await {
            Ok(Some(ctx)) => ctx.status,
            Ok(None) => return context_not_found_response("station", &id),
            Err(e) => return context_error_response("station", &id, &e),
        };
        rows.push(StationRow {
            id: id.to_string(),
            dot_class: status_dot_class(&dot).to_string(),
            name: station.name,
            code: station.code,
            region: station.region.unwrap_or_else(|| "-".to_string()),
        });
    }

    render(RailStationsTemplate { stations: rows })
}

/// GET /dashboard/rail/services/:id
pub async fn service_detail_page(State(pool): State<PgPool>, Path(id): Path<Uuid>) -> Response {
    let context = match rail::get_service_context(&pool, id).await {
        Ok(Some(ctx)) => ctx,
        Ok(None) => return (StatusCode::NOT_FOUND, "Rail service not found").into_response(),
        Err(e) => {
            tracing::error!("rail service_detail_page error for {}: {}", id, e);
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to load rail service detail",
            )
                .into_response();
        }
    };

    let staff_total_count = context.staff.len();
    let staff_on_duty_count = context
        .staff
        .iter()
        .filter(|staff| staff.status == "ON_DUTY")
        .count();

    let stops = context
        .stops
        .into_iter()
        .map(|stop| StopRow {
            stop_sequence: stop.stop_sequence,
            station_id: stop
                .station_id
                .map(|station_id| station_id.to_string())
                .unwrap_or_else(|| "-".to_string()),
            scheduled_arrival: format_optional_time(stop.scheduled_arrival),
            scheduled_departure: format_optional_time(stop.scheduled_departure),
        })
        .collect::<Vec<_>>();

    let events = context
        .active_events
        .into_iter()
        .map(map_event_row)
        .collect::<Vec<_>>();

    let staff = context
        .staff
        .into_iter()
        .map(map_staff_row)
        .collect::<Vec<_>>();

    render(RailServiceDetailTemplate {
        service_id: context.service.id.to_string(),
        service_code: context.service.service_code,
        direction: context.service.direction,
        status: context.service.status,
        dot_class: status_dot_class(&context.status_dot).to_string(),
        route_id: context
            .service
            .route_id
            .map(|route_id| route_id.to_string())
            .unwrap_or_else(|| "-".to_string()),
        scheduled_start_time: format_optional_time(context.service.scheduled_start_time),
        scheduled_end_time: format_optional_time(context.service.scheduled_end_time),
        active_event_count: context.active_event_count,
        staff_total_count,
        staff_on_duty_count,
        stops,
        events,
        staff,
    })
}

/// GET /dashboard/rail/stations/:id
pub async fn station_detail_page(State(pool): State<PgPool>, Path(id): Path<Uuid>) -> Response {
    let context = match rail::get_station_context(&pool, id).await {
        Ok(Some(ctx)) => ctx,
        Ok(None) => return (StatusCode::NOT_FOUND, "Rail station not found").into_response(),
        Err(e) => {
            tracing::error!("rail station_detail_page error for {}: {}", id, e);
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to load rail station detail",
            )
                .into_response();
        }
    };

    let station = context.station;
    let station_id = station.id.to_string();
    let station_name = station.name;
    let station_code = station.code;
    let station_region = station.region.unwrap_or_else(|| "-".to_string());
    let active_event_count = context.active_event_count;
    let staff_on_duty_count = context.staff_on_duty;
    let staff_total_count = context.staff.len();

    let events = context
        .active_events
        .into_iter()
        .map(map_event_row)
        .collect::<Vec<_>>();

    let staff = context
        .staff
        .into_iter()
        .map(map_staff_row)
        .collect::<Vec<_>>();

    render(RailStationDetailTemplate {
        station_id,
        station_name,
        station_code,
        station_region,
        dot_class: status_dot_class(&context.status).to_string(),
        active_event_count,
        staff_total_count,
        staff_on_duty_count,
        events,
        staff,
    })
}
