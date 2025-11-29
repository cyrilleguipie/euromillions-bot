# Euromillions Bot

A complete Euromillions lottery system with Rust-based API backend that scrapes draw history, calculates statistics, generates optimized grids, and provides native mobile apps (iOS/Android) plus a modern web interface.

## Features

-   **Historical Data Scraping**: Fetches draw results from 2024 and 2025.
-   **Statistical Generation**: Generates 4 grids using the most frequently drawn numbers and stars.
-   **Automated Updates**: Scheduled job runs every Wednesday and Saturday at 23:00 UTC to fetch new results.
-   **API Endpoints**:
    -   `GET /history`: Manually trigger history fetch.
    -   `GET /generate`: Generate 4 optimized grids.
    -   `GET /grids`: List recently generated grids.

## Tech Stack

**Backend API:**
-   **Language**: Rust
-   **Web Framework**: Actix-web
-   **Database**: PostgreSQL (via SQLx)
-   **Scheduling**: Tokio Cron Scheduler
-   **Scraping**: Reqwest + Scraper

**Client Applications:**
-   **Web**: Svelte 5 + TypeScript + Vite
-   **iOS**: Swift + SwiftUI
-   **Android**: Kotlin + Jetpack Compose

See [`/mobile/README.md`](mobile/README.md) and [`/web/README.md`](web/README.md) for client app documentation.

## Setup

### Prerequisites

-   Rust (latest stable)
-   PostgreSQL
-   Docker (optional)

### Local Development

#### With Nix (Recommended)

If you have Nix with flakes enabled:

```bash
# Enter development shell
nix develop

# Or with direnv (automatic)
direnv allow
```

**What's included:**
- Rust toolchain (from `rust-toolchain.toml`)
- Node.js 20 (for web frontend)
- PostgreSQL + sqlx-cli
- Cargo tools: watch, expand, audit, edit, outdated, tarpaulin
- Docker Compose
- All required dependencies

**Build commands:**
```bash
# Build the binary
nix build

# Build Docker image
nix build .#docker

# Run directly
nix run
```

#### Without Nix

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd euromillions_bot
    ```

2.  **Environment Variables**:
    Create a `.env` file:
    ```env
    DATABASE_URL=postgres://user:password@localhost/euromillions_bot
    RUST_LOG=info
    ```

3.  **Database Setup**:
    ```bash
    sqlx database create
    sqlx migrate run
    ```

4.  **Run**:
    ```bash
    cargo run
    ```

## Deployment

### Docker

Build and run the container:

```bash
docker build -t euromillions_bot .
docker run -p 8080:8080 -e DATABASE_URL=... euromillions_bot
```

### Docker Compose (Local Development)

To run the entire stack locally without installing dependencies:

```bash
docker-compose up
```

This will:
1.  Start a PostgreSQL database.
2.  Start the backend API container (which will compile and run the app).
3.  Build and start the web frontend with nginx.
4.  The API will be available at `http://localhost:8080`.
5.  The web app will be available at `http://localhost:3000`.

Note: The first run will take some time to compile dependencies. Subsequent runs will be faster due to cached cargo registry.

### Render.com (Recommended - Free Tier Available)

**One-Click Deploy:**

1. Push your code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com/)
3. Click **"New +"** → **"Blueprint"**
4. Connect your repository
5. Render will detect `render.yaml` and deploy automatically

**What gets deployed:**
- PostgreSQL database (free tier)
- Backend API web service with Docker (free tier)
- Frontend static site (free tier)

**URLs after deployment:**
- API: `https://euromillions-bot.onrender.com`
- Web: `https://euromillions-web.onrender.com`

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

### Heroku (Legacy - No Free Tier)

1.  Create a Heroku app.
2.  Add Heroku Postgres add-on.
3.  Deploy via Git or Docker.
4.  Ensure the `Procfile` is present:
    ```
    web: euromillions_bot
    ```

## CI/CD

A GitHub Actions workflow is included in `.github/workflows/ci.yml` to build and test the project on every push.
