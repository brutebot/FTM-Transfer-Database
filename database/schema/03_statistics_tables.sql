-- ==============================================================================
-- FTM MASTER DATABASE - STATISTICS & HONOURS ENTITIES
-- Schema Version: 1.0.0
-- Description: Player statistics, club statistics, injuries, awards, and trophies
-- ==============================================================================

-- 2. PLAYER STATISTICS
CREATE TABLE player_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    season_id UUID NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    competition_id UUID NOT NULL REFERENCES competitions(id) ON DELETE CASCADE,
    club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
    is_goalkeeper BOOLEAN DEFAULT FALSE,
    
    -- General appearances
    appearances INTEGER CHECK (appearances >= 0 OR appearances IS NULL),
    starts INTEGER CHECK (starts >= 0 OR starts IS NULL),
    minutes INTEGER CHECK (minutes >= 0 OR minutes IS NULL),

    -- Outfield attacking & passing stats
    goals INTEGER CHECK (goals >= 0 OR goals IS NULL),
    assists INTEGER CHECK (assists >= 0 OR assists IS NULL),
    shots INTEGER CHECK (shots >= 0 OR shots IS NULL),
    shots_on_target INTEGER CHECK (shots_on_target >= 0 OR shots_on_target IS NULL),
    chances_created INTEGER CHECK (chances_created >= 0 OR chances_created IS NULL),
    key_passes INTEGER CHECK (key_passes >= 0 OR key_passes IS NULL),
    passes INTEGER CHECK (passes >= 0 OR passes IS NULL),
    pass_accuracy DECIMAL(5,2) CHECK (pass_accuracy BETWEEN 0 AND 100 OR pass_accuracy IS NULL),
    progressive_passes INTEGER CHECK (progressive_passes >= 0 OR progressive_passes IS NULL),
    
    -- Outfield dribbling & defensive stats
    dribbles INTEGER CHECK (dribbles >= 0 OR dribbles IS NULL),
    successful_dribbles INTEGER CHECK (successful_dribbles >= 0 OR successful_dribbles IS NULL),
    tackles INTEGER CHECK (tackles >= 0 OR tackles IS NULL),
    interceptions INTEGER CHECK (interceptions >= 0 OR interceptions IS NULL),
    clearances INTEGER CHECK (clearances >= 0 OR clearances IS NULL),
    blocks INTEGER CHECK (blocks >= 0 OR blocks IS NULL),
    recoveries INTEGER CHECK (recoveries >= 0 OR recoveries IS NULL),
    duels INTEGER CHECK (duels >= 0 OR duels IS NULL),
    aerial_duels INTEGER CHECK (aerial_duels >= 0 OR aerial_duels IS NULL),
    
    -- Discipline & cards
    fouls INTEGER CHECK (fouls >= 0 OR fouls IS NULL),
    fouls_won INTEGER CHECK (fouls_won >= 0 OR fouls_won IS NULL),
    offsides INTEGER CHECK (offsides >= 0 OR offsides IS NULL),
    yellow_cards INTEGER CHECK (yellow_cards >= 0 OR yellow_cards IS NULL),
    red_cards INTEGER CHECK (red_cards >= 0 OR red_cards IS NULL),
    
    -- Shared / Goalkeeper clean sheets
    clean_sheets INTEGER CHECK (clean_sheets >= 0 OR clean_sheets IS NULL),
    
    -- Goalkeeper specific stats
    saves INTEGER CHECK (saves >= 0 OR saves IS NULL),
    save_percentage DECIMAL(5,2) CHECK (save_percentage BETWEEN 0 AND 100 OR save_percentage IS NULL),
    goals_conceded INTEGER CHECK (goals_conceded >= 0 OR goals_conceded IS NULL),
    penalties_saved INTEGER CHECK (penalties_saved >= 0 OR penalties_saved IS NULL),
    errors_leading_to_goals INTEGER CHECK (errors_leading_to_goals >= 0 OR errors_leading_to_goals IS NULL),

    -- Data Quality & Provenance metadata
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    confidence_level VARCHAR(50),
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unique_player_season_comp_club UNIQUE (player_id, season_id, competition_id, club_id)
);

-- 6. CLUB STATISTICS
CREATE TABLE club_statistics (
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

-- 23. INJURIES
CREATE TABLE injuries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    injury_type VARCHAR(255) NOT NULL,
    severity VARCHAR(50), -- minor, moderate, severe, critical
    start_date DATE NOT NULL,
    expected_return_date DATE,
    actual_return_date DATE,
    status injury_status NOT NULL DEFAULT 'active',
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 24. PLAYER AWARDS
CREATE TABLE player_awards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    award_name VARCHAR(255) NOT NULL,
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    award_date DATE,
    organizer VARCHAR(100),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 25. CLUB TROPHIES
CREATE TABLE club_trophies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    competition_id UUID REFERENCES competitions(id) ON DELETE SET NULL,
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    trophy_name VARCHAR(255) NOT NULL,
    won_date DATE,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
