-- Q: Of the customers acquired in a given month, what share order again N months later?
-- Technique: classic cohort matrix - self-join on cohort month + month offset.
WITH first_order AS (
    SELECT customer_id,
           date_trunc('month', min(order_date)) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
activity AS (
    SELECT f.cohort_month,
           date_diff('month', f.cohort_month, date_trunc('month', o.order_date)) AS month_offset,
           o.customer_id
    FROM orders o
    JOIN first_order f USING (customer_id)
),
sized AS (
    SELECT cohort_month, count(*) AS cohort_size
    FROM first_order GROUP BY cohort_month
)
SELECT a.cohort_month,
       s.cohort_size,
       a.month_offset,
       count(DISTINCT a.customer_id)                                    AS active_customers,
       round(100.0 * count(DISTINCT a.customer_id) / s.cohort_size, 1)  AS retention_pct
FROM activity a
JOIN sized s USING (cohort_month)
WHERE a.month_offset BETWEEN 0 AND 6
GROUP BY a.cohort_month, s.cohort_size, a.month_offset
ORDER BY a.cohort_month, a.month_offset;
