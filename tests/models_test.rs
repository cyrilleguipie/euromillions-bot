use euromillions_bot::models::{NewDraw, NewGrid};
use chrono::NaiveDate;

#[test]
fn test_new_draw_creation() {
    let draw = NewDraw {
        date: NaiveDate::from_ymd_opt(2025, 1, 1).unwrap(),
        numbers: vec![1, 15, 23, 42, 50],
        stars: vec![3, 9],
    };

    assert_eq!(draw.numbers.len(), 5);
    assert_eq!(draw.stars.len(), 2);
    assert_eq!(draw.date.year(), 2025);
}

#[test]
fn test_new_grid_creation() {
    let grid = NewGrid {
        draw_date: NaiveDate::from_ymd_opt(2025, 11, 28).unwrap(),
        numbers: vec![7, 18, 29, 41, 48],
        stars: vec![1, 12],
    };

    assert_eq!(grid.numbers.len(), 5);
    assert_eq!(grid.stars.len(), 2);
}

#[test]
fn test_draw_serialization() {
    let draw = NewDraw {
        date: NaiveDate::from_ymd_opt(2025, 1, 1).unwrap(),
        numbers: vec![1, 2, 3, 4, 5],
        stars: vec![1, 2],
    };

    let json = serde_json::to_string(&draw).unwrap();
    assert!(json.contains("2025-01-01"));
    assert!(json.contains("[1,2,3,4,5]"));
}
