-- Adoption core query (redacted)
-- Notes:
-- - Table names and environment values are genericized
-- - Logic matches the production query you used

WITH 

sitecore_active AS (
    SELECT 
        LPAD(community_number, 5, '0') AS community_code,
        CAST(lastmodified AS DATE) AS event_date
    FROM analytics.sitecore_community_attributes
    WHERE status = 'ACT'
      AND lastmodified >= DATEADD(year, -1, CURRENT_DATE())
      AND lastmodified <= CURRENT_DATE()
),

active_communities AS (
    SELECT
        community_code,
        community_name,
        division_name,
        region
    FROM analytics.community_wide
    WHERE community_status = 'Active'
),

community_active_dates AS (
    SELECT
        ac.community_code,
        ac.community_name,
        ac.division_name,
        ac.region,
        sa.event_date
    FROM active_communities ac
    INNER JOIN sitecore_active sa
        ON ac.community_code = sa.community_code
),

events_aggregated AS (
    SELECT
        LPAD(t.community_number, 5, '0') AS community_code,
        t.event_timestamp::DATE AS event_date,
        COUNT_IF(t.event_name = 'Navigation - Viewed Page') AS navigation_viewed_page_count,
        COUNT_IF(t.event_name = 'Start Tour - Click') AS start_tour_click_count
    FROM analytics.mp_traffic t
    WHERE t.event_timestamp >= DATEADD(year, -1, CURRENT_DATE())
      AND t.environment = 'production'  -- optional filter
    GROUP BY 1, 2
),

homesite_summary AS (
    SELECT 
        community_code,
        MAX(rpt_comm_pace_status) as pace_status,
        SUM(CASE WHEN age_color = 'Black' THEN count_as_of_report_week ELSE 0 END) AS black_homesites,
        SUM(CASE WHEN age_color = 'Red' THEN count_as_of_report_week ELSE 0 END) AS red_homesites,
        SUM(CASE WHEN age_color = 'Yellow' THEN count_as_of_report_week ELSE 0 END) AS yellow_homesites,
        SUM(CASE WHEN age_color = 'Green' THEN count_as_of_report_week ELSE 0 END) AS green_homesites,
        SUM(CASE WHEN age_color = 'Dirt' THEN count_as_of_report_week ELSE 0 END) AS dirt_homesites
    FROM analytics.smartpace_piv
    WHERE current_week_flag = true
    GROUP BY community_code
)
SELECT
    cad.division_name,
    cad.region,
    cad.community_code,
    cad.community_name,
    cad.event_date,
    COALESCE(ea.navigation_viewed_page_count, 0) AS navigation_viewed_page_count,
    COALESCE(ea.start_tour_click_count, 0) AS start_tour_click_count,
    hs.pace_status,
    COALESCE(hs.black_homesites, 0) AS black_homesites,
    COALESCE(hs.red_homesites, 0) AS red_homesites,
    COALESCE(hs.yellow_homesites, 0) AS yellow_homesites,
    COALESCE(hs.green_homesites, 0) AS green_homesites,
    COALESCE(hs.dirt_homesites, 0) AS dirt_homesites,
    COALESCE(hs.black_homesites, 0) + COALESCE(hs.red_homesites, 0) AS ready_inventory
FROM community_active_dates cad
LEFT JOIN events_aggregated ea
    ON cad.community_code = ea.community_code
    AND cad.event_date = ea.event_date
LEFT JOIN homesite_summary hs
    ON cad.community_code = hs.community_code
ORDER BY
    cad.division_name,
    cad.community_code,
    cad.event_date;
