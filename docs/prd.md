# DSP Adoption Dashboard — Product Requirements (Portfolio-Safe)

All data and names in this repo are synthetic/redacted.

## 1. Background
The Digital Sales Presentation (DSP) helps associates showcase homesites during community tours. The product team needed a clear read on adoption across Regions → Divisions → Communities.

## 2. Problem
Leaders lacked a trustworthy view of adoption that:
- Uses the right denominator (communities active on a given day)
- Rolls up cleanly to Region/Division
- Responds to relative date filters
- Highlights low‑usage communities with inventory or behind pace

## 3. Goals and Metrics
- One dashboard covering: adoption KPIs, trendlines, last‑usage distribution
- Accurate counts using active‑days only
- Load time within ~30s for a 1‑year window (warehouse‑dependent)
- Smooth drill‑down and filtering

## 4. Users
- DSP product owners: national view, target areas for enablement
- Regional/Division leaders: track local adoption and prioritize outreach

## 5. Scope
- Hierarchical table with KPIs: Active Communities, Communities with DSP PVs, Communities with no DSP PVs, Adoption %, Total PVs, Black+Red Inventory, Pace Status
- Trendline: % Communities with DSP PVs by Region (relative date)
- Last usage buckets: 0–7, 8–30, 31–90, 90+ days, Never (mutually exclusive)
- Filters: Relative Date, Region, Division, Community Name, Pace Status

## 6. Out of scope (v1)
- Associate‑level performance, appointments/recaps integration
- Forecasting and seasonality analysis

## 7. Data (redacted sources)
- Daily page view events: `analytics.mp_traffic`
- Community reference: `analytics.community_wide`
- Daily active status: `analytics.sitecore_community_attributes`
- Weekly inventory/pace: `analytics.smartpace_piv`

## 8. Model and grain
- Backbone: one row per community per active day (last 365 days)
- Events aggregated to daily grain
- Inventory/pace via most‑recent weekly snapshot

## 9. Key calculations (Tableau)
- Communities with DSP PVs:
  - COUNTD(IF { INCLUDE [Community Code], [Event Date] : SUM([Navigation Viewed Page Count]) } > 0 THEN [Community Code] END)
- Adoption %:
  - Communities with DSP PVs / Active Communities
- Last usage (filter‑responsive):
  - Last Usage Date in Period = { FIXED [Community Code] : MAX(IF [Navigation Viewed Page Count] > 0 AND [Event Date] <= MAX([Event Date]) THEN [Event Date] END) }
  - Bucket via DATEDIFF to `MAX([Event Date])`
- Ready inventory (current):
  - MAX(Black) + MAX(Red) at community level

## 10. SQL
- Replace date spine with active‑days backbone (`sitecore_active`)
- Pre‑aggregate events; join to active‑days
- Join latest weekly inventory/pace
- See `sql/adoption_core_redacted.sql`

## 11. Perf & quality
- Early date filters
- Pre‑aggregation in warehouse
- Sanity checks: adoption ≤ 100%, totals reconcile, inventory not double‑counted

## 12. UX
- Top: hierarchy table
- Middle: region trendline
- Right: last‑usage bars
- Bottom: community list with PVs and inventory

## 13. Risks & mitigations
- LODs ignoring filters → use `INCLUDE` or scoped `FIXED`
- Weekly inventory double counting → community‑level MAX
- Join mismatches → standardize codes with `LPAD`

## 14. Deliverables
- Tableau workbook (prod and synthetic variants)
- Redacted SQL, docs, and screenshots

## 15. Future work
- Add appointments/recaps
- Simple propensity model for outreach prioritization
- Automated weekly KPI export
