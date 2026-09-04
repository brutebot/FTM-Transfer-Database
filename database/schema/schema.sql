-- ==============================================================================
-- FTM MASTER DATABASE - COMPLETE PRODUCTION DDL SCHEMA
-- Description: Unified database definition file for PostgreSQL & Supabase
-- Version: 1.0.0
-- ==============================================================================

-- 1. TYPES & ENUMS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

DO $$ BEGIN
    CREATE TYPE player_position AS ENUM ('GK', 'CB', 'LB', 'RB', 'LWB', 'RWB', 'CDM', 'CM', 'CAM', 'LM', 'RM', 'LW', 'RW', 'CF', 'ST');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE preferred_foot AS ENUM ('left', 'right', 'both');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE player_status AS ENUM ('active', 'retired', 'free_agent', 'banned');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE club_status AS ENUM ('active', 'dissolved', 'merged');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE transfer_type AS ENUM ('permanent', 'loan', 'free_transfer', 'return_from_loan');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE fee_status AS ENUM ('confirmed', 'undisclosed', 'free', 'undisclosed_loan_fee');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE rumour_status AS ENUM ('rumour', 'reported', 'interest', 'negotiations', 'advanced', 'agreement', 'confirmed', 'dismissed');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE source_type AS ENUM ('official_announcement', 'tier_1_journalism', 'tier_2_journalism', 'tier_3_journalism', 'provider_api', 'club_statement');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE contract_status AS ENUM ('active', 'expired', 'terminated', 'pending_extension');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE salary_period AS ENUM ('weekly', 'annual');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE match_status AS ENUM ('scheduled', 'in_progress', 'finished', 'postponed', 'cancelled');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE match_event_type AS ENUM ('goal', 'assist', 'yellow_card', 'red_card', 'substitution', 'penalty', 'var_event');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE injury_status AS ENUM ('active', 'recovered');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 2. CORE TABLES
