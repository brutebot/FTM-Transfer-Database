-- ==============================================================================
-- FTM MASTER DATABASE - INDEXES & PERFORMANCE OPTIMIZATION
-- Schema Version: 1.0.0
-- Description: B-Tree, GIN, and Trigram indexes designed for high throughput & low latency API queries
-- ==============================================================================

-- 1. PLAYERS INDEXES
CREATE INDEX idx_players_full_name_trgm ON players USING gin (full_name gin_trgm_ops);
CREATE INDEX idx_players_known_name_trgm ON players USING gin (known_name gin_trgm_ops);
CREATE INDEX idx_players_nationality ON players (nationality_id);
CREATE INDEX idx_players_position ON players (position);
CREATE INDEX idx_players_current_club ON players (current_club_id);
CREATE INDEX idx_players_external_id ON players (external_id);
CREATE INDEX idx_players_status ON players (status);

-- 2. CLUBS INDEXES
CREATE INDEX idx_clubs_official_name_trgm ON clubs USING gin (official_name gin_trgm_ops);
CREATE INDEX idx_clubs_short_name_trgm ON clubs USING gin (short_name gin_trgm_ops);
CREATE INDEX idx_clubs_country ON clubs (country_id);
CREATE INDEX idx_clubs_league ON clubs (league_id);
CREATE INDEX idx_clubs_external_id ON clubs (external_id);

-- 3. TRANSFERS INDEXES
CREATE INDEX idx_transfers_transfer_date ON transfers (transfer_date DESC);
CREATE INDEX idx_transfers_player ON transfers (player_id);
CREATE INDEX idx_transfers_fee_amount ON transfers (fee_amount DESC NULLS LAST);
CREATE INDEX idx_transfers_previous_club ON transfers (previous_club_id);
CREATE INDEX idx_transfers_new_club ON transfers (new_club_id);
CREATE INDEX idx_transfers_season ON transfers (season_id);

-- 4. RUMOURS INDEXES
CREATE INDEX idx_rumours_update_date ON rumours (latest_update_at DESC);
CREATE INDEX idx_rumours_player ON rumours (player_id);
CREATE INDEX idx_rumours_status ON rumours (status);
CREATE INDEX idx_rumours_interested_club ON rumours (interested_club_id);

-- 5. MARKET VALUES INDEXES
CREATE INDEX idx_market_values_player ON market_values (player_id);
CREATE INDEX idx_market_values_amount ON market_values (current_market_value DESC);
CREATE INDEX idx_market_values_valuation_date ON market_values (valuation_date DESC);
CREATE INDEX idx_market_value_hist_player_date ON market_value_history (player_id, valuation_date DESC);

-- 6. MATCHES INDEXES
CREATE INDEX idx_matches_competition ON matches (competition_id);
CREATE INDEX idx_matches_season ON matches (season_id);
CREATE INDEX idx_matches_date ON matches (match_date DESC);
CREATE INDEX idx_matches_home_away ON matches (home_club_id, away_club_id);

-- 7. PLAYER STATISTICS INDEXES
CREATE INDEX idx_player_stats_player ON player_statistics (player_id);
CREATE INDEX idx_player_stats_season_comp ON player_statistics (season_id, competition_id);
CREATE INDEX idx_player_stats_club ON player_statistics (club_id);

-- 8. CONTRACTS INDEXES
CREATE INDEX idx_contracts_player ON contracts (player_id);
CREATE INDEX idx_contracts_club ON contracts (club_id);
CREATE INDEX idx_contracts_end_date ON contracts (contract_end);

-- 9. SQUADS & HISTORY INDEXES
CREATE INDEX idx_club_squads_club_season ON club_squads (club_id, season_id);
CREATE INDEX idx_player_history_player ON player_history (player_id);
