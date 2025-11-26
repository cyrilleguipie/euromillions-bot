use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use chrono::NaiveDate;

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Draw {
    pub id: i32,
    pub date: NaiveDate,
    pub numbers: Vec<i32>,
    pub stars: Vec<i32>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct NewDraw {
    pub date: NaiveDate,
    pub numbers: Vec<i32>,
    pub stars: Vec<i32>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Grid {
    pub id: i32,
    pub draw_date: NaiveDate,
    pub numbers: Vec<i32>,
    pub stars: Vec<i32>,
    pub created_at: Option<chrono::NaiveDateTime>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct NewGrid {
    pub draw_date: NaiveDate,
    pub numbers: Vec<i32>,
    pub stars: Vec<i32>,
}
