-- ============================================================
-- PROJECT  : Canadian Housing Market Analytics
-- SCRIPT   : 03 — Business SQL Queries
-- AUTHOR   : Akshay Thakare
-- DATE     : 2026
--
-- 10 Business questions about Canadian housing market
-- Skills: CTEs, Window Functions, JOINs, CASE WHEN
-- Data  : Statistics Canada + Bank of Canada
-- ============================================================

USE canadian_housing_db;

-- ============================================================
-- QUERY 1: Latest Housing Price Index by City
-- Skill: WHERE, ORDER BY, filtering recent data
-- Business Question: Which Canadian city has highest prices?
-- ============================================================
SELECT
    GEO                                     AS CITY,
    REF_DATE                                AS LATEST_DATE,
    ROUND(VALUE, 1)                         AS PRICE_INDEX,
    price_index_type                        AS INDEX_TYPE
FROM housing_price_index
WHERE REF_DATE = '2025-12'
  AND price_index_type = 'Total (house and land)'
  AND VALUE IS NOT NULL
ORDER BY PRICE_INDEX DESC;

-- ============================================================
-- QUERY 2: Year-over-Year Price Change by City
-- Skill: CTE, self-join, percentage calculation
-- Business Question: Which city saw biggest price growth?
-- ============================================================
WITH current_year AS (
    SELECT GEO, ROUND(AVG(VALUE), 2) AS avg_index
    FROM housing_price_index
    WHERE REF_DATE >= '2024-01'
      AND price_index_type = 'Total (house and land)'
      AND VALUE IS NOT NULL
    GROUP BY GEO
),
prior_year AS (
    SELECT GEO, ROUND(AVG(VALUE), 2) AS avg_index
    FROM housing_price_index
    WHERE REF_DATE >= '2023-01'
      AND REF_DATE < '2024-01'
      AND price_index_type = 'Total (house and land)'
      AND VALUE IS NOT NULL
    GROUP BY GEO
)
SELECT
    c.GEO                                   AS CITY,
    c.avg_index                             AS INDEX_2024,
    p.avg_index                             AS INDEX_2023,
    ROUND(((c.avg_index - p.avg_index)
        / p.avg_index) * 100, 2)            AS YOY_CHANGE_PCT
FROM current_year c
JOIN prior_year p ON c.GEO = p.GEO
ORDER BY YOY_CHANGE_PCT DESC;

-- ============================================================
-- QUERY 3: Impact of 2022 Rate Hikes on Housing Prices
-- Skill: CTE, CASE WHEN, before/after analysis
-- Business Question: Did rate hikes cool the market?
-- ============================================================
WITH rate_periods AS (
    SELECT
        h.GEO,
        h.REF_DATE,
        h.VALUE                             AS PRICE_INDEX,
        i.TARGET_RATE_PCT,
        CASE
            WHEN h.REF_DATE < '2022-03' THEN 'Pre-Hike (Rate < 1%)'
            WHEN h.REF_DATE BETWEEN '2022-03' AND '2023-07'
                THEN 'Hiking Period'
            ELSE 'Post-Hike (Rate > 4%)'
        END                                 AS RATE_PERIOD
    FROM housing_price_index h
    JOIN interest_rates i
        ON LEFT(h.REF_DATE, 7) = i.REF_DATE
    WHERE h.price_index_type = 'Total (house and land)'
      AND h.VALUE IS NOT NULL
      AND h.REF_DATE >= '2020-01'
)
SELECT
    RATE_PERIOD,
    COUNT(*)                                AS DATA_POINTS,
    ROUND(AVG(PRICE_INDEX), 2)              AS AVG_PRICE_INDEX,
    ROUND(AVG(TARGET_RATE_PCT), 2)          AS AVG_INTEREST_RATE
FROM rate_periods
GROUP BY RATE_PERIOD
ORDER BY AVG_INTEREST_RATE;

-- ============================================================
-- QUERY 4: Housing Starts Trend by Province
-- Skill: GROUP BY, aggregation, ORDER BY
-- Business Question: Which province is building the most?
-- ============================================================
SELECT
    GEO                                     AS PROVINCE,
    ROUND(AVG(VALUE), 0)                    AS AVG_MONTHLY_STARTS,
    ROUND(SUM(VALUE), 0)                    AS TOTAL_STARTS,
    COUNT(*)                                AS MONTHS_OF_DATA
FROM housing_starts
WHERE REF_DATE >= '2020-01'
  AND housing_estimates = 'Housing starts'
  AND type_of_unit = 'Total units'
  AND seasonal_adjustment = 'Unadjusted'
  AND GEO NOT IN ('Canada',
                  'Atlantic provinces',
                  'Prairie provinces')
  AND VALUE IS NOT NULL
GROUP BY GEO
ORDER BY AVG_MONTHLY_STARTS DESC;

-- ============================================================
-- QUERY 5: Interest Rate vs Price Index Correlation
-- Skill: JOIN across tables, trend analysis
-- Business Question: How do rate changes affect prices?
-- ============================================================
SELECT
    i.REF_DATE,
    i.TARGET_RATE_PCT,
    i.RATE_DIRECTION,
    ROUND(AVG(h.VALUE), 2)                  AS AVG_NATIONAL_INDEX
FROM interest_rates i
JOIN housing_price_index h
    ON i.REF_DATE = LEFT(h.REF_DATE, 7)
WHERE h.GEO = 'Canada'
  AND h.price_index_type = 'Total (house and land)'
  AND h.VALUE IS NOT NULL
GROUP BY i.REF_DATE, i.TARGET_RATE_PCT, i.RATE_DIRECTION
ORDER BY i.REF_DATE;

