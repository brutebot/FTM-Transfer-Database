# FTM Master Database (Football Transfer Market)

![FTM Master Database](https://img.shields.io/badge/Database-PostgreSQL%20%7C%20Supabase-blue)
![Validation Engine](https://img.shields.io/badge/Validation-10%2F10%20Checks%20Passed-success)
![Schema Version](https://img.shields.io/badge/Schema%20Version-1.0.0-emerald)
![Data Integrity](https://img.shields.io/badge/Data%20Integrity-Source--Traceable-orange)

The **FTM Master Database** is an enterprise-grade, highly normalized, production-ready football relational database architecture. Built specifically for the **Football Transfer Market (FTM)** platform, it serves as the centralized backend data foundation designed to handle millions of players, clubs, competitions, matches, historical transfers, intelligence rumours, statistics, and market valuations.

> **IMPORTANT ARCHITECTURAL NOTICE**  
> This project is a **NEW, SEPARATE DATABASE PROJECT**. It functions as the standalone backend database foundation. It does NOT modify or run frontend website code, but is designed to cleanly connect to the FTM website via an API layer.

---

## Architecture Overview

```
REAL FOOTBALL DATA SOURCES
        ↓
DATA INGESTION (/scripts/import)
        ↓
NORMALIZATION (/scripts/normalization)
        ↓
VALIDATION ENGINE (/scripts/validation)
        ↓
FTM MASTER DATABASE (PostgreSQL / Supabase Schema & Views)
        ↓
FTM API LAYER (RESTful / GraphQL)
        ↓
FTM WEBSITE (Frontend Application)
```

---

## Core Entities (25 Total)

The database schema implements **25 complete relational entities**:

1. **PLAYERS**: Profile, positions, physical attributes, current club, national team, verified status.
2. **PLAYER STATISTICS**: Granular season/competition stats for outfield players & goalkeepers (supports NULL for unprovided fields).
3. **PLAYER HISTORY**: Historical career club tenures and transfer reasons.
4. **CLUBS**: Official name, short name, country, league, stadium, capacity, manager, status.
5. **CLUB SQUADS**: Seasonal club squad roster listings.
6. **CLUB STATISTICS**: League standings, points, goals for/against, clean sheets per season.
7. **LEAGUES**: Domestic and international league pyramids.
8. **COMPETITIONS**: League, cup, super cup, and continental tournaments.
9. **SEASONS**: Competition annual seasons with start/end bounds.
10. **MATCHES**: Fixtures, results, venues, referees, attendances.
11. **MATCH EVENTS**: Real-time event log (goals, assists, cards, substitutions, penalties, VAR).
12. **TRANSFERS**: Complete historical transfer ledger (permanent, loan, free, return).
13. **TRANSFER WINDOWS**: Country-specific transfer window opening/closing bounds.
14. **TRANSFER FEES**: Granular breakdown (base fee, guaranteed fee, performance add-ons, sell-on %).
15. **RUMOURS**: Transfer intelligence reports (headline, summary, status timeline, reported fee).
16. **RUMOUR UPDATES**: Sequential progression history for active transfer rumours.
17. **SOURCES**: Data quality & source provenance tracking (`source_url`, `publication_date`, `verified_at`).
18. **MARKET VALUES**: Current player market valuation snapshot.
19. **MARKET VALUE HISTORY**: Time-series historical market values for charting.
20. **CONTRACTS**: Active & historical contracts (salary, currency, period, release clauses).
21. **NATIONAL TEAMS**: Senior and youth international squads.
22. **PLAYER NATIONAL TEAM HISTORY**: Caps, goals, call-up dates, debuts.
23. **INJURIES**: Medical history, injury types, severity, return dates.
24. **PLAYER AWARDS**: Individual player honors (e.g. Ballon d'Or, Golden Boot).
25. **CLUB TROPHIES**: Club silverware and trophies won.

---

## Directory Structure

```
ftm-master-database/
├── database/
│   ├── schema/
│   │   ├── 01_types_and_enums.sql         # Custom ENUMs & custom types
│   │   ├── 02_core_tables.sql            # Countries, Clubs, Players, Squads, Sources
│   │   ├── 03_statistics_tables.sql      # Player & Club stats, Injuries, Awards, Trophies
│   │   ├── 04_transfer_rumour_tables.sql  # Transfers, Windows, Fees, Rumours, Timeline
│   │   ├── 05_market_contract_tables.sql  # Market Values, History, Contracts
│   │   ├── 06_match_tables.sql            # Matches & Match Events
│   │   ├── 07_indexes.sql                 # B-Tree & Trigram search performance indexes
│   │   ├── 08_triggers.sql                # Automated updated_at & market value triggers
│   │   └── schema.sql                     # Unified production DDL script
│   ├── migrations/
│   │   └── 001_initial_schema.sql         # Initial database migration
│   ├── seeds/
│   │   ├── sample_seed_data.sql           # SQL seed data [SAMPLE DATA ONLY]
│   │   └── sample_data.json               # JSON seed payload [SAMPLE DATA ONLY]
│   └── views/
│       └── 01_api_views.sql               # Production SQL views optimized for REST API
├── data/                                  # Ingestion landing directories
│   ├── players/
│   ├── clubs/
│   ├── leagues/
│   ├── competitions/
│   ├── seasons/
│   ├── matches/
│   ├── transfers/
│   ├── rumours/
│   ├── market/
│   ├── contracts/
│   └── sources/
├── scripts/
│   ├── import/
│   │   └── ingest_provider_data.js        # Provider API ingestion module
│   ├── export/
│   │   └── export_data.js                 # JSON export utility
│   ├── validation/
│   │   ├── validate_database.js           # 10-Point automated validation suite
│   │   └── schema_rules.js                # Data formatting & compliance rules
│   └── normalization/
│       └── normalize_football_data.js     # Data transformer & normalizer pipeline
├── docs/
│   ├── architecture.md                    # Data flow & architecture specification
│   ├── relationships.md                   # Complete Entity-Relationship matrix
│   ├── data-dictionary.md                 # Full data dictionary for all 25 tables
│   ├── api.md                             # REST API specification & response schemas
│   └── contributing.md                    # Sourcing integrity & contribution rules
├── package.json
└── README.md
```

---

## Installation & Setup

### Requirements
- **PostgreSQL 14+** (or Supabase instance)
- **Node.js 18+**

### 1. Initialize Database Schema
Execute the production DDL script in your PostgreSQL or Supabase SQL Editor:
```bash
psql -h localhost -U postgres -d ftm_master -f database/schema/schema.sql
psql -h localhost -U postgres -d ftm_master -f database/views/01_api_views.sql
```

### 2. Environment Variables (`.env`)
Create a `.env` file in the root directory:
```env
# Database Credentials
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ftm_master
DB_USER=postgres
DB_PASSWORD=your_secure_password

# Data Provider API Keys (When Sourced)
FOOTBALL_PROVIDER_API_KEY=your_licensed_api_key
FOOTBALL_PROVIDER_BASE_URL=https://api.sportradar.com/v1

# API & Security
FTM_API_SECRET=your_jwt_secret_key
NODE_ENV=production
```

---

## Validation Engine

Run the automated 10-point integrity validation suite:

```bash
npm run validate
```

### 10 Automated Integrity Checks Executed:
1. **Duplicate IDs**: Scans for internal UUID and provider external ID collisions.
2. **Missing Required Fields**: Enforces mandatory fields (names, DOBs, positions).
3. **Invalid Dates**: Validates strict ISO-8601 formatting (`YYYY-MM-DD`).
4. **Invalid Currency Codes**: Enforces ISO 4217 currency compliance (`EUR`, `GBP`, `USD`).
5. **Broken Relationships**: Audits foreign key integrity across tables.
6. **Duplicate Transfers**: Detects identical player transfer signatures.
7. **Invalid Player/Club References**: Verifies existence of referenced entities.
8. **Malformed URLs**: Validates source URL syntax.
9. **Impossible Negative Statistics**: Guarantees non-negative bounds for appearances, goals, saves, etc.
10. **Invalid Season Formats**: Enforces standard `YYYY/YYYY` or `YYYY` formats.

---

## Importing Real Data

1. Place raw feed files from licensed data providers (e.g. Opta, Wyscout, Sportradar, Transfermarkt) into `/data/{entity}/`.
2. Run normalization and ingestion:
```bash
npm run ingest
npm run normalize
npm run validate
```

---

## Connecting to Future FTM Website

The future FTM website connects to this database via API endpoints backed by SQL views:

| API Endpoint | Underlying Database View | Description |
|---|---|---|
| `GET /api/v1/players` | `v_players_api` | List & search players |
| `GET /api/v1/players/{id}` | `v_players_api` | Detailed player profile |
| `GET /api/v1/players/{id}/stats` | `v_player_stats_api` | Player career statistics |
| `GET /api/v1/players/{id}/transfers` | `v_transfers_api` | Player transfer history |
| `GET /api/v1/players/{id}/rumours` | `v_rumours_api` | Player transfer rumours |
| `GET /api/v1/clubs` | `v_clubs_api` | Club directory |
| `GET /api/v1/clubs/{id}` | `v_clubs_api` | Club profile |
| `GET /api/v1/transfers` | `v_transfers_api` | Global transfers feed |
| `GET /api/v1/rumours` | `v_rumours_api` | Global rumour intelligence feed |

---

## Sourcing & Licensing Considerations

- **Data Rules**: Never fabricate real-world football data, transfer fees, or rumour reports. Store unconfirmed values as `NULL`.
- **Licensing**: For production deployment with live football stats and transfers, ensure integration with a licensed provider API (Opta, Wyscout, Sportradar, API-Football).
