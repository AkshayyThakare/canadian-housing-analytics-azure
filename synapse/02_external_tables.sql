-- ============================================================
-- PROJECT  : Canadian Housing Market Analytics
-- SCRIPT   : 02 — External Tables
-- AUTHOR   : Akshay Thakare
-- DATE     : 2026
--
-- PURPOSE  : Create external tables pointing directly to
--            CSV files in Azure Data Lake Gen2
--            Synapse queries files without copying data!
-- ============================================================

USE canadian_housing_db;

-- ============================================================
-- TABLE 1: Housing Price Index
-- Source: Statistics Canada Table 18-10-0205-01
-- Rows  : 64,920
-- ============================================================
CREATE EXTERNAL TABLE housing_price_index (
    REF_DATE            VARCHAR(10),
    GEO                 VARCHAR(100),
    DGUID               VARCHAR(50),
    price_index_type    VARCHAR(100),
    UOM                 VARCHAR(50),
    UOM_ID              INT,
    SCALAR_FACTOR       VARCHAR(20),
    SCALAR_ID           INT,
    VECTOR              VARCHAR(20),
    COORDINATE          VARCHAR(20),
    VALUE               FLOAT,
    STATUS              VARCHAR(10),
    SYMBOL              VARCHAR(10),
    TERMINATED          VARCHAR(10),
    DECIMALS            INT
)
WITH (
    LOCATION = 'housing_price_index.csv',
    DATA_SOURCE = housing_data_lake,
    FILE_FORMAT = csv_format
);

-- ============================================================
-- TABLE 2: Housing Starts
-- Source: Statistics Canada Table 34-10-0135-01
-- Rows  : 56,348
-- ============================================================
CREATE EXTERNAL TABLE housing_starts (
    REF_DATE            VARCHAR(10),
    GEO                 VARCHAR(100),
    DGUID               VARCHAR(50),
    housing_estimates   VARCHAR(100),
    type_of_unit        VARCHAR(100),
    seasonal_adjustment VARCHAR(50),
    UOM                 VARCHAR(20),
    UOM_ID              INT,
    SCALAR_FACTOR       VARCHAR(20),
    SCALAR_ID           INT,
    VECTOR              VARCHAR(20),
    COORDINATE          VARCHAR(20),
    VALUE               FLOAT,
    STATUS              VARCHAR(10),
    SYMBOL              VARCHAR(10),
    TERMINATED          VARCHAR(10),
    DECIMALS            INT
)
WITH (
    LOCATION = 'housing_starts.csv',
    DATA_SOURCE = housing_data_lake,
    FILE_FORMAT = csv_format
);

-- ============================================================
-- TABLE 3: Interest Rates
-- Source: Bank of Canada Policy Rate Decisions
-- Rows  : 123
-- ============================================================
CREATE EXTERNAL TABLE interest_rates (
    REF_DATE            VARCHAR(10),
    GEO                 VARCHAR(50),
    TARGET_RATE_PCT     FLOAT,
    RATE_DIRECTION      VARCHAR(20),
    SOURCE              VARCHAR(50)
)
WITH (
    LOCATION = 'interest_rates.csv',
    DATA_SOURCE = housing_data_lake,
    FILE_FORMAT = csv_format
);

-- ============================================================
-- VERIFY ALL 3 TABLES
-- ============================================================
SELECT 'housing_price_index' AS TABLE_NAME, COUNT(*) AS ROW_COUNT
FROM housing_price_index
UNION ALL
SELECT 'housing_starts', COUNT(*)
FROM housing_starts
UNION ALL
SELECT 'interest_rates', COUNT(*)
FROM interest_rates;
