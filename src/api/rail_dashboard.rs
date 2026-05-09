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
        StatusDot::Amber => "bg-amber-500",
        StatusDot::Red => "bg-red-500",
    }
}

fn service_status_to_dot(status: &str) -> StatusDot {
    match status {
        "CANCELLED" => StatusDot::Red,
        "NORMAL" | "ACTIVE" => StatusDot::Green,
        _ => StatusDot::Amber,
    }
}

// ─── Handlers ────────────────────────────────────────────────────────────────

/// GET /dashboard/rail/services
pub async fn services_page(State(pool): State<PgPool>) -> Response {
    match rail::list_services(&pool).await {
        Ok(services) => {
            let rows = services
                .into_iter()
                .map(|s| {
                    let dot = service_status_to_dot(&s.status);
                    ServiceRow {
                        dot_class: status_dot_class(&dot).to_string(),
                        service_code: s.service_code,
                        direction: s.direction,
                        status: s.status,
                    }
                })
                .collect();
            render(RailServicesTemplate { services: rows })
        }
        Err(e) => {
            tracing::error!("rail services_page error: {e}");
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to load rail services",
            )
                .into_response()
        }
    }
}

/// GET /dashboard/rail/stations
pub async fn stations_page(State(pool): State<PgPool>) -> Response {
    match rail::list_stations(&pool).await {
        Ok(stations) => {
            let rows = stations
                .into_iter()
                .map(|s| StationRow {
                    name: s.name,
                    code: s.code,
                    region: s.region.unwrap_or_else(|| "-".to_string()),
                })
                .collect();
            render(RailStationsTemplate { stations: rows })
        }
        Err(e) => {
            tracing::error!("rail stations_page error: {e}");
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to load rail stations",
            )
                .into_response()
        }
    }
}
