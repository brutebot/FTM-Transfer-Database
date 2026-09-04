-- ==============================================================================
-- FTM MASTER DATABASE - CORE ENTITIES
-- Schema Version: 1.0.0
-- Description: Primary structural tables for countries, competitions, clubs, players, sources
-- ==============================================================================

-- 1. COUNTRIES / NATIONALITIES
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    iso_code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    confederation VARCHAR(50), -- e.g., UEFA, CONMEBOL, CAF, AFC, CONCACAF, OFC
    flag_url VARCHAR(500),
    fifa_ranking INTEGER CHECK (fifa_ranking > 0 OR fifa_ranking IS NULL),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 17. SOURCES & DATA QUALITY (Defined early for foreign key references)
CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_name VARCHAR(255) NOT NULL,
    source_url VARCHAR(1000),
    source_type source_type NOT NULL DEFAULT 'provider_api',
    publication_date DATE,
    reliability_metadata JSONB DEFAULT '{}'::jsonb, -- e.g., {"tier": 1, "accuracy_rate": 0.95}
    retrieved_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 7. LEAGUES
CREATE TABLE leagues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(20),
    country_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    tier INTEGER DEFAULT 1 CHECK (tier > 0),
    league_type VARCHAR(50) DEFAULT 'domestic_league',
    logo_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. COMPETITIONS
CREATE TABLE competitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    league_id UUID REFERENCES leagues(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    competition_type VARCHAR(50) NOT NULL DEFAULT 'league', -- league, cup, continental, international
    organizer VARCHAR(100),
    logo_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 9. SEASONS
CREATE TABLE seasons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    competition_id UUID REFERENCES competitions(id) ON DELETE CASCADE,
    name VARCHAR(20) NOT NULL, -- e.g. "2025/2026" or "2026"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_season_dates CHECK (end_date >= start_date)
);

-- 4. CLUBS
CREATE TABLE clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    official_name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100) NOT NULL,
    country_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    city VARCHAR(100),
    league_id UUID REFERENCES leagues(id) ON DELETE SET NULL,
    stadium_name VARCHAR(255),
    stadium_capacity INTEGER CHECK (stadium_capacity >= 0 OR stadium_capacity IS NULL),
    founded_year INTEGER CHECK (founded_year > 1800 OR founded_year IS NULL),
    logo_url VARCHAR(500),
    official_website VARCHAR(500),
    current_manager VARCHAR(255),
    status club_status NOT NULL DEFAULT 'active',
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 21. NATIONAL TEAMS
CREATE TABLE national_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
    official_name VARCHAR(255) NOT NULL,
    team_type VARCHAR(50) DEFAULT 'senior', -- senior, u21, u19, womens
    manager VARCHAR(255),
    logo_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 1. PLAYERS
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    known_name VARCHAR(150),
    dob DATE,
    nationality_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    secondary_nationality_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    position player_position NOT NULL,
    secondary_positions JSONB DEFAULT '[]'::jsonb, -- e.g. ["LW", "CAM"]
    preferred_foot preferred_foot,
    height_cm INTEGER CHECK (height_cm > 100 AND height_cm < 250 OR height_cm IS NULL),
    weight_kg INTEGER CHECK (weight_kg > 40 AND weight_kg < 150 OR weight_kg IS NULL),
    shirt_number INTEGER CHECK (shirt_number >= 1 AND shirt_number <= 99 OR shirt_number IS NULL),
    current_club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    national_team_id UUID REFERENCES national_teams(id) ON DELETE SET NULL,
    profile_photo_url VARCHAR(500),
    status player_status NOT NULL DEFAULT 'active',
    career_start_year INTEGER CHECK (career_start_year >= 1950 OR career_start_year IS NULL),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. PLAYER HISTORY
CREATE TABLE player_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    joined_date DATE NOT NULL,
    left_date DATE,
    joining_reason VARCHAR(100) DEFAULT 'transfer',
    leaving_reason VARCHAR(100),
    shirt_number INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_tenure_dates CHECK (left_date IS NULL OR left_date >= joined_date)
);

-- 22. PLAYER NATIONAL TEAM HISTORY
CREATE TABLE player_national_team_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    national_team_id UUID NOT NULL REFERENCES national_teams(id) ON DELETE CASCADE,
    callup_date DATE,
    debut_date DATE,
    caps INTEGER DEFAULT 0 CHECK (caps >= 0),
    goals INTEGER DEFAULT 0 CHECK (goals >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. CLUB SQUADS
CREATE TABLE club_squads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    squad_number INTEGER CHECK (squad_number >= 1 AND squad_number <= 99 OR squad_number IS NULL),
    position player_position,
    joined_squad_date DATE,
    status VARCHAR(50) DEFAULT 'first_team', -- first_team, reserve, youth, loaned_out
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_club_season_player UNIQUE (club_id, season_id, player_id)
);
