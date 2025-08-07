# DSP Adoption Dashboard (Synthetic)

This repository showcases a sanitized version of a Tableau analytics project that measures adoption of a Digital Sales Presentation (DSP) using page view activity. Data here are fully synthetic and table names are generic.

## What this shows
- Hierarchical adoption tracking (Region → Division → Community)
- Key metrics: Active Communities, Communities with DSP Page Views, % Adoption, Total DSP Page Views, Black+Red Inventory, Pace Status
- Relative-date responsive usage buckets (0–7, 8–30, 31–90, 90+ days, Never)
- SQL approach that replaces a static date spine with an "active days only" backbone

## Repo structure
- `data/`: synthetic CSVs
- `scripts/`: generator scripts for data
- `sql/`: generic SQL illustrating the model
- `tableau/`: workbook wired to synthetic data (or screenshots if you don’t use Tableau Desktop)
- `docs/`: diagrams and detailed calc notes
- `screenshots/`: images used in README (safe to include sanitized real screenshot if allowed)

## Quick start
1) Generate synthetic data
```bash
python3 scripts/generate_synthetic_data.py
```
2) Open `tableau/DSP_Adoption_Sample.twbx` (or use the screenshots if you don’t have Desktop)

## Notes
- All data are synthetic; schema/table names are redacted/generic.
- The SQL and calculations reflect real patterns: active-days backbone, weekly inventory snapshot joining, and filter-responsive bucket logic.

## License
MIT
