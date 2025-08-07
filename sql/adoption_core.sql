-- Generic, redacted SQL showing the model with active-days backbone
WITH sitecore_active AS (
    SELECT community_code, event_date
    FROM synthetic.sitecore_active -- daily ACT-only rows in real system; here derived from data
    WHERE event_date BETWEEN DATEADD(year, -1, CURRENT_DATE()) AND CURRENT_DATE()
),
active_communities AS (
    SELECT community_code, community_name, division_name, region
    FROM synthetic.community_wide
    WHERE community_status = 'Active'
),
community_active_dates AS (
    SELECT ac.community_code, ac.community_name, ac.division_name, ac.region, sa.event_date
    FROM active_communities ac
    JOIN sitecore_active sa USING (community_code)
),
events_aggregated AS (
    SELECT community_code, CAST(event_date AS DATE) AS event_date,
           SUM(navigation_viewed_page_count) AS navigation_viewed_page_count,
           SUM(start_tour_click_count) AS start_tour_click_count
    FROM synthetic.page_views
    WHERE event_date BETWEEN DATEADD(year, -1, CURRENT_DATE()) AND CURRENT_DATE()
    GROUP BY 1,2
),
homesite_summary AS (
    SELECT community_code,
           MAX(rpt_comm_pace_status) AS pace_status,
           MAX(black_homesites) AS black_homesites,
           MAX(red_homesites) AS red_homesites,
           MAX(yellow_homesites) AS yellow_homesites,
           MAX(green_homesites) AS green_homesites,
           MAX(dirt_homesites) AS dirt_homesites
    FROM synthetic.weekly_inventory
    WHERE week_start = (SELECT MAX(week_start) FROM synthetic.weekly_inventory)
    GROUP BY 1
)
SELECT cad.division_name, cad.region, cad.community_code, cad.community_name, cad.event_date,
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
LEFT JOIN events_aggregated ea USING (community_code, event_date)
LEFT JOIN homesite_summary hs USING (community_code)
ORDER BY cad.division_name, cad.community_code, cad.event_date;
