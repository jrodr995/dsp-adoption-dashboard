# DSP Adoption Dashboard — Product Requirements Document (Portfolio-Safe)

Note: This PRD describes the sanitized project. All data and schema names in this repository are synthetic/redacted.

## 1. Background
The Digital Sales Presentation (DSP) is a tool used by sales associates during community tours to showcase homesites. Product owners requested an adoption dashboard to understand which Regions, Divisions, and Communities are using the tool, identify gaps, and prioritize outreach.

## 2. Problem Statement
Stakeholders lack a reliable view of DSP adoption that:
- Accurately reflects the number of active communities by day
- Aggregates to Region/Division with drill-down
- Responds correctly to date filters (e.g., last 30 days)
- Surfaces low-usage communities, especially those with inventory or behind pace

## 3. Objectives and Success Metrics
- Provide a single dashboard for: adoption KPIs, trendlines, and last-usage distribution
- Adoption accuracy: counts only days where communities are active
- Performance: load under ~30 seconds for a 1-year window (dependent on warehouse)
- Usability: drill down from Region → Division → Community and filter by date, pace, and name

## 4. Users and Use Cases
- DSP Product Owners: national view, identify lagging areas for enablement
- Regional/Division Leaders: track their areas; target communities with high inventory but low usage

## 5. In Scope
- Table view with hierarchy (Region/Division/Community) and KPIs:
  - Active Communities
  - Communities with DSP Page Views
  - Communities with no DSP Page Views
  - % Communities with DSP PVs (Adoption)
  - Total DSP PVs and % of Total PVs
  - Black + Red Inventory (weekly snapshot)
- Trendline: % Communities with DSP PVs by Region (relative date)
- Last DSP Usage distribution: mutually exclusive buckets (0–7, 8–30, 31–90, 90+ days, Never)
- Filters: Relative Date, Region, Division, Community Name, Pace Status

## 6. Out of Scope (Initial Version)
- Individual associate performance, appointments, recaps integration
- Complex forecasting; deep seasonality modeling

## 7. Data Sources (Redacted)
- Daily page view events: `analytics.mp_traffic`
- Community reference: `analytics.community_wide`
- Daily active status (Sitecore-style): `analytics.sitecore_community_attributes`
- Weekly inventory & pace: `analytics.smartpace_piv`

## 8. Data Model and Grain
- Backbone: one row per community per active day (status = ACT), last 365 days
- Events aggregated to daily counts per community
- Inventory/pace as a weekly snapshot (use most recent week for “current” context)

## 9. Calculations (Tableau specs)
- Communities with DSP PVs:
  - COUNTD(IF { INCLUDE [Community Code], [Event Date] : SUM([Navigation Viewed Page Count]) } > 0 THEN [Community Code] END)
- Adoption %:
  - Communities with DSP PVs / Active Communities
- Last Usage (filter-responsive):
  - Last Usage Date in Period = { FIXED [Community Code] : MAX(IF [Navigation Viewed Page Count] > 0 AND [Event Date] <= MAX([Event Date]) THEN [Event Date] END) }
  - Bucket: 0–7, 8–30, 31–90, 90+ days, Never (mutually exclusive via DATEDIFF to MAX([Event Date]))
- Ready Inventory (current):
  - MAX(Black Homesites) + MAX(Red Homesites) at community level

## 10. SQL Approach
- Replace static date spine with active-days backbone using `sitecore_active` (ACT rows only)
- Pre-aggregate events to daily grain; join to active-days
- Join latest weekly inventory/pace snapshot
- Redacted query: `sql/adoption_core_redacted.sql`

## 11. Performance & Quality
- Early filtering (last 365 days) in CTEs
- Pre-aggregation in warehouse
- Validation checks:
  - Active community counts change with date filters
  - Sum of community PVs matches totals at higher levels when properly scoped
  - Inventory values reflect weekly snapshot (no multi-day double counting)

## 12. UX Specification
- Dashboard layout:
  - Top: hierarchical table (Region/Division/Community)
  - Middle: adoption trendline by Region
  - Right: last usage distribution bars
  - Bottom: community list with PVs and inventory annotation
- Consistent color palette (greens good, reds attention)

## 13. Risks & Mitigations
- Risk: LOD calculations ignore filters → Use `INCLUDE` or scoped `FIXED` with `MAX([Event Date])`
- Risk: Weekly inventory double counting → use MAX at community level
- Risk: Data joins on community code consistency → standardize with `LPAD`

## 14. Deliverables
- Tableau workbook wired to warehouse (production) and to synthetic data (portfolio)
- Redacted SQL, documentation, and screenshots
- README linking to PRD and calculations

## 15. Future Work
- Integrate appointments/recaps for a fuller adoption picture
- Add ML propensity scoring for outreach prioritization (time-split validation)
- Automate KPI exports for weekly email digests
