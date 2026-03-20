-- ============================================================
-- PROJECT  : Canadian Housing Market Analytics
-- SCRIPT   : 01 — Database Setup
-- AUTHOR   : Akshay Thakare
-- DATE     : 2026
--
-- PLATFORM : Azure Synapse Analytics Serverless SQL Pool
-- PURPOSE  : Create dedicated database for housing analytics
-- ============================================================

-- Create dedicated database
CREATE DATABASE canadian_housing_db;

-- ============================================================
-- STEP 1: Create Master Key
-- ============================================================
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Housing@Canada2025!';

-- ============================================================
-- STEP 2: Create Database Scoped Credential
-- Uses Managed Identity for secure Data Lake access
-- ============================================================
CREATE DATABASE SCOPED CREDENTIAL housing_credential
WITH IDENTITY = 'Managed Identity';

-- ============================================================
-- STEP 3: Create External Data Source
-- Points to Azure Data Lake Gen2 clean folder
-- ============================================================
CREATE EXTERNAL DATA SOURCE housing_data_lake
WITH (
    LOCATION = 'https://canadianhousingdl.dfs.core.windows.net/housing-data/clean/',
    CREDENTIAL = housing_credential
);

-- ============================================================
-- STEP 4: Create External File Format
-- ============================================================
CREATE EXTERNAL FILE FORMAT csv_format
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS (
        FIELD_TERMINATOR = ',',
        STRING_DELIMITER = '"',
        FIRST_ROW = 2,
        USE_TYPE_DEFAULT = TRUE
    )
);
