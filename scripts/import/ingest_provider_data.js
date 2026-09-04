/**
 * FTM MASTER DATABASE - PROVIDER DATA INGESTION ENGINE
 * 
 * Ingests external raw feed data into local landing folders (/data/*),
 * normalizes data payloads, and validates records before DB insertion.
 */

const fs = require('fs');
const path = require('path');
const { normalizePlayer } = require('../normalization/normalize_football_data');

const DATA_DIR = path.join(__dirname, '../../data');

// Supported landing directories
const ENTITY_FOLDERS = [
  'players', 'clubs', 'leagues', 'competitions', 'seasons',
  'matches', 'transfers', 'rumours', 'market', 'contracts', 'sources'
];

function ensureLandingFolders() {
  ENTITY_FOLDERS.forEach(folder => {
    const folderPath = path.join(DATA_DIR, folder);
    if (!fs.existsSync(folderPath)) {
      fs.mkdirSync(folderPath, { recursive: true });
    }
  });
  console.log('✔ Verified data landing folders in /data/*');
}

function ingestPayload(entityType, rawPayloadArray, sourceName = 'Provider API') {
  ensureLandingFolders();
  console.log(`Ingesting ${rawPayloadArray.length} raw records for '${entityType}' from source '${sourceName}'...`);

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const landingFile = path.join(DATA_DIR, entityType, `feed_${timestamp}.json`);

  fs.writeFileSync(landingFile, JSON.stringify(rawPayloadArray, null, 2), 'utf8');
  console.log(`✔ Saved raw payload snapshot to: ${landingFile}`);

  if (entityType === 'players') {
    const normalized = rawPayloadArray.map(normalizePlayer);
    console.log(`✔ Successfully normalized ${normalized.length} player records.`);
    return normalized;
  }

  return rawPayloadArray;
}

if (require.main === module) {
  ensureLandingFolders();
  console.log('FTM Ingestion Framework Initialized.');
}

module.exports = {
  ingestPayload,
  ensureLandingFolders
};
