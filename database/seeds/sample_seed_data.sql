-- ==============================================================================
-- FTM MASTER DATABASE - SAMPLE SEED DATA
-- Description: Sample records ONLY for relationship validation & schema testing.
-- NOTICE: THIS IS SAMPLE DATA FOR INTEGRATION TESTING. DO NOT USE AS REAL DATA.
-- ==============================================================================

-- 1. COUNTRIES (SAMPLE)
INSERT INTO countries (id, iso_code, name, confederation, fifa_ranking) VALUES
('11111111-1111-4111-a111-111111111111', 'ENG', 'England [SAMPLE DATA]', 'UEFA', 3),
('22222222-2222-4222-a222-222222222222', 'FRA', 'France [SAMPLE DATA]', 'UEFA', 2),
('33333333-3333-4333-a333-333333333333', 'ESP', 'Spain [SAMPLE DATA]', 'UEFA', 1)
ON CONFLICT (iso_code) DO NOTHING;

-- 2. SOURCES (SAMPLE)
INSERT INTO sources (id, source_name, source_url, source_type, reliability_metadata) VALUES
('a0000000-0000-4000-a000-000000000001', 'Official League Release [SAMPLE DATA]', 'https://example.com/source/official-release', 'official_announcement', '{"tier": 1, "trust_score": 1.0}'),
('a0000000-0000-4000-a000-000000000002', 'Tier 1 Transfer Journalist [SAMPLE DATA]', 'https://example.com/source/journalist-report', 'tier_1_journalism', '{"tier": 1, "trust_score": 0.95}');

-- 3. LEAGUES & COMPETITIONS (SAMPLE)
INSERT INTO leagues (id, external_id, name, code, country_id, tier, league_type) VALUES
('b0000000-0000-4000-a000-000000000001', 'ext_league_eng_1', 'Premier League [SAMPLE DATA]', 'EPL', '11111111-1111-4111-a111-111111111111', 1, 'domestic_league'),
('b0000000-0000-4000-a000-000000000002', 'ext_league_esp_1', 'La Liga [SAMPLE DATA]', 'LALIGA', '33333333-3333-4333-a333-333333333333', 1, 'domestic_league');

INSERT INTO competitions (id, external_id, league_id, name, competition_type) VALUES
('c0000000-0000-4000-a000-000000000001', 'ext_comp_epl_2025', 'b0000000-0000-4000-a000-000000000001', 'Premier League 2025/26 [SAMPLE DATA]', 'league'),
('c0000000-0000-4000-a000-000000000002', 'ext_comp_laliga_2025', 'b0000000-0000-4000-a000-000000000002', 'La Liga 2025/26 [SAMPLE DATA]', 'league');

-- 4. SEASONS (SAMPLE)
INSERT INTO seasons (id, external_id, competition_id, name, start_date, end_date, is_current) VALUES
('d0000000-0000-4000-a000-000000000001', 'ext_season_2025_2026_epl', 'c0000000-0000-4000-a000-000000000001', '2025/2026', '2025-08-15', '2026-05-24', TRUE),
('d0000000-0000-4000-a000-000000000002', 'ext_season_2025_2026_laliga', 'c0000000-0000-4000-a000-000000000002', '2025/2026', '2025-08-15', '2026-05-24', TRUE);

-- 5. CLUBS (SAMPLE)
INSERT INTO clubs (id, external_id, official_name, short_name, country_id, city, league_id, stadium_name, stadium_capacity, founded_year, status) VALUES
('e0000000-0000-4000-a000-000000000001', 'ext_club_mcfc', 'Manchester City FC [SAMPLE DATA]', 'Man City', '11111111-1111-4111-a111-111111111111', 'Manchester', 'b0000000-0000-4000-a000-000000000001', 'Etihad Stadium', 53400, 1880, 'active'),
('e0000000-0000-4000-a000-000000000002', 'ext_club_rmcf', 'Real Madrid CF [SAMPLE DATA]', 'Real Madrid', '33333333-3333-4333-a333-333333333333', 'Madrid', 'b0000000-0000-4000-a000-000000000002', 'Santiago Bernabéu', 81044, 1902, 'active');

