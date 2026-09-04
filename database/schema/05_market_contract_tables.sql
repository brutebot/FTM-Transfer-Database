-- ==============================================================================
-- FTM MASTER DATABASE - MARKET VALUE & CONTRACT ENTITIES
-- Schema Version: 1.0.0
-- Description: Current market values, historical valuation records, player contracts
-- ==============================================================================

-- 18. MARKET VALUES (Current Value Snapshot)
CREATE TABLE market_values (
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

-- 19. MARKET VALUE HISTORY (Time-Series for Historical Charts)
CREATE TABLE market_value_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    market_value DECIMAL(15,2) NOT NULL CHECK (market_value >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    valuation_date DATE NOT NULL,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_player_valuation_date UNIQUE (player_id, valuation_date)
);

-- 20. CONTRACTS
CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    contract_start DATE,
    contract_end DATE NOT NULL,
    status contract_status NOT NULL DEFAULT 'active',
    salary_amount DECIMAL(15,2) CHECK (salary_amount >= 0 OR salary_amount IS NULL),
    salary_currency VARCHAR(3) DEFAULT 'EUR',
    salary_period salary_period, -- weekly or annual
    release_clause_amount DECIMAL(15,2) CHECK (release_clause_amount >= 0 OR release_clause_amount IS NULL),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    last_verified_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_contract_dates CHECK (contract_start IS NULL OR contract_end >= contract_start)
);
