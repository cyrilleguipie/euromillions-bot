# Deployment Guide - Render.com

This guide explains how to deploy the Euromillions Bot to Render.com (free tier).

## Prerequisites

- A GitHub account
- A Render.com account (free)

## Deployment Steps

### Option 1: One-Click Deploy (Blueprint)

1. **Push to GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Deploy on Render**:
   - Go to [Render Dashboard](https://dashboard.render.com/)
   - Click **"New +"** → **"Blueprint"**
   - Connect your GitHub repository
   - Render will detect the `render.yaml` file and create:
     - A PostgreSQL database (free tier)
     - A web service running your Docker container (free tier)

3. **Wait for deployment**:
   - Initial build takes ~5-10 minutes (compiling Rust)
   - Once deployed, Render provides a URL like: `https://euromillions-bot.onrender.com`

### Option 2: Manual Setup

1. **Create PostgreSQL Database**:
   - Go to Render Dashboard
   - Click **"New +"** → **"PostgreSQL"**
   - Name: `euromillions-db`
   - Plan: **Free**
   - Create Database

2. **Create Web Service**:
   - Click **"New +"** → **"Web Service"**
   - Connect your GitHub repo
   - Settings:
     - **Name**: `euromillions-bot`
     - **Runtime**: **Docker**
     - **Plan**: **Free**
     - **Environment Variables**:
       - `DATABASE_URL`: (copy Internal Database URL from your PostgreSQL)
       - `RUST_LOG`: `info`
   - Deploy

## Post-Deployment

### Test Endpoints

```bash
# Replace with your Render URL
export RENDER_URL="https://euromillions-bot.onrender.com"

# Fetch history
curl $RENDER_URL/history

# Generate grids
curl $RENDER_URL/generate

# List grids
curl $RENDER_URL/grids
```

### Important Notes

> [!IMPORTANT]
> **Free Tier Limitations**:
> - Web services spin down after 15 minutes of inactivity
> - Cold starts take ~30 seconds (includes Rust compilation if needed)
> - Database limited to 1GB storage
> - 750 hours/month (sufficient for continuous running)

> [!NOTE]
> **Scheduled Jobs**:
> The cron job runs in-process, so it only executes when the service is active. To ensure it runs on Wed/Sat at 23:00 UTC, you can:
> - Use a free uptime monitoring service (like UptimeRobot) to ping your service every 14 minutes
> - Or manually trigger `/history` after each draw

## Alternatives

If Render doesn't meet your needs:

### Railway.app
- Similar to Render
- $5 free credits monthly
- Good for Rust projects

### Fly.io
- Free tier with more generous limits
- Requires installing `flyctl` CLI
- Good Docker support

## Troubleshooting

### Build Fails
- Check logs in Render Dashboard
- Ensure `DATABASE_URL` is set correctly
- Verify Dockerfile builds locally with `docker build .`

### Database Connection Issues
- Ensure you're using the **Internal Database URL** (not external)
- Check that the database is in the same region as the web service

### Service Won't Start
- Check environment variables
- Verify migrations ran successfully (check logs)
- Ensure port 8080 is exposed in Dockerfile
