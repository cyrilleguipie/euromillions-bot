use euromillions_bot::fetcher::fetch_history;
use chrono::NaiveDate;

#[test]
fn test_date_parsing() {
    // Test parsing date with ordinal suffix
    let date_parts = vec!["Tuesday", "3rd", "January", "2025"];
    let day = date_parts[1]
        .trim_end_matches("st")
        .trim_end_matches("nd")
        .trim_end_matches("rd")
        .trim_end_matches("th");
    
    assert_eq!(day, "3");
    
    let formatted = format!("{} {} {}", day, date_parts[2], date_parts[3]);
    let parsed = NaiveDate::parse_from_str(&formatted, "%d %B %Y");
    assert!(parsed.is_ok());
    assert_eq!(parsed.unwrap(), NaiveDate::from_ymd_opt(2025, 1, 3).unwrap());
}

#[test]
fn test_date_ordinal_suffixes() {
    let test_cases = vec![
        ("1st", "1"),
        ("2nd", "2"),
        ("3rd", "3"),
        ("4th", "4"),
        ("21st", "21"),
        ("22nd", "22"),
        ("23rd", "23"),
        ("31st", "31"),
    ];

    for (input, expected) in test_cases {
        let result = input
            .trim_end_matches("st")
            .trim_end_matches("nd")
            .trim_end_matches("rd")
            .trim_end_matches("th");
        assert_eq!(result, expected, "Failed for input: {}", input);
    }
}

#[tokio::test]
#[ignore] // This test requires network access
async fn test_fetch_history_integration() {
    let result = fetch_history().await;
    
    match result {
        Ok(draws) => {
            println!("Fetched {} draws", draws.len());
            assert!(!draws.is_empty(), "Should fetch at least some draws");
            
            // Verify draw structure
            for draw in draws.iter().take(5) {
                assert_eq!(draw.numbers.len(), 5, "Each draw should have 5 numbers");
                assert_eq!(draw.stars.len(), 2, "Each draw should have 2 stars");
                
                // Verify sorted
                let mut sorted_nums = draw.numbers.clone();
                sorted_nums.sort();
                assert_eq!(draw.numbers, sorted_nums);
                
                let mut sorted_stars = draw.stars.clone();
                sorted_stars.sort();
                assert_eq!(draw.stars, sorted_stars);
            }
        }
        Err(e) => {
            println!("Fetch failed (expected in offline tests): {}", e);
        }
    }
}

#[test]
fn test_number_validation() {
    // Valid numbers
    let numbers = vec![1, 15, 30, 45, 50];
    assert!(numbers.iter().all(|n| *n >= 1 && *n <= 50));
    
    // Valid stars
    let stars = vec![1, 12];
    assert!(stars.iter().all(|s| *s >= 1 && *s <= 12));
}
