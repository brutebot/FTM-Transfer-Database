-- ==============================================================================
-- FTM MASTER DATABASE - TRIGGERS & AUTOMATION
-- Schema Version: 1.0.0
-- Description: Automated timestamp updating and market value history retention triggers
-- ==============================================================================

-- Generic Function for updating updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to main entities
CREATE TRIGGER trigger_countries_updated_at BEFORE UPDATE ON countries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_sources_updated_at BEFORE UPDATE ON sources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_leagues_updated_at BEFORE UPDATE ON leagues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_competitions_updated_at BEFORE UPDATE ON competitions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_seasons_updated_at BEFORE UPDATE ON seasons FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_clubs_updated_at BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_national_teams_updated_at BEFORE UPDATE ON national_teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_players_updated_at BEFORE UPDATE ON players FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_club_squads_updated_at BEFORE UPDATE ON club_squads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_player_statistics_updated_at BEFORE UPDATE ON player_statistics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_club_statistics_updated_at BEFORE UPDATE ON club_statistics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_transfers_updated_at BEFORE UPDATE ON transfers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_rumours_updated_at BEFORE UPDATE ON rumours FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_contracts_updated_at BEFORE UPDATE ON contracts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_market_values_updated_at BEFORE UPDATE ON market_values FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_matches_updated_at BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function for auto-archiving market value history
CREATE OR REPLACE FUNCTION archive_market_value_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO market_value_history (
        player_id,
        market_value,
        currency,
        valuation_date,
        source_id
    ) VALUES (
        NEW.player_id,
        NEW.current_market_value,
        NEW.currency,
        NEW.valuation_date,
        NEW.source_id
    )
    ON CONFLICT (player_id, valuation_date) DO UPDATE
    SET market_value = EXCLUDED.market_value,
        currency = EXCLUDED.currency,
        source_id = EXCLUDED.source_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_archive_market_value
AFTER INSERT OR UPDATE ON market_values
FOR EACH ROW EXECUTE FUNCTION archive_market_value_history();
