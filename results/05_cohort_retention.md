# 05_cohort_retention

> Q: Of the customers acquired in a given month, what share order again N months later?
> Technique: classic cohort matrix - self-join on cohort month + month offset.

```sql
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
```

**146 row(s)** - showing first 25

| cohort_month        |   cohort_size |   month_offset |   active_customers |   retention_pct |
|:--------------------|--------------:|---------------:|-------------------:|----------------:|
| 2024-01-01 00:00:00 |            34 |              0 |                 34 |           100   |
| 2024-01-01 00:00:00 |            34 |              1 |                  5 |            14.7 |
| 2024-01-01 00:00:00 |            34 |              2 |                  7 |            20.6 |
| 2024-01-01 00:00:00 |            34 |              3 |                  2 |             5.9 |
| 2024-01-01 00:00:00 |            34 |              4 |                  2 |             5.9 |
| 2024-01-01 00:00:00 |            34 |              5 |                  3 |             8.8 |
| 2024-01-01 00:00:00 |            34 |              6 |                  1 |             2.9 |
| 2024-02-01 00:00:00 |            64 |              0 |                 64 |           100   |
| 2024-02-01 00:00:00 |            64 |              1 |                  9 |            14.1 |
| 2024-02-01 00:00:00 |            64 |              2 |                 11 |            17.2 |
| 2024-02-01 00:00:00 |            64 |              3 |                  6 |             9.4 |
| 2024-02-01 00:00:00 |            64 |              5 |                  1 |             1.6 |
| 2024-02-01 00:00:00 |            64 |              6 |                  2 |             3.1 |
| 2024-03-01 00:00:00 |            83 |              0 |                 83 |           100   |
| 2024-03-01 00:00:00 |            83 |              1 |                 10 |            12   |
| 2024-03-01 00:00:00 |            83 |              2 |                 10 |            12   |
| 2024-03-01 00:00:00 |            83 |              3 |                 13 |            15.7 |
| 2024-03-01 00:00:00 |            83 |              4 |                  2 |             2.4 |
| 2024-03-01 00:00:00 |            83 |              5 |                  4 |             4.8 |
| 2024-03-01 00:00:00 |            83 |              6 |                  1 |             1.2 |
| 2024-04-01 00:00:00 |            93 |              0 |                 93 |           100   |
| 2024-04-01 00:00:00 |            93 |              1 |                  9 |             9.7 |
| 2024-04-01 00:00:00 |            93 |              2 |                 15 |            16.1 |
| 2024-04-01 00:00:00 |            93 |              3 |                  9 |             9.7 |
| 2024-04-01 00:00:00 |            93 |              4 |                  8 |             8.6 |
