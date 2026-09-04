# FTM Master Database - Data Dictionary

Comprehensive specification of all **25 Entities**, field attributes, SQL data types, constraints, and business logic rules.

---

## 1. `countries`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unique internal identifier |
| `iso_code` | VARCHAR(3) | UNIQUE, NOT NULL | Standard ISO 3-letter country code (e.g. 'ENG', 'FRA') |
| `name` | VARCHAR(100) | NOT NULL | Official country name |
| `confederation` | VARCHAR(50) | NULL | Governing confederation (UEFA, CONMEBOL, CAF, AFC, CONCACAF, OFC) |
| `flag_url` | VARCHAR(500) | NULL | Flag graphic image URL |
| `fifa_ranking` | INTEGER | CHECK (fifa_ranking > 0 OR NULL) | Official FIFA men's world ranking |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Audit timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Audit timestamp |

---

## 2. `sources`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Source record ID |
| `source_name` | VARCHAR(255) | NOT NULL | Name of publication, provider API, or journalist |
| `source_url` | VARCHAR(1000) | NULL | Web link or documentation reference |
| `source_type` | ENUM | NOT NULL, DEFAULT 'provider_api' | Category (official_announcement, tier_1_journalism, etc.) |
| `publication_date` | DATE | NULL | Date story/data was published |
| `reliability_metadata` | JSONB | DEFAULT '{}' | Metadata including trust score and tier rating |
| `retrieved_at` | TIMESTAMPTZ | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Timestamp when ingested |
| `last_verified_at` | TIMESTAMPTZ | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Timestamp when verified |

---

## 3. `leagues`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Feed provider external ID |
| `name` | VARCHAR(255) | NOT NULL | Official league title |
| `code` | VARCHAR(20) | NULL | Abbreviated code (e.g. 'EPL', 'LALIGA') |
| `country_id` | UUID | FK -> countries(id) | Host nation |
| `tier` | INTEGER | DEFAULT 1, CHECK (tier > 0) | Pyramid tier (1 = top flight) |
| `league_type` | VARCHAR(50) | DEFAULT 'domestic_league' | Category |
| `logo_url` | VARCHAR(500) | NULL | Emblem graphics link |

---

## 4. `competitions`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Feed provider ID |
| `league_id` | UUID | FK -> leagues(id) | Associated league hierarchy |
| `name` | VARCHAR(255) | NOT NULL | Competition title |
| `competition_type` | VARCHAR(50) | DEFAULT 'league' | Type: league, cup, continental, international |
| `organizer` | VARCHAR(100) | NULL | Governing body (e.g. UEFA, FA) |

---

## 5. `seasons`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Provider ID |
| `competition_id` | UUID | FK -> competitions(id) | Competition reference |
| `name` | VARCHAR(20) | NOT NULL | Season label (e.g., '2025/2026') |
| `start_date` | DATE | NOT NULL | Opening date |
| `end_date` | DATE | NOT NULL | Closing date (CHECK end_date >= start_date) |
| `is_current` | BOOLEAN | DEFAULT FALSE | Flag for active season |

---

## 6. `clubs`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Provider ID |
| `official_name` | VARCHAR(255) | NOT NULL | Full legal club name |
| `short_name` | VARCHAR(100) | NOT NULL | Display name |
| `country_id` | UUID | FK -> countries(id) | Country of domicile |
| `city` | VARCHAR(100) | NULL | City location |
| `league_id` | UUID | FK -> leagues(id) | Primary domestic league |
| `stadium_name` | VARCHAR(255) | NULL | Home ground venue name |
| `stadium_capacity` | INTEGER | CHECK (capacity >= 0) | Venue seating capacity |
| `founded_year` | INTEGER | CHECK (year > 1800) | Foundation year |
| `logo_url` | VARCHAR(500) | NULL | Crest URL |
| `official_website` | VARCHAR(500) | NULL | Official website URL |
| `current_manager` | VARCHAR(255) | NULL | Manager name |
| `status` | ENUM | DEFAULT 'active' | active, dissolved, merged |
| `source_id` | UUID | FK -> sources(id) | Provenance source |
| `last_verified_at` | TIMESTAMPTZ | NOT NULL | Freshness check timestamp |

---

