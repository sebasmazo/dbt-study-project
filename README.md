# dbt Study Project

A hands-on learning project for [dbt (data build tool)](https://docs.getdbt.com/docs/introduction) using **DuckDB** as the local database. Built around a simple e-commerce dataset to explore dbt's core concepts end-to-end.

> **Status:** Work in progress. Orchestration layer (Airflow or Dagster) to be added.

---

## Roadmap

- [x] Project scaffolding and configuration
- [x] Seed data (raw customers, orders, payments)
- [ ] Staging models
- [ ] Mart models (facts & dimensions)
- [ ] Data tests
- [ ] Macros
- [ ] Snapshots (SCD)
- [ ] Orchestration (Airflow or Dagster)

---

## Project Structure

```
dbt-study-project/
├── models/
│   └── staging/
│       └── staging_models.yml       # (in progress)
├── seeds/
│   ├── raw_customers.csv            # 100 customer records
│   ├── raw_orders.csv               # 99 orders (Jan–Apr 2018)
│   └── raw_payments.csv             # 113 payments (multi-method)
├── macros/                          # (planned)
├── tests/                           # (planned)
├── snapshots/                       # (planned)
├── analyses/                        # (planned)
├── dbt_project.yml
└── requirements.txt
```

---

## Source Data Model

Seeds provide a minimal e-commerce domain sourced from [dbt-labs/jaffle_shop_duckdb](https://github.com/dbt-labs/jaffle_shop_duckdb/tree/duckdb):

```
raw_customers (1) ──< raw_orders (1) ──< raw_payments
     id                  id                  id
     first_name          user_id             order_id
     last_name           order_date          payment_method
                         status              amount
```

**raw_orders statuses:** `placed`, `shipped`, `completed`, `return_pending`, `returned`
**raw_payments methods:** `credit_card`, `bank_transfer`, `coupon`, `gift_card`

---

## Planned Model Layers

```
seeds (raw_*)
  └── staging (stg_*)     ← standardize & clean
        └── marts
              ├── dim_customers
              └── fct_orders
```

---

## Setup

**Requirements:** Python 3.8+

```bash
pip install -r requirements.txt
```

### dbt Commands

```bash
dbt seed      # Load CSV files into DuckDB
dbt run       # Build all models
dbt test      # Run data quality tests
dbt build     # seed + run + test
```

The local database is stored in `dev.duckdb`.

---

## Key Concepts

| Concept | Description |
|---|---|
| **Materializations** | `table` vs `view` configured per-model or in `dbt_project.yml` |
| **`ref()`** | Links models into a DAG, ensuring correct build order |
| **Seeds** | Load static CSV data into the warehouse with `dbt seed` |
| **Schema tests** | `unique` and `not_null` declared in `.yml`, run with `dbt test` |
| **Staging layer** | Cleans and standardizes raw sources before transformation |
| **Macros** | Reusable Jinja2 SQL logic (planned) |
| **Snapshots** | Track slowly-changing dimensions over time (planned) |
| **Orchestration** | Schedule and monitor dbt runs via Airflow or Dagster (planned) |

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
