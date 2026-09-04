-- ==============================================================================
-- FTM MASTER DATABASE - TRANSFERS & RUMOURS ENTITIES
-- Schema Version: 1.0.0
-- Description: Transfer windows, historical transfers, fee breakdowns, rumours, rumour timeline
-- ==============================================================================

-- 13. TRANSFER WINDOWS
CREATE TABLE transfer_windows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL, -- e.g. "Summer 2025", "Winter 2026"
    season_id UUID REFERENCES seasons(id) ON DELETE SET NULL,
    country_id UUID REFERENCES countries(id) ON DELETE SET NULL,
    open_date DATE NOT NULL,
    close_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_window_dates CHECK (close_date >= open_date)
);

-- 12. TRANSFERS
CREATE TABLE transfers (
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

-- 14. TRANSFER FEES (Detailed Fee Structure Breakdown)
CREATE TABLE transfer_fees (
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

-- 15. RUMOURS / TRANSFER INTELLIGENCE
CREATE TABLE rumours (
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

-- 16. RUMOUR UPDATES (Timeline of rumour progression)
CREATE TABLE rumour_updates (
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
