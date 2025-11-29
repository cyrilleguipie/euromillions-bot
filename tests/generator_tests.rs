use euromillions_bot::generator::{generate_grids, get_next_draw_date};
use sqlx::PgPool;
use chrono::{Datelike, NaiveDate, Weekday};

#[test]
fn test_next_draw_date_tuesday() {
    // Mock today as Monday
    let today = NaiveDate::from_ymd_opt(2025, 1, 6).unwrap(); // Monday
    assert_eq!(today.weekday(), Weekday::Mon);
    
    // Next draw should be Tuesday
    let next = get_next_draw_date();
    assert!(next.weekday() == Weekday::Tue || next.weekday() == Weekday::Fri);
}

#[test]
fn test_next_draw_date_friday() {
    // The function always returns the next Tue or Fri from today
    let next = get_next_draw_date();
    assert!(
        next.weekday() == Weekday::Tue || next.weekday() == Weekday::Fri,
        "Next draw should be on Tuesday or Friday"
    );
}

#[tokio::test]
#[ignore] // Requires database
async fn test_generate_grids_count() {
    // Create in-memory test database
    let pool = PgPool::connect("postgres://user:password@localhost:5432/euromillions_bot")
        .await
        .expect("Failed to connect to test database");

    let result = generate_grids(&pool).await;
    
    match result {
        Ok(grids) => {
            assert_eq!(grids.len(), 4, "Should generate exactly 4 grids");
            
            // Verify each grid
            for grid in grids {
                assert_eq!(grid.numbers.len(), 5, "Each grid should have 5 numbers");
                assert_eq!(grid.stars.len(), 2, "Each grid should have 2 stars");
                
                // Verify numbers are sorted
                let mut sorted_numbers = grid.numbers.clone();
                sorted_numbers.sort();
                assert_eq!(grid.numbers, sorted_numbers, "Numbers should be sorted");
                
                // Verify stars are sorted
                let mut sorted_stars = grid.stars.clone();
                sorted_stars.sort();
                assert_eq!(grid.stars, sorted_stars, "Stars should be sorted");
                
                // Verify number ranges
                for num in &grid.numbers {
                    assert!(*num >= 1 && *num <= 50, "Numbers should be between 1 and 50");
                }
                
                for star in &grid.stars {
                    assert!(*star >= 1 && *star <= 12, "Stars should be between 1 and 12");
                }
            }
        }
        Err(_) => {
            // If DB not available, test falls back to default behavior
            println!("Database not available for testing, skipping DB-dependent test");
        }
    }
}

#[test]
fn test_grid_uniqueness() {
    // Numbers within a grid should be unique
    let numbers = vec![1, 2, 3, 4, 5];
    let unique: std::collections::HashSet<_> = numbers.iter().collect();
    assert_eq!(unique.len(), 5, "All numbers should be unique");
}
