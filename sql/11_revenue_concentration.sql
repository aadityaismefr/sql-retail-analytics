-- Q: How dependent are we on a handful of customers? (Pareto check)
-- Technique: cumulative SUM() OVER an ordered window.
WITH per_customer AS (
    SELECT customer_id, sum(order_total) AS revenue
    FROM orders GROUP BY customer_id
),
ranked AS (
    SELECT customer_id,
           revenue,
           row_number() OVER (ORDER BY revenue DESC)                       AS rn,
           sum(revenue) OVER (ORDER BY revenue DESC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_revenue,
           sum(revenue) OVER ()                                            AS total_revenue,
           count(*)     OVER ()                                            AS total_customers
    FROM per_customer
)
SELECT decile,
       count(*)                       AS customers,
       round(sum(revenue), 2)         AS revenue,
       round(100.0 * sum(revenue) / max(total_revenue), 1) AS pct_of_revenue
FROM (SELECT *, ntile(10) OVER (ORDER BY revenue DESC) AS decile FROM ranked)
GROUP BY decile
ORDER BY decile;
