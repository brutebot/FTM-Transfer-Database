# FTM Master Database - Architecture Specification

## Overview

The **FTM (Football Transfer Market) Master Database** is a enterprise-grade, highly normalized relational database architecture built for storing, querying, and analyzing football transfer intelligence, player career statistics, market valuations, club profiles, match events, and source provenance.

This project serves as the centralized backend data foundation designed to support high-throughput, low-latency API access for the FTM web application and external integration points.

---

## Data Pipeline & Architecture Flow

```
+-----------------------------------------------------------------------+
|                       REAL FOOTBALL DATA SOURCES                      |
| (Licensed APIs: Opta, Wyscout, Sportradar, Transfermarkt, Club Feeds) |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
|                           DATA INGESTION                              |
|          (Raw JSON Payload Landing in /data/{entity}/)                |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
|                      NORMALIZATION & VALIDATION                       |
|   (scripts/normalization & scripts/validation/validate_database.js)   |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
|                          FTM MASTER DATABASE                          |
|         (PostgreSQL / Supabase Schema with Triggers & Views)          |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
|                                FTM API                                |
|        (RESTful / GraphQL endpoints backed by v_*_api views)         |
+-----------------------------------------------------------------------+
                                   |
                                   v
+-----------------------------------------------------------------------+
|                              FTM WEBSITE                              |
|               (Frontend Client - Consumes API Layer)                  |
+-----------------------------------------------------------------------+
```

---

## Key Design Principles

### 1. Zero Hallucination & Absolute Data Integrity
- **No Inventions**: Statistical, financial, or transfer rumour data is never fabricated. Unknown parameters are stored as `NULL`.
- **Source Traceability**: Every time-sensitive entity maintains a foreign key to the `sources` table with provenance metadata (`source_url`, `publication_date`, `verified_at`, `confidence_level`).

### 2. Relational Normalization (3NF / BCNF)
- Structural separation between core entities (Players, Clubs, Leagues), time-bounded relationships (Contracts, Squads, History), and event logs (Transfers, Rumours, Matches).
- Primary keys utilize standard `UUID` (`uuid_generate_v4()`) to enable seamless distributed clustering and migration.

### 3. API-First Views Layer
- Optimized SQL views (`v_players_api`, `v_transfers_api`, `v_rumours_api`, `v_clubs_api`) encapsulate SQL JOIN overhead, delivering ready-to-serve JSON payloads directly to REST/GraphQL endpoints.

### 4. High-Performance Indexing Strategy
- Fast trigram GIN indexes (`pg_trgm`) for fuzzy text searching on player and club names.
- B-Tree indexes on frequently filtered fields: `transfer_date`, `fee_amount`, `current_market_value`, `nationality_id`, `league_id`, `position`, `latest_update_at`.

---

## Database Components Structure

- `/database/schema`: DDL scripts containing custom ENUMs, core tables, statistics tables, transfer/rumour tables, market/contract tables, match tables, indexes, and triggers.
- `/database/views`: Production SQL views optimized for REST API endpoints.
- `/database/migrations`: Version-controlled DDL migration steps.
- `/database/seeds`: Sample seed data for schema validation testing.
- `/scripts`: Automated ingestion, normalization, export, and 10-point integrity validation engine.
