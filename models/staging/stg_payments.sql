{{
    config(
        materialized='incremental',
        unique_key='payment_id'
    )
}}
SELECT
    id AS payment_id,
    order_id,
    payment_method,
    amount
FROM {{ source('jaffle_shop', 'raw_payments') }}

{%if is_incremental() %}
    WHERE id > (SELECT MAX(id) FROM {{ this }})
{% endif %}
