{{
    config(
        materialized='incremental',
        unique_key='customer_id' 
    )
}}
WITH tmp AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        payment_method,
        amount
    FROM {{ ref('fct_finance_payments') }}
    WHERE order_status = 'completed'
)
SELECT
    tmp.customer_id,
    c.first_name,
    c.last_name,
    MIN(tmp.order_date) AS first_order_date,
    MAX(tmp.order_date) AS last_order_date,
    COUNT(DISTINCT tmp.order_id) AS total_orders,
    AVG(tmp.amount) AS avg_ticket
FROM tmp
INNER JOIN {{ ref('stg_customers') }} AS c
ON tmp.customer_id = c.customer_id
GROUP BY 1, 2, 3
--SCP Type 1