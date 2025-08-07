## Key Tableau Calculations (Generic)

- Communities with DSP PVs
```
COUNTD(IF { INCLUDE [Community Code], [Event Date] : SUM([Navigation Viewed Page Count]) } > 0 THEN [Community Code] END)
```
- % Communities with DSP PVs
```
DIVIDE([Communities with DSP PVs], [Active Communities])
```
- Last Usage Date in Period (filter-responsive)
```
{ FIXED [Community Code] : MAX( IF [Navigation Viewed Page Count] > 0 AND [Event Date] <= MAX([Event Date]) THEN [Event Date] END ) }
```
- DSP Usage Buckets (mutually exclusive; uses MAX date in filtered range)
```
IF ISNULL([Last Usage Date in Period]) THEN "Never"
ELSEIF DATEDIFF('day', [Last Usage Date in Period], MAX([Event Date])) <= 7 THEN "0-7 Days"
ELSEIF DATEDIFF('day', [Last Usage Date in Period], MAX([Event Date])) <= 30 THEN "8-30 Days"
ELSEIF DATEDIFF('day', [Last Usage Date in Period], MAX([Event Date])) <= 90 THEN "31-90 Days"
ELSE "90+ Days" END
```
- Ready Inventory (current snapshot)
```
{ FIXED [Community Code] : MAX([Black Homesites]) } + { FIXED [Community Code] : MAX([Red Homesites]) }
```
Notes: Use table calc "Percent of Total" with the proper addressing to get distribution shares.