## 7. `national_teams`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `country_id` | UUID | FK -> countries(id) | Country represented |
| `official_name` | VARCHAR(255) | NOT NULL | National team name |
| `team_type` | VARCHAR(50) | DEFAULT 'senior' | senior, u21, u19, womens |
| `manager` | VARCHAR(255) | NULL | Head coach |

---

## 8. `players`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Feed provider ID |
| `full_name` | VARCHAR(255) | NOT NULL | Complete legal name |
| `known_name` | VARCHAR(150) | NULL | Common display name (e.g. 'Pelé', 'Haaland') |
| `dob` | DATE | NULL | Date of birth |
| `nationality_id` | UUID | FK -> countries(id) | Primary nationality |
| `secondary_nationality_id` | UUID | FK -> countries(id) | Secondary citizenship |
| `position` | ENUM | NOT NULL | Pitch position (GK, CB, LB, RB, CDM, CM, CAM, LW, RW, ST, etc.) |
| `secondary_positions` | JSONB | DEFAULT '[]' | Array of alternative positions |
| `preferred_foot` | ENUM | NULL | left, right, both |
| `height_cm` | INTEGER | CHECK (100 < height < 250) | Height in centimeters |
| `weight_kg` | INTEGER | CHECK (40 < weight < 150) | Weight in kilograms |
| `shirt_number` | INTEGER | CHECK (1 <= number <= 99) | Current shirt number |
| `current_club_id` | UUID | FK -> clubs(id) | Club affiliation |
| `national_team_id` | UUID | FK -> national_teams(id) | International team |
| `profile_photo_url` | VARCHAR(500) | NULL | Profile photo URL |
| `status` | ENUM | DEFAULT 'active' | active, retired, free_agent, banned |
| `career_start_year` | INTEGER | CHECK (year >= 1950) | Professional debut year |
| `source_id` | UUID | FK -> sources(id) | Data provenance |
| `last_verified_at` | TIMESTAMPTZ | NOT NULL | Verification timestamp |

---

## 9. `player_history`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Player reference |
| `club_id` | UUID | FK -> clubs(id) | Club reference |
| `joined_date` | DATE | NOT NULL | Tenure start date |
| `left_date` | DATE | NULL | Tenure end date (CHECK left_date >= joined_date) |
| `joining_reason` | VARCHAR(100) | DEFAULT 'transfer' | transfer, youth_academy, loan |
| `leaving_reason` | VARCHAR(100) | NULL | transfer, loan, contract_expiry, retirement |

---

## 10. `player_national_team_history`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Player reference |
| `national_team_id` | UUID | FK -> national_teams(id) | National team |
| `callup_date` | DATE | NULL | Initial callup date |
| `debut_date` | DATE | NULL | International debut date |
| `caps` | INTEGER | DEFAULT 0, CHECK (caps >= 0) | Senior international caps |
| `goals` | INTEGER | DEFAULT 0, CHECK (goals >= 0) | Senior international goals |

---

## 11. `club_squads`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `club_id` | UUID | FK -> clubs(id) | Club reference |
| `season_id` | UUID | FK -> seasons(id) | Season reference |
| `player_id` | UUID | FK -> players(id) | Player reference |
| `squad_number` | INTEGER | CHECK (1 <= number <= 99) | Registered squad number |
| `position` | ENUM | NULL | Squad registered position |
| `status` | VARCHAR(50) | DEFAULT 'first_team' | first_team, reserve, youth, loaned_out |

---

## 12. `transfers`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Provider ID |
| `player_id` | UUID | FK -> players(id) | Transferred player |
| `previous_club_id` | UUID | FK -> clubs(id) | Selling club |
| `new_club_id` | UUID | FK -> clubs(id) | Buying club |
| `transfer_date` | DATE | NOT NULL | Official date of transfer |
| `season_id` | UUID | FK -> seasons(id) | Season context |
| `transfer_window_id` | UUID | FK -> transfer_windows(id) | Window context |
| `transfer_type` | ENUM | DEFAULT 'permanent' | permanent, loan, free_transfer, return_from_loan |
| `is_permanent` | BOOLEAN | DEFAULT TRUE | Permanent transfer flag |
| `fee_amount` | DECIMAL(15,2)| CHECK (fee_amount >= 0) | Numerical fee amount (NULL if undisclosed/free) |
| `currency` | VARCHAR(3) | DEFAULT 'EUR' | ISO 4217 currency code |
| `reported_fee` | VARCHAR(255) | NULL | Textual reported fee |
| `fee_status` | ENUM | DEFAULT 'confirmed' | confirmed, undisclosed, free, undisclosed_loan_fee |
| `add_ons` | JSONB | DEFAULT '{}' | Add-on terms |
| `contract_duration_years`| DECIMAL(3,1) | CHECK (duration > 0) | Contract length in years |
| `source_id` | UUID | FK -> sources(id) | Provenance tracking |
| `source_url` | VARCHAR(1000) | NULL | Verification link |

