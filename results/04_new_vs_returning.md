# 04_new_vs_returning

> Q: How much of each month's revenue comes from first-time vs returning buyers?
> Technique: first_value/min over customer partition to label each order.

```sql
-- Q: How much of each month's revenue comes from first-time vs returning buyers?
-- Technique: first_value/min over customer partition to label each order.
WITH labelled AS (
    SELECT o.order_id,
           o.customer_id,
           o.order_date,
           o.order_total,
           min(o.order_date) OVER (PARTITION BY o.customer_id) AS first_order_date
    FROM orders o
)
SELECT date_trunc('month', order_date) AS month,
       round(sum(CASE WHEN order_date = first_order_date THEN order_total ELSE 0 END), 2) AS new_customer_revenue,
       round(sum(CASE WHEN order_date > first_order_date THEN order_total ELSE 0 END), 2) AS returning_revenue,
       round(100.0 * sum(CASE WHEN order_date > first_order_date THEN order_total ELSE 0 END)
             / sum(order_total), 1) AS pct_returning
FROM labelled
GROUP BY 1
ORDER BY 1;
```

**24 row(s)**

| month               |   new_customer_revenue |   returning_revenue |   pct_returning |
|:--------------------|-----------------------:|--------------------:|----------------:|
| 2024-01-01 00:00:00 |                3453.51 |               17.34 |             0.5 |
| 2024-02-01 00:00:00 |                9219.32 |              636.5  |             6.5 |
| 2024-03-01 00:00:00 |                9698.37 |             1539.93 |            13.7 |
| 2024-04-01 00:00:00 |                8889.01 |             3134.11 |            26.1 |
| 2024-05-01 00:00:00 |               10713.4  |             5799.69 |            35.1 |
| 2024-06-01 00:00:00 |               11938.3  |             7896.75 |            39.8 |
| 2024-07-01 00:00:00 |               16570.7  |             7644.72 |            31.6 |
| 2024-08-01 00:00:00 |               15591    |             8552.93 |            35.4 |
| 2024-09-01 00:00:00 |               11200.8  |             5523.57 |            33   |
| 2024-10-01 00:00:00 |               17929    |             9974.5  |            35.7 |
| 2024-11-01 00:00:00 |               16692.7  |            14752.7  |            46.9 |
| 2024-12-01 00:00:00 |               17483.6  |            14823.2  |            45.9 |
| 2025-01-01 00:00:00 |               13264.4  |            13803.8  |            51   |
| 2025-02-01 00:00:00 |               15891.4  |            13470.7  |            45.9 |
| 2025-03-01 00:00:00 |               14763.5  |            12665.3  |            46.2 |
| 2025-04-01 00:00:00 |               15211.9  |            13545.8  |            47.1 |
| 2025-05-01 00:00:00 |               20206.4  |            13519.5  |            40.1 |
| 2025-06-01 00:00:00 |               18283.6  |            12473.6  |            40.6 |
| 2025-07-01 00:00:00 |               17909.7  |            15859.4  |            47   |
| 2025-08-01 00:00:00 |               19756.3  |            15001.1  |            43.2 |
| 2025-09-01 00:00:00 |               18066.1  |            13825.5  |            43.4 |
| 2025-10-01 00:00:00 |               15263.7  |            17855.7  |            53.9 |
| 2025-11-01 00:00:00 |               21387.3  |            17818.1  |            45.4 |
| 2025-12-01 00:00:00 |               25122.3  |            20266.4  |            44.7 |
