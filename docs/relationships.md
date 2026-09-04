# FTM Master Database - Entity Relationships Specification

This document details the relational entity structure, foreign key mappings, and cardinalities across all **25 Core Entities** of the FTM Master Database.

---

## Entity Relationship Overview

```
                      +-------------------+
                      |     COUNTRIES     |
                      +-------------------+
                               |
            +------------------+------------------+
            |                  |                  |
            v                  v                  v
    +---------------+  +---------------+  +----------------+
    |    LEAGUES    |  |     CLUBS     |  | NATIONAL_TEAMS |
    +---------------+  +---------------+  +----------------+
            |                  |                  |
            v                  v                  v
   +-----------------+ +---------------+  +----------------+
   |  COMPETITIONS   | |  CLUB_SQUADS  |  | PLAYER_NT_HIST |
   +-----------------+ +---------------+  +----------------+
            |                  |                  |
            v                  +--------+---------+
   +-----------------+                  |
   |     SEASONS     |                  v
   +-----------------+          +---------------+
            |                   |    PLAYERS    |
            +------------------>+---------------+
                                        |
      +-----------------+---------------+-----------------+----------------+
      |                 |               |                 |                |
      v                 v               v                 v                v
+-----------+    +-------------+  +-----------+    +-------------+  +------------+
| TRANSFERS |    |   RUMOURS   |  | CONTRACTS |    | MARKET_VALS |  | PLAYER_STAT|
+-----------+    +-------------+  +-----------+    +-------------+  +------------+
      |                 |               |                 |
      v                 v               v                 v
+-----------+    +-------------+  +-----------+    +-------------+
|  SOURCES  |<---| RUMOUR_UPDS |  | MATCHES   |    | MV_HISTORY  |
+-----------+    +-------------+  +-----------+    +-------------+
```

---

## Complete Cardinality Matrix (All 25 Entities)

| Parent Entity | Child Entity | Relationship Type | Foreign Key Field | Description |
|---|---|---|---|---|
| `countries` | `leagues` | 1:N | `country_id` | A country hosts multiple domestic leagues. |
| `countries` | `clubs` | 1:N | `country_id` | A club belongs to a country of origin. |
| `countries` | `players` | 1:N | `nationality_id` | Primary nationality of the player. |
| `countries` | `players` | 1:N | `secondary_nationality_id` | Dual citizenship / secondary nationality. |
| `countries` | `national_teams` | 1:N | `country_id` | National team representing a country. |
| `leagues` | `competitions` | 1:N | `league_id` | League organizing tier competitions. |
| `competitions` | `seasons` | 1:N | `competition_id` | Competition spans multiple annual seasons. |
| `leagues` | `clubs` | 1:N | `league_id` | Club competes in a primary league. |
| `clubs` | `players` | 1:N | `current_club_id` | Player currently contracted to a club. |
| `national_teams` | `players` | 1:N | `national_team_id` | Player assigned to national squad. |
| `players` | `player_history` | 1:N | `player_id` | Historical record of clubs player represented. |
| `players` | `player_national_team_history` | 1:N | `player_id` | History of international caps and goals. |
| `clubs` | `club_squads` | 1:N | `club_id` | Squad roster for a specific season. |
| `seasons` | `club_squads` | 1:N | `season_id` | Season roster tracking. |
| `players` | `club_squads` | 1:N | `player_id` | Player inclusion in squad roster. |
| `players` | `transfers` | 1:N | `player_id` | All historical and active transfers for player. |
| `clubs` | `transfers` | 1:N | `previous_club_id` | Selling / departing club in a transfer. |
| `clubs` | `transfers` | 1:N | `new_club_id` | Buying / receiving club in a transfer. |
| `seasons` | `transfers` | 1:N | `season_id` | Transfer occurring during season. |
| `transfer_windows` | `transfers` | 1:N | `transfer_window_id` | Transfer registered in transfer window. |
| `transfers` | `transfer_fees` | 1:1 | `transfer_id` | Granular breakdown of transfer fee components. |
| `players` | `rumours` | 1:N | `player_id` | Transfer rumours associated with player. |
| `clubs` | `rumours` | 1:N | `current_club_id` | Current club in rumour reports. |
| `clubs` | `rumours` | 1:N | `interested_club_id` | Pursuing / interested club in rumour reports. |
| `rumours` | `rumour_updates` | 1:N | `rumour_id` | Development timeline for a rumour entry. |
| `players` | `market_values` | 1:1 | `player_id` | Current market value snapshot. |
| `players` | `market_value_history` | 1:N | `player_id` | Time-series historical market value records. |
| `players` | `contracts` | 1:N | `player_id` | Employment contracts signed by player. |
| `clubs` | `contracts` | 1:N | `club_id` | Club holding player contract. |
| `players` | `player_statistics` | 1:N | `player_id` | Season/competition performance metrics. |
| `seasons` | `player_statistics` | 1:N | `season_id` | Season associated with stats. |
| `competitions` | `player_statistics` | 1:N | `competition_id` | Competition associated with stats. |
| `clubs` | `club_statistics` | 1:N | `club_id` | Club standings and performance stats per season. |
| `competitions` | `matches` | 1:N | `competition_id` | Competition match fixtures. |
| `seasons` | `matches` | 1:N | `season_id` | Season match fixtures. |
| `clubs` | `matches` | 1:N | `home_club_id` | Home team in match fixture. |
| `clubs` | `matches` | 1:N | `away_club_id` | Away team in match fixture. |
| `matches` | `match_events` | 1:N | `match_id` | Granular timeline events (goals, cards, VAR). |
| `players` | `injuries` | 1:N | `player_id` | Medical and injury history tracking. |
| `players` | `player_awards` | 1:N | `player_id` | Individual player honours and awards. |
| `clubs` | `club_trophies` | 1:N | `club_id` | Silverware won by club. |
| `sources` | * (multiple) | 1:N | `source_id` | Traceability provenance across all major tables. |
