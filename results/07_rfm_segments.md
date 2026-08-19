# 07_rfm_segments

> Q: Who should marketing actually email? Segment customers by
> Recency / Frequency / Monetary value.
> Technique: NTILE(5) to score each dimension, then a CASE to name segments.

```sql
-- Q: Who should marketing actually email? Segment customers by
--    Recency / Frequency / Monetary value.
-- Technique: NTILE(5) to score each dimension, then a CASE to name segments.
WITH base AS (
    SELECT customer_id,
           date_diff('day', max(order_date), DATE '2025-12-31') AS recency_days,
           count(*)                                             AS frequency,
           sum(order_total)                                     AS monetary
    FROM orders
    GROUP BY customer_id
),
scored AS (
    SELECT *,
           ntile(5) OVER (ORDER BY recency_days DESC) AS r_score,  -- 5 = most recent
           ntile(5) OVER (ORDER BY frequency)         AS f_score,
           ntile(5) OVER (ORDER BY monetary)          AS m_score
    FROM base
)
SELECT CASE
           WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
           WHEN r_score >= 4 AND f_score <= 2 THEN 'New / promising'
           WHEN r_score <= 2 AND f_score >= 4 THEN 'At risk - was valuable'
           WHEN r_score <= 2 AND f_score <= 2 THEN 'Lapsed'
           ELSE 'Steady'
       END                                   AS segment,
       count(*)                              AS customers,
       round(avg(recency_days))              AS avg_days_since_order,
       round(avg(frequency), 2)              AS avg_orders,
       round(avg(monetary), 2)               AS avg_revenue,
       round(sum(monetary), 2)               AS segment_revenue
FROM scored
GROUP BY segment
ORDER BY segment_revenue DESC;
```

**5 row(s)**

| segment                |   customers |   avg_days_since_order |   avg_orders |   avg_revenue |   segment_revenue |
|:-----------------------|------------:|-----------------------:|-------------:|--------------:|------------------:|
| Champions              |         469 |                     84 |         2.84 |        373.41 |          175131   |
| Steady                 |         816 |                    257 |         1.6  |        202.69 |          165399   |
| At risk - was valuable |         406 |                    452 |         2.51 |        351.01 |          142511   |
| New / promising        |         565 |                     78 |         1    |        132.92 |           75099.9 |
| Lapsed                 |         517 |                    561 |         1    |        129.14 |           66766.4 |