CREATE TABLE IF NOT EXISTS countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    iso_code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    confederation VARCHAR(50),
    flag_url VARCHAR(500),
    fifa_ranking INTEGER CHECK (fifa_ranking > 0 OR fifa_ranking IS NULL),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_name VARCHAR(255) NOT NULL,
    source_url VARCHAR(1000),
    source_type source_type NOT NULL DEFAULT 'provider_api',
    publication_date DATE,
    reliability_metadata JSONB DEFAULT '{}'::jsonb,
    retrieved_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS leagues (
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

CREATE TABLE IF NOT EXISTS competitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    league_id UUID REFERENCES leagues(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    competition_type VARCHAR(50) NOT NULL DEFAULT 'league',
    organizer VARCHAR(100),
    logo_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS seasons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    competition_id UUID REFERENCES competitions(id) ON DELETE CASCADE,
    name VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_season_dates CHECK (end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS clubs (
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

CREATE TABLE IF NOT EXISTS national_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    country_id UUID NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
    official_name VARCHAR(255) NOT NULL,
    team_type VARCHAR(50) DEFAULT 'senior',
    manager VARCHAR(255),
    logo_url VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    known_name VARCHAR(150),
    dob DATE,
    nationality_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    secondary_nationality_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    position player_position NOT NULL,
    secondary_positions JSONB DEFAULT '[]'::jsonb,
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

CREATE TABLE IF NOT EXISTS player_history (
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

CREATE TABLE IF NOT EXISTS player_national_team_history (
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

CREATE TABLE IF NOT EXISTS club_squads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    squad_number INTEGER CHECK (squad_number >= 1 AND squad_number <= 99 OR squad_number IS NULL),
    position player_position,
    joined_squad_date DATE,
    status VARCHAR(50) DEFAULT 'first_team',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_club_season_player UNIQUE (club_id, season_id, player_id)
);

-- 3. STATISTICS & HONOURS
CREATE TABLE IF NOT EXISTS player_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    competition_id UUID NOT NULL REFERENCES competitions(id) ON DELETE CASCADE,
    club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    is_goalkeeper BOOLEAN DEFAULT FALSE,
    appearances INTEGER CHECK (appearances >= 0 OR appearances IS NULL),
    starts INTEGER CHECK (starts >= 0 OR starts IS NULL),
    minutes INTEGER CHECK (minutes >= 0 OR minutes IS NULL),
    goals INTEGER CHECK (goals >= 0 OR goals IS NULL),
    assists INTEGER CHECK (assists >= 0 OR assists IS NULL),
    shots INTEGER CHECK (shots >= 0 OR shots IS NULL),
    shots_on_target INTEGER CHECK (shots_on_target >= 0 OR shots_on_target IS NULL),
    chances_created INTEGER CHECK (chances_created >= 0 OR chances_created IS NULL),
    key_passes INTEGER CHECK (key_passes >= 0 OR key_passes IS NULL),
    passes INTEGER CHECK (passes >= 0 OR passes IS NULL),
    pass_accuracy DECIMAL(5,2) CHECK (pass_accuracy BETWEEN 0 AND 100 OR pass_accuracy IS NULL),
    progressive_passes INTEGER CHECK (progressive_passes >= 0 OR progressive_passes IS NULL),
    dribbles INTEGER CHECK (dribbles >= 0 OR dribbles IS NULL),
    successful_dribbles INTEGER CHECK (successful_dribbles >= 0 OR successful_dribbles IS NULL),
    tackles INTEGER CHECK (tackles >= 0 OR tackles IS NULL),
    interceptions INTEGER CHECK (interceptions >= 0 OR interceptions IS NULL),
    clearances INTEGER CHECK (clearances >= 0 OR clearances IS NULL),
    blocks INTEGER CHECK (blocks >= 0 OR blocks IS NULL),
    recoveries INTEGER CHECK (recoveries >= 0 OR recoveries IS NULL),
    duels INTEGER CHECK (duels >= 0 OR duels IS NULL),
    aerial_duels INTEGER CHECK (aerial_duels >= 0 OR aerial_duels IS NULL),
    fouls INTEGER CHECK (fouls >= 0 OR fouls IS NULL),
    fouls_won INTEGER CHECK (fouls_won >= 0 OR fouls_won IS NULL),
    offsides INTEGER CHECK (offsides >= 0 OR offsides IS NULL),
    yellow_cards INTEGER CHECK (yellow_cards >= 0 OR yellow_cards IS NULL),
    red_cards INTEGER CHECK (red_cards >= 0 OR red_cards IS NULL),
    clean_sheets INTEGER CHECK (clean_sheets >= 0 OR clean_sheets IS NULL),
    saves INTEGER CHECK (saves >= 0 OR saves IS NULL),
    save_percentage DECIMAL(5,2) CHECK (save_percentage BETWEEN 0 AND 100 OR save_percentage IS NULL),
    goals_conceded INTEGER CHECK (goals_conceded >= 0 OR goals_conceded IS NULL),
    penalties_saved INTEGER CHECK (penalties_saved >= 0 OR penalties_saved IS NULL),
    errors_leading_to_goals INTEGER CHECK (errors_leading_to_goals >= 0 OR errors_leading_to_goals IS NULL),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_player_season_comp_club UNIQUE (player_id, season_id, competition_id, club_id)
);

CREATE TABLE IF NOT EXISTS club_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    competition_id UUID NOT NULL REFERENCES competitions(id) ON DELETE CASCADE,
    matches_played INTEGER CHECK (matches_played >= 0 OR matches_played IS NULL),
    wins INTEGER CHECK (wins >= 0 OR wins IS NULL),
    draws INTEGER CHECK (draws >= 0 OR draws IS NULL),
    losses INTEGER CHECK (losses >= 0 OR losses IS NULL),
    goals_for INTEGER CHECK (goals_for >= 0 OR goals_for IS NULL),
    goals_against INTEGER CHECK (goals_against >= 0 OR goals_against IS NULL),
    goal_difference INTEGER,
    points INTEGER CHECK (points >= 0 OR points IS NULL),
    league_position INTEGER CHECK (league_position > 0 OR league_position IS NULL),
    clean_sheets INTEGER CHECK (clean_sheets >= 0 OR clean_sheets IS NULL),
    possession_avg DECIMAL(5,2) CHECK (possession_avg BETWEEN 0 AND 100 OR possession_avg IS NULL),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_club_season_comp UNIQUE (club_id, season_id, competition_id)
);

CREATE TABLE IF NOT EXISTS injuries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    injury_type VARCHAR(255) NOT NULL,
    severity VARCHAR(50),
    start_date DATE NOT NULL,
    expected_return_date DATE,
    actual_return_date DATE,
    status injury_status NOT NULL DEFAULT 'active',
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS player_awards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    award_name VARCHAR(255) NOT NULL,
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    award_date DATE,
    organizer VARCHAR(100),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS club_trophies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    competition_id UUID REFERENCES competitions(id) ON DELETE SET NULL,
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    trophy_name VARCHAR(255) NOT NULL,
    won_date DATE,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. TRANSFERS & RUMOURS
CREATE TABLE IF NOT EXISTS transfer_windows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    country_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    open_date DATE NOT NULL,
    close_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_window_dates CHECK (close_date >= open_date)
);

CREATE TABLE IF NOT EXISTS transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(100) UNIQUE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    previous_club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    new_club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    transfer_date DATE NOT NULL,
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    transfer_window_id UUID REFERENCES transfer_windows(id) ON DELETE SET NULL,
    transfer_type transfer_type NOT NULL DEFAULT 'permanent',
    is_permanent BOOLEAN NOT NULL DEFAULT TRUE,
    fee_amount DECIMAL(15,2) CHECK (fee_amount >= 0 OR fee_amount IS NULL),
    currency VARCHAR(3) DEFAULT 'EUR',
    reported_fee VARCHAR(255),
    fee_status fee_status NOT NULL DEFAULT 'confirmed',
    add_ons JSONB DEFAULT '{}'::jsonb,
    contract_duration_years DECIMAL(3,1) CHECK (contract_duration_years > 0 OR contract_duration_years IS NULL),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    source_url VARCHAR(1000),
    publication_date DATE,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transfer_fees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_id UUID NOT NULL REFERENCES transfers(id) ON DELETE CASCADE,
    base_fee DECIMAL(15,2) CHECK (base_fee >= 0 OR base_fee IS NULL),
    guaranteed_fee DECIMAL(15,2) CHECK (guaranteed_fee >= 0 OR guaranteed_fee IS NULL),
    performance_add_ons DECIMAL(15,2) CHECK (performance_add_ons >= 0 OR performance_add_ons IS NULL),
    sell_on_percentage DECIMAL(5,2) CHECK (sell_on_percentage BETWEEN 0 AND 100 OR sell_on_percentage IS NULL),
    currency VARCHAR(3) DEFAULT 'EUR',
    fee_structure_details JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rumours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    current_club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    interested_club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    headline VARCHAR(255) NOT NULL,
    summary TEXT,
    status rumour_status NOT NULL DEFAULT 'rumour',
    reported_fee DECIMAL(15,2) CHECK (reported_fee >= 0 OR reported_fee IS NULL),
    currency VARCHAR(3) DEFAULT 'EUR',
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    source_url VARCHAR(1000),
    journalist_name VARCHAR(150),
    publication_date DATE NOT NULL,
    latest_update_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rumour_updates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rumour_id UUID NOT NULL REFERENCES rumours(id) ON DELETE CASCADE,
    update_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    headline VARCHAR(255) NOT NULL,
    update_text TEXT NOT NULL,
    status_at_update rumour_status NOT NULL,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    source_url VARCHAR(1000),
    journalist_name VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. MARKET VALUE & CONTRACTS
CREATE TABLE IF NOT EXISTS market_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL UNIQUE REFERENCES players(id) ON DELETE CASCADE,
    current_market_value DECIMAL(15,2) NOT NULL CHECK (current_market_value >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    valuation_date DATE NOT NULL,
    value_change DECIMAL(15,2) DEFAULT 0.00,
    percentage_change DECIMAL(6,2) DEFAULT 0.00,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS market_value_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    market_value DECIMAL(15,2) NOT NULL CHECK (market_value >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    valuation_date DATE NOT NULL,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_player_valuation_date UNIQUE (player_id, valuation_date)
);

CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    contract_start DATE,
    contract_end DATE NOT NULL,
    status contract_status NOT NULL DEFAULT 'active',
    salary_amount DECIMAL(15,2) CHECK (salary_amount >= 0 OR salary_amount IS NULL),
    salary_currency VARCHAR(3) DEFAULT 'EUR',
    salary_period salary_period,
    release_clause_amount DECIMAL(15,2) CHECK (release_clause_amount >= 0 OR release_clause_amount IS NULL),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_contract_dates CHECK (contract_start IS NULL OR contract_end >= contract_start)
);

-- 6. MATCHES & MATCH EVENTS
CREATE TABLE IF NOT EXISTS matches (
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

CREATE TABLE IF NOT EXISTS match_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    minute INTEGER NOT NULL CHECK (minute >= 0 AND minute <= 130),
    extra_minute INTEGER CHECK (extra_minute >= 0 OR extra_minute IS NULL),
    event_type match_event_type NOT NULL,
    player_id UUID REFERENCES players(id) ON DELETE SET NULL,
    secondary_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
    club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
    details JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
