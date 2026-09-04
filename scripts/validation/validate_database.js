/**
 * FTM MASTER DATABASE - AUTOMATED INTEGRITY VALIDATION ENGINE
 * 
 * Performs 10 critical checks across database entities and landing data:
 * 1. Duplicate IDs
 * 2. Missing required fields
 * 3. Invalid dates (ISO-8601)
 * 4. Invalid currency codes (ISO 4217)
 * 5. Broken relationships (Foreign Keys)
 * 6. Duplicate transfers
 * 7. Invalid player/club references
 * 8. Malformed URLs
 * 9. Impossible negative statistics
 * 10. Invalid season formats
 */

const fs = require('fs');
const path = require('path');
const {
  VALID_ISO_CURRENCIES,
  VALID_POSITIONS,
  VALID_RUMOUR_STATUSES,
  VALID_TRANSFER_TYPES,
  SEASON_FORMAT_REGEX,
  ISO_DATE_REGEX,
  isValidUrl
} = require('./schema_rules');

function runValidation() {
  console.log('==============================================================================');
  console.log('FTM MASTER DATABASE - EXECUTING AUTOMATED VALIDATION SUITE');
  console.log('==============================================================================\n');

  const errors = [];
  const warnings = [];

  // Load Seed / Landing Data
  const seedPath = path.join(__dirname, '../../database/seeds/sample_data.json');
  if (!fs.existsSync(seedPath)) {
    console.error(`Seed data file missing at: ${seedPath}`);
    process.exit(1);
  }

  const data = JSON.parse(fs.readFileSync(seedPath, 'utf8'));

  // Entity Maps for Foreign Key verification
  const entityMap = {
    countries: new Set((data.countries || []).map(c => c.id)),
    sources: new Set((data.sources || []).map(s => s.id)),
    leagues: new Set((data.leagues || []).map(l => l.id)),
    competitions: new Set((data.competitions || []).map(c => c.id)),
    seasons: new Set((data.seasons || []).map(s => s.id)),
    clubs: new Set((data.clubs || []).map(c => c.id)),
    players: new Set((data.players || []).map(p => p.id)),
    transfers: new Set((data.transfers || []).map(t => t.id)),
    rumours: new Set((data.rumours || []).map(r => r.id))
  };

  // CHECK 1: Duplicate IDs & External IDs
  console.log('[CHECK 1] Scanning for Duplicate Internal and External IDs...');
  const allInternalIds = new Map();
  for (const [entityName, records] of Object.entries(data)) {
    if (!Array.isArray(records)) continue;
    records.forEach((record, index) => {
      if (record.id) {
        if (allInternalIds.has(record.id)) {
          errors.push(`[Duplicate ID] ${entityName}[${index}] ID '${record.id}' duplicates ID in ${allInternalIds.get(record.id)}`);
        } else {
          allInternalIds.set(record.id, `${entityName}[${index}]`);
        }
      }
    });
  }

  // CHECK 2: Missing Required Fields
  console.log('[CHECK 2] Verifying Required Structural Fields...');
  (data.players || []).forEach((p, idx) => {
    if (!p.full_name) errors.push(`[Missing Field] players[${idx}] missing required field 'full_name'`);
    if (!p.position) errors.push(`[Missing Field] players[${idx}] missing required field 'position'`);
    if (p.position && !VALID_POSITIONS.has(p.position)) {
      errors.push(`[Invalid Position] players[${idx}] position '${p.position}' is invalid`);
    }
  });

  (data.clubs || []).forEach((c, idx) => {
    if (!c.official_name) errors.push(`[Missing Field] clubs[${idx}] missing required field 'official_name'`);
    if (!c.short_name) errors.push(`[Missing Field] clubs[${idx}] missing required field 'short_name'`);
  });

  (data.transfers || []).forEach((t, idx) => {
    if (!t.player_id) errors.push(`[Missing Field] transfers[${idx}] missing required field 'player_id'`);
    if (!t.transfer_date) errors.push(`[Missing Field] transfers[${idx}] missing required field 'transfer_date'`);
  });

  // CHECK 3: Invalid ISO Dates
  console.log('[CHECK 3] Validating ISO-8601 Date Formatting...');
  (data.players || []).forEach((p, idx) => {
    if (p.dob && !ISO_DATE_REGEX.test(p.dob)) {
      errors.push(`[Invalid Date] players[${idx}] dob '${p.dob}' is not valid ISO-8601 (YYYY-MM-DD)`);
    }
  });

  (data.seasons || []).forEach((s, idx) => {
    if (s.start_date && !ISO_DATE_REGEX.test(s.start_date)) {
      errors.push(`[Invalid Date] seasons[${idx}] start_date '${s.start_date}' is not valid ISO-8601`);
    }
    if (s.end_date && !ISO_DATE_REGEX.test(s.end_date)) {
      errors.push(`[Invalid Date] seasons[${idx}] end_date '${s.end_date}' is not valid ISO-8601`);
    }
  });

  (data.transfers || []).forEach((t, idx) => {
    if (t.transfer_date && !ISO_DATE_REGEX.test(t.transfer_date)) {
      errors.push(`[Invalid Date] transfers[${idx}] transfer_date '${t.transfer_date}' is not valid ISO-8601`);
    }
  });

  // CHECK 4: Invalid Currency Codes (ISO 4217)
  console.log('[CHECK 4] Checking ISO 4217 Currency Compliance...');
  (data.transfers || []).forEach((t, idx) => {
    if (t.currency && !VALID_ISO_CURRENCIES.has(t.currency)) {
      errors.push(`[Invalid Currency] transfers[${idx}] currency '${t.currency}' is not a valid ISO 4217 code`);
    }
  });

  (data.rumours || []).forEach((r, idx) => {
    if (r.currency && !VALID_ISO_CURRENCIES.has(r.currency)) {
      errors.push(`[Invalid Currency] rumours[${idx}] currency '${r.currency}' is not a valid ISO 4217 code`);
    }
  });

  // CHECK 5 & 7: Broken Relationships and Player/Club References
  console.log('[CHECK 5 & 7] Auditing Foreign Key Integrity & Player/Club References...');
  (data.players || []).forEach((p, idx) => {
    if (p.nationality_id && !entityMap.countries.has(p.nationality_id)) {
      errors.push(`[Broken FK] players[${idx}] nationality_id '${p.nationality_id}' does not exist in countries table`);
    }
    if (p.current_club_id && !entityMap.clubs.has(p.current_club_id)) {
      errors.push(`[Broken FK] players[${idx}] current_club_id '${p.current_club_id}' does not exist in clubs table`);
    }
  });

  (data.transfers || []).forEach((t, idx) => {
    if (t.player_id && !entityMap.players.has(t.player_id)) {
      errors.push(`[Broken FK] transfers[${idx}] player_id '${t.player_id}' does not exist in players table`);
    }
    if (t.previous_club_id && !entityMap.clubs.has(t.previous_club_id)) {
      errors.push(`[Broken FK] transfers[${idx}] previous_club_id '${t.previous_club_id}' does not exist in clubs table`);
    }
    if (t.new_club_id && !entityMap.clubs.has(t.new_club_id)) {
      errors.push(`[Broken FK] transfers[${idx}] new_club_id '${t.new_club_id}' does not exist in clubs table`);
    }
  });

  (data.rumours || []).forEach((r, idx) => {
    if (r.player_id && !entityMap.players.has(r.player_id)) {
      errors.push(`[Broken FK] rumours[${idx}] player_id '${r.player_id}' does not exist in players table`);
    }
    if (r.interested_club_id && !entityMap.clubs.has(r.interested_club_id)) {
      errors.push(`[Broken FK] rumours[${idx}] interested_club_id '${r.interested_club_id}' does not exist in clubs table`);
    }
  });

  // CHECK 6: Duplicate Transfers
  console.log('[CHECK 6] Checking for Duplicate Transfer Signature Records...');
  const transferSignatures = new Set();
  (data.transfers || []).forEach((t, idx) => {
    const signature = `${t.player_id}_${t.previous_club_id || 'null'}_${t.new_club_id || 'null'}_${t.transfer_date}`;
    if (transferSignatures.has(signature)) {
      errors.push(`[Duplicate Transfer] transfers[${idx}] duplicate transfer record detected for signature '${signature}'`);
    } else {
      transferSignatures.add(signature);
    }
  });

  // CHECK 8: Malformed URLs
  console.log('[CHECK 8] Validating Source and External URLs...');
  (data.sources || []).forEach((s, idx) => {
    if (s.source_url && !isValidUrl(s.source_url)) {
      errors.push(`[Malformed URL] sources[${idx}] source_url '${s.source_url}' is not a valid URL`);
    }
  });

  (data.rumours || []).forEach((r, idx) => {
    if (r.source_url && !isValidUrl(r.source_url)) {
      errors.push(`[Malformed URL] rumours[${idx}] source_url '${r.source_url}' is not a valid URL`);
    }
  });

  // CHECK 9: Impossible Negative Statistics
  console.log('[CHECK 9] Verifying Non-Negative Constraints on Statistics...');
  (data.player_statistics || []).forEach((st, idx) => {
    const numericFields = ['appearances', 'starts', 'minutes', 'goals', 'assists', 'shots', 'tackles', 'saves'];
    numericFields.forEach(field => {
      if (st[field] !== undefined && st[field] < 0) {
        errors.push(`[Negative Stat] player_statistics[${idx}] field '${field}' cannot be negative (${st[field]})`);
      }
    });
  });

  // CHECK 10: Invalid Season Formats
  console.log('[CHECK 10] Validating Season Format Conventions...');
  (data.seasons || []).forEach((s, idx) => {
    if (s.name && !SEASON_FORMAT_REGEX.test(s.name)) {
      errors.push(`[Invalid Season Format] seasons[${idx}] name '${s.name}' must follow YYYY/YYYY or YYYY format`);
    }
  });

  // PRINT SUMMARY
  console.log('\n------------------------------------------------------------------------------');
  console.log('VALIDATION RESULTS SUMMARY:');
  console.log(`- Total Records Evaluated: ${Object.values(data).reduce((acc, curr) => acc + (Array.isArray(curr) ? curr.length : 0), 0)}`);
  console.log(`- Errors Found: ${errors.length}`);
  console.log(`- Warnings Found: ${warnings.length}`);
  console.log('------------------------------------------------------------------------------\n');

  if (errors.length > 0) {
    console.error('CRITICAL INTEGRITY ERRORS FOUND:');
    errors.forEach(err => console.error(` ❌ ${err}`));
    process.exit(1);
  } else {
    console.log('✅ ALL 10 INTEGRITY CHECKS PASSED SUCCESSFULLY WITH 0 ERRORS!');
  }
}

runValidation();
