use axum::{
    body::Body,
    http::{Method, Request, StatusCode},
};
use serde_json::json;
use tower::ServiceExt;
use uuid::Uuid;

fn make_create_event_body() -> String {
    serde_json::to_string(&json!({
        "event_type": "passenger_assistance",
        "created_by": "00000000-0000-0000-0000-000000000001",
        "destination_location_id": "station-euston",
        "vertical_metadata": {
            "assistance_type": "wheelchair_ramp",
            "coach_number": "C"
        }
    }))
    .unwrap()
}

#[sqlx::test]
async fn create_event_returns_created(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool);

    let response = app
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::CREATED);
}

#[sqlx::test]
async fn list_events_returns_ok(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool);

    let response = app
        .oneshot(
            Request::builder()
                .uri("/events")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[sqlx::test]
async fn get_event_by_id_returns_event(pool: sqlx::PgPool) {
    // Create an event first
    let create_app = pulse_event_ops::create_app(pool.clone());
    let create_response = create_app
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(create_response.status(), StatusCode::CREATED);

    let body_bytes = axum::body::to_bytes(create_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let created: serde_json::Value = serde_json::from_slice(&body_bytes).unwrap();
    let id = created["id"].as_str().unwrap();

    // Fetch it by id
    let fetch_app = pulse_event_ops::create_app(pool);
    let fetch_response = fetch_app
        .oneshot(
            Request::builder()
                .uri(format!("/events/{}", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(fetch_response.status(), StatusCode::OK);
}

#[sqlx::test]
async fn get_event_by_id_not_found(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool);

    let response = app
        .oneshot(
            Request::builder()
                .uri(format!("/events/{}", Uuid::new_v4()))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

fn make_acknowledge_body() -> String {
    serde_json::to_string(&json!({
        "acknowledged_by": "00000000-0000-0000-0000-000000000002"
    }))
    .unwrap()
}

fn make_add_update_body() -> String {
    serde_json::to_string(&json!({
        "content": "Train diverted",
        "update_type": "NOTE",
        "actor_id": "00000000-0000-0000-0000-000000000003"
    }))
    .unwrap()
}

#[sqlx::test]
async fn acknowledge_event_transitions_status(pool: sqlx::PgPool) {
    let create_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(create_response.status(), StatusCode::CREATED);
    let body = axum::body::to_bytes(create_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let created: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let id = created["id"].as_str().unwrap();

    let ack_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::PATCH)
                .uri(format!("/events/{}/acknowledge", id))
                .header("content-type", "application/json")
                .body(Body::from(make_acknowledge_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(ack_response.status(), StatusCode::OK);

    let fetch_response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .uri(format!("/events/{}", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(fetch_response.status(), StatusCode::OK);
    let body = axum::body::to_bytes(fetch_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let event: serde_json::Value = serde_json::from_slice(&body).unwrap();
    assert_eq!(event["status"], "ACKNOWLEDGED");
    assert_eq!(
        event["acknowledged_by"],
        "00000000-0000-0000-0000-000000000002"
    );
    assert!(!event["acknowledged_at"].is_null());
}

#[sqlx::test]
async fn acknowledge_event_duplicate_returns_409(pool: sqlx::PgPool) {
    let create_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(create_response.status(), StatusCode::CREATED);
    let body = axum::body::to_bytes(create_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let created: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let id = created["id"].as_str().unwrap();

    let ack_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::PATCH)
                .uri(format!("/events/{}/acknowledge", id))
                .header("content-type", "application/json")
                .body(Body::from(make_acknowledge_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(ack_response.status(), StatusCode::OK);

    let dup_response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .method(Method::PATCH)
                .uri(format!("/events/{}/acknowledge", id))
                .header("content-type", "application/json")
                .body(Body::from(make_acknowledge_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(dup_response.status(), StatusCode::CONFLICT);
}

#[sqlx::test]
async fn acknowledge_auto_creates_timeline_entry(pool: sqlx::PgPool) {
    let create_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(create_response.status(), StatusCode::CREATED);
    let body = axum::body::to_bytes(create_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let created: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let id = created["id"].as_str().unwrap();

    let ack_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::PATCH)
                .uri(format!("/events/{}/acknowledge", id))
                .header("content-type", "application/json")
                .body(Body::from(make_acknowledge_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(ack_response.status(), StatusCode::OK);

    let updates_response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .uri(format!("/events/{}/updates", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(updates_response.status(), StatusCode::OK);
    let body = axum::body::to_bytes(updates_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let updates: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let arr = updates.as_array().unwrap();
    assert!(arr.len() >= 1);
    assert_eq!(arr[0]["update_type"], "ACKNOWLEDGED");
}

#[sqlx::test]
async fn add_event_update_returns_201(pool: sqlx::PgPool) {
    let create_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(create_response.status(), StatusCode::CREATED);
    let body = axum::body::to_bytes(create_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let created: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let id = created["id"].as_str().unwrap();

    let update_response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri(format!("/events/{}/updates", id))
                .header("content-type", "application/json")
                .body(Body::from(make_add_update_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(update_response.status(), StatusCode::CREATED);
    let body = axum::body::to_bytes(update_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let update: serde_json::Value = serde_json::from_slice(&body).unwrap();
    assert_eq!(update["event_id"], id);
    assert_eq!(update["content"], "Train diverted");
    assert_eq!(update["update_type"], "NOTE");
}

#[sqlx::test]
async fn list_event_updates_returns_ordered_entries(pool: sqlx::PgPool) {
    let create_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(make_create_event_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(create_response.status(), StatusCode::CREATED);
    let body = axum::body::to_bytes(create_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let created: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let id = created["id"].as_str().unwrap();

    let ack_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::PATCH)
                .uri(format!("/events/{}/acknowledge", id))
                .header("content-type", "application/json")
                .body(Body::from(make_acknowledge_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(ack_response.status(), StatusCode::OK);

    let update_response = pulse_event_ops::create_app(pool.clone())
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri(format!("/events/{}/updates", id))
                .header("content-type", "application/json")
                .body(Body::from(make_add_update_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(update_response.status(), StatusCode::CREATED);

    let list_response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .uri(format!("/events/{}/updates", id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(list_response.status(), StatusCode::OK);
    let body = axum::body::to_bytes(list_response.into_body(), usize::MAX)
        .await
        .unwrap();
    let updates: serde_json::Value = serde_json::from_slice(&body).unwrap();
    let arr = updates.as_array().unwrap();
    assert_eq!(arr.len(), 2);
    assert_eq!(arr[0]["update_type"], "ACKNOWLEDGED");
    assert_eq!(arr[1]["content"], "Train diverted");
}

#[sqlx::test]
async fn acknowledge_unknown_event_returns_404(pool: sqlx::PgPool) {
    let response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .method(Method::PATCH)
                .uri("/events/00000000-0000-0000-0000-000000000099/acknowledge")
                .header("content-type", "application/json")
                .body(Body::from(make_acknowledge_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[sqlx::test]
async fn add_update_unknown_event_returns_404(pool: sqlx::PgPool) {
    let response = pulse_event_ops::create_app(pool)
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events/00000000-0000-0000-0000-000000000099/updates")
                .header("content-type", "application/json")
                .body(Body::from(make_add_update_body()))
                .unwrap(),
        )
        .await
        .unwrap();
    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[sqlx::test]
async fn sse_endpoint_returns_200_text_event_stream(pool: sqlx::PgPool) {
    use axum::http::header;

    let app = pulse_event_ops::create_app(pool);
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri("/events/stream")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
    let content_type = response
        .headers()
        .get(header::CONTENT_TYPE)
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");
    assert!(
        content_type.contains("text/event-stream"),
        "Expected text/event-stream, got: {}",
        content_type
    );
}

#[sqlx::test]
async fn create_event_broadcasts_sse_event_created(pool: sqlx::PgPool) {
    use pulse_event_ops::application::events as event_app;
    use pulse_event_ops::domain::event::CreateEventRequest;
    use pulse_event_ops::domain::sse_event::SseEvent;
    use tokio::sync::broadcast;

    let (tx, mut rx) = broadcast::channel::<SseEvent>(16);

    let req = serde_json::from_value::<CreateEventRequest>(serde_json::json!({
        "event_type": "passenger_assistance",
        "created_by": "00000000-0000-0000-0000-000000000001",
        "destination_location_id": "station-euston"
    }))
    .unwrap();

    event_app::create(&pool, &tx, req).await.unwrap();

    let event = rx.try_recv().expect("Expected SSE event to be broadcast");
    assert!(matches!(event, SseEvent::EventCreated { .. }));
}

#[sqlx::test]
async fn acknowledge_event_broadcasts_sse_event_acknowledged(pool: sqlx::PgPool) {
    use pulse_event_ops::application::events::{self as event_app, AcknowledgeEventRequest};
    use pulse_event_ops::domain::event::CreateEventRequest;
    use pulse_event_ops::domain::sse_event::SseEvent;
    use tokio::sync::broadcast;

    let (tx, mut rx) = broadcast::channel::<SseEvent>(16);

    let req = serde_json::from_value::<CreateEventRequest>(serde_json::json!({
        "event_type": "passenger_assistance",
        "created_by": "00000000-0000-0000-0000-000000000001",
        "destination_location_id": "station-euston"
    }))
    .unwrap();
    let event = event_app::create(&pool, &tx, req).await.unwrap();

    // Consume the EventCreated broadcast
    let _ = rx.try_recv();

    let ack_req = AcknowledgeEventRequest {
        acknowledged_by: Uuid::new_v4(),
    };
    event_app::acknowledge(&pool, &tx, event.id, ack_req)
        .await
        .unwrap();

    let broadcast_event = rx.try_recv().expect("Expected SSE event to be broadcast");
    assert!(matches!(
        broadcast_event,
        SseEvent::EventAcknowledged { .. }
    ));
}

#[sqlx::test]
async fn add_update_broadcasts_sse_event_update_added(pool: sqlx::PgPool) {
    use pulse_event_ops::application::events as event_app;
    use pulse_event_ops::domain::event::CreateEventRequest;
    use pulse_event_ops::domain::event_update::CreateEventUpdateRequest;
    use pulse_event_ops::domain::sse_event::SseEvent;
    use tokio::sync::broadcast;

    let (tx, mut rx) = broadcast::channel::<SseEvent>(16);

    let req = serde_json::from_value::<CreateEventRequest>(serde_json::json!({
        "event_type": "passenger_assistance",
        "created_by": "00000000-0000-0000-0000-000000000001",
        "destination_location_id": "station-euston"
    }))
    .unwrap();
    let event = event_app::create(&pool, &tx, req).await.unwrap();

    // Consume the EventCreated broadcast
    let _ = rx.try_recv();

    let update_req = CreateEventUpdateRequest {
        content: "Train delayed at platform 3".to_string(),
        actor_id: Some(Uuid::new_v4()),
        update_type: Some("NOTE".to_string()),
    };
    event_app::add_update(&pool, &tx, event.id, update_req)
        .await
        .unwrap();

    let broadcast_event = rx.try_recv().expect("Expected SSE event to be broadcast");
    assert!(matches!(broadcast_event, SseEvent::EventUpdateAdded { .. }));
}