-- 6. PLAYERS (SAMPLE)
INSERT INTO players (id, external_id, full_name, known_name, dob, nationality_id, position, secondary_positions, preferred_foot, height_cm, weight_kg, shirt_number, current_club_id, status, career_start_year) VALUES
('f0000000-0000-4000-a000-000000000001', 'ext_player_sample_1', 'Erling Haaland [SAMPLE DATA]', 'Haaland', '2000-07-21', '11111111-1111-4111-a111-111111111111', 'ST', '["CF"]', 'left', 195, 88, 9, 'e0000000-0000-4000-a000-000000000001', 'active', 2016),
('f0000000-0000-4000-a000-000000000002', 'ext_player_sample_2', 'Jude Bellingham [SAMPLE DATA]', 'Bellingham', '2003-06-29', '11111111-1111-4111-a111-111111111111', 'CAM', '["CM"]', 'right', 186, 75, 5, 'e0000000-0000-4000-a000-000000000002', 'active', 2019);

-- 7. MARKET VALUES (SAMPLE)
INSERT INTO market_values (id, player_id, current_market_value, currency, valuation_date, value_change, percentage_change, source_id) VALUES
('g0000000-0000-4000-a000-000000000001', 'f0000000-0000-4000-a000-000000000001', 180000000.00, 'EUR', '2026-01-01', 0.00, 0.00, 'a0000000-0000-4000-a000-000000000001'),
('g0000000-0000-4000-a000-000000000002', 'f0000000-0000-4000-a000-000000000002', 180000000.00, 'EUR', '2026-01-01', 0.00, 0.00, 'a0000000-0000-4000-a000-000000000001');

-- 8. CONTRACTS (SAMPLE)
INSERT INTO contracts (id, player_id, club_id, contract_start, contract_end, status, salary_amount, salary_currency, salary_period, source_id) VALUES
('h0000000-0000-4000-a000-000000000001', 'f0000000-0000-4000-a000-000000000001', 'e0000000-0000-4000-a000-000000000001', '2022-07-01', '2027-06-30', 'active', 375000.00, 'GBP', 'weekly', 'a0000000-0000-4000-a000-000000000001');

-- 9. TRANSFERS (SAMPLE)
INSERT INTO transfer_windows (id, name, season_id, open_date, close_date, is_active) VALUES
('w0000000-0000-4000-a000-000000000001', 'Summer 2022 [SAMPLE DATA]', 'd0000000-0000-4000-a000-000000000001', '2022-06-10', '2022-09-01', FALSE);

INSERT INTO transfers (id, external_id, player_id, previous_club_id, new_club_id, transfer_date, season_id, transfer_window_id, transfer_type, is_permanent, fee_amount, currency, reported_fee, fee_status, source_id, source_url) VALUES
('t0000000-0000-4000-a000-000000000001', 'ext_tr_sample_1', 'f0000000-0000-4000-a000-000000000001', NULL, 'e0000000-0000-4000-a000-000000000001', '2022-07-01', 'd0000000-0000-4000-a000-000000000001', 'w0000000-0000-4000-a000-000000000001', 'permanent', TRUE, 60000000.00, 'EUR', '€60M [SAMPLE DATA]', 'confirmed', 'a0000000-0000-4000-a000-000000000001', 'https://example.com/transfers/sample-1');

-- 10. RUMOURS (SAMPLE)
INSERT INTO rumours (id, player_id, current_club_id, interested_club_id, headline, summary, status, reported_fee, currency, source_id, source_url, journalist_name, publication_date, is_verified) VALUES
('r0000000-0000-4000-a000-000000000001', 'f0000000-0000-4000-a000-000000000002', 'e0000000-0000-4000-a000-000000000002', 'e0000000-0000-4000-a000-000000000001', 'Sample Contract Extension Interest [SAMPLE DATA]', 'Sample intelligence entry for architecture testing.', 'interest', NULL, 'EUR', 'a0000000-0000-4000-a000-000000000002', 'https://example.com/rumours/sample-1', 'Sample Journalist', '2026-02-01', TRUE);
