use axum::{
    body::Body,
    http::{Method, Request, StatusCode},
};
use serde_json::json;
use tower::ServiceExt;
use uuid::Uuid;

fn make_base_event_body() -> serde_json::Value {
    json!({
        "event_type": "delay",
        "created_by": "00000000-0000-0000-0000-000000000001",
        "destination_location_id": "platform-1",
        "title": "Test rail event",
        "priority": "normal"
    })
}

#[sqlx::test]
async fn create_event_with_valid_rail_service_id_inserts_context(pool: sqlx::PgPool) {
    // Grab the seeded service ID
    let service_id: Uuid = sqlx::query_scalar("SELECT id FROM rail_services LIMIT 1")
        .fetch_one(&pool)
        .await
        .expect("seed service must exist");

    let mut body = make_base_event_body();
    body["rail_service_id"] = json!(service_id.to_string());

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&body).unwrap()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::CREATED);

    let count: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM rail_event_context")
        .fetch_one(&pool)
        .await
        .unwrap();
    assert_eq!(count, 1);
}

#[sqlx::test]
async fn create_event_without_rail_ids_does_not_insert_context(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(
                    serde_json::to_string(&make_base_event_body()).unwrap(),
                ))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::CREATED);

    let count: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM rail_event_context")
        .fetch_one(&pool)
        .await
        .unwrap();
    assert_eq!(count, 0);
}

#[sqlx::test]
async fn create_event_with_nonexistent_rail_service_id_returns_422(pool: sqlx::PgPool) {
    let mut body = make_base_event_body();
    body["rail_service_id"] = json!(Uuid::new_v4().to_string());

    let app = pulse_event_ops::create_app(pool);
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&body).unwrap()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::UNPROCESSABLE_ENTITY);
}

#[sqlx::test]
async fn invalid_rail_service_id_does_not_persist_orphan_event(pool: sqlx::PgPool) {
    let mut body = make_base_event_body();
    body["rail_service_id"] = json!(Uuid::new_v4().to_string());

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::POST)
                .uri("/events")
                .header("content-type", "application/json")
                .body(Body::from(serde_json::to_string(&body).unwrap()))
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::UNPROCESSABLE_ENTITY);

    // No orphaned event row must have been persisted.
    let count: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM events")
        .fetch_one(&pool)
        .await
        .unwrap();
    assert_eq!(
        count, 0,
        "orphaned event row must not be persisted on invalid rail_service_id"
    );
}
