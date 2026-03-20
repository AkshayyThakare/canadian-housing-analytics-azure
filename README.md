# 🏠 Canadian Housing Market Analytics Pipeline
## Azure Data Factory | Azure Data Lake Gen2 | Azure Synapse Analytics | Power BI

An end-to-end analytics pipeline analyzing the Canadian housing 
market using real government data from Statistics Canada and the 
Bank of Canada — covering price trends, housing supply, and the 
impact of interest rate decisions across major Canadian cities.

---

## 🏗️ Architecture
```
Statistics Canada + Bank of Canada (Official Data)
                    ↓
     Azure Data Factory (Pipeline Orchestration)
                    ↓
     Azure Data Lake Gen2 (raw/ → clean/ layers)
                    ↓
   Azure Synapse Analytics (Serverless SQL Pool)
                    ↓
        Power BI Dashboard (4 interactive pages)
```

## 🛠️ Tools Used
- **Azure Data Factory** — Pipeline orchestration + data ingestion
- **Azure Data Lake Gen2** — Hierarchical cloud storage (raw/clean layers)
- **Azure Synapse Analytics** — Serverless SQL pool + external tables
- **Power BI + DAX** — 4-page interactive dashboard
- **SQL** — 10 business queries (CTEs, window functions, JOINs)
- **GitHub** — Version control + documentation

## 📦 Data Sources
| Dataset | Source | Rows |
|---|---|---|
| New Housing Price Index | Statistics Canada (18-10-0205-01) | 64,920 |
| Housing Starts | Statistics Canada (34-10-0135-01) | 56,348 |
| Interest Rate History | Bank of Canada Policy Decisions | 123 |

> All data sourced directly from official Canadian government 
> open data portals — the same sources used by economists and 
> housing policy researchers.

## 📁 Project Structure
```
├── synapse/
│   ├── 01_database_setup.sql      # Master key, credentials, data source
│   ├── 02_external_tables.sql     # 3 external tables on Data Lake
│   └── 03_business_queries.sql    # 10 business SQL queries
├── data/
│   ├── housing_price_index.csv    # Statistics Canada price index
│   ├── housing_starts.csv         # CMHC housing starts by province
│   └── interest_rates.csv         # Bank of Canada overnight rate
└── powerbi/
    └── canadian_housing_dashboard.pbix
```

## 📊 Dashboard Pages
1. **National Overview** — Price index trend + interest rate history
2. **City Comparison** — Toronto vs Vancouver vs Calgary vs Edmonton
3. **Interest Rate Impact** — Rate hike analysis + price correlation
4. **Housing Supply** — Starts vs completions by province

## 🔍 Key SQL Concepts Demonstrated
- External tables on Azure Data Lake Gen2
- CTEs (Common Table Expressions)
- Window functions (RANK, running totals)
- Cross-table JOINs (housing prices + interest rates)
- CASE WHEN period classification
- Before/after analysis (pre/post rate hikes)
- TOP N filtering with ranking

## 💡 Key Business Insights
- Canadian housing prices peaked during 2022 rate hiking cycle
- Ontario and BC consistently lead housing starts nationally
- Interest rate cuts in 2024 beginning to stimulate market recovery
- Post-COVID price growth exceeded 30% in key Canadian cities

## 🔑 Azure Architecture Highlights
- **Managed Identity** authentication between ADF and Data Lake
- **Serverless SQL Pool** — pay-per-query, zero provisioning cost
- **External tables** — Synapse queries Data Lake directly
- **Hierarchical namespace** enabled for Data Lake Gen2

## 🚀 How to Reproduce
1. Create Azure free account at azure.microsoft.com/free
2. Create Resource Group → Data Lake Gen2 → Data Factory → Synapse
3. Upload CSVs to Data Lake raw/ folder
4. Run ADF pipeline to copy to clean/ folder
5. Run Synapse SQL scripts in order (01 → 03)
6. Connect Power BI to Synapse or load CSVs directly

## 📫 Connect
- **LinkedIn:** linkedin.com/in/thakare26
- **GitHub:** github.com/AkshayyThakare
- **Portfolio:** akshay-portfolio1.vercel.app
