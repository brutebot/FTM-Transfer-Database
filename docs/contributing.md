# FTM Master Database - Contribution & Data Sourcing Guide

This document outlines guidelines for contributing schema changes, migration scripts, data ingestion normalizers, and maintaining strict data quality.

---

## 1. Core Data Principles

1. **Zero Fabrication Policy**: NEVER invent player stats, transfer fees, rumour sources, or contract details. Store unconfirmed or unavailable attributes as `NULL`.
2. **ISO Standard Strictness**: All dates must adhere to ISO-8601 (`YYYY-MM-DD`). All currency fields must use valid ISO 4217 currency codes (`EUR`, `GBP`, `USD`).
3. **Traceability**: Every time-sensitive record added must be linked to a valid record in the `sources` table.
4. **Non-Destructive History**: Historical transfers, contracts, and market valuations must be preserved in historical tables rather than overwritten.

---

## 2. Schema Modification & Migration Process

- Do not modify existing production tables directly without a migration file.
- Create new migration scripts inside `/database/migrations/` using timestamp prefixing (e.g. `002_add_var_event_metadata.sql`).
- Update `/database/schema/schema.sql` to keep the master DDL snapshot current.
- Run `npm run validate` to ensure 0 integrity errors before submitting pull requests.

---

## 3. Data Validation Checklist

Before merging new feed ingestion modules or seed datasets:
- [ ] Run `npm run validate` to test all 10 automated integrity checks.
- [ ] Confirm no duplicate internal or external IDs exist.
- [ ] Ensure all Foreign Key relationships resolve properly.
- [ ] Ensure position strings match standard `player_position` ENUMs.
- [ ] Confirm no negative statistical values exist.
