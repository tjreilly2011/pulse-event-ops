use askama::Template;
use axum::{
    extract::State,
    http::StatusCode,
    response::{Html, IntoResponse, Response},
};
use sqlx::PgPool;

use crate::application::rail;
use crate::domain::rail::StatusDot;

// ─── View models ─────────────────────────────────────────────────────────────

struct ServiceRow {
    service_code: String,
    direction: String,
    status: String,
    dot_class: String,
}

struct StationRow {
    name: String,
    code: String,
    region: String,
    dot_class: String,
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
            dot_class: status_dot_class(&dot).to_string(),
            name: station.name,
            code: station.code,
            region: station.region.unwrap_or_else(|| "-".to_string()),
        });
    }

    render(RailStationsTemplate { stations: rows })
}
