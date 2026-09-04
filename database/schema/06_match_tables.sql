-- ==============================================================================
-- FTM MASTER DATABASE - MATCHES & MATCH EVENTS ENTITIES
-- Schema Version: 1.0.0
-- Description: Match fixtures, results, and real-time event logs
-- ==============================================================================

-- 10. MATCHES
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    competition_id UUID NOT NULL REFERENCES competitions(id) ON DELETE CASCADE,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    match_date TIMESTAMPTZ NOT NULL,
    home_club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    away_club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    home_score INTEGER CHECK (home_score >= 0 OR home_score IS NULL),
    away_score INTEGER CHECK (away_score >= 0 OR away_score IS NULL),
    venue VARCHAR(255),
    referee VARCHAR(255),
    attendance INTEGER CHECK (attendance >= 0 OR attendance IS NULL),
    match_status match_status NOT NULL DEFAULT 'scheduled',
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_home_away_clubs CHECK (home_club_id <> away_club_id)
);

-- 11. MATCH EVENTS
CREATE TABLE match_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    minute INTEGER NOT NULL CHECK (minute >= 0 AND minute <= 130),
    extra_minute INTEGER CHECK (extra_minute >= 0 OR extra_minute IS NULL),
    event_type match_event_type NOT NULL,
    player_id UUID REFERENCES players(id) ON DELETE SET NULL,
    secondary_player_id UUID REFERENCES players(id) ON DELETE SET NULL, -- e.g., Assister or Substituted player
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    details JSONB DEFAULT '{}'::jsonb, -- e.g., {"penalty_outcome": "scored", "var_decision": "overturned"}
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
