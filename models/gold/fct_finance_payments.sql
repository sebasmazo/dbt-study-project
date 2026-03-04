SELECT  
    o.order_id,
    o.customer_id,
    p.payment_id,
    o.order_date,
    o.order_status,
    p.payment_method,
    p.amount
FROM {{ ref('stg_orders') }} AS o
INNER JOIN {{ ref('stg_payments') }} AS p
ON o.order_id = p.order_id
