mod db;
mod fetcher;
mod generator;
mod models;
mod routes;

use actix_web::{web, App, HttpServer};
use dotenvy::dotenv;
use tokio_cron_scheduler::{Job, JobScheduler};
use std::time::Duration;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    dotenv().ok();
    env_logger::init();

    let pool = db::init_db().await;
    
    // Run migrations
    sqlx::migrate!("./migrations")
        .run(&pool)
        .await
        .expect("Failed to run migrations");

    // Setup Scheduler
    let sched = JobScheduler::new().await.unwrap();
    let pool_clone = pool.clone();
    
    // Run every Wednesday and Saturday at 23:00 UTC
    // Cron: sec min hour day_of_month month day_of_week year
    let job = Job::new_async("0 0 23 * * Wed,Sat", move |_uuid, _l| {
        let pool = pool_clone.clone();
        Box::pin(async move {
            println!("Running scheduled fetch...");
            match fetcher::fetch_history().await {
                Ok(draws) => {
                    let mut count = 0;
                    for draw in draws {
                        if let Ok(_) = db::upsert_draw(&pool, draw).await {
                            count += 1;
                        }
                    }
                    println!("Scheduled fetch completed. Processed {} draws.", count);
                }
                Err(e) => eprintln!("Scheduled fetch failed: {}", e),
            }
        })
    }).unwrap();

    sched.add(job).await.unwrap();
    sched.start().await.unwrap();

    println!("Starting server at http://0.0.0.0:8080");

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .route("/history", web::get().to(routes::get_history))
            .route("/generate", web::get().to(routes::generate_grids))
            .route("/grids", web::get().to(routes::list_grids))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
