-- Q: How is revenue trending month over month, and where were the inflection points?
-- Technique: date_trunc + LAG window function for MoM growth.
WITH monthly AS (
    SELECT date_trunc('month', order_date)         AS month,
           count(*)                                AS orders,
           round(sum(order_total), 2)              AS revenue
    FROM orders
    GROUP BY 1
)
SELECT month,
       orders,
       revenue,
       round(revenue - lag(revenue) OVER (ORDER BY month), 2)              AS mom_abs,
       round(100.0 * (revenue / lag(revenue) OVER (ORDER BY month) - 1), 1) AS mom_pct
FROM monthly
ORDER BY month;
