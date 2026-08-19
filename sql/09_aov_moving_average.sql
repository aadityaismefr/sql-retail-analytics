-- Q: Is average order value drifting, once you strip out monthly noise?
-- Technique: ROWS BETWEEN frame for a trailing 3-month moving average.
WITH monthly AS (
    SELECT date_trunc('month', order_date) AS month,
           round(avg(order_total), 2)      AS aov,
           count(*)                        AS orders
    FROM orders
    GROUP BY 1
)
SELECT month,
       orders,
       aov,
       round(avg(aov) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS aov_3mo_ma
FROM monthly
ORDER BY month;
