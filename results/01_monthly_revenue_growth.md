# 01_monthly_revenue_growth

> Q: How is revenue trending month over month, and where were the inflection points?
> Technique: date_trunc + LAG window function for MoM growth.

```sql
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
```

**24 row(s)**

| month               |   orders |   revenue |   mom_abs |   mom_pct |
|:--------------------|---------:|----------:|----------:|----------:|
| 2024-01-01 00:00:00 |       35 |   3470.85 |    nan    |     nan   |
| 2024-02-01 00:00:00 |       73 |   9855.82 |   6384.97 |     184   |
| 2024-03-01 00:00:00 |      102 |  11238.3  |   1382.48 |      14   |
| 2024-04-01 00:00:00 |      117 |  12023.1  |    784.82 |       7   |
| 2024-05-01 00:00:00 |      117 |  16513    |   4489.92 |      37.3 |
| 2024-06-01 00:00:00 |      151 |  19835.1  |   3322.04 |      20.1 |
| 2024-07-01 00:00:00 |      166 |  24215.4  |   4380.31 |      22.1 |
| 2024-08-01 00:00:00 |      182 |  24143.9  |    -71.48 |      -0.3 |
| 2024-09-01 00:00:00 |      145 |  16724.4  |  -7419.55 |     -30.7 |
| 2024-10-01 00:00:00 |      197 |  27903.5  |  11179.1  |      66.8 |
| 2024-11-01 00:00:00 |      202 |  31445.4  |   3541.91 |      12.7 |
| 2024-12-01 00:00:00 |      216 |  32306.8  |    861.33 |       2.7 |
| 2025-01-01 00:00:00 |      208 |  27068.2  |  -5238.5  |     -16.2 |
| 2025-02-01 00:00:00 |      214 |  29362.2  |   2293.91 |       8.5 |
| 2025-03-01 00:00:00 |      215 |  27428.9  |  -1933.29 |      -6.6 |
| 2025-04-01 00:00:00 |      230 |  28757.7  |   1328.82 |       4.8 |
| 2025-05-01 00:00:00 |      242 |  33726    |   4968.29 |      17.3 |
| 2025-06-01 00:00:00 |      256 |  30757.2  |  -2968.83 |      -8.8 |
| 2025-07-01 00:00:00 |      269 |  33769.1  |   3011.92 |       9.8 |
| 2025-08-01 00:00:00 |      262 |  34757.4  |    988.37 |       2.9 |
| 2025-09-01 00:00:00 |      272 |  31891.7  |  -2865.79 |      -8.2 |
| 2025-10-01 00:00:00 |      268 |  33119.4  |   1227.74 |       3.8 |
| 2025-11-01 00:00:00 |      277 |  39205.4  |   6086.03 |      18.4 |
| 2025-12-01 00:00:00 |      324 |  45388.7  |   6183.32 |      15.8 |
