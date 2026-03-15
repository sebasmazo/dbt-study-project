{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}
SELECT
    id AS order_id,
    user_id AS customer_id,
    order_date,
    status AS order_status
FROM {{ source('jaffle_shop', 'raw_orders') }}
{%if is_incremental() %}
    WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}