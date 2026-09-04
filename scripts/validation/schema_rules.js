/**
 * FTM MASTER DATABASE - DATA INTEGRITY & VALIDATION RULES
 * 
 * Rules for validating data quality, relationships, dates, currencies, stats, and URLs.
 */

// Valid ISO 4217 Currency Codes (Top Football Currencies + Standard List)
const VALID_ISO_CURRENCIES = new Set([
  'EUR', 'GBP', 'USD', 'BRL', 'ARS', 'SAR', 'JPY', 'CAD', 'AUD', 'CHF', 'SEK', 'NOK', 'DKK', 'TRY', 'MXN'
]);

// Valid Positions
const VALID_POSITIONS = new Set([
  'GK', 'CB', 'LB', 'RB', 'LWB', 'RWB', 'CDM', 'CM', 'CAM', 'LM', 'RM', 'LW', 'RW', 'CF', 'ST'
]);

// Valid Rumour Statuses
const VALID_RUMOUR_STATUSES = new Set([
  'rumour', 'reported', 'interest', 'negotiations', 'advanced', 'agreement', 'confirmed', 'dismissed'
]);

// Valid Transfer Types
const VALID_TRANSFER_TYPES = new Set([
  'permanent', 'loan', 'free_transfer', 'return_from_loan'
]);

// Valid Season Format (e.g., "2025/2026" or "2026")
const SEASON_FORMAT_REGEX = /^(\d{4}\/\d{4}|\d{4})$/;

// Valid ISO Date Format (YYYY-MM-DD)
const ISO_DATE_REGEX = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$/;

// Valid URL Format
function isValidUrl(urlString) {
  if (!urlString) return true; // Optional fields can be null
  try {
    const parsed = new URL(urlString);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch (e) {
    return false;
  }
}

module.exports = {
  VALID_ISO_CURRENCIES,
  VALID_POSITIONS,
  VALID_RUMOUR_STATUSES,
  VALID_TRANSFER_TYPES,
  SEASON_FORMAT_REGEX,
  ISO_DATE_REGEX,
  isValidUrl
};
