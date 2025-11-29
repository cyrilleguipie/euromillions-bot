use actix_web::{test, App, web};
use euromillions_bot::routes;

#[actix_web::test]
async fn test_index_route() {
    let app = test::init_service(
        App::new().route("/", web::get().to(routes::index))
    ).await;

    let req = test::TestRequest::get().uri("/").to_request();
    let resp = test::call_service(&app, req).await;

    assert!(resp.status().is_success());
    
    let body = test::read_body(resp).await;
    assert_eq!(body, "Euromillions Bot API is running");
}