-- ============================================================
-- QUERY 6: Top 5 Cities — Price Growth Since COVID
-- Skill: CTE, filtering, ranking
-- Business Question: Which cities exploded post-COVID?
-- ============================================================
WITH pre_covid AS (
    SELECT GEO, ROUND(AVG(VALUE), 2) AS avg_index
    FROM housing_price_index
    WHERE REF_DATE BETWEEN '2019-01' AND '2020-03'
      AND price_index_type = 'Total (house and land)'
      AND VALUE IS NOT NULL
    GROUP BY GEO
),
post_covid AS (
    SELECT GEO, ROUND(AVG(VALUE), 2) AS avg_index
    FROM housing_price_index
    WHERE REF_DATE >= '2022-01'
      AND price_index_type = 'Total (house and land)'
      AND VALUE IS NOT NULL
    GROUP BY GEO
)
SELECT TOP 5
    po.GEO                                  AS CITY,
    pr.avg_index                            AS PRE_COVID_INDEX,
    po.avg_index                            AS POST_COVID_INDEX,
    ROUND(((po.avg_index - pr.avg_index)
        / pr.avg_index) * 100, 2)           AS GROWTH_SINCE_COVID_PCT
FROM post_covid po
JOIN pre_covid pr ON po.GEO = pr.GEO
ORDER BY GROWTH_SINCE_COVID_PCT DESC;

-- ============================================================
-- QUERY 7: Monthly Housing Starts — Running Total
-- Skill: Window function, running total
-- Business Question: Cumulative supply being added?
-- ============================================================
SELECT
    REF_DATE,
    GEO,
    VALUE                                   AS MONTHLY_STARTS,
    SUM(VALUE) OVER (
        PARTITION BY GEO
        ORDER BY REF_DATE
    )                                       AS RUNNING_TOTAL_STARTS
FROM housing_starts
WHERE GEO IN ('Ontario', 'British Columbia',
              'Alberta', 'Quebec')
  AND housing_estimates = 'Housing starts'
  AND type_of_unit = 'Total units'
  AND seasonal_adjustment = 'Unadjusted'
  AND REF_DATE >= '2020-01'
  AND VALUE IS NOT NULL
ORDER BY GEO, REF_DATE;

-- ============================================================
-- QUERY 8: Rate Hike Periods — CASE WHEN Classification
-- Skill: CASE WHEN, GROUP BY
-- Business Question: How many hikes, holds and cuts?
-- ============================================================
SELECT
    RATE_DIRECTION,
    COUNT(*)                                AS TOTAL_MONTHS,
    ROUND(MIN(TARGET_RATE_PCT), 2)          AS MIN_RATE,
    ROUND(MAX(TARGET_RATE_PCT), 2)          AS MAX_RATE,
    ROUND(AVG(TARGET_RATE_PCT), 2)          AS AVG_RATE
FROM interest_rates
GROUP BY RATE_DIRECTION
ORDER BY TOTAL_MONTHS DESC;

-- ============================================================
-- QUERY 9: Price Index Ranking by City (Window Function)
-- Skill: RANK, window function, latest data
-- Business Question: Rank cities by affordability
-- ============================================================
SELECT
    GEO                                     AS CITY,
    ROUND(AVG(VALUE), 2)                    AS AVG_PRICE_INDEX,
    RANK() OVER (
        ORDER BY AVG(VALUE) DESC
    )                                       AS AFFORDABILITY_RANK
FROM housing_price_index
WHERE REF_DATE >= '2024-01'
  AND price_index_type = 'Total (house and land)'
  AND VALUE IS NOT NULL
  AND GEO NOT IN ('Canada', 'Atlantic Region',
                  'Quebec', 'Ontario',
                  'British Columbia')
GROUP BY GEO
ORDER BY AFFORDABILITY_RANK;

-- ============================================================
-- QUERY 10: Complete Market Summary (Executive View)
-- Skill: Multi-table JOIN, CROSS JOIN, aggregation
-- Business Question: Full Canadian housing market snapshot
-- ============================================================
WITH price_summary AS (
    SELECT
        ROUND(AVG(VALUE), 2)                AS national_avg_index,
        ROUND(MAX(VALUE), 2)                AS peak_index,
        ROUND(MIN(VALUE), 2)                AS trough_index
    FROM housing_price_index
    WHERE GEO = 'Canada'
      AND price_index_type = 'Total (house and land)'
      AND REF_DATE >= '2020-01'
      AND VALUE IS NOT NULL
),
starts_summary AS (
    SELECT
        ROUND(AVG(VALUE), 0)                AS avg_monthly_starts
    FROM housing_starts
    WHERE GEO = 'Canada'
      AND housing_estimates = 'Housing starts'
      AND type_of_unit = 'Total units'
      AND REF_DATE >= '2020-01'
      AND VALUE IS NOT NULL
),
rate_summary AS (
    SELECT
        ROUND(MIN(TARGET_RATE_PCT), 2)      AS lowest_rate,
        ROUND(MAX(TARGET_RATE_PCT), 2)      AS highest_rate,
        ROUND(AVG(TARGET_RATE_PCT), 2)      AS avg_rate
    FROM interest_rates
    WHERE REF_DATE >= '2020-01'
)
SELECT
    p.national_avg_index,
    p.peak_index,
    p.trough_index,
    s.avg_monthly_starts,
    r.lowest_rate,
    r.highest_rate,
    r.avg_rate                              AS avg_rate_2020_present
FROM price_summary p
CROSS JOIN starts_summary s
CROSS JOIN rate_summary r;
