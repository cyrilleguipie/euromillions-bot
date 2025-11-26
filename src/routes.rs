use actix_web::{web, HttpResponse, Responder};
use crate::db;
use crate::fetcher;
use crate::generator;
use crate::models::{Grid, NewGrid};
use sqlx::PgPool;

pub async fn get_history(pool: web::Data<PgPool>) -> impl Responder {
    // Trigger fetch
    match fetcher::fetch_history().await {
        Ok(draws) => {
            // Save to DB
            let mut count = 0;
            for draw in draws {
                if let Ok(_) = db::upsert_draw(pool.get_ref(), draw).await {
                    count += 1;
                }
            }
            HttpResponse::Ok().body(format!("History fetched. Processed {} draws.", count))
        }
        Err(e) => HttpResponse::InternalServerError().body(format!("Error fetching history: {}", e)),
    }
}

pub async fn generate_grids(pool: web::Data<PgPool>) -> impl Responder {
    match generator::generate_grids(pool.get_ref()).await {
        Ok(grids) => {
            // Save generated grids
            for grid in &grids {
                let _ = sqlx::query!(
                    "INSERT INTO grids (draw_date, numbers, stars) VALUES ($1, $2, $3)",
                    grid.draw_date,
                    &grid.numbers,
                    &grid.stars
                )
                .execute(pool.get_ref())
                .await;
            }
            HttpResponse::Ok().json(grids)
        }
        Err(e) => {
            eprintln!("Error generating grids: {}", e);
            HttpResponse::InternalServerError().finish()
        }
    }
}

pub async fn list_grids(pool: web::Data<PgPool>) -> impl Responder {
    let result = sqlx::query_as!(
        Grid,
        "SELECT id, draw_date, numbers, stars, created_at FROM grids ORDER BY created_at DESC LIMIT 20"
    )
    .fetch_all(pool.get_ref())
    .await;

    match result {
        Ok(grids) => HttpResponse::Ok().json(grids),
        Err(e) => HttpResponse::InternalServerError().body(format!("Error listing grids: {}", e)),
    }
}
