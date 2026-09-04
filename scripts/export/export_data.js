/**
 * FTM MASTER DATABASE - DATA EXPORT UTILITY
 * 
 * Exports database entities to formatted JSON or CSV files for backup or caching.
 */

const fs = require('fs');
const path = require('path');

function exportEntityToJson(entityName, dataArray, outputDir) {
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const filename = path.join(outputDir, `${entityName}_export.json`);
  fs.writeFileSync(filename, JSON.stringify(dataArray, null, 2), 'utf8');
  console.log(`✔ Exported ${dataArray.length} records of '${entityName}' to ${filename}`);
}

if (require.main === module) {
  console.log('FTM Export Utility Ready.');
}

module.exports = {
  exportEntityToJson
};
