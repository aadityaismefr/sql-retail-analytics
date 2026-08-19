-- Q: How fast does each channel's cohort accumulate revenue? A channel that
--    reaches the same cumulative revenue later is a cash-flow problem even if
--    its final LTV is fine.
-- Technique: cumulative window inside a cohort x month-offset grid.
WITH first_order AS (
    SELECT customer_id, min(order_date) AS first_order_date
    FROM orders GROUP BY customer_id
),
offsets AS (
    SELECT c.acquisition_channel,
           date_diff('month', f.first_order_date, o.order_date) AS month_offset,
           o.order_total
    FROM orders o
    JOIN first_order f USING (customer_id)
    JOIN customers  c USING (customer_id)
),
sizes AS (
    SELECT c.acquisition_channel, count(*) AS cohort_size
    FROM first_order f JOIN customers c USING (customer_id)
    GROUP BY 1
)
SELECT o.acquisition_channel,
       o.month_offset,
       round(sum(sum(o.order_total)) OVER (PARTITION BY o.acquisition_channel
                                           ORDER BY o.month_offset) / max(s.cohort_size), 2)
           AS cum_revenue_per_customer
FROM offsets o
JOIN sizes s USING (acquisition_channel)
WHERE o.month_offset BETWEEN 0 AND 12
GROUP BY o.acquisition_channel, o.month_offset
ORDER BY o.acquisition_channel, o.month_offset;
