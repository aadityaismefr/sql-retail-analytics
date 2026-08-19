# 09_aov_moving_average

> Q: Is average order value drifting, once you strip out monthly noise?
> Technique: ROWS BETWEEN frame for a trailing 3-month moving average.

```sql
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
```

**24 row(s)**

| month               |   orders |    aov |   aov_3mo_ma |
|:--------------------|---------:|-------:|-------------:|
| 2024-01-01 00:00:00 |       35 |  99.17 |        99.17 |
| 2024-02-01 00:00:00 |       73 | 135.01 |       117.09 |
| 2024-03-01 00:00:00 |      102 | 110.18 |       114.79 |
| 2024-04-01 00:00:00 |      117 | 102.76 |       115.98 |
| 2024-05-01 00:00:00 |      117 | 141.14 |       118.03 |
| 2024-06-01 00:00:00 |      151 | 131.36 |       125.09 |
| 2024-07-01 00:00:00 |      166 | 145.88 |       139.46 |
| 2024-08-01 00:00:00 |      182 | 132.66 |       136.63 |
| 2024-09-01 00:00:00 |      145 | 115.34 |       131.29 |
| 2024-10-01 00:00:00 |      197 | 141.64 |       129.88 |
| 2024-11-01 00:00:00 |      202 | 155.67 |       137.55 |
| 2024-12-01 00:00:00 |      216 | 149.57 |       148.96 |
| 2025-01-01 00:00:00 |      208 | 130.14 |       145.13 |
| 2025-02-01 00:00:00 |      214 | 137.21 |       138.97 |
| 2025-03-01 00:00:00 |      215 | 127.58 |       131.64 |
| 2025-04-01 00:00:00 |      230 | 125.03 |       129.94 |
| 2025-05-01 00:00:00 |      242 | 139.36 |       130.66 |
| 2025-06-01 00:00:00 |      256 | 120.15 |       128.18 |
| 2025-07-01 00:00:00 |      269 | 125.54 |       128.35 |
| 2025-08-01 00:00:00 |      262 | 132.66 |       126.12 |
| 2025-09-01 00:00:00 |      272 | 117.25 |       125.15 |
| 2025-10-01 00:00:00 |      268 | 123.58 |       124.5  |
| 2025-11-01 00:00:00 |      277 | 141.54 |       127.46 |
| 2025-12-01 00:00:00 |      324 | 140.09 |       135.07 |
