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
