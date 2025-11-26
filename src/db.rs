use sqlx::postgres::{PgPool, PgPoolOptions};
use std::env;
use dotenvy::dotenv;
use crate::models::NewDraw;

pub async fn init_db() -> PgPool {
    dotenv().ok();
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    
    PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
        .expect("Failed to create pool")
}

pub async fn upsert_draw(pool: &PgPool, draw: NewDraw) -> Result<(), sqlx::Error> {
    sqlx::query!(
        r#"
        INSERT INTO draws (date, numbers, stars)
        VALUES ($1, $2, $3)
        ON CONFLICT (date) DO NOTHING
        "#,
        draw.date,
        &draw.numbers,
        &draw.stars
    )
    .execute(pool)
    .await?;
    Ok(())
}

pub async fn get_most_frequent_numbers(pool: &PgPool, limit: i64) -> Result<Vec<i32>, sqlx::Error> {
    let recs = sqlx::query!(
        r#"
        SELECT unnest(numbers) as num, count(*) as freq
        FROM draws
        GROUP BY num
        ORDER BY freq DESC
        LIMIT $1
        "#,
        limit
    )
    .fetch_all(pool)
    .await?;

    Ok(recs.into_iter().map(|r| r.num.unwrap_or(0)).collect())
}

pub async fn get_most_frequent_stars(pool: &PgPool, limit: i64) -> Result<Vec<i32>, sqlx::Error> {
    let recs = sqlx::query!(
        r#"
        SELECT unnest(stars) as num, count(*) as freq
        FROM draws
        GROUP BY num
        ORDER BY freq DESC
        LIMIT $1
        "#,
        limit
    )
    .fetch_all(pool)
    .await?;

    Ok(recs.into_iter().map(|r| r.num.unwrap_or(0)).collect())
}
