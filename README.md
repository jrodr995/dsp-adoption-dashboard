# DSP Adoption Dashboard — Portfolio (Synthetic Data)

[![Made with Tableau](https://img.shields.io/badge/Made%20with-Tableau-1f74bf)](https://www.tableau.com/)
![Python 3](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Snowflake-blue)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Data: Synthetic](https://img.shields.io/badge/Data-Synthetic-blue)](#)
![Last commit](https://img.shields.io/github/last-commit/jrodr995/dsp-adoption-dashboard)
![Stars](https://img.shields.io/github/stars/jrodr995/dsp-adoption-dashboard?style=social)

This repo shows how I built a DSP (Digital Sales Presentation) adoption dashboard. It tracks usage by Region → Division → Community, handles mixed grains (daily activity + weekly inventory), and keeps counts honest by only including days when a community is active.

---

## Table of contents
- [Features](#features)
- [Screenshots](#screenshots)
- [Screenshots and Attribution](#screenshots-and-attribution)
- [Data model](#data-model)
- [Key calculations](#key-calculations)
- [Run locally](#run-locally)
- [Why this is interesting](#why-this-is-interesting)
- [Impact](#impact)
- [Project structure](#project-structure)
- [PRD and Architecture](#prd-and-architecture)
- [License](#license)

## Features
- Region → Division → Community hierarchy with drill-down
- KPIs: Active Communities, Communities with DSP PVs, Adoption %, Total PVs, Black+Red Inventory, Pace Status
- Last‑usage buckets (0–7, 8–30, 31–90, 90+ days, Never) that respect the date filter
- SQL model that replaces a static date spine with an active‑days backbone
- Synthetic dataset and redacted SQL for safe sharing

## Screenshots
![Demo](screenshots/demo.gif)

![DSP Adoption Report](screenshots/dsp_adoption_dashboard.png)

Optional:
- ![Appointments Leaderboard](screenshots/appointments_leaderboard.png)
- ![DSP Sales Detail](screenshots/dsp_sales_detail.png)

## Screenshots and Attribution
- No confidential data is in this repo; all data are synthetic.
- Screenshots are illustrative and used to show my work experience. Logos belong to their owners.

## Data model
- Daily page views at community level; weekly inventory/pace snapshot
- Only count days where a community is active (avoids under‑stating adoption)
- See `sql/adoption_core_redacted.sql` for the core query

## Key calculations
See `docs/calculations.md` for exact formulas, including:
- Adoption = Communities with page views / Active communities
- Filter‑responsive last‑usage buckets using `MAX([Event Date])` from the selected range
- Ready inventory from weekly snapshot (max per community)

## Run locally
```bash
python3 scripts/generate_synthetic_data.py
```
Open a workbook wired to the CSVs under `data/` (or use the screenshots).

## Why this is interesting
- Practical LOD patterns that play nicely with relative date filters
- Clean approach to joining mixed-grain sources without double counting
- Readable SQL + Tableau logic that’s easy to validate

## Impact
- Helps product owners spot regions/divisions/communities with low DSP usage, especially where inventory is high or pace is behind.
- Uses true denominators (active days only), which improved trust in metrics.
- Consolidates drill‑down reporting into one dashboard instead of multiple sheets.

## Project structure
- `data/` synthetic CSVs
- `scripts/` generator for reproducible data
- `sql/` redacted SQL (`adoption_core_redacted.sql`)
- `docs/` PRD, calculation notes, and a short demo flow
- `screenshots/` images used in this README
- `tableau/` optional workbook wired to the CSVs

## PRD and Architecture
- PRD: `docs/prd.md`
- Architecture (Mermaid): `docs/architecture.mmd`

## License
MIT
