use axum::{
    body::Body,
    http::{Request, StatusCode},
};
use tower::ServiceExt;

#[sqlx::test]
async fn health_returns_ok(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool);

    let response = app
        .oneshot(
            Request::builder()
                .uri("/health")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}
