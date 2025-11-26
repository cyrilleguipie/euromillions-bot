use crate::models::NewGrid;
use crate::db;
use sqlx::PgPool;
use rand::seq::SliceRandom;
use rand::thread_rng;
use chrono::NaiveDate;
use chrono::Datelike;
use chrono::Weekday;

pub async fn generate_grids(pool: &PgPool) -> Result<Vec<NewGrid>, sqlx::Error> {
    let mut grids = Vec::new();
    let next_draw_date = get_next_draw_date();

    // Fetch top 15 frequent numbers and top 6 stars to allow for some variation
    // while still focusing on the "most drawn".
    let frequent_numbers = db::get_most_frequent_numbers(pool, 15).await?;
    let frequent_stars = db::get_most_frequent_stars(pool, 6).await?;

    // Fallback if DB is empty (e.g. first run before scrape)
    let pool_numbers = if frequent_numbers.len() >= 5 { frequent_numbers } else { (1..=50).collect() };
    let pool_stars = if frequent_stars.len() >= 2 { frequent_stars } else { (1..=12).collect() };

    for _ in 0..4 {
        grids.push(generate_single_grid(next_draw_date, &pool_numbers, &pool_stars));
    }
    Ok(grids)
}

fn generate_single_grid(date: NaiveDate, number_pool: &[i32], star_pool: &[i32]) -> NewGrid {
    let mut rng = thread_rng();
    
    let mut numbers = number_pool.to_vec();
    numbers.shuffle(&mut rng);
    let selected_numbers: Vec<i32> = numbers.into_iter().take(5).collect();
    let mut selected_numbers = selected_numbers;
    selected_numbers.sort();

    let mut stars = star_pool.to_vec();
    stars.shuffle(&mut rng);
    let selected_stars: Vec<i32> = stars.into_iter().take(2).collect();
    let mut selected_stars = selected_stars;
    selected_stars.sort();

    NewGrid {
        draw_date: date,
        numbers: selected_numbers,
        stars: selected_stars,
    }
}

fn get_next_draw_date() -> NaiveDate {
    let today = chrono::Local::now().date_naive();
    let mut current = today;
    loop {
        current = current.succ_opt().unwrap();
        match current.weekday() {
            Weekday::Tue | Weekday::Fri => return current,
            _ => continue,
        }
    }
}
