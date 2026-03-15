# dbt Study Project

A hands-on learning project for [dbt (data build tool)](https://docs.getdbt.com/docs/introduction) using **DuckDB** as the local database. Built around a simple e-commerce dataset to explore dbt's core concepts end-to-end.

> **Status:** Work in progress. Orchestration layer (Airflow or Dagster) to be added.

---

## Roadmap

- [x] Project scaffolding and configuration
- [x] Seed data (raw customers, orders, payments)
- [x] Staging models
- [x] Gold models (facts & dimensions)
- [x] Data tests (built-in: unique, not_null, relationships, accepted_values)
- [ ] Incremental Load and Snapshots (SCD)
- [ ] Macros
- [ ] Orchestration (Airflow or Dagster)

---

## Project Structure

```
dbt-study-project/
├── models/
│   ├── staging/
│   │   ├── _sources.yml              # Source declarations (jaffle_shop)
│   │   ├── staging_models.yml        # Docs & tests for staging models
│   │   ├── stg_customers.sql         # Cleaned customers
│   │   ├── stg_orders.sql            # Cleaned orders (cast dates, std status)
│   │   └── stg_payments.sql          # Cleaned payments
│   └── gold/
│       ├── gold_models.yml           # Docs & tests for gold models
│       ├── fct_finance_payments.sql  # Fact: one row per payment
│       └── dim_customers.sql         # Dimension: one row per customer + metrics
├── seeds/
│   ├── _seeds.yml                    # Docs for seed tables
│   ├── raw_customers.csv             # 100 customer records
│   ├── raw_orders.csv                # 99 orders (Jan–Apr 2018)
│   └── raw_payments.csv              # 113 payments (multi-method)
├── macros/                           # (planned)
├── tests/                            # (planned)
├── snapshots/                        # (planned)
├── analyses/                         # (planned)
├── dbt_project.yml
└── requirements.txt
```

---

## Data Lineage

```
seeds/raw_*  ──►  jaffle_shop.raw_*  (sources)
                        │
              ┌─────────┼─────────┐
              ▼         ▼         ▼
        stg_customers  stg_orders  stg_payments   (staging / views)
                            │
                  ┌─────────┴──────────┐
                  ▼                    │
        fct_finance_payments           │            (gold / tables)
                  │                    │
                  └──────────┬─────────┘
                             ▼
                       dim_customers                (gold / tables)
```

---

## Model Layers

### Staging (`models/staging/` — materialized as views)
One model per source table. Renames columns, casts types, standardizes values. No joins, no business logic.

| Model | Source | Purpose |
|---|---|---|
| `stg_customers` | `raw_customers` | Rename `id` → `customer_id` |
| `stg_orders` | `raw_orders` | Cast dates, standardize status |
| `stg_payments` | `raw_payments` | Rename `id` → `payment_id` |

### Gold (`models/gold/` — materialized as tables)
Business-oriented tables consumed by analysts and BI tools.

| Model | Type | Description |
|---|---|---|
| `fct_finance_payments` | Fact | One row per payment, joined with order info |
| `dim_customers` | Dimension | One row per customer with order history metrics |

`dim_customers` aggregates only `completed` orders to compute `total_orders`, `avg_ticket`, `first_order_date`, and `last_order_date`.

---

## Source Data

Seeds provide a minimal e-commerce domain sourced from [dbt-labs/jaffle_shop_duckdb](https://github.com/dbt-labs/jaffle_shop_duckdb/tree/duckdb):

```
raw_customers (1) ──< raw_orders (1) ──< raw_payments
     id                  id                  id
     first_name          user_id             order_id
     last_name           order_date          payment_method
                         status              amount
```

**Order statuses:** `placed`, `shipped`, `completed`, `return_pending`, `returned`
**Payment methods:** `credit_card`, `bank_transfer`, `coupon`, `gift_card`

---

## Setup

**Requirements:** Python 3.8+

```bash
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

### dbt Commands

```bash
dbt seed      # Load CSV files into DuckDB
dbt run       # Build all models
dbt test      # Run data quality tests
dbt build     # seed + run + test
dbt docs generate && dbt docs serve  # View lineage DAG
```

The local database is stored in `dev.duckdb`.

---

## Key Concepts

| Concept | Description |
|---|---|
| **Materializations** | `table` vs `view` configured per-layer in `dbt_project.yml` |
| **`ref()`** | Links models into a DAG, ensuring correct build order |
| **`source()`** | Declares external/seed tables; separates ingestion from transformation |
| **Seeds** | Load static CSV data into the warehouse with `dbt seed` |
| **Schema tests** | `unique`, `not_null`, `relationships`, `accepted_values` with `severity: error/warn` |
| **Staging layer** | Cleans and standardizes raw sources, one model per source table |
| **Gold layer** | Wide, business-oriented facts and dimensions ready for consumption |
| **Macros** | Reusable Jinja2 SQL logic (planned) |
| **Snapshots** | Track slowly-changing dimensions over time (planned) |
| **Orchestration** | Schedule and monitor dbt runs via Airflow or Dagster (planned) |

---

## Design Decisions

### Seeds + `source()` coexistence

Seeds simulate raw ingestion in this project. Staging models reference them via `source()` rather than `ref()` to practice the production pattern — in a real pipeline, an ingestion tool (Fivetran, Airbyte) would populate these tables and seeds wouldn't exist.

This causes a visual gap in the dbt DAG: seed nodes and source nodes appear as separate entries even though they resolve to the same table in DuckDB. This is an expected limitation of mixing both concepts in a learning environment and is intentional.

When the orchestration layer is added, seeds will be replaced by real ingestion and the DAG will be fully connected.

### Gold layer naming

The output layer is named `gold/` following the Medallion architecture convention (Bronze → Silver → Gold) rather than the dbt-native `marts/` convention. Both are equivalent; `gold/` was chosen to reinforce the connection to Data Lake architecture patterns.

---

## Attribution

Seed data and base dependencies derived from [dbt-labs/jaffle_shop_duckdb](https://github.com/dbt-labs/jaffle_shop_duckdb/tree/duckdb), copyright dbt Labs, licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). Files used as-is for learning purposes.

---

## Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt-duckdb Adapter](https://github.com/duckdb/dbt-duckdb)
- [DuckDB Documentation](https://duckdb.org/docs/)
- [Apache Airflow](https://airflow.apache.org/docs/)
- [Dagster](https://docs.dagster.io/)
- [dbt Community Slack](https://community.getdbt.com/)
