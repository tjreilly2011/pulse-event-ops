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
