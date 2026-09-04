# FTM Master Database - API Integration Specification

This document details the RESTful API endpoints and response schemas supported by the **FTM Master Database**.

The backend architecture is engineered with database views (`v_*_api`) so that API middleware services (Node.js/Express, Python/FastAPI, or Supabase REST Auto-API) can serve requests with low query latency.

---

## Base API Endpoint URL Structure

```
https://api.footballtransfermarket.com/v1
```

---

## Standardized Endpoints Specification

### 1. `GET /api/v1/players`
- **Description**: Returns paginated player listings with primary position, club, nationality, market value, and contract summaries.
- **Query Parameters**:
  - `page` (integer, default: 1)
  - `limit` (integer, default: 20)
  - `search` (string, fuzzy search on `full_name` or `known_name`)
  - `nationality` (ISO code, e.g., `ENG`)
  - `position` (ENUM, e.g., `ST`, `CAM`, `CB`)
  - `club_id` (UUID)
- **Response View**: `v_players_api`

```json
{
  "status": "success",
  "total": 1,
  "page": 1,
  "data": [
    {
      "player_id": "f0000000-0000-4000-a000-000000000001",
      "external_id": "ext_player_sample_1",
      "full_name": "Erling Haaland [SAMPLE DATA]",
      "known_name": "Haaland",
      "age": 25,
      "nationality": "England [SAMPLE DATA]",
      "nationality_iso": "ENG",
      "primary_position": "ST",
      "secondary_positions": ["CF"],
      "preferred_foot": "left",
      "height_cm": 195,
      "weight_kg": 88,
      "shirt_number": 9,
      "current_club_name": "Manchester City FC [SAMPLE DATA]",
      "current_market_value": 180000000.00,
      "market_value_currency": "EUR",
      "contract_end": "2027-06-30",
      "last_verified_at": "2026-09-04T19:48:00Z"
    }
  ]
}
```

---

### 2. `GET /api/v1/players/{id}`
- **Description**: Detailed profile of a specific player.
- **Response View**: `v_players_api` filtering on `player_id = {id}`.

---

### 3. `GET /api/v1/players/{id}/stats`
- **Description**: Historical season-by-season and competition-by-competition statistics for a player.
- **Query Parameters**:
  - `season_id` (UUID)
  - `competition_id` (UUID)
- **Response View**: `v_player_stats_api`

---

### 4. `GET /api/v1/players/{id}/transfers`
- **Description**: Transfer history records for a specific player.
- **Response View**: `v_transfers_api` filtering on `player_id = {id}`.

---

### 5. `GET /api/v1/players/{id}/rumours`
- **Description**: Intelligence rumour reports and update timelines involving a player.
- **Response View**: `v_rumours_api` filtering on `player_id = {id}`.

---

### 6. `GET /api/v1/players/{id}/market-value`
- **Description**: Current market value and historical valuation timeline for charting.
- **Underlying Tables**: `market_values` and `market_value_history`.

---

### 7. `GET /api/v1/clubs`
- **Description**: List of all clubs with league, country, stadium, manager, and squad size metadata.
- **Response View**: `v_clubs_api`

---

### 8. `GET /api/v1/clubs/{id}`
- **Description**: Detailed club profile.
- **Response View**: `v_clubs_api` filtering on `club_id = {id}`.

---

### 9. `GET /api/v1/clubs/{id}/squad`
- **Description**: Current or historical squad roster of a club.
- **Underlying View / Table**: `club_squads` JOIN `v_players_api`.

---

### 10. `GET /api/v1/clubs/{id}/transfers`
- **Description**: Transfers involving a club as buyer (`new_club_id`) or seller (`previous_club_id`).
- **Response View**: `v_transfers_api`

---

### 11. `GET /api/v1/transfers`
- **Description**: Global feed of verified transfer records.
- **Response View**: `v_transfers_api`

---

### 12. `GET /api/v1/rumours`
- **Description**: Global feed of active transfer rumours and intelligence updates.
- **Response View**: `v_rumours_api`

---

### 13. `GET /api/v1/market-values`
- **Description**: Global market value ranking leaders and recent value changes.
- **Response View**: `v_players_api` ORDER BY `current_market_value` DESC.

---

## Authentication & Headers

```http
Authorization: Bearer <API_SECRET_TOKEN>
Content-Type: application/json
Accept: application/json
```
