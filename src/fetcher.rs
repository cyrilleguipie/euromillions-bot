use crate::models::NewDraw;
use chrono::NaiveDate;
use reqwest::Client;
use scraper::{Html, Selector};
use std::error::Error;

pub async fn fetch_history() -> Result<Vec<NewDraw>, Box<dyn Error + Send + Sync>> {
    let client = Client::new();
    let years = vec![2024, 2025];
    let mut all_draws = Vec::new();

    for year in years {
        let url = format!("https://www.euro-millions.com/results-history-{}", year);
        let resp = match client.get(&url).send().await {
            Ok(r) => r.text().await?,
            Err(e) => {
                eprintln!("Failed to fetch {}: {}", url, e);
                continue;
            }
        };

        let document = Html::parse_document(&resp);
        let row_selector = Selector::parse("tr.resultRow").unwrap();
        let date_selector = Selector::parse("td:nth-child(1) > a").unwrap();
        let ball_selector = Selector::parse("td:nth-child(2) > ul > li").unwrap();

        for row in document.select(&row_selector) {
            let date_text = match row.select(&date_selector).next() {
                Some(el) => el.text().collect::<String>(),
                None => continue,
            };

            // Date format: "Tuesday\n18th March 2025" (with lots of whitespace)
            // Clean up and remove ordinal suffixes
            let cleaned = date_text
                .split_whitespace()
                .filter(|s| !s.is_empty())
                .collect::<Vec<&str>>()
                .join(" ");
            
            // Remove day of week (first word) and ordinal suffixes (st, nd, rd, th)
            let parts: Vec<&str> = cleaned.split_whitespace().collect();
            if parts.len() < 4 {
                eprintln!("Failed to parse date '{}': not enough parts", date_text);
                continue;
            }
            
            //parts: ["Tuesday", "18th", "March", "2025"]
            // We want: "18 March 2025" (without ordinal)
            let day_with_ordinal = parts[1];
            let day = day_with_ordinal.trim_end_matches("st")
                .trim_end_matches("nd")
                .trim_end_matches("rd")
                .trim_end_matches("th");
            let formatted_date = format!("{} {} {}", day, parts[2], parts[3]);
            
            let date = match NaiveDate::parse_from_str(&formatted_date, "%d %B %Y") {
                Ok(d) => d,
                Err(e) => {
                    eprintln!("Failed to parse date '{}' (formatted: '{}'): {}", date_text, formatted_date, e);
                    continue;
                }
            };

            let mut numbers = Vec::new();
            let mut stars = Vec::new();
            let mut balls_iter = row.select(&ball_selector);

            // First 5 are numbers
            for _ in 0..5 {
                if let Some(ball) = balls_iter.next() {
                    if let Ok(num) = ball.text().collect::<String>().trim().parse::<i32>() {
                        numbers.push(num);
                    }
                }
            }

            // Next 2 are stars
            for _ in 0..2 {
                if let Some(star) = balls_iter.next() {
                    if let Ok(num) = star.text().collect::<String>().trim().parse::<i32>() {
                        stars.push(num);
                    }
                }
            }

            if numbers.len() == 5 && stars.len() == 2 {
                numbers.sort();
                stars.sort();
                all_draws.push(NewDraw {
                    date,
                    numbers,
                    stars,
                });
            }
        }
    }

    Ok(all_draws)
}

#[cfg(test)]
mod tests {
    include!("fetcher_tests.rs");
}

