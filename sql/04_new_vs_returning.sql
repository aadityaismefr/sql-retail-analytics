-- Q: How much of each month's revenue comes from first-time vs returning buyers?
-- Technique: first_value/min over customer partition to label each order.
WITH labelled AS (
    SELECT o.order_id,
           o.customer_id,
           o.order_date,
           o.order_total,
           min(o.order_date) OVER (PARTITION BY o.customer_id) AS first_order_date
    FROM orders o
)
SELECT date_trunc('month', order_date) AS month,
       round(sum(CASE WHEN order_date = first_order_date THEN order_total ELSE 0 END), 2) AS new_customer_revenue,
       round(sum(CASE WHEN order_date > first_order_date THEN order_total ELSE 0 END), 2) AS returning_revenue,
       round(100.0 * sum(CASE WHEN order_date > first_order_date THEN order_total ELSE 0 END)
             / sum(order_total), 1) AS pct_returning
FROM labelled
GROUP BY 1
ORDER BY 1;
