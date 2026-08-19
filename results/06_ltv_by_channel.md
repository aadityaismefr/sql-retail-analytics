# 06_ltv_by_channel

> Q: Which acquisition channel produces the most valuable customers?
> This is the query that changes budget decisions: paid_social wins on volume
> and loses on value.

```sql
-- Q: Which acquisition channel produces the most valuable customers?
-- This is the query that changes budget decisions: paid_social wins on volume
-- and loses on value.
WITH per_customer AS (
    SELECT c.customer_id,
           c.acquisition_channel,
           count(o.order_id)          AS orders,
           sum(o.order_total)         AS lifetime_revenue
    FROM customers c
    LEFT JOIN orders o USING (customer_id)
    GROUP BY 1, 2
)
SELECT acquisition_channel,
       count(*)                                                    AS customers,
       round(100.0 * count(*) FILTER (WHERE orders > 0) / count(*), 1) AS pct_ever_ordered,
       round(avg(orders), 2)                                       AS avg_orders,
       round(avg(lifetime_revenue), 2)                             AS avg_ltv,
       round(median(lifetime_revenue), 2)                          AS median_ltv,
       round(sum(lifetime_revenue), 2)                             AS total_revenue
FROM per_customer
GROUP BY acquisition_channel
ORDER BY avg_ltv DESC NULLS LAST;
```

**5 row(s)**

| acquisition_channel   |   customers |   pct_ever_ordered |   avg_orders |   avg_ltv |   median_ltv |   total_revenue |
|:----------------------|------------:|-------------------:|-------------:|----------:|-------------:|----------------:|
| organic               |        1270 |               58.3 |         1.15 |    281.68 |       190.77 |        208441   |
| referral              |         826 |               62.2 |         1.23 |    280.72 |       201.06 |        144289   |
| email                 |         494 |               51.6 |         0.88 |    204.97 |       147    |         52266.9 |
| paid_search           |        1438 |               43.2 |         0.63 |    188.8  |       126.72 |        117245   |
| paid_social           |        1972 |               32.6 |         0.47 |    159.67 |       110.57 |        102666   |
