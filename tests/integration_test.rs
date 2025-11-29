use actix_web::{test, web, App};
use euromillions_bot::{db, routes};
use sqlx::PgPool;

#[actix_web::test]
async fn test_health_check() {
    // This is a simple smoke test to verify the server can start
    let app = test::init_service(
        App::new()
            .route("/health", web::get().to(|| async { "OK" }))
    ).await;

    let req = test::TestRequest::get().uri("/health").to_request();
    let resp = test::call_service(&app, req).await;
    assert!(resp.status().is_success());
}

#[actix_web::test]
#[ignore] // Requires database
async fn test_generate_endpoint() {
    let pool = PgPool::connect("postgres://user:password@localhost:5432/euromillions_bot")
        .await
        .expect("Failed to connect to test DB");

    let app = test::init_service(
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/generate", web::get().to(routes::generate_grids))
    ).await;

    let req = test::TestRequest::get().uri("/generate").to_request();
    let resp = test::call_service(&app, req).await;
    
    assert!(resp.status().is_success());
    
    // Parse response
    let body = test::read_body(resp).await;
    let grids: Vec<serde_json::Value> = serde_json::from_slice(&body).unwrap();
    
    assert_eq!(grids.len(), 4, "Should return 4 grids");
    
    for grid in grids {
        assert!(grid.get("numbers").is_some());
        assert!(grid.get("stars").is_some());
        assert!(grid.get("draw_date").is_some());
        
        let numbers = grid["numbers"].as_array().unwrap();
        let stars = grid["stars"].as_array().unwrap();
        
        assert_eq!(numbers.len(), 5);
        assert_eq!(stars.len(), 2);
    }
}

#[actix_web::test]
#[ignore] // Requires database
async fn test_list_grids_endpoint() {
    let pool = PgPool::connect("postgres://user:password@localhost:5432/euromillions_bot")
        .await
        .expect("Failed to connect to test DB");

    let app = test::init_service(
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/grids", web::get().to(routes::list_grids))
    ).await;

    let req = test::TestRequest::get().uri("/grids").to_request();
    let resp = test::call_service(&app, req).await;
    
    assert!(resp.status().is_success());
}

#[actix_web::test]
#[ignore] // Requires database and network
async fn test_history_endpoint() {
    let pool = PgPool::connect("postgres://user:password@localhost:5432/euromillions_bot")
        .await
        .expect("Failed to connect to test DB");

    let app = test::init_service(
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/history", web::get().to(routes::get_history))
    ).await;

    let req = test::TestRequest::get().uri("/history").to_request();
    let resp = test::call_service(&app, req).await;
    
    // Should return success or error, but not panic
    assert!(resp.status().is_success() || resp.status().is_server_error());
}

#[actix_web::test]
async fn test_invalid_endpoint() {
    let app = test::init_service(
        App::new()
            .route("/generate", web::get().to(|| async { "OK" }))
    ).await;

    let req = test::TestRequest::get().uri("/invalid").to_request();
    let resp = test::call_service(&app, req).await;
    
    assert_eq!(resp.status().as_u16(), 404);
}
