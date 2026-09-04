-- ==============================================================================
-- FTM MASTER DATABASE - API-READY VIEWS
-- Schema Version: 1.0.0
-- Description: Database views optimized for REST API & GraphQL consumption
-- ==============================================================================

-- 1. PLAYERS SUMMARY VIEW FOR GET /api/v1/players & GET /api/v1/players/{id}
CREATE OR REPLACE VIEW v_players_api AS
SELECT 
    p.id AS player_id,
    p.external_id,
    p.full_name,
    p.known_name,
    p.dob,
    EXTRACT(YEAR FROM AGE(p.dob))::INTEGER AS age,
    c_nat.name AS nationality,
    c_nat.iso_code AS nationality_iso,
    c_sec.name AS secondary_nationality,
    p.position AS primary_position,
    p.secondary_positions,
    p.preferred_foot,
    p.height_cm,
    p.weight_kg,
    p.shirt_number,
    p.status AS player_status,
    p.profile_photo_url,
    p.current_club_id,
    cl.official_name AS current_club_name,
    cl.short_name AS current_club_short_name,
    cl.logo_url AS current_club_logo,
    nt.official_name AS national_team_name,
    mv.current_market_value,
    mv.currency AS market_value_currency,
    mv.valuation_date AS market_value_date,
    con.contract_end,
    con.salary_amount,
    con.salary_period,
    p.last_verified_at,
    p.updated_at
FROM players p
LEFT JOIN countries c_nat ON p.nationality_id = c_nat.id
LEFT JOIN countries c_sec ON p.secondary_nationality_id = c_sec.id
LEFT JOIN clubs cl ON p.current_club_id = cl.id
LEFT JOIN national_teams nt ON p.national_team_id = nt.id
LEFT JOIN market_values mv ON p.id = mv.player_id
LEFT JOIN contracts con ON p.id = con.player_id AND con.status = 'active';

-- 2. PLAYER STATS VIEW FOR GET /api/v1/players/{id}/stats
CREATE OR REPLACE VIEW v_player_stats_api AS
SELECT 
    ps.id AS stat_id,
    ps.player_id,
    p.full_name AS player_name,
    ps.season_id,
    s.name AS season_name,
    ps.competition_id,
    comp.name AS competition_name,
    ps.club_id,
    cl.official_name AS club_name,
    ps.is_goalkeeper,
    ps.appearances,
    ps.starts,
    ps.minutes,
    ps.goals,
    ps.assists,
    ps.shots,
    ps.shots_on_target,
    ps.chances_created,
    ps.key_passes,
    ps.passes,
    ps.pass_accuracy,
    ps.progressive_passes,
    ps.dribbles,
    ps.successful_dribbles,
    ps.tackles,
    ps.interceptions,
    ps.clearances,
    ps.blocks,
    ps.recoveries,
    ps.duels,
    ps.aerial_duels,
    ps.fouls,
    ps.fouls_won,
    ps.offsides,
    ps.yellow_cards,
    ps.red_cards,
    ps.clean_sheets,
    ps.saves,
    ps.save_percentage,
    ps.goals_conceded,
    ps.penalties_saved,
    ps.errors_leading_to_goals,
    ps.confidence_level,
    ps.is_verified,
    ps.last_verified_at
FROM player_statistics ps
JOIN players p ON ps.player_id = p.id
JOIN seasons s ON ps.season_id = s.id
JOIN competitions comp ON ps.competition_id = comp.id
LEFT JOIN clubs cl ON ps.club_id = cl.id;

-- 3. TRANSFERS VIEW FOR GET /api/v1/transfers & GET /api/v1/players/{id}/transfers
CREATE OR REPLACE VIEW v_transfers_api AS
SELECT 
    t.id AS transfer_id,
    t.external_id,
    t.player_id,
    p.full_name AS player_name,
    p.known_name AS player_known_name,
    p.profile_photo_url AS player_photo,
    t.previous_club_id,
    c_prev.official_name AS previous_club_name,
    c_prev.logo_url AS previous_club_logo,
    t.new_club_id,
    c_new.official_name AS new_club_name,
    c_new.logo_url AS new_club_logo,
    t.transfer_date,
    t.season_id,
    s.name AS season_name,
    tw.name AS transfer_window_name,
    t.transfer_type,
    t.is_permanent,
    t.fee_amount,
    t.currency,
    t.reported_fee,
    t.fee_status,
    t.add_ons,
    t.contract_duration_years,
    src.source_name,
    src.source_type,
    t.source_url,
    t.is_verified,
    t.verified_at
FROM transfers t
JOIN players p ON t.player_id = p.id
LEFT JOIN clubs c_prev ON t.previous_club_id = c_prev.id
LEFT JOIN clubs c_new ON t.new_club_id = c_new.id
LEFT JOIN seasons s ON t.season_id = s.id
LEFT JOIN transfer_windows tw ON t.transfer_window_id = tw.id
LEFT JOIN sources src ON t.source_id = src.id;

-- 4. RUMOURS VIEW FOR GET /api/v1/rumours & GET /api/v1/players/{id}/rumours
CREATE OR REPLACE VIEW v_rumours_api AS
SELECT 
    r.id AS rumour_id,
    r.player_id,
    p.full_name AS player_name,
    p.known_name AS player_known_name,
    p.profile_photo_url AS player_photo,
    r.current_club_id,
    c_curr.official_name AS current_club_name,
    c_curr.logo_url AS current_club_logo,
    r.interested_club_id,
    c_int.official_name AS interested_club_name,
    c_int.logo_url AS interested_club_logo,
    r.headline,
    r.summary,
    r.status AS rumour_status,
    r.reported_fee,
    r.currency,
    src.source_name,
    src.source_type,
    r.source_url,
    r.journalist_name,
    r.publication_date,
    r.latest_update_at,
    r.is_verified,
    r.verified_at
FROM rumours r
JOIN players p ON r.player_id = p.id
LEFT JOIN clubs c_curr ON r.current_club_id = c_curr.id
LEFT JOIN clubs c_int ON r.interested_club_id = c_int.id
LEFT JOIN sources src ON r.source_id = src.id;

-- 5. CLUBS VIEW FOR GET /api/v1/clubs & GET /api/v1/clubs/{id}
CREATE OR REPLACE VIEW v_clubs_api AS
SELECT 
    cl.id AS club_id,
    cl.external_id,
    cl.official_name,
    cl.short_name,
    cnt.name AS country_name,
    cnt.iso_code AS country_iso,
    cl.city,
    l.id AS league_id,
    l.name AS league_name,
    cl.stadium_name,
    cl.stadium_capacity,
    cl.founded_year,
    cl.logo_url,
    cl.official_website,
    cl.current_manager,
    cl.status AS club_status,
    (SELECT COUNT(*) FROM players p WHERE p.current_club_id = cl.id AND p.status = 'active') AS total_squad_size,
    cl.last_verified_at,
    cl.updated_at
FROM clubs cl
LEFT JOIN countries cnt ON cl.country_id = cnt.id
LEFT JOIN leagues l ON cl.league_id = l.id;
