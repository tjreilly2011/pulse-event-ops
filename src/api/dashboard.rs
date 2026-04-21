use askama::Template;
use axum::{
    extract::{Path, State},
    http::{HeaderMap, StatusCode},
    response::{Html, IntoResponse, Response},
};
use sqlx::PgPool;
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::application::events::{self as event_app, AcknowledgeError, AcknowledgeEventRequest};
use crate::domain::event::{Event, EventStatus};
use crate::domain::event_update::EventUpdate;
use crate::domain::sse_event::SseEvent;
use crate::infrastructure::update_repo;

// ─── Template structs ────────────────────────────────────────────────────────

#[derive(Template)]
#[template(path = "events_feed.html")]
struct FeedPageTemplate {
    events: Vec<Event>,
}

#[derive(Template)]
#[template(path = "partials/event_list.html")]
struct EventListTemplate {
    events: Vec<Event>,
}

#[derive(Template)]
#[template(path = "events_detail.html")]
struct DetailPageTemplate {
    event: Event,
    updates: Vec<EventUpdate>,
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

// ─── Handlers ────────────────────────────────────────────────────────────────

/// GET /dashboard/events — full feed page
pub async fn feed_page(State(pool): State<PgPool>) -> Response {
    match event_app::list(&pool).await {
        Ok(events) => render(FeedPageTemplate { events }),
        Err(e) => {
            tracing::error!("dashboard feed_page error: {e}");
            (StatusCode::INTERNAL_SERVER_ERROR, "Failed to load events").into_response()
        }
    }
}

/// GET /dashboard/events/feed — HTMX partial (event list only, SSE swap target)
pub async fn feed_partial(State(pool): State<PgPool>) -> Response {
    match event_app::list(&pool).await {
        Ok(events) => render(EventListTemplate { events }),
        Err(e) => {
            tracing::error!("dashboard feed_partial error: {e}");
            (StatusCode::INTERNAL_SERVER_ERROR, "Failed to load events").into_response()
        }
    }
}

/// GET /dashboard/events/:id — full event detail page
pub async fn detail_page(State(pool): State<PgPool>, Path(id): Path<Uuid>) -> Response {
    let event = match event_app::get_by_id(&pool, id).await {
        Ok(Some(e)) => e,
        Ok(None) => return (StatusCode::NOT_FOUND, "Event not found").into_response(),
        Err(e) => {
            tracing::error!("dashboard detail_page error: {e}");
            return (StatusCode::INTERNAL_SERVER_ERROR, "Failed to load event").into_response();
        }
    };

    let updates = match update_repo::list_for_event(&pool, id).await {
        Ok(u) => u,
        Err(e) => {
            tracing::error!("dashboard detail_page updates error: {e}");
            return (StatusCode::INTERNAL_SERVER_ERROR, "Failed to load updates").into_response();
        }
    };

    render(DetailPageTemplate { event, updates })
}

/// PATCH /dashboard/events/:id/acknowledge — acknowledge action from dashboard
///
/// Uses sentinel UUID as acknowledged_by until auth is introduced.
/// Returns HX-Redirect header so HTMX redirects to the detail page.
pub async fn acknowledge(
    State(pool): State<PgPool>,
    State(tx): State<broadcast::Sender<SseEvent>>,
    Path(id): Path<Uuid>,
) -> Response {
    let sentinel =
        Uuid::parse_str("00000000-0000-0000-0000-000000000001").expect("sentinel UUID is valid");
    let req = AcknowledgeEventRequest {
        acknowledged_by: sentinel,
    };

    match event_app::acknowledge(&pool, &tx, id, req).await {
        Ok(_) | Err(AcknowledgeError::InvalidStatus) => {
            let mut headers = HeaderMap::new();
            let location = format!("/dashboard/events/{id}");
            headers.insert("HX-Redirect", location.parse().expect("valid header value"));
            (StatusCode::OK, headers).into_response()
        }
        Err(AcknowledgeError::NotFound) => {
            (StatusCode::NOT_FOUND, "Event not found").into_response()
        }
        Err(AcknowledgeError::Db(e)) => {
            tracing::error!("dashboard acknowledge error: {e}");
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to acknowledge event",
            )
                .into_response()
        }
    }
}
