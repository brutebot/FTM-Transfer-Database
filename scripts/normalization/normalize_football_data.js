/**
 * FTM MASTER DATABASE - DATA NORMALIZATION PIPELINE
 * 
 * Transforms raw third-party provider payloads (e.g., Opta, Wyscout, API-Football)
 * into standardized FTM Master Database formats.
 */

const { VALID_ISO_CURRENCIES, VALID_POSITIONS } = require('../validation/schema_rules');

// Map legacy or provider specific positions to FTM standard position ENUMs
const POSITION_MAPPINGS = {
  'Goalkeeper': 'GK',
  'GK': 'GK',
  'Center-Back': 'CB',
  'Central Defender': 'CB',
  'CB': 'CB',
  'Left-Back': 'LB',
  'LB': 'LB',
  'Right-Back': 'RB',
  'RB': 'RB',
  'Defensive Midfield': 'CDM',
  'CDM': 'CDM',
  'Central Midfield': 'CM',
  'CM': 'CM',
  'Attacking Midfield': 'CAM',
  'CAM': 'CAM',
  'Left Winger': 'LW',
  'LW': 'LW',
  'Right Winger': 'RW',
  'RW': 'RW',
  'Centre-Forward': 'CF',
  'CF': 'CF',
  'Striker': 'ST',
  'ST': 'ST'
};

// Currency mapping for non-standard symbols
const CURRENCY_MAPPINGS = {
  '€': 'EUR',
  '£': 'GBP',
  '$': 'USD',
  'EUR': 'EUR',
  'GBP': 'GBP',
  'USD': 'USD'
};

/**
 * Normalizes raw player records from external provider feeds
 */
function normalizePlayer(rawPayload) {
  if (!rawPayload) return null;

  const rawPosition = rawPayload.position || rawPayload.primary_position;
  const position = POSITION_MAPPINGS[rawPosition] || 'CM';

  return {
    external_id: String(rawPayload.id || rawPayload.external_id),
    full_name: (rawPayload.name || rawPayload.full_name || '').trim(),
    known_name: (rawPayload.short_name || rawPayload.known_name || '').trim() || null,
    dob: rawPayload.dob || rawPayload.date_of_birth || null,
    position: position,
    secondary_positions: Array.isArray(rawPayload.secondary_positions) 
      ? rawPayload.secondary_positions.map(p => POSITION_MAPPINGS[p] || p).filter(Boolean)
      : [],
    preferred_foot: (rawPayload.foot || rawPayload.preferred_foot || 'right').toLowerCase(),
    height_cm: rawPayload.height ? parseInt(rawPayload.height, 10) : null,
    weight_kg: rawPayload.weight ? parseInt(rawPayload.weight, 10) : null,
    shirt_number: rawPayload.number ? parseInt(rawPayload.number, 10) : null,
    status: rawPayload.status || 'active',
    last_verified_at: new Date().toISOString()
  };
}

/**
 * Normalizes transfer fee amounts and currency codes
 */
function normalizeTransferFee(feeInput, currencyInput) {
  let currency = CURRENCY_MAPPINGS[currencyInput] || 'EUR';
  let feeAmount = null;

  if (typeof feeInput === 'number') {
    feeAmount = feeInput;
  } else if (typeof feeInput === 'string') {
    const cleaned = feeInput.replace(/[^0-9.]/g, '');
    if (cleaned) feeAmount = parseFloat(cleaned);
  }

  return {
    fee_amount: feeAmount,
    currency: VALID_ISO_CURRENCIES.has(currency) ? currency : 'EUR'
  };
}

module.exports = {
  normalizePlayer,
  normalizeTransferFee,
  POSITION_MAPPINGS,
  CURRENCY_MAPPINGS
};