---

## 13. `transfer_windows`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `name` | VARCHAR(100) | NOT NULL | E.g. 'Summer 2025' |
| `season_id` | UUID | FK -> seasons(id) | Season context |
| `country_id` | UUID | FK -> countries(id) | Country window applies to |
| `open_date` | DATE | NOT NULL | Window opening date |
| `close_date` | DATE | NOT NULL | Window closing date |
| `is_active` | BOOLEAN | DEFAULT FALSE | Current active window flag |

---

## 14. `transfer_fees`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `transfer_id` | UUID | FK -> transfers(id) | Transfer reference |
| `base_fee` | DECIMAL(15,2)| CHECK (base_fee >= 0) | Guaranteed base transfer fee |
| `guaranteed_fee` | DECIMAL(15,2)| CHECK (guaranteed_fee >= 0) | Fixed fee portion |
| `performance_add_ons` | DECIMAL(15,2)| CHECK (add_ons >= 0) | Maximum bonus add-on potential |
| `sell_on_percentage` | DECIMAL(5,2) | CHECK (0 <= percentage <= 100)| Sell-on clause percentage |
| `currency` | VARCHAR(3) | DEFAULT 'EUR' | Currency code |

---

## 15. `rumours`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Subject player |
| `current_club_id` | UUID | FK -> clubs(id) | Current club |
| `interested_club_id` | UUID | FK -> clubs(id) | Target / interested club |
| `headline` | VARCHAR(255) | NOT NULL | Headline summary |
| `summary` | TEXT | NULL | Contextual report details |
| `status` | ENUM | DEFAULT 'rumour' | rumour, reported, interest, negotiations, advanced, agreement, confirmed, dismissed |
| `reported_fee` | DECIMAL(15,2)| CHECK (reported_fee >= 0) | Speculated transfer fee |
| `currency` | VARCHAR(3) | DEFAULT 'EUR' | Currency code |
| `source_id` | UUID | FK -> sources(id) | Report source provenance |
| `source_url` | VARCHAR(1000) | NULL | Article link |
| `journalist_name` | VARCHAR(150) | NULL | Reporting journalist |
| `publication_date` | DATE | NOT NULL | Initial report date |
| `latest_update_at` | TIMESTAMPTZ | NOT NULL | Latest timeline update |

---

## 16. `rumour_updates`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `rumour_id` | UUID | FK -> rumours(id) | Parent rumour thread |
| `update_timestamp` | TIMESTAMPTZ | DEFAULT CURRENT_TIMESTAMP | Timestamp of update |
| `headline` | VARCHAR(255) | NOT NULL | Progression update title |
| `update_text` | TEXT | NOT NULL | Detailed update text |
| `status_at_update` | ENUM | NOT NULL | Status transition state |

---

## 17. `market_values`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | UNIQUE, FK -> players(id) | Player reference |
| `current_market_value` | DECIMAL(15,2)| NOT NULL, CHECK (val >= 0) | Current valuation amount |
| `currency` | VARCHAR(3) | DEFAULT 'EUR' | ISO currency code |
| `valuation_date` | DATE | NOT NULL | Valuation benchmark date |
| `value_change` | DECIMAL(15,2)| DEFAULT 0.00 | Net difference since last update |
| `percentage_change` | DECIMAL(6,2) | DEFAULT 0.00 | Percentage change |

---

## 18. `market_value_history`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Player reference |
| `market_value` | DECIMAL(15,2)| NOT NULL, CHECK (val >= 0) | Historical market value point |
| `currency` | VARCHAR(3) | DEFAULT 'EUR' | Currency code |
| `valuation_date` | DATE | NOT NULL | Date of historical valuation |

