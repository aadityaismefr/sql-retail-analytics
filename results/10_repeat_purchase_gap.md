# 10_repeat_purchase_gap

> Q: Of customers who buy twice, how long do they take? This sets the window
> for a "come back" campaign.
> Technique: LEAD to reach the next order per customer.

```sql
-- Q: Of customers who buy twice, how long do they take? This sets the window
--    for a "come back" campaign.
-- Technique: LEAD to reach the next order per customer.
WITH seq AS (
    SELECT customer_id,
           order_date,
           row_number() OVER (PARTITION BY customer_id ORDER BY order_date) AS n,
           lead(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date
    FROM orders
)
SELECT count(*)                                                     AS first_time_buyers,
       count(next_order_date)                                       AS bought_again,
       round(100.0 * count(next_order_date) / count(*), 1)          AS repeat_rate_pct,
       round(median(date_diff('day', order_date, next_order_date))) AS median_days_to_2nd,
       round(quantile_cont(date_diff('day', order_date, next_order_date), 0.25)) AS p25_days,
       round(quantile_cont(date_diff('day', order_date, next_order_date), 0.75)) AS p75_days
FROM seq
WHERE n = 1;
```

**1 row(s)**

|   first_time_buyers |   bought_again |   repeat_rate_pct |   median_days_to_2nd |   p25_days |   p75_days |
|--------------------:|---------------:|------------------:|---------------------:|-----------:|-----------:|
|                2773 |           1180 |              42.6 |                   42 |         26 |         68 |
