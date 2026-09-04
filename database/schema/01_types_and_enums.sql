-- ==============================================================================
-- FTM MASTER DATABASE - TYPES AND ENUMS
-- Schema Version: 1.0.0
-- Description: Core custom PostgreSQL data types, domains, and enum definitions
-- ==============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Player primary pitch position enum
CREATE TYPE player_position AS ENUM (
    'GK',  -- Goalkeeper
    'CB',  -- Centre-Back
    'LB',  -- Left-Back
    'RB',  -- Right-Back
    'LWB', -- Left Wing-Back
    'RWB', -- Right Wing-Back
    'CDM', -- Central Defensive Midfielder
    'CM',  -- Central Midfielder
    'CAM', -- Central Attacking Midfielder
    'LM',  -- Left Midfielder
    'RM',  -- Right Midfielder
    'LW',  -- Left Winger
    'RW',  -- Right Winger
    'CF',  -- Centre Forward
    'ST'   -- Striker
);

-- Preferred foot enum
CREATE TYPE preferred_foot AS ENUM (
    'left',
    'right',
    'both'
);

-- Player status enum
CREATE TYPE player_status AS ENUM (
    'active',
    'retired',
    'free_agent',
    'banned'
);

-- Club status enum
CREATE TYPE club_status AS ENUM (
    'active',
    'dissolved',
    'merged'
);

-- Transfer type enum
CREATE TYPE transfer_type AS ENUM (
    'permanent',
    'loan',
    'free_transfer',
    'return_from_loan'
);

-- Fee status enum
CREATE TYPE fee_status AS ENUM (
    'confirmed',
    'undisclosed',
    'free',
    'undisclosed_loan_fee'
);

-- Rumour status enum
CREATE TYPE rumour_status AS ENUM (
    'rumour',
    'reported',
    'interest',
    'negotiations',
    'advanced',
    'agreement',
    'confirmed',
    'dismissed'
);

-- Source reliability & tier enum
CREATE TYPE source_type AS ENUM (
    'official_announcement',
    'tier_1_journalism',
    'tier_2_journalism',
    'tier_3_journalism',
    'provider_api',
    'club_statement'
);

-- Contract status enum
CREATE TYPE contract_status AS ENUM (
    'active',
    'expired',
    'terminated',
    'pending_extension'
);

-- Salary period enum
CREATE TYPE salary_period AS ENUM (
    'weekly',
    'annual'
);

-- Match status enum
CREATE TYPE match_status AS ENUM (
    'scheduled',
    'in_progress',
    'finished',
    'postponed',
    'cancelled'
);

-- Match event type enum
CREATE TYPE match_event_type AS ENUM (
    'goal',
    'assist',
    'yellow_card',
    'red_card',
    'substitution',
    'penalty',
    'var_event'
);

-- Injury status enum
CREATE TYPE injury_status AS ENUM (
    'active',
    'recovered'
);