---

## 19. `contracts`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Contracted player |
| `club_id` | UUID | FK -> clubs(id) | Employing club |
| `contract_start` | DATE | NULL | Start date |
| `contract_end` | DATE | NOT NULL | Expiry date (CHECK end >= start) |
| `status` | ENUM | DEFAULT 'active' | active, expired, terminated, pending_extension |
| `salary_amount` | DECIMAL(15,2)| CHECK (salary >= 0) | Remuneration amount (NULL if undisclosed) |
| `salary_currency` | VARCHAR(3) | DEFAULT 'EUR' | ISO currency code |
| `salary_period` | ENUM | NULL | weekly, annual |
| `release_clause_amount` | DECIMAL(15,2)| CHECK (clause >= 0) | Release clause fee (NULL if none/undisclosed) |

---

## 20. `player_statistics`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Player reference |
| `season_id` | UUID | FK -> seasons(id) | Season reference |
| `competition_id` | UUID | FK -> competitions(id) | Competition reference |
| `club_id` | UUID | FK -> clubs(id) | Club represented |
| `is_goalkeeper` | BOOLEAN | DEFAULT FALSE | Goalkeeper flag |
| `appearances` | INTEGER | CHECK (appearances >= 0) | Match appearances |
| `starts` | INTEGER | CHECK (starts >= 0) | Starting lineup appearances |
| `minutes` | INTEGER | CHECK (minutes >= 0) | Total minutes played |
| `goals` | INTEGER | CHECK (goals >= 0) | Goals scored |
| `assists` | INTEGER | CHECK (assists >= 0) | Assists provided |
| `shots` | INTEGER | CHECK (shots >= 0) | Shots taken |
| `shots_on_target` | INTEGER | CHECK (shots_on_target >= 0) | Shots on target |
| `chances_created` | INTEGER | CHECK (chances_created >= 0) | Chances created |
| `key_passes` | INTEGER | CHECK (key_passes >= 0) | Key passes |
| `passes` | INTEGER | CHECK (passes >= 0) | Total passes |
| `pass_accuracy` | DECIMAL(5,2) | CHECK (0 <= accuracy <= 100) | Pass accuracy percentage |
| `progressive_passes` | INTEGER | CHECK (passes >= 0) | Progressive passes |
| `dribbles` | INTEGER | CHECK (dribbles >= 0) | Dribble attempts |
| `successful_dribbles` | INTEGER | CHECK (dribbles >= 0) | Successful dribbles |
| `tackles` | INTEGER | CHECK (tackles >= 0) | Tackles attempted |
| `interceptions` | INTEGER | CHECK (interceptions >= 0) | Interceptions |
| `clearances` | INTEGER | CHECK (clearances >= 0) | Defensive clearances |
| `blocks` | INTEGER | CHECK (blocks >= 0) | Shot/cross blocks |
| `recoveries` | INTEGER | CHECK (recoveries >= 0) | Loose ball recoveries |
| `duels` | INTEGER | CHECK (duels >= 0) | Duels contested |
| `aerial_duels` | INTEGER | CHECK (aerial_duels >= 0) | Aerial duels contested |
| `fouls` | INTEGER | CHECK (fouls >= 0) | Fouls committed |
| `fouls_won` | INTEGER | CHECK (fouls_won >= 0) | Fouls suffered |
| `offsides` | INTEGER | CHECK (offsides >= 0) | Offside infractions |
| `yellow_cards` | INTEGER | CHECK (yellow_cards >= 0) | Yellow cards |
| `red_cards` | INTEGER | CHECK (red_cards >= 0) | Red cards |
| `clean_sheets` | INTEGER | CHECK (clean_sheets >= 0) | Clean sheets |
| `saves` | INTEGER | CHECK (saves >= 0) | GK Saves |
| `save_percentage` | DECIMAL(5,2) | CHECK (0 <= save_pct <= 100) | GK Save percentage |
| `goals_conceded` | INTEGER | CHECK (goals >= 0) | GK Goals conceded |
| `penalties_saved` | INTEGER | CHECK (penalties >= 0) | GK Penalties saved |
| `errors_leading_to_goals`| INTEGER | CHECK (errors >= 0) | Errors leading to opponent goals |

