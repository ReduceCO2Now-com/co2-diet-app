# CO₂ Methodology: CO₂ Diet App

## Overview
CO₂ Diet estimates the climate impact of food in kg CO₂e (carbon dioxide equivalent) per kg of product. Estimates cover the full production lifecycle including farming, processing, and packaging — not transport from store to home.

## Data Source
**AGRIBALYSE v3.1.1** — a French LCA (Life Cycle Assessment) database covering ~2,500 food categories.

- **Producer:** INRAE / ADEME (Agence de la transition écologique)
- **Version:** 3.1.1 (2023)
- **License:** Licence Ouverte / Open Licence v2.0 (Etalab) — commercial use permitted, redistribution permitted, attribution required
- **Citation:** Source ADEME, données AGRIBALYSE v3.1.1
- **DOI:** 10.57745/B5DTRR (DATAVERSE)

Only precomputed impact score CSV files are used — NOT the raw LCI/ecoinvent-linked formats (which carry an ecoinvent license dependency).

## Confidence Bands

| Band | Meaning |
|------|---------|
| **High** | Product-specific LCA value: the exact barcode was matched to a CIQUAL product code with a measured lifecycle assessment |
| **Medium** | Category-average estimate: the product's food category was matched to an AGRIBALYSE food group; the displayed value is the median CO₂e for that group |
| *(none)* | No AGRIBALYSE coverage: no CO₂ estimate is shown — the app never displays a poorly-sourced guess |

## Category Mapping
Products without a direct AGRIBALYSE barcode match are assigned CO₂e values using a category mapping file (`tools/off_to_agribalyse_map.csv`). This file maps Open Food Facts `categories_tags` values to AGRIBALYSE food groups. The mapping is hand-curated and committed to this repository.

## Display Format
CO₂e values are always displayed with a `~` prefix and rounded to 1–2 significant figures (e.g., `~2.3 kg CO₂e/kg`, not `2.345 kg CO₂e/kg`). This reflects honest uncertainty — even "High" confidence values are LCA model outputs, not physical measurements.

## What Is Not Included
- Transport from store to home
- Home cooking energy
- Food waste after purchase
- Packaging disposal

These factors are scoped to the CO₂ Calculation Settings screen (Phase 5), which lets users optionally configure regional transport, cooking method, and waste level.

## Out of Scope
- **Poore & Nemecek 2018:** Under AAAS copyright with non-commercial restrictions — not included. A CC0 permission request is a deferred action item.
- **Clark et al. 2022 (PLOS ONE, CC-BY 4.0):** Identified as a potential future enhancement (Phase 8).

## Version History

| Version string | Data | Date |
|----------------|------|------|
| AGRIBALYSE-3.1.1-v1 | AGRIBALYSE v3.1.1 synthesis CSV | Phase 3 (2026) |
