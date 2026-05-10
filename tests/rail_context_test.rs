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
    let service_id: Uuid =
        sqlx::query_scalar("SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'")
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
async fn realistic_seed_contains_two_routes_and_replaces_northern_line(pool: sqlx::PgPool) {
    let route_names: Vec<String> = sqlx::query_scalar("SELECT name FROM rail_routes ORDER BY name")
        .fetch_all(&pool)
        .await
        .unwrap();
    assert_eq!(route_names.len(), 2);
    assert_eq!(route_names[0], "London Waterloo - Kingston");
    assert_eq!(route_names[1], "Westport - Dublin Heuston");

    let service_codes: Vec<String> =
        sqlx::query_scalar("SELECT service_code FROM rail_services ORDER BY service_code")
            .fetch_all(&pool)
            .await
            .unwrap();
    assert_eq!(service_codes, vec!["GB-WAT-KGN-001", "IE-WPT-HST-001"]);

    let northern_line_count: i64 =
        sqlx::query_scalar("SELECT COUNT(*) FROM rail_services WHERE service_code = 'NL-001'")
            .fetch_one(&pool)
            .await
            .unwrap();
    assert_eq!(northern_line_count, 0);
}

#[sqlx::test]
async fn service_stops_endpoint_returns_ordered_seeded_timeline(pool: sqlx::PgPool) {
    let service_id: Uuid =
        sqlx::query_scalar("SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'")
            .fetch_one(&pool)
            .await
            .expect("seed service must exist");
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/rail/services/{}/stops", service_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    let body = axum::body::to_bytes(response.into_body(), usize::MAX)
        .await
        .unwrap();
    let json: Vec<serde_json::Value> = serde_json::from_slice(&body).unwrap();
    assert_eq!(json.len(), 15);

    for (idx, stop) in json.iter().enumerate() {
        assert_eq!(stop["stop_sequence"], (idx + 1) as i64);
        assert!(stop.get("station_name").is_some());
        assert!(stop.get("station_code").is_some());
        assert!(stop.get("scheduled_arrival").is_some());
        assert!(stop.get("scheduled_departure").is_some());
    }

    assert_eq!(json[0]["station_code"], "WPT");
    assert_eq!(json[0]["station_name"], "Westport");
    assert_eq!(json[14]["station_code"], "HST");
    assert_eq!(json[14]["station_name"], "Dublin Heuston");
}

#[sqlx::test]
async fn service_stops_endpoint_returns_404_for_unknown_service(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/rail/services/{}/stops", Uuid::new_v4()))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NOT_FOUND);
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

#[sqlx::test]
async fn station_context_returns_200_for_seeded_station(pool: sqlx::PgPool) {
    let station_id: Uuid = sqlx::query_scalar("SELECT id FROM rail_stations WHERE code = 'HST'")
        .fetch_one(&pool)
        .await
        .expect("seed station must exist");

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/rail/stations/{}/context", station_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    let body = axum::body::to_bytes(response.into_body(), usize::MAX)
        .await
        .unwrap();
    let json: serde_json::Value = serde_json::from_slice(&body).unwrap();
    assert!(json.get("station").is_some());
    assert!(json.get("status").is_some());
    assert!(json.get("active_event_count").is_some());
    assert!(json.get("staff_on_duty").is_some());
}

#[sqlx::test]
async fn station_context_returns_404_for_unknown_station(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri("/rail/stations/00000000-0000-0000-0000-000000000000/context")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[sqlx::test]
async fn dashboard_service_detail_returns_200_for_seeded_service(pool: sqlx::PgPool) {
    let service_id: Uuid =
        sqlx::query_scalar("SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'")
            .fetch_one(&pool)
            .await
            .expect("seed service must exist");

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/dashboard/rail/services/{}", service_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[sqlx::test]
async fn dashboard_service_detail_returns_404_for_unknown_service(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri("/dashboard/rail/services/00000000-0000-0000-0000-000000000000")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[sqlx::test]
async fn dashboard_service_detail_contains_expected_context_sections(pool: sqlx::PgPool) {
    let service_id: Uuid =
        sqlx::query_scalar("SELECT id FROM rail_services WHERE service_code = 'IE-WPT-HST-001'")
            .fetch_one(&pool)
            .await
            .expect("seed service must exist");

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/dashboard/rail/services/{}", service_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    let body = axum::body::to_bytes(response.into_body(), usize::MAX)
        .await
        .unwrap();
    let html = String::from_utf8(body.to_vec()).unwrap();

    assert!(html.contains("IE-WPT-HST-001"));
    assert!(html.contains("Service Status"));
    assert!(html.contains("Related Events"));
}

#[sqlx::test]
async fn dashboard_services_list_contains_context_summaries(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri("/dashboard/rail/services")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    let body = axum::body::to_bytes(response.into_body(), usize::MAX)
        .await
        .unwrap();
    let html = String::from_utf8(body.to_vec()).unwrap();

    assert!(html.contains("Staff Availability"));
    assert!(html.contains("Related Events"));
    assert!(html.contains("on duty") || html.contains(">-<"));
    assert!(html.contains("active event"));
}

#[sqlx::test]
async fn dashboard_station_detail_returns_200_for_seeded_station(pool: sqlx::PgPool) {
    let station_id: Uuid = sqlx::query_scalar("SELECT id FROM rail_stations WHERE code = 'HST'")
        .fetch_one(&pool)
        .await
        .expect("seed station must exist");

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/dashboard/rail/stations/{}", station_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);
}

#[sqlx::test]
async fn dashboard_station_detail_returns_404_for_unknown_station(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri("/dashboard/rail/stations/00000000-0000-0000-0000-000000000000")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::NOT_FOUND);
}

#[sqlx::test]
async fn dashboard_station_detail_contains_expected_context_sections(pool: sqlx::PgPool) {
    let (station_id, station_name, station_code): (Uuid, String, String) =
        sqlx::query_as("SELECT id, name, code FROM rail_stations WHERE code = 'HST'")
            .fetch_one(&pool)
            .await
            .expect("seed station must exist");

    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri(format!("/dashboard/rail/stations/{}", station_id))
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    let body = axum::body::to_bytes(response.into_body(), usize::MAX)
        .await
        .unwrap();
    let html = String::from_utf8(body.to_vec()).unwrap();

    assert!(html.contains(&station_name));
    assert!(html.contains(&station_code));
    assert!(html.contains("Staff Presence"));
    assert!(html.contains("Related Events"));
    assert!(html.contains("Region"));
}

#[sqlx::test]
async fn dashboard_stations_list_contains_context_summaries(pool: sqlx::PgPool) {
    let app = pulse_event_ops::create_app(pool.clone());
    let response = app
        .oneshot(
            Request::builder()
                .method(Method::GET)
                .uri("/dashboard/rail/stations")
                .body(Body::empty())
                .unwrap(),
        )
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::OK);

    let body = axum::body::to_bytes(response.into_body(), usize::MAX)
        .await
        .unwrap();
    let html = String::from_utf8(body.to_vec()).unwrap();

    assert!(html.contains("Staff Availability"));
    assert!(html.contains("Related Events"));
    assert!(html.contains("on duty") || html.contains(">-<"));
    assert!(html.contains("active event"));
}