---

## 21. `club_statistics`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `club_id` | UUID | FK -> clubs(id) | Club reference |
| `season_id` | UUID | FK -> seasons(id) | Season reference |
| `competition_id` | UUID | FK -> competitions(id) | Competition reference |
| `matches_played` | INTEGER | CHECK (matches >= 0) | Fixtures played |
| `wins` | INTEGER | CHECK (wins >= 0) | Wins |
| `draws` | INTEGER | CHECK (draws >= 0) | Draws |
| `losses` | INTEGER | CHECK (losses >= 0) | Losses |
| `goals_for` | INTEGER | CHECK (goals_for >= 0) | Goals scored |
| `goals_against` | INTEGER | CHECK (goals_against >= 0) | Goals allowed |
| `goal_difference` | INTEGER | NULL | Goal difference |
| `points` | INTEGER | CHECK (points >= 0) | Accumulated points |
| `league_position` | INTEGER | CHECK (position > 0) | Final/current standing |

---

## 22. `matches`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `external_id` | VARCHAR(100) | UNIQUE | Feed provider ID |
| `competition_id` | UUID | FK -> competitions(id) | Competition reference |
| `season_id` | UUID | FK -> seasons(id) | Season context |
| `match_date` | TIMESTAMPTZ | NOT NULL | Kickoff date & time |
| `home_club_id` | UUID | FK -> clubs(id) | Home team |
| `away_club_id` | UUID | FK -> clubs(id) | Away team (CHECK home <> away) |
| `home_score` | INTEGER | CHECK (home_score >= 0) | Goals scored by home team |
| `away_score` | INTEGER | CHECK (away_score >= 0) | Goals scored by away team |
| `venue` | VARCHAR(255) | NULL | Stadium venue |
| `referee` | VARCHAR(255) | NULL | Match official referee |
| `attendance` | INTEGER | CHECK (attendance >= 0) | Spectator count |
| `match_status` | ENUM | DEFAULT 'scheduled' | scheduled, in_progress, finished, postponed, cancelled |

---

## 23. `match_events`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `match_id` | UUID | FK -> matches(id) | Parent match fixture |
| `minute` | INTEGER | NOT NULL, CHECK (0 <= min <= 130) | Event minute |
| `extra_minute` | INTEGER | CHECK (extra >= 0) | Stoppage time minute |
| `event_type` | ENUM | NOT NULL | goal, assist, yellow_card, red_card, substitution, penalty, var_event |
| `player_id` | UUID | FK -> players(id) | Primary event player |
| `secondary_player_id` | UUID | FK -> players(id) | Secondary player (assister / subbed out) |
| `club_id` | UUID | FK -> clubs(id) | Team associated with event |

---

## 24. `injuries`
| Field Name | SQL Type | Constraints / Default | Description |
|---|---|---|---|
| `id` | UUID | PRIMARY KEY | Internal UUID |
| `player_id` | UUID | FK -> players(id) | Injured player |
| `injury_type` | VARCHAR(255) | NOT NULL | Description (e.g., 'Hamstring Strain') |
| `severity` | VARCHAR(50) | NULL | minor, moderate, severe, critical |
| `start_date` | DATE | NOT NULL | Injury occurrence date |
| `expected_return_date` | DATE | NULL | Projected recovery date |
| `actual_return_date` | DATE | NULL | Actual return date |
| `status` | ENUM | DEFAULT 'active' | active, recovered |

---

## 25. `player_awards` & `club_trophies`
| Table Name | Field Name | SQL Type | Description |
|---|---|---|---|
| `player_awards` | `id` | UUID PRIMARY KEY | Internal UUID |
| | `player_id` | UUID FK -> players(id) | Award winner |
| | `award_name` | VARCHAR(255) NOT NULL | Award title (e.g. 'Ballon d\'Or') |
| | `season_id` | UUID FK -> seasons(id) | Season context |
| | `award_date` | DATE | Award ceremony date |
| `club_trophies` | `id` | UUID PRIMARY KEY | Internal UUID |
| | `club_id` | UUID FK -> clubs(id) | Champion club |
| | `trophy_name` | VARCHAR(255) NOT NULL | Trophy title |
| | `season_id` | UUID FK -> seasons(id) | Season won |
