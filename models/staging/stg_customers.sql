{{
    config(
        materialized='incremental',
        unique_key='customer_id'
    )
}}
SELECT
    id AS customer_id,
    first_name,
    last_name
FROM {{ source('jaffle_shop', 'raw_customers') }}
{%if is_incremental() %}
    WHERE id > (SELECT MAX(customer_id) FROM {{ this }})
{% endif %}