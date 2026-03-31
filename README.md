# TwittTraverse

> Twitter/X data extraction tool — search tweets by keyword, hashtag, or user and export to CSV.

## Overview

TwittTraverse fetches tweets via the Twitter/X API using Perl and exports results to CSV files. Designed for social media analysis, trend monitoring, and data collection.

## Features

- **Search by keyword** — find tweets containing specific terms
- **Search by hashtag** — track hashtag usage and trends
- **User timeline** — extract all tweets from a specific user
- **CSV export** — structured output with timestamp, user, and text
- **Docker ready** — run anywhere with zero dependencies

## Prerequisites

- Twitter/X Developer Account with API credentials
- Environment variables:
  - `TWITTER_CONSUMER_KEY`
  - `TWITTER_CONSUMER_SECRET`
  - `TWITTER_ACCESS_TOKEN`
  - `TWITTER_ACCESS_TOKEN_SECRET`

## Usage

### CLI

```bash
# Search by keyword
./One.pl --search "DevSecOps" --count 10

# Search by hashtag
./One.pl --hashtag "PlatformEngineering" --count 20

# Fetch user timeline
./One.pl --user "sirfan98cs" --count 50
```

### Docker

```bash
# Build
docker build -t twitttraverse .

# Run with env vars
docker run --rm \
  -e TWITTER_CONSUMER_KEY=your_key \
  -e TWITTER_CONSUMER_SECRET=your_secret \
  -e TWITTER_ACCESS_TOKEN=your_token \
  -e TWITTER_ACCESS_TOKEN_SECRET=your_token_secret \
  -v ./data:/data \
  twitttraverse --search "Docker" --count 10
```

### Docker Compose

```bash
# Set credentials in .env
echo "TWITTER_CONSUMER_KEY=your_key" > .env
echo "TWITTER_CONSUMER_SECRET=your_secret" >> .env
echo "TWITTER_ACCESS_TOKEN=your_token" >> .env
echo "TWITTER_ACCESS_TOKEN_SECRET=your_token_secret" >> .env

# Run
docker-compose up --build
```

## Output

Results are saved to `/data/twitter_{query}_{timestamp}.csv`:

```csv
created_at,from_user,text
Mon Mar 31 10:32:00 +0000 2026,username,This is a sample tweet...
```

## Tech Stack

- **Perl** — Core scripting language
- **Net::Twitter** — Twitter API client
- **Docker** — Containerized deployment

## License

MIT
