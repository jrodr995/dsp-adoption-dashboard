# DSP Adoption Dashboard — Product Requirements (Portfolio‑Safe)

All data and names in this repo are synthetic/redacted.

## 1) Overview
The Digital Sales Presentation (DSP) is used by associates during tours to showcase homesites. The dashboard answers a simple question reliably: where is DSP being used, and where is it not — by Region → Division → Community — with enough context (inventory, pace) to drive outreach.

## 2) Objectives
- Provide a single place to monitor DSP adoption with drill‑down and filters.
- Use the correct denominator: only days when a community is active count toward totals.
- Surface low‑usage communities that also have inventory or are behind pace.
- Keep performance reasonable for a 365‑day window.

### Success metrics
- Accuracy: adoption % matches definitions below across levels (community/division/region).
- Consistency: totals reconcile across drill‑downs when scoping is equivalent.
- Performance: dashboard renders under ~30s for a 1‑year window (warehouse‑dependent).
- Usability: users can answer “where to focus?” in under 60 seconds.

## 3) Users and key jobs‑to‑be‑done
- Product owners: national overview; identify slow‑adoption areas for enablement.
- Regional/Division leaders: see their rollups; find communities with inventory and low usage.

## 4) Scope
In scope (v1)
- Hierarchical table with KPIs: Active Communities, Communities with DSP PVs, Communities with no DSP PVs, Adoption %, Total DSP PVs, % of Total PVs, Black+Red Inventory, Pace Status.
- Trendline: % Communities with DSP PVs by Region over selected relative date.
- Last usage distribution: 0–7, 8–30, 31–90, 90+ days, Never (mutually exclusive, filter‑aware).
- Filters: Relative Date, Region, Division, Community Name, Pace Status.

Out of scope (v1)
- Associate‑level reporting, appointments/recaps integration.
- Forecasting or seasonal normalization.

## 5) Data (redacted sources)
- Daily events: `analytics.mp_traffic`
- Community reference: `analytics.community_wide`
- Daily active status: `analytics.sitecore_community_attributes`
- Weekly inventory/pace: `analytics.smartpace_piv`

## 6) Data model & grain
- Row grain: one row per community per active day within the last 365 days.
- Events are pre‑aggregated to daily counts per community.
- Inventory/Pace comes from the most‑recent weekly snapshot and is treated as a current attribute (no daily summing).
- Community codes standardized via `LPAD(community_number, 5, '0')`.

## 7) Definitions (canonical)
- Active Community (day‑level): community has status = ACT on that day.
- Communities with DSP PVs: COUNTD of communities with SUM(page views) > 0 within the filter window.
- Communities with no DSP PVs: Active Communities − Communities with DSP PVs.
- Adoption %: Communities with DSP PVs ÷ Active Communities.
- Total DSP PVs: SUM of page view counts over the filtered window.
- % of Total PVs: table calculation with correct addressing (region/division scope).
- Ready Inventory (current): MAX(Black) + MAX(Red) per community (from latest weekly snapshot); aggregate sums at higher levels.
- Pace Status: the latest weekly value per community; aggregated by display (no averaging).
- Last Usage Buckets (mutually exclusive):
  - 0–7, 8–30, 31–90, 90+ days since last usage in the filtered window; Never = no usage in the window.
  - Reference date = MAX([Event Date]) after filters; not TODAY().

## 8) Filter/parameter behavior
- Date filter: relative date (default Last 30 days). All metrics and buckets use the filtered range.
- Hierarchy filters: Region → Division → Community; each level should reflect the same date scope.
- Pace filter: filters current pace per community (from latest weekly snapshot); does not backfill by day.

## 9) Interaction design
- Hierarchical table supports expanding Regions into Divisions, and Divisions into Communities.
- Trendline shows Regions; when the table is scoped to a subset, the line chart should reflect the same subset via dashboard filter actions.
- Last usage bars show counts and percentages with a fixed color scheme (e.g., green for 0–7, red for Never) independent of values.

## 10) Calculations (implementation notes)
- Use `INCLUDE` for community/day sums that must respect filters.
- Use scoped `FIXED` with `MAX([Event Date])` when a single window anchor is needed.
- Use community‑level `MAX()` for weekly snapshot metrics to avoid multi‑day double counting.
- See `docs/calculations.md` for exact expressions.

## 11) SQL approach
- Replace date spine with active‑days backbone (`sitecore_active` ACT rows only).
- Pre‑aggregate events to daily counts, filtered to last 365 days.
- Join the most‑recent weekly snapshot for inventory/pace.
- Redacted query lives at `sql/adoption_core_redacted.sql`.

## 12) Non‑functional requirements
- Performance: ≤ 30s for a 365‑day window on typical warehouse cache.
- Reliability: joins on standardized codes; handle missing communities gracefully.
- Clarity: titles, headers, and tooltips explain definitions.
- Accessibility: color choices readable; headers not truncated.

## 13) Data quality & acceptance criteria
- Adoption math
  - For any scope, 0 ≤ Adoption % ≤ 100%.
  - Communities with no DSP PVs = Active Communities − Communities with DSP PVs.
- Totals reconcile
  - Sum of community PVs equals division PVs; sum of divisions equals region PVs (given the same date filter).
- Inventory handling
  - Ready Inventory at community level uses MAX per week; aggregated sums do not scale with number of days in the filter.
- Buckets
  - Each community appears in exactly one last‑usage bucket for a given filter window.
- Active‑days denominator
  - Changing the date filter changes Active Communities as expected (e.g., fewer active communities in a shorter range).

### Validation queries (examples)
- Code alignment (expect near‑zero mismatches):
  - Compare distinct padded codes across sources.
- Snapshot sanity: latest week exists for all communities with inventory.
- PV reconciliation: SELECT sums by level and compare.

## 14) Risks & mitigations
- LODs ignoring filters → prefer `INCLUDE` or scope `FIXED` with MAX(Event Date).
- Weekly snapshot double counting → community‑level MAX; never SUM across days.
- Join mismatches → standardize codes with `LPAD`.
- Performance variance → early WHERE filters and pre‑aggregation.

## 15) Deliverables
- Tableau workbook (production version and synthetic/portfolio version).
- Redacted SQL, PRD, calculations, architecture diagram, screenshots.

## 16) Rollout & ownership (portfolio framing)
- Owner: dashboard maintainer (you).
- Update cadence: daily for events, weekly for inventory/pace.
- Change management: update SQL/LODs with version notes in `docs/`.

## 17) Future work
- Add appointments/recaps context.
- Propensity scoring to prioritize outreach (time‑based validation).
- Automated weekly exports for stakeholders.

## 18) Glossary
- Adoption: share of active communities with ≥ 1 page view in the filtered range.
- Active day: day where community status = ACT.
- Ready Inventory: Black + Red homesites (from weekly snapshot).
- Pace Status: On Pace / Behind / Very Behind / Ahead / Very Ahead (latest week).
