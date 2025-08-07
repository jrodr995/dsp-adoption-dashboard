#!/usr/bin/env python3
import csv
import random
from datetime import date, timedelta

random.seed(42)

# Config
NUM_REGIONS = 8
DIVISIONS_PER_REGION = 4
COMMUNITIES_PER_DIVISION = 50  # total ~1600
DAYS = 365

start_date = date.today() - timedelta(days=DAYS - 1)
end_date = date.today()

# Helpers
regions = [f"Region_{i+1}" for i in range(NUM_REGIONS)]
divisions = {
    r: [f"{r}_Div_{j+1}" for j in range(DIVISIONS_PER_REGION)] for r in regions
}

community_rows = []
community_codes = []
for r in regions:
    for d in divisions[r]:
        for k in range(COMMUNITIES_PER_DIVISION):
            code = f"{len(community_codes)+1:05d}"
            name = f"Community_{code}"
            community_codes.append(code)
            community_rows.append({
                "community_code": code,
                "community_name": name,
                "division_name": d,
                "region": r,
                "community_status": "Active",
            })

# Active days (simulate sitecore-style daily ACT)
active_days = {}
for code in community_codes:
    # random offboarding/onboarding windows to simulate varying activity
    start_offset = random.randint(0, 60)
    end_offset = random.randint(0, 30)
    act_start = start_date + timedelta(days=start_offset)
    act_end = end_date - timedelta(days=end_offset)
    if act_start > act_end:
        act_start, act_end = start_date, end_date
    days = set(act_start + timedelta(days=i) for i in range((act_end - act_start).days + 1))
    active_days[code] = days

# Daily page views table (synthetic adoption patterns)
page_view_rows = []
for code in community_codes:
    base = random.choice([0, 0, 1, 2, 3])  # many low-use communities
    for i in range(DAYS):
        day = start_date + timedelta(days=i)
        if day in active_days[code]:
            # bursty usage
            views = max(0, int(random.gauss(mu=base, sigma=1)))
            # occasional spikes
            if random.random() < 0.05:
                views += random.randint(5, 20)
            page_view_rows.append({
                "community_code": code,
                "event_date": day.isoformat(),
                "navigation_viewed_page_count": views,
                "start_tour_click_count": 0,
            })

# Weekly inventory + pace snapshot (per community per week)
inv_rows = []
pace_values = ["On Pace", "Behind Pace", "Very Behind Pace", "Ahead of Pace", "Very Ahead of Pace"]
for code in community_codes:
    day = start_date
    while day <= end_date:
        # week bucket (Monday-based)
        week_start = day - timedelta(days=day.weekday())
        blacks = max(0, int(random.gauss(5, 4)))
        reds = max(0, int(random.gauss(3, 3)))
        yellows = max(0, int(random.gauss(2, 2)))
        greens = max(0, int(random.gauss(10, 5)))
        dirt = max(0, int(random.gauss(15, 7)))
        pace = random.choices(pace_values, weights=[30, 25, 10, 25, 10])[0]
        inv_rows.append({
            "community_code": code,
            "week_start": week_start.isoformat(),
            "rpt_comm_pace_status": pace,
            "black_homesites": blacks,
            "red_homesites": reds,
            "yellow_homesites": yellows,
            "green_homesites": greens,
            "dirt_homesites": dirt,
        })
        day += timedelta(days=7)

# Write CSVs
with open("data/communities.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["community_code", "community_name", "division_name", "region", "community_status"])
    w.writeheader()
    w.writerows(community_rows)

with open("data/page_views.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["community_code", "event_date", "navigation_viewed_page_count", "start_tour_click_count"])
    w.writeheader()
    w.writerows(page_view_rows)

with open("data/weekly_inventory.csv", "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["community_code", "week_start", "rpt_comm_pace_status", "black_homesites", "red_homesites", "yellow_homesites", "green_homesites", "dirt_homesites"])
    w.writeheader()
    w.writerows(inv_rows)

print("Wrote data/communities.csv, data/page_views.csv, data/weekly_inventory.csv")
