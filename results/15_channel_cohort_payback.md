# 15_channel_cohort_payback

> Q: How fast does each channel's cohort accumulate revenue? A channel that
> reaches the same cumulative revenue later is a cash-flow problem even if
> its final LTV is fine.
> Technique: cumulative window inside a cohort x month-offset grid.

```sql
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
```

**63 row(s)** - showing first 25

| acquisition_channel   |   month_offset |   cum_revenue_per_customer |
|:----------------------|---------------:|---------------------------:|
| email                 |              0 |                     133.22 |
| email                 |              1 |                     158.18 |
| email                 |              2 |                     179.03 |
| email                 |              3 |                     188.08 |
| email                 |              4 |                     190.92 |
| email                 |              5 |                     196.31 |
| email                 |              6 |                     200.72 |
| email                 |              7 |                     202.59 |
| email                 |              8 |                     202.8  |
| email                 |              9 |                     203.81 |
| email                 |             10 |                     204.8  |
| email                 |             12 |                     204.84 |
| organic               |              0 |                     146.61 |
| organic               |              1 |                     183.38 |
| organic               |              2 |                     211.77 |
| organic               |              3 |                     228.79 |
| organic               |              4 |                     244.12 |
| organic               |              5 |                     255.26 |
| organic               |              6 |                     262.19 |
| organic               |              7 |                     267.26 |
| organic               |              8 |                     271.01 |
| organic               |              9 |                     275.31 |
| organic               |             10 |                     278.25 |
| organic               |             11 |                     278.62 |
| organic               |             12 |                     279.5  |
